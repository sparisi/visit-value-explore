classdef GridworldSparseSimple < GridworldEnv
% Just a 5x5 with some peculiarities with one reward, located on the
% opposite corner wrt the agent initial position.
    
    %% Properties
    properties
        % Environment variables
        reward = zeros(5,5);
        isopen = ones(5,5);
        
        % Finite states and actions
        allstates = allcomb(1:5, 1:5);

        % Bounds
        stateLB = [1 1]';
        stateUB = [5 5]';
        rewardLB = 0;
        rewardUB = 1;
    end
    
    methods
        
        %% Constructor
        function obj = GridworldSparseSimple()
            obj.reward(5,5) = 1;
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
            
            if obj.realtimeplot, obj.updateplot(state), end
        end
    end
    
end