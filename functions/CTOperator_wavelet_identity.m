function Smat = CTOperator_wavelet_identity(Cmat, wave, N, d, siz)

Cmat = reshape(Cmat, N, d);
Smat = 0*Cmat;

for kk=1:d
    tmp = reshape(Cmat(:, kk), siz);
    if (kk == 1)
        tmp1 = wavedec2(tmp, wave.level, wave.name);
    else
        tmp1 = (tmp);
    end
    Smat(:, kk) = tmp1(:);
end
Smat = Smat(:);