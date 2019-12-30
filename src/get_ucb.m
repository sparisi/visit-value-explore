function value = get_ucb(Q, VC, K, maxU)

if nargin == 3, maxU = (1 + sqrt(2 * log(size(VC,2) - 1))); end

U = sqrt(2 * bsxfun(@times, log(1 + sum(VC,2)), 1 ./ VC));
U(isnan(U) | isinf(U)) = maxU;
value = Q + K .* U;
