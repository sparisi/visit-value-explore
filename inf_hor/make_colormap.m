clear all
close all

N = 27;
list_name = ['Chain' num2str(N)];
seed = 2;

y_steps = [1, 5, 50, 200, 500, 2000];
y_steps = [1, 2, 3, 4, 5, 10, 25, 50, 100, 150, 200, 500, 2000];
y_steps_str = cellfun(@num2str,num2cell(y_steps*100),'UniformOutput',false);

j = 0;
all_algs = ["vv_ucb", "vv_n", "boot_thom", "ucb1", "bonus", "egreedy"];
for list_alg = all_algs
    j = j + 1;
    
    mdp_name = char(list_name);
    alg = char(list_alg);
    
    load(['ql\res\' mdp_name '\' alg '_' num2str(seed) '.mat'])
    k = 0;
    for i = y_steps
        k = k + 1;
        ALL(j,k,:) = VC_history(:,i);
    end
end

%%
        
ALL2 = ALL;
ALL = log(ALL+1);

cmap = gray(ceil(max(ALL(:))));
cmap = parula(ceil(max(ALL(:))));
% cmap(:,1:2) = cmap(:,1:2) * 0.;

for i = 1 : size(ALL,1)
    
Z = squeeze(ALL(i,:,:));

% input definition
X = repmat(1:size(Z,2), 1, size(Z,1));
Y = kron(1:size(Z,1),ones(1,size(Z,2)));
C = reshape(Z',1,[]);
S = 620; % size of marker (handle spaces between patches)

figure('Color', 'w');  
scatter(X, Y, S, C, 'fill', 's'); 

ax = gca();

pause(0.1)

ax.XRuler.Axle.LineStyle = 'none';  
ax.YRuler.Axle.LineStyle = 'none';

set(ax, 'XLim', [0 size(Z,2)+1], 'YLim', [0 size(Z,1)+1]);  
set(ax, 'YDir','reverse'); 

ax.set('ytick',1:length(y_steps))
ax.set('xtick',1:N)

ylim([1,length(y_steps)+0.5])
xlim([0,N])

yticklabels(y_steps_str)

colormap(cmap(1:ceil(max(max(max(ALL(i,:,:))))),:))

% if i == size(ALL,1)
%     hFig_cb = colorbar();
%     tickLabelsToUse = hFig_cb.TickLabels;
%     tickLabelsMod = cellfun(@(c) sprintf('%.0e',exp(str2double(c))-1) , tickLabelsToUse, 'uni', 0);
%     hFig_cb.TickLabels = [];
%     hFig_cb.TickLabels = tickLabelsMod;
%     set(hFig_cb, 'ylim', [0 max(ALL(:))])
% end

drawnow limitrate

pause(0.1)

% keyboard
filename = [mdp_name '_count_' char(all_algs(i)) '.png'];
export_fig(filename)

end