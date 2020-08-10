close all
clear all

id = 12;
figure(id)

%%
variable = 'J_history';
env = 'DeepSea';

filenames = {'vv_n'};
colors = {};
markers = {};
linestyle = {};
legendnames = {};


%%
nMatrix = [];
sizes = 5 : 2 : 57;

for deep_depth = sizes
    setting_str = [env num2str(deep_depth)];
    folder_data = ['ql/res/' setting_str '/'];
    
    separator = '_';
        
    %% Plot
    for name = filenames
        dataMatrix = [];
        for trial = 1 : 10
            load([folder_data name{:} separator num2str(trial) '.mat'])
            x = find(eval(variable) > 0.2);
            dataMatrix(end+1) = x(1);
        end
        nMatrix(end+1) = mean(dataMatrix);
    end
        
end

if ~isempty(nMatrix)
    hold all
    figure(id)
    tmp = plot(sizes, nMatrix*50);
    plot(sizes, sizes.^(2.5))
    plot(sizes, sizes.^(2.7))
end

legend({'count', '2.5', '2.7'})