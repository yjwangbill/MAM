function [err_val,err_tst,width_tst,cover_tst] = evaluation(x,y,theta,nu,param,inner_func,meantrn,stdtrn)
 error_val = zeros(1,param.inner.nTasks);
 error_tst = zeros(1,param.inner.nTasks);
 cover = zeros(1,param.inner.nTasks);
 width = zeros(1,param.inner.nTasks);
for xtt=1:param.inner.nTasks
    [output] = Hq_DFBB(x.trn{xtt},y.trn{xtt},theta,inner_func,param); 
    beta = output{end}.w;
    y.tst{xtt} = y.tst{xtt}*stdtrn{xtt}+meantrn{xtt};
    y.true{xtt} = y.true{xtt}*stdtrn{xtt}+meantrn{xtt};
    y_pre = x.tst{xtt}*(repelem(nu,size(beta,1)/size(theta,1),1).*beta);
    y_pre = y_pre*stdtrn{xtt}+meantrn{xtt};
    error_val(xtt) =  norm(y.tst{xtt}-y_pre)^2/50;
    error_tst(xtt) =  norm(y.true{xtt}-y_pre)^2/50; 
    [width(xtt),cover(xtt)] =  coverage(y.tst{xtt},y_pre,param.alpha);
end
err_val = sum(error_val)/param.inner.nTasks;
err_tst = sum(error_tst)/param.inner.nTasks;
width_tst = sum(width)/param.inner.nTasks;
cover_tst = sum(cover)/param.inner.nTasks;
end
