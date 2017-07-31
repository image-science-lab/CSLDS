function Cmat = COperator_dct(Smat, N, d, siz)

Smat = reshape(Smat, N, d);
Cmat = 0*Smat;

for kk=1:d
   tmp1 = idct2(reshape(Smat(:, kk), siz));
    Cmat(:, kk) = tmp1(:);
end
Cmat = Cmat(:);