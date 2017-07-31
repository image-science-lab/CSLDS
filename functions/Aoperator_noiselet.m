function z = Aoperator_noiselet(x, idx, idx2)

x = x(idx2);
z = realnoiselet(x)/sqrt(length(x));
z = z(idx);
