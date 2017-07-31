function y = spg_wrapper(x, mode, A, At)
if (mode == 1)
    y = A(x);
else
    y = At(x);
end