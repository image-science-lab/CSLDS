function x = AToperator_noiselet_AllColumns(z, idx, idx2, N, T)

z = reshape(z, size(idx));

x = zeros([N T]);
for kk=1:T
    tmp1 = zeros(N, 1);
    tmp1(idx(:, kk)) = z(:, kk);
    tmp = realnoiselet(tmp1)/sqrt(N);
    x(:, kk) = tmp;
end
x(idx2, :) = x;
