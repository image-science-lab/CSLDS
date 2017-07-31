function x = AToperator_noiselet(z, idx, idx2)

y = zeros(length(idx2), 1);

y(idx) = z;
x = realnoiselet(y)/sqrt(length(y));
x(idx2) = x;
