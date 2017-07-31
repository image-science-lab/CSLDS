function sCosamp = Cosamp_mean_cslds(b, A, At, K1, K2, grp, MaxIter, tol, method)
%%%%%%
% solves b = A(sCosamp) using a model-based cosamp algorithm
%
% b - observation vector
% A, At - forward/adjoint in a functional form. Includes sparsifying operator
% K1 - sparsity of the mean
% K2 - sparsity of the remainder
% grp - [N d] where N = number of pixels, d = LDS state dim (doesnt include
%        mean term)
% MaxIter - max number of cosamp iterations
% tol - stopping criterion on normalized residue
% method - for solving least sqyares problem below. use 'cgs' for conj
%          gradient, 'lsqr' for least sqyare 


M = length(b);
N = length(At(b));


y = b;
iter = 0;
S_old = [];
S_tilde_old = [];
lsqr_iter = 20;

while ((iter < MaxIter) & (norm(y)/norm(b) > tol))
    iter = iter + 1;
    
    %Support discovery
    r = At(y);
    r1 = r(1:grp(1)); r2 = r(grp(1)+1:end);
    
    [tmp, idx1] = sort(abs(r1), 'descend');
    idx1 = idx1(1:K1);
    
    r_model = signalToModel(r2, grp);
    [tmp, idx_m] = sort(r_model, 'descend');
    idx_m = idx_m(1:K2);
    idx2 = modelToSupp(idx_m, grp);
    
    idx = [idx1(:); idx2(:)];
    S_tilde = [S_old; idx(:) ];
    
    
    %Least Squares over S_tilde
    if (strcmp(method, 'lsqr'))
        funcA = @(x,t) AHandle(x, t, A, At, S_tilde, N);
        [a, flag] = lsqr(funcA, b, 1e-3, lsqr_iter);
    end
    if (strcmp(method, 'cgs'))
        funcA = @(x,t) AHandle(x, t, A, At, S_tilde, N);
        funcB = @(x) funcA(funcA(x, 'notransp'), 'transp');
        [a , flag] = cgs(funcB, funcA(b, 'transp'), 1e-3, lsqr_iter);
    end
    if (flag == 1)
        lsqr_iter = lsqr_iter*2
    end
    
    stmp = zeros(N, 1); stmp(S_tilde) = a;
    
    stmp1 = stmp(1:grp(1)); stmp2 = stmp(grp(1)+1:end);
    
    [tmp, idx1] = sort(abs(stmp1), 'descend');
    idx1 = idx1(1:K1);
    
    r_model = signalToModel(stmp2, grp);

    [tmp, idx_m] = sort(r_model, 'descend');
    idx_m = idx_m(1:K2);
    idx2 = modelToSupp(idx_m, grp);
    
    idx = [idx1(:); idx2(:)];
    s0 = zeros(N, 1); s0(idx) = stmp(idx);
    y = b - A(s0);
    
    err = norm(y)/norm(b);
    %disp(sprintf('Iter: %04d. Err: %2.5f. Diff: %d', iter, err, length(setdiff(idx, S_old))));
    disp(sprintf('Iter: %04d. Err: %2.5f. Diff: %d', iter, err, length(setdiff(idx, S_old))));
    if length(setdiff(idx, S_old)) < length(S_old)/100
        disp('Converged');
        break;
    end        
    
    
    S_old = idx;
    S_tilde_old = S_tilde;
    
    
end
sCosamp = s0;

function y = AHandle(x, t, A, At, Supp, N)
if strcmp(t,'transp')
    s = At(x);
    y = s(Supp);
elseif strcmp(t,'notransp')
    s = zeros(N, 1);
    s(Supp) = x;
    y = A(s);
end


function y = signalToModel(x, grp)
    x = x.^2;
    x = reshape(x, grp(1), []);
    y = sum(x, 2);

function y = modelToSupp(x, grp)
    
    x1 = x(:)*ones(1, grp(2));
    x2 = ones(length(x(:)),1)*(1:grp(2));
    y = x1+grp(1)*x2;
    y = y(:);
    