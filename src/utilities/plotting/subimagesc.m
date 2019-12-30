function subimagesc(name, X, Y, Z, addcolorbar)
% SUBIMAGESC Plots multiple imagesc on the same figure using subplot.
%
%    INPUT
%     - name : figure name
%     - X    : [1 x M] vector
%     - Y    : [1 x N] vector
%     - Z    : [D x MN] matrix

[nplots, ~] = size(Z);
m = length(X);
n = length(Y);
nrows = floor(sqrt(nplots));
ncols = ceil(nplots/nrows);

f = findobj('type','figure','name',name);

if isempty(f)
    if nargin == 4, addcolorbar = 0; end
    figure('Name',name);
    for i = nplots : -1 : 1
        subplot(nrows,ncols,i,'align')
        imagesc('XData',X,'YData',Y,'CData',reshape(Z(i,:),n,m))
        axis([min(X)-0.5 max(X)+0.5 min(Y)-0.5 max(Y)+0.5])
        if nplots > 1, title(num2str(i)), end
        if addcolorbar, colorbar, end
        xticks([])
        yticks([])
    end
else
    axes = findobj(f,'type','axes');
    for i = nplots : -1 : 1
        axes(i).Children.CData = reshape(Z(i,:),n,m);
    end
end

drawnow
