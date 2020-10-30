function [theta_hyper,nu_hyper,hyperGrad_aux,hyperGrad_aux_nu,step_theta,step_nu] = hyper_modal(X,y,Batch_I,hyperGrad_aux,hyperGrad_aux_nu,theta,nu,param,inner_func)
%% initialization   
        hyperGrad_batch    = NaN(param.inner.nFeatures,param.inner.nGroups,param.outer.batchSize);
        hyperGrad_diff     = NaN(param.inner.nFeatures,param.inner.nGroups);
        hyperGrad_batch_nu = NaN(param.inner.nFeatures,1,param.outer.batchSize);
        hyperGrad_diff_nu  = NaN(param.inner.nFeatures,1);
%% Hq-DFBB and Partial Gradient
        for j = 1: param.outer.batchSize
              index                         =    Batch_I(j);
              [output]                      =    Hq_DFBB(X.trn{index},y.trn{index},theta,inner_func,param);  
              [hyperGrad, hyperGrad_nu]     =    Hq_Dual_Hypergradient (X.trn{index},y.trn{index},X.val{index},y.val{index},param,output,theta,inner_func,nu);
              hyperGrad_batch(:,:,j)        =    hyperGrad;  
              hyperGrad_batch_nu(:,1,j)     =    hyperGrad_nu;
       end

       for xtt=1: param.outer.batchSize
            hyperGrad_diff(:,:,xtt) = hyperGrad_batch(:,:,xtt) - hyperGrad_aux.all(:,:,Batch_I(xtt));
            hyperGrad_aux.all(:,:,Batch_I(xtt))   = hyperGrad_batch(:,:,xtt); 

            hyperGrad_diff_nu(:,:,xtt) = hyperGrad_batch_nu(:,:,xtt) - hyperGrad_aux_nu.all(:,:,Batch_I(xtt));
            hyperGrad_aux_nu.all(:,1,Batch_I(xtt))   = hyperGrad_batch_nu(:,1,xtt); 
       end         
       theta_hyper  =  mean(hyperGrad_diff,3)    + hyperGrad_aux.mean;
       hyperGrad_aux.mean  = sum(hyperGrad_diff,3)/param.inner.nTasks + hyperGrad_aux.mean;

       nu_hyper  =  mean(hyperGrad_diff_nu,3)    + hyperGrad_aux_nu.mean;
       hyperGrad_aux_nu.mean  = sum(hyperGrad_diff_nu,3)/param.inner.nTasks + hyperGrad_aux_nu.mean;
       
       step_theta =  10^-(1+fix(log10(abs(max(max(theta_hyper))))));
       step_nu    =  10^-(2+fix(log10(abs(max(nu_hyper)))));
end