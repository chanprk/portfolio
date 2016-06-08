function lr=uctest(alpha, I)
    p = 1-alpha;
    T = length(I);
    T1 = sum(I); T0 = T - T1;
    p_est = T1/T;
    lr= -2 * log(likelihood(p, T0, T1) / likelihood(p_est, T0, T1));
end

function lik=likelihood(pi, T0, T1)
    lik = (1-pi)^T0*pi^T1;
end