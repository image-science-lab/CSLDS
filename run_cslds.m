function [yrec, c0, Xhat, snr, psnr] = run_cslds(ydata, spSelect, Comp, d, hank_param, solver)
%%%%%Simulate CS-LDS on a video
%%%%% Look at "Compressive Acquisition of Linear Dynamical Systems" paper
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Input
%    ydata --- 3D video cube.
%    spSelect --- Sparsity basis for the observation matrix
%                 (spSelect == 1)  %sparsity in a wavelet basis
%                 (spSelect == 2) %sparsity in a identity basis
%                 (spSelect == 3) %sparisty in a DCT basis
%                 (spSelect == 4) %sparisty of mean in wavelet, rest in DCT
%                 (spSelect == 5) %sparsity of mean in wavelet, rest in identity
%    Comp  --- Compression factor.
%    d     --- LDS state space dimension
%    solver --- 1 or 0
%              1 -- uses cosamp code in 'cosamp' folder
%              0 -- uses spg_bpdn (needs spgl1 package)
%
% Output
%    yrec ---- reconstructed video
%    c0    --- estimated observation matrix
%    Xhat  --- Estiamted state sequence
%    snr, psnr --- SNR and Peak SNR
%
%

addpath('functions')
addpath('utility')
addpath('cosamp');

mycolon = @(x) x(:);

%loading dataset
siz = [ size(ydata, 1) size(ydata, 2)];
N = prod(siz);
T = size(ydata, 3);



M = floor(N/Comp);
Mhat = 3*d;    %Feel free to change this
Mtilde = M - Mhat;
if (Mtilde < 0)
    Mhat = floor(M/2);
    Mtilde = M - Mhat;
end

%%Get Compressive measurements
%I am using noiselets for speed
%Noiselt code is in "utility" folder
idx2 = randperm(N); %column permutation
idx = zeros(M, T);
for kk=1:T
    tmp = randperm(N);
    idx(:, kk) = tmp(1:M);
end

%this next step ensures that we obtain "common" measurements for each frame
idx(1:Mhat, :) = idx(1:Mhat,1)*ones(1, T);

%Obtain compressive measurements
disp('Obtaining compressive menasurements');
z = zeros(M, T);
for kk=1:T
    z(:, kk) = Aoperator_noiselet( mycolon(ydata(:, :, kk)), idx(:, kk), idx2);
end


%%%%%%%
% CSLDS Starts here
%%%%%%%%%%%%%%%%%%%%%%%
%GET STATE SEQUENCE
disp('Estimating state sequence');
%We use a simple version of the Hankel matrix here (just the top block).
zhat = z(1:Mhat, :);

if (spSelect >= 4)
    zhat = zhat - mean(zhat, 2)*ones(1, T); %Subtracting mean
end

hankmat = formHankelMatrix( zhat, hank_param);
[Uz, Sz, Vz] = svd(hankmat);
dhat = d; %Can use heuristics here
Xhat = (Sz(1:dhat, 1:dhat))*Vz(:, 1:dhat)';
Xhat = [ Xhat Xhat(:, end)*ones(1, hank_param-1) ];

if (spSelect >= 4)
    Xhat = [ ones(1, T); Xhat]; %The ones(1, T) incorporates the mean term
    dhat = dhat + 1;
end

%GET OBSERVATION MATRIX
wave.name = 'db4';
wave.level = 5;
dwtmode('per');
[tmp, wave.Cbook] = wavedec2(randn(siz), wave.level, wave.name);

%Function handles for the nosielet operator
funMeas = @(Cvar) ANoiselet_Cmat(Cvar, idx, idx2, Xhat, N, dhat);
funMeasTr = @(zVar)  ATNoiselet_Cmat(zVar, idx, idx2, Xhat, N, dhat);

if (spSelect == 1)  %sparsity in a wavelet basis
    funSparse = @(Svar) COperator_wavelet(Svar, wave, N, dhat, siz);
    funSparseTr = @(Cvar) CTOperator_wavelet(Cvar, wave, N, dhat, siz);
end
if (spSelect == 2) %sparsity in a identity basis
    funSparse = @(x) x(:);
    funSparseTr = @(x) x(:);
end
if (spSelect == 3) %sparisty in a DCT basis
    funSparse = @(Svar) COperator_dct(Svar, N, dhat, siz);
    funSparseTr = @(Cvar) CTOperator_dct(Cvar, N, dhat, siz);
end
if (spSelect == 4) %sparisty of mean in wavelet, rest in DCT
    funSparse = @(Svar) COperator_wavelet_dct(Svar, wave, N, dhat, siz);
    funSparseTr = @(Cvar) CTOperator_wavelet_dct(Cvar, wave, N, dhat, siz);
end
if (spSelect == 5) %sparsity of mean in wavelet, rest in identity
    funSparse = @(Svar) COperator_wavelet_identity(Svar, wave, N, dhat, siz);
    funSparseTr = @(Cvar) CTOperator_wavelet_identity(Cvar, wave, N, dhat, siz);
end

%form compound measurement operator
A = @(x) funMeas(funSparse(x));
At = @(x) funSparseTr(funMeasTr(x));

Kmax = floor((M*T - Mhat*T)/(5*d)); %Feel free to change this
K1 = min(2*Kmax, prod(siz)); %Sparsity of mean
K2 = min(prod(siz), floor(Kmax*2/3)); %sparsity of the rest

MaxIter = 10; %A small value is usally good enough
tol = 1e-3;

if (solver)
    if (spSelect >= 4)
        grp = [N dhat-1]; %this tells the cosamp code on the grouping pattern of the structured sparisty
        s0 = Cosamp_mean_cslds(z(:), A, At, K1, K2, grp, MaxIter, tol, 'cgs');
    else
        grp = [N dhat]; %this tells the cosamp code on the grouping pattern of the structured sparisty
        s0 = Cosamp_groupsparsity(z(:), A, At, Kmax, grp, MaxIter, tol, 'cgs');
    end
else
    fSPG = @(x, mode) spg_wrapper(x, mode, A, At);
    opt = spgSetParms; opt.iterations = 300;
    opt.verbosity = 1;
    groups = [ (1:prod(siz))' (prod(siz)+(1:prod(siz))')*ones(1, d)];
    [s0,r,g,info] = spg_group( fSPG, z(:), groups, norm(z(:))/100, opt );
end

c0 = funSparse(s0);
c0 = reshape(c0, [N dhat]);

yrec = c0*Xhat;

snr = -20*log10( norm(yrec(:) - ydata(:))/norm(ydata(:)));
psnr = -20*log10( norm(yrec(:) - ydata(:))/(sqrt(length(yrec(:)))*max(abs(ydata(:)))));


disp(sprintf('Final results. \n Compression = %d x \n Reconstruction SNR = %3.3f dB ', Comp, -20*log10( norm(yrec(:) - ydata(:))/norm(ydata(:)))))
disp(sprintf(' Peak SNR = % 3.3f dB',-20*log10( norm(yrec(:) - ydata(:))/(sqrt(length(yrec(:)))*max(abs(ydata(:)))))))


ydata = reshape(ydata, siz(1), siz(2), 1,  []);
yrec = reshape(yrec, siz(2), siz(2), 1, []);

