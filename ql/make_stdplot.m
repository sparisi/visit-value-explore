close all
clear all

id = 12;
figure(id)

%%
variable = 'J_history';
% variable = 'VC_history';

env = 'GridworldSparseSimple';
env = 'GridworldSparseSmall';
env = 'DeepGridworld';
% env = 'Taxi';
env = 'DeepSea50';
% env = 'GridworldSparseWall';

filenames = {'vv_n', 'vv_ucb', 'boot', 'boot_thom', 'brlsvi', 'ucb1', 'bonus', 'egreedy', 'random'};
colors = {};
markers = {};
linestyle = {};
legendnames = {};


%%
plotidx = 0;
for optimistic = [0, 1]
    for long_horizon = [0, 1]

        setting_str = env;
        if optimistic, setting_str = [setting_str '_OPT']; end
        if long_horizon, setting_str = [setting_str '_LONG']; end
        plotidx = plotidx + 1;
        folder_data = ['ql/res/' setting_str '/'];
        subplot(3,2,plotidx)
        
        separator = '_';
        
        if isempty(filenames) % automatically identify algorithms name
            allfiles = dir(fullfile(folder_data,'*.mat'));
            for i = 1 : length(allfiles)
                tmpname = allfiles(i).name(1:end-4); % remove .mat from string
                trial_idx = strfind(tmpname, separator); % find separator
                tmpname = tmpname(1:trial_idx(end)-1); % remove trial idx from string
                if (isempty(filenames) || ~strcmp(filenames{end}, tmpname) ) && ~any(strcmp(filenames, tmpname)) % if new name, add it
                    filenames{end+1} = tmpname;
                end
            end
        end
        
        %% Plot
        h = {};
        h_count = 0;
        for name = filenames
            
            h_count = h_count + 1;
            
            counter = 1;
            dataMatrix = [];
            for trial = 1 : 20
                try
                    load([folder_data name{:} separator num2str(trial) '.mat'])
                    l = min(length(eval(variable)), size(dataMatrix,2));
                    dataMatrix = dataMatrix(:,1:l);
                    dataMatrix(counter,:) = eval(variable);
                    counter = counter + 1;
                catch err
%                     err.message
                end
            end
            
            if ~isempty(dataMatrix)
                hold all
                lineprops = { 'LineWidth', 1, 'DisplayName', name{:} };
                if ~isempty(colors)
                    lineprops = {lineprops{:}, 'Color', colors{h_count} };
                end
                if ~isempty(markers)
                    lineprops = {lineprops{:}, 'Marker', markers{h_count} };
                end
                if ~isempty(linestyle)
                    lineprops = {lineprops{:}, 'LineStyle', linestyle{h_count} };
                end
                
                figure(id)
                
                %% Use this to plot only the mean
%                 tmp = semilogy(mean(dataMatrix,1), lineprops{:});
                tmp = plot(mean(dataMatrix,1), lineprops{:});
                h{end+1} = tmp;
                
            end
        end
        
        title(setting_str, 'Interpreter', 'none')
%         ylim([-0.1, 1])
        
        if plotidx == 1, hLeg = h; end
        
    end
end

hL = subplot(3,2,5.5);
poshL = get(hL,'position');
lgd = legend([hLeg{:}], legendnames, 'Interpreter', 'none');
set(lgd,'position',poshL);
axis(hL,'off');
% leg.Position = [0.2 0.7 0 0];
