function make_map_count(A, name)

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
caxis([min(A(:)) max(A(:))]);
xlim([0, len])
ylim([0, len])

colormap(parula(1+max(A(:))))
c = colorbar;
set(c,'YTick',[0:max(A(:))])
set(c,'Location','northoutside')

ax = gca;
ax.FontSize = 16; 
ax.FontWeight = 'bold';

% axis equal
% axis tight
