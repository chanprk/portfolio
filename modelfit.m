function modelfit(lr, df, alpha)
    disp('');
    critcl = chi2inv(alpha, df);
    pvalue = 1 - chi2cdf(lr, df);
    fprintf('Chi-square with %d-dof :\n\tAlpha=%.3f, Critical Value=%.3f \n',...
        df, alpha, critcl);
    fprintf('\tLR=%.3f, P-Value=%.3f \n', lr, pvalue);
    
    if pvalue < (1-alpha)
        decision = 'Reject';
    else
        decision = 'Accept';
    end
    fprintf('\t%s null hypothesis \n', decision);
    chiplot(lr, critcl, df);
end

function chiplot(lr, critcl, df)
    xs = 0:0.1:8;
    rng = critcl:0.1:8;
    plot(xs, pdf('Chisquare',xs, df),'Color','Black');
    ylim([0,1.2]);
    hold on
    area(rng,pdf('Chisquare',rng, df));
    line([lr, lr],[0,0.2],'Color','Blue');
    line([critcl, critcl],[0,0.3],'Color','Red');
    text(lr,0.2,'test statistics');
    text(critcl,0.3,'critical value');
    hold off
end