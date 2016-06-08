function lr=indtest(alpha, I)
    p = 1-alpha;
    I_t = I(1:end-1);
    I_tplus1 = I(2:end);
    T00 = sum(I_t==0 & I_tplus1==0);
    T01 = sum(I_t==0 & I_tplus1==1);
    T10 = sum(I_t==1 & I_tplus1==0);
    T11 = sum(I_t==1 & I_tplus1==1);
    p01_est = T01/(T00+T01);
    p11_est = T11/(T10+T11);
    lr = -2 * log(likelihood(p, p, T00, T01, T10, T11) / ...
                  likelihood(p01_est, p11_est, T00, T01, T10, T11));
end

function lik=likelihood(p01, p11, T00, T01, T10, T11)
    lik = (1-p01)^T00 * p01^T01 * (1-p11)^T10 * p11^T11;
end