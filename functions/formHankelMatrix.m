function hk = formHankelMatrix( dMat, q)

hk = [];
for kk=1:q
    hk = [ hk; dMat(:, kk:end-q+kk)];
end