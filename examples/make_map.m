function make_map(A, name, range)

fig('name', name), hold all

span = 100;
n = sqrt(size(A,1));

[Y, X] = ndgrid(1:n*span,1:n*span);
Jf = n*span + 1 - Y;
idx_up = (Y<=X & X<=Jf);
idx_right = (Y<X & X>Jf);
idx_down = (Y>=X & X>=Jf);
idx_left = (Y>X & X<Jf);

Z = nan(n*span);

count = 0;
for j = 1 : n
    for i = n : -1 : 1
        count = count + 1;
        i_init = (i - 1) * n * span + 1;
        i_end = i_init + n * span - 1;
        j_init = (j - 1) * n * span + 1;
        j_end = j_init + n * span - 1;
        tmp = idx_up * A(count,4) + ...
            idx_right * A(count,2) + ...
            idx_down * A(count,3) + ...
            idx_left * A(count,1);
        Z(i_init:i_end, j_init:j_end) = tmp;
    end
end

imagesc(Z)
len = span * n * n;
ax = gca();
ax.set('xtick',[0:span*n:len]+(span*n/2));
ax.set('xticklabels',1:n);
ax.set('ytick',[0:span*n:len]+(span*n/2));
ax.set('yticklabels',1:n);

hold on
for i = 0:span*n:len
    plot([i,i],[0,len],'k','linewidth',0.6)
    plot([0,len],[i,i],'k','linewidth',0.6)
end

caxis manual
try
    caxis([min(A(:)) max(A(:))]);
catch
end
xlim([0, len])
ylim([0, len])

%%
shift = 10;
arr_c = 'k';
arr_w = 3;
arr_h = 3;
arr_l = span * n / 2;
count = 0;

for j = 1 : n
    for i = 1 : n
        count = count + 1;

        i_init = (i - 1) * n * span + 1;
        j_init = (j - 1) * n * span + 1;
        center_i = i_init + arr_l;
        center_j = j_init + arr_l;
        center_i = len - center_i;

        max_a = max(A(count,:));
        actions = find(max_a == A(count,:));
        for a = actions
            if a == 2 % right
                quiver(center_j,center_i,arr_l-shift,0,'color',arr_c,'linewidth',arr_w,'maxheadsize',arr_h)
            end
            if a == 3 % down
                quiver(center_j,center_i,0,arr_l-shift,'color',arr_c,'linewidth',arr_w,'maxheadsize',arr_h)
            end
            if a == 1 % left
                quiver(center_j,center_i,-arr_l+shift,0,'color',arr_c,'linewidth',arr_w,'maxheadsize',arr_h)
            end
            if a == 4 % up
                quiver(center_j,center_i,0,-arr_l+shift,'color',arr_c,'linewidth',arr_w,'maxheadsize',arr_h)
            end
        end
    end
end

ax = gca;
ax.FontSize = 16; 
ax.FontWeight = 'bold';

% axis equal
% axis tight

if nargin == 3 && length(range) > 0
    caxis manual
    caxis(range)
end