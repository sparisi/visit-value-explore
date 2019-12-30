close all
clear all
figure()
h = {};
plot_every = 1; % plots data with the following indices [1, 5, 10, ..., end]

%% Change entries according to your needs
env = 'GridworldSparseSimple';
env = 'GridworldSparseSmall';
% env = 'GridworldSparseVerySmall';
% env = 'Taxi';
% env = 'DeepSea50';

variable = 'J_history';
% variable = 'VC_history';

%%
folder = ['ql/res/' env];
separator = '_';
filenames = {'vv_n_classic', 'vv_ucb_classic', 'egreedy_classic', 'brlsvi_finite' 'vv_n', 'vv_ucb', 'brlsvi', 'egreedy'};

if isempty(filenames) % automatically identify algorithms name
    allfiles = dir(fullfile(folder,'*.mat'));
    for i = 1 : length(allfiles)
        tmpname = allfiles(i).name(1:end-4); % remove .mat from string
        trial_idx = strfind(tmpname, separator); % find separator
        tmpname = tmpname(1:trial_idx(end)-1); % remove trial idx from string
        if (isempty(filenames) || ~strcmp(filenames{end}, tmpname) ) && ~any(strcmp(filenames, tmpname)) % if new name, add it
            filenames{end+1} = tmpname;
        end
    end
end

legendnames = {};
if isempty(legendnames), legendnames = filenames; end
colors = {};
markers = {};

title(variable, 'Interpreter', 'none')

%% Plot
name_idx = 1;
name_valid = [];
for name = filenames
    counter = 1;
    dataMatrix = [];
    for trial = 1 : 20
        try
            load([folder '/' name{:} separator num2str(trial) '.mat'], variable)
            tmp = eval(variable);
            if counter == 1
                dataMatrix(counter,:) = tmp;
            else
                len = min(size(dataMatrix,2), length(tmp));
                dataMatrix = dataMatrix(:,1:len);
                dataMatrix(counter,:) = tmp(1:len);
            end
            counter = counter + 1;
        catch
        end
    end

    if ~isempty(dataMatrix)
        hold all
        lineprops = { 'LineWidth', 3, 'DisplayName', name{:} };
        if ~isempty(colors)
            lineprops = {lineprops{:}, 'Color', colors{name_idx} };
        end
        if ~isempty(markers)
            lineprops = {lineprops{:}, 'Marker', markers{name_idx} };
        end
        
        x = [1, plot_every : plot_every : size(dataMatrix,2)];
        dataMatrix = dataMatrix(:,x);
        tmp = shadedErrorBar( ...
            x, ...
            mean(dataMatrix,1), ...
            1.96*std(dataMatrix,[],1)/sqrt(size(dataMatrix,1)), ...
            lineprops, ...
            0.1, 0 );
        h{end+1} = tmp.mainLine;
        name_valid(end+1) = name_idx;
    else
        disp([name{:} ' is empty!'])
    end
    name_idx = name_idx + 1;

end

legend([h{:}], {legendnames{name_valid}}, 'Interpreter', 'none')

leg.Position = [0.2 0.7 0 0];
