clear all
close all

addpath('functions')
addpath('utility')
addpath('cosamp');

mycolon = @(x) x(:);


siz = [256 256]/2; %Spatial resolution
Comp = 40; %Compression
d = 20;  %d = LDS state dimension. Reduce this as Comp is increased.
solver = 1; %1 - Cosamp, 0 - Basis pursuit-group sparsity
hank_param = 1; % Used in forming hankel matrix. This is the number of blocks in the hankel matrix


%This variable selects the sparsity basis
% (spSelect == 1)  %sparsity in a wavelet basis
% (spSelect == 2) %sparsity in a identity basis
% (spSelect == 3) %sparisty in a DCT basis
% (spSelect == 4) %sparisty of mean in wavelet, rest in DCT
% (spSelect == 5) %sparsity of mean in wavelet, rest in identity
spSelect = 4; 

fname = 'dyntex/64cae10';
ydata = loadDyntexDataset(fname, siz);

[yrec, c0, Xhat, snr, psnr] = run_cslds(ydata, spSelect, Comp, d, hank_param, solver);

ydata = reshape(ydata, size(ydata, 1), size(ydata, 2), 1, size(ydata, 3));

figure(1)
subplot 121
montage(ydata(:,:,:,1:30:end));
title('Ground truth');
subplot 122
montage(yrec(:,:,:, 1:30:end));
title('Recovered video');

figure(2)
subplot 211
montage(reshape(c0*diag(1./(1e-10+max(c0)+max(-c0))), siz(1), siz(2),1,[]), [-1 1]/2); colormap jet 
axis image; axis off
title('Observation matrix');
subplot 212
plot(Xhat')
title('state transition')