function s = AWavelet_AllColumns(x, wave, N, T)

s = zeros(N, T);
x = reshape(x, [N T]);

for kk=1:T
    tmp = waverec2(x(:, kk), wave.Cbook, wave.name);

    s(:, kk) =tmp(:);
end
s = s(:);
