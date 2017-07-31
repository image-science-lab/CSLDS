function Smat = CTOperator_wavelet(Cmat, wave, N, d, siz)

Cmat = reshape(Cmat, N, d);
Smat = 0*Cmat;

for kk=1:d
   tmp = reshape(Cmat(:, kk), siz);
   tmp1 = wavedec2(tmp, wave.level, wave.name);
    Smat(:, kk) = tmp1(:);
end
Smat = Smat(:);