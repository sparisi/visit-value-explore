classdef Chain < MDP
    % Chain with N states.
    % Very small reward for "stay" in init state (fixed), and 1 for "stay"
    % in the last state.
    % Random transition to make it ergodic.
    
    %% Properties
    properties
        n
        r
        p = 0.01;
        allstates
        allactions
        
        dstate = 1;
        daction = 1;
        dreward = 1;
        isAveraged = 0;
        gamma = 0.99;
        
        % Upper/lower bounds
        stateUB
        stateLB = 1;
        rewardLB = 0;
        rewardUB
        actionLB = 1;
        actionUB
    end
    
    methods
        
        %% Constructor
        function obj = Chain(n)
            if nargin == 0, n = 100; end
            obj.n = n;
            obj.stateUB = n;
            obj.actionUB = 3;
            obj.allstates = [1 : obj.n]';
            obj.allactions = 1 : obj.actionUB;
            
            obj.r = zeros(obj.n, obj.actionUB);
            obj.r(1,3) = 1e-8; % action 3 is "stay"
            obj.r(end,3) = 1;
            obj.rewardUB = max(obj.r(:));
        end
        
        %% Simulator
        function state = init(obj, n)
            if nargin == 1, n = 1; end
            state = ones(1,n);
        end
        
        function [nextstate, reward, absorb] = simulator(obj, state, action)
            r = rand();
            switch action
                case 1 % go forward
                    if r > obj.p
                        nextstate = min(state + 1, obj.n);
                    else
                        nextstate = max(state - 1, 1);
                    end
                case 2 % go backward
                    if r > obj.p
                        nextstate = max(state - 1, 1);
                    else
                        nextstate = min(state + 1, obj.n);
                    end
                otherwise % stay
                    if r > obj.p
                        nextstate = state;
                    elseif r < obj.p / 2
                        nextstate = max(state - 1, 1);
                    else
                        nextstate = min(state + 1, obj.n);
                    end
            end
            
            reward = obj.r(state,action);
            absorb = false;
        end
        
    end
    
    %% Plotting
    methods(Hidden = true)
        
        function initplot(obj)
        end
        
        function updateplot(obj, state)
        end
        
    end
    
end