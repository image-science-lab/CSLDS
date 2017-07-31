function z = ANoiselet_Cmat(Cmat, idx, idx2, Xmat, N, d);

Cmat = reshape(Cmat, N, d);

%z = zeros( size(idx, 1), size(Xmat, 2));

%CX = Cmat*Xmat;
%for kk=1:size(idx, 2)
%   z(:, kk) = Aoperator_noiselet(Cmat*Xmat(:, kk), idx(:, kk), idx2);
%end

%    z = Aoperator_noiselet_AllColumns(Cmat*Xmat, idx, idx2, N, size(Xmat, 2));

%z = z(:);

Cmat = Cmat(idx2, :);
z = realnoiselet(Cmat)/sqrt(N);
z = z*Xmat;

z1 = zeros( size(idx, 1), size(Xmat, 2));
for kk=1:size(idx, 2)
    z1(:, kk) = z(idx(:, kk), kk);
end
z = z1(:);

