function s = ATWavelet_AllColumns(x, wave, N, T)

s = zeros([N T]);
x = reshape(x, [ N T]);
for kk=1:T
    tmp = reshape(x(:, kk), wave.siz);
    s(:, kk) = wavedec2(tmp, wave.level, wave.name);
end
s = s(:);
