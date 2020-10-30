function [hyperGrad_aux,hyperGrad_aux_nu, theta] = initialization (param)

theta =  proj_unitSimplex( ((1/param.inner.nGroups)*ones(param.inner.nFeatures,param.inner.nGroups) + .01*randn(param.inner.nFeatures,param.inner.nGroups))')'; 
hyperGrad_aux.all   = zeros(param.inner.nFeatures,param.inner.nGroups,param.inner.nTasks);
hyperGrad_aux.mean  = zeros(param.inner.nFeatures,param.inner.nGroups);             
hyperGrad_aux_nu.all   = zeros(param.inner.nFeatures,1,param.inner.nTasks);
hyperGrad_aux_nu.mean  = zeros(param.inner.nFeatures,1);
end