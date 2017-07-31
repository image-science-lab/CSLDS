function Cmat = COperator_wavelet(Smat, wave, N, d, siz)

Smat = reshape(Smat, N, d);
Cmat = 0*Smat;

for kk=1:d
   tmp1 = waverec2(Smat(:, kk), wave.Cbook, wave.name);
    Cmat(:, kk) = tmp1(:);
end
Cmat = Cmat(:);