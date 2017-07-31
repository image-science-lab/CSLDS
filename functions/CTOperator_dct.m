function Smat = CTOperator_dct(Cmat, N, d, siz)

Cmat = reshape(Cmat, N, d);
Smat = 0*Cmat;

for kk=1:d
   tmp = reshape(Cmat(:, kk), siz);
   tmp1 = dct2(tmp); %
    Smat(:, kk) = tmp1(:);
end
Smat = Smat(:);