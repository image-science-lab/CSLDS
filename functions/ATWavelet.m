function s = ATWavelet(x, wave)

x = reshape(x, wave.siz);
s = wavedec2(x, wave.level, wave.name);
s = s(:);
