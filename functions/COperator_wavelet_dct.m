function Cmat = COperator_wavelet_dct(Smat, wave, N, d, siz)

Smat = reshape(Smat, N, d);
Cmat = 0*Smat;


for kk=1:d
    if (kk ==1)
        tmp1 = waverec2(Smat(:, kk), wave.Cbook, wave.name);
    else
        tmp1 = idct2(reshape(Smat(:, kk), siz));
    end
    Cmat(:, kk) = tmp1(:);
end
Cmat = Cmat(:);