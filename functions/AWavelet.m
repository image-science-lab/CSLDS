function s = AWavelet(x, wave)

s = waverec2(x, wave.Cbook, wave.name);
s = s(:);
