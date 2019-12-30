classdef GridworldSparseVerySmall < GridworldEnv
% Just a 3x3 with some peculiarities:
% - (2,2) is a trap: if the agent goes there, it won't be able to move
%                    anywhere else
% - there is one distractor reward
    
    %% Properties
    properties
        % Environment variables
        reward = zeros(3,3);
        isopen = ones(3,3);
        
        % Finite states and actions
        allstates = allcomb(1:3, 1:3);

        % Bounds
        stateLB = [1 1]';
        stateUB = [3 3]';
        rewardLB
        rewardUB
    end
    
    methods
        
        %% Constructor
        function obj = GridworldSparseVerySmall()
            obj.reward(3,3) = 2;
            obj.reward(3,1) = 1;
            obj.rewardLB = min(obj.reward(:));
            obj.rewardUB = max(obj.reward(:));
        end
        
        %% Simulator
        function state = init(obj, n)
            if nargin == 1, n = 1; end
            state = 1 * ones(2,n);
%             state = [randi(obj.stateUB(1),1,n); randi(obj.stateUB(2),1,n)];
        end
        
        %% Simulator
        function [nextstate, reward, absorb] = simulator(obj, state, action)
            r = rand(1,size(state,2));
            wrong = r >= obj.probT(1) & r < (obj.probT(1) + obj.probT(2));
            stay = r >= (obj.probT(1) + obj.probT(2));
            stay = stay | ...
                ( (state(1,:) == 2 & state(2,:) == 2) & rand(size(r) > 1e-8) ); % (4,4) is a trap
            action(wrong) = randi(obj.actionUB,1,sum(wrong));
            
            nextstate = state + obj.allactions(:,action);
            nextstate(:,stay) = state(:,stay);
            
            % Bound the state
            nextstate = bsxfun(@max, bsxfun(@min,nextstate,obj.stateUB), obj.stateLB);
            
            % Check if the cell is not black
            isopen = obj.isopen(size(obj.isopen,1)*(nextstate(2,:)-1) + nextstate(1,:));
            nextstate(:,~isopen) = state(:,~isopen);
            
            % Reward function
            reward = obj.reward(size(obj.reward,1)*(state(2,:)-1) + state(1,:));

            % Any reward or penalty cell is terminal
            absorb = reward~=0;
            
%             % Add a small constant penalty
%             reward = reward - 0.01;
            
            if obj.realtimeplot, obj.updateplot(state), end
        end
    end
    
    %% Plotting
    methods(Hidden = true)
        function initplot(obj)
            initplot@GridworldEnv(obj)
            text('position', [4 2], ...
                'fontsize', 12, ...
                'string', ':(', ...
                'color', 'red', ...
                'horizontalalignment', 'center')
            uistack(obj.handleAgent,'top');
        end
    end
end