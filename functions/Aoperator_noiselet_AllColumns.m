function z = Aoperator_noiselet_AllColumns(x, idx, idx2, N, T)

x = reshape(x, [N T]);
x = x(idx2, :);
if (1)
    z = zeros(size(idx));
    for kk=1:T
        tmp = realnoiselet(x(:, kk))/sqrt(N);
        z(:, kk) = tmp(idx(:, kk));
    end
    z = z(:);
else
    z = realnoiselet(x)/sqrt(N);
    idx = idx + ones(size(idx, 1), 1)*[0:size(idx,2)-1]*N;
    
    z = z(idx(:));
end
