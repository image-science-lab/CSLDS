function Cmat = ATNoiselet_Cmat(z, idx, idx2, Xmat, N, d);

z = reshape(z, size(idx, 1), size(idx, 2));

if (0)
    Cmat = zeros(N, d);
    
    for kk=1:size(z, 2)
        tmp = AToperator_noiselet(z(:, kk), idx(:, kk), idx2);
        Cmat = Cmat + tmp*Xmat(:, kk)';
    end
    
else
    T = size(idx, 2);
    Z1 = zeros(N, T);
    for kk=1:size(z, 2)
        Z1(idx(:, kk), kk) = z(:, kk);
    end
    Cmat = Z1*Xmat';
    Cmat = realnoiselet(Cmat)/sqrt(N);
    Cmat(idx2, :) = Cmat; 
end

Cmat = Cmat(:);
