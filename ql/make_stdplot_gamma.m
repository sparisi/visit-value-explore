close all
clear all

id = 12;
figure(id)

set(0,'defaultaxeslinestyleorder',{'-', '-*', ':' ,'o'})

%%
variable = 'J_history';
% variable = 'VC_history';

env = 'GridworldSparseSimple';
env = 'GridworldSparseSmall';
% env = 'DeepGridworld';
% env = 'Taxi';
% env = 'DeepSea';
% env = 'GridworldSparseWall';

filenames = {};
for gamma_vv = [0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 0.99]
    %     filenames{end+1} = ['vv_ucb_' num2str(gamma_vv*100)];
    filenames{end+1} = ['vv_n_' num2str(gamma_vv*100)];
end
filenames{end+1} = 'count';
colors = {};

markers = {};
linestyle = {};
legendnames = {};


%%
optimistic = 0;
long_horizon = 0;

setting_str = env;
if optimistic, setting_str = [setting_str '_OPT']; end
if long_horizon, setting_str = [setting_str '_LONG']; end
folder_data = ['ql/res/' setting_str '/'];

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
        tmp = plot(mean(dataMatrix,1), lineprops{:});
        h{end+1} = tmp;
        
    end
end

title(setting_str, 'Interpreter', 'none')

leg = legend([h{:}], legendnames, 'Interpreter', 'none');
leg.Position = [0.9 0.4 0 0];
