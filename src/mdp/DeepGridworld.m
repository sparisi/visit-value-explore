classdef DeepGridworld < GridworldEnv
% 5x11 with a corridor accessible only from its left entrance.
% At the end of the corridor lies a treasure of value 2, while two 
% treasures of vaue 1 are placed next to the corridor entrance. 
% The corridor is filled with puddles, each giving a penalty of -0.01.
% The initial position is fixed next to the corridor entrance, and the 
% episode ends when any of the treasure is collected. 
    
    %% Properties
    properties
        % Environment variables
        reward = [ 0 0 0 0 0 0 0 0 0 0 0
                   0 1 0 0 0 0 0 0 0 0 0
                   0 -0.01 -0.01 -0.01 -0.01 -0.01 -0.01 -0.01 -0.01 -0.01 2
                   0 1 0 0 0 0 0 0 0 0 0
                   0 0 0 0 0 0 0 0 0 0 0];
                  
        isopen = ones(5,11);
        
        % Finite states and actions
        allstates = allcomb(1:5, 1:11);

        % Bounds
        stateLB = [1 1]';
        stateUB = [5 11]';
        rewardLB = -0.01;
        rewardUB = 2;
    end
    
    methods
        
        %% Simulator
        function state = init(obj, n)
            if nargin == 1, n = 1; end
            state = repmat([3;1], 1, n);
        end
        
        %% Simulator
        function [nextstate, reward, absorb] = simulator(obj, state, action)
            r = rand(1,size(state,2));
            wrong = r >= obj.probT(1) & r < (obj.probT(1) + obj.probT(2));
            stay = r >= (obj.probT(1) + obj.probT(2));
            action(wrong) = randi(obj.actionUB,1,sum(wrong));
            
            % The agent tries to enter the corrider from above or below
            attempt_from_above = (state(1,:) == 2) & (state(2,:) > 1) & (action == 4);
            attempt_from_below = (state(1,:) == 4) & (state(2,:) > 1) & (action == 3);
            stay = stay | attempt_from_above | attempt_from_below;

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
            absorb = (reward == -10) | (reward > 0);
            
            if obj.realtimeplot, obj.updateplot(state), end
        end
    end
    
end