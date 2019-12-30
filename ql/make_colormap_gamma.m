clear all

for list_alg = ["vv_ucb", "vv_n"]
for gamma_vv = [0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 0.99, 0.99999]
for list_name = ["GridworldSparseSimple"]
seed = 7;

mdp_name = char(list_name);
alg = [char(list_alg) '_' num2str(gamma_vv*100)];

common_settings_ql

if strcmp(mdp_name,'DeepSea')
    mdp_name = 'DeepSea50';
end

load(['ql\res\' mdp_name '\' alg '_' num2str(seed) '.mat'])

close all

if strcmp(mdp_name, 'DeepSea50')
    subimagesc('Visit count',X,Y,[VC(1:2:end)' + VC(2:2:end)'])
    f = gcf();
    ax = f.Children;
    camroll(ax,-90)
elseif strcmp(mdp_name, 'DeepGridworld')
    subimagesc('Visit count',X,Y,VC')
    f = gcf();
    ax = f.Children;
    camroll(ax,-90)
elseif strcmp(mdp_name, 'Taxi')
    subimagesc('Visit count',X,Y,[VC(1:8:end)'; 
        VC(2:8:end)';
        VC(3:8:end)';
        VC(4:8:end)';
        VC(5:8:end)';
        VC(6:8:end)';
        VC(7:8:end)';
        VC(8:8:end)'],1)
    f = gcf();
    ax = f.Children(2:2:end);
    for i = 1 : length(ax)
        camroll(ax(i),-90)
    end
else
    subimagesc('Visit count',X,Y,VC')
end

f = gcf();
ax = f.Children;
for i = 1 : length(ax)
    ax(i).set('xtick',[])
    ax(i).set('ytick',[])
end

% h = colorbar;
% set(h, 'ylim', [0 max(z)])

if any(VC==0)
cmap = parula(max(VC));
tmp = unique(VC);
cmap(1:tmp(2),:) = 0;
colormap(cmap)
end

filename = [mdp_name '_count_' alg '.png'];
export_fig(filename)

end
end
end