switch data_type
    case 1
        s = [1 1 2 2 3, 1 1 2 5 5, 1 4 1 4 5, 1 4 5 5 5]';
        a = [1 4 1 4 4, 3 4 2 2 2, 2 1 2 4 4, 2 4 1 3 2]';
        sn = [1 2 2 3 3, 1 2 5 5 5, 4 1 4 5 5, 4 5 5 5 5]';
        D = [0 0 0 0 1, 0 0 0 0 0, 0 0 0 0 0, 0 0 0 0 0];
        R = [0 0 0 0 1, 0 0 0 0 0, 0 0 0 0 0, 0 0 0 0 0];
    case 2
        S = repmat(allstates', 1, length(allactions));
        A = repmat(allactions, 1, size(allstates,1));
        [SN, R, D] = mdp.simulator(S,A);
        [~, s] = ismember(S',allstates,'rows');
        [~, sn] = ismember(SN',allstates,'rows');
        [~, a] = ismember(A',allactions);
end

sa = sub2ind(size(VCA),s,a);
