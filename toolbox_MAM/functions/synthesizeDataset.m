function [y,X,X_spline,theta,w,Xw,nustar,mean_trn,std_trn] = synthesizeDataset( param,synth)
%SYNTHESIZEDATASET Summary of this function goes here
%   Detailed explanation goes here
%\\\\  Design matrices
N     =       param.N;
P     =       param.P;
T     =       param.T;
L     =       param.L;
S     =       param.G;

if ~isfield(synth.design,'setting')
    synth.design.setting = 'general';
end

%\\\\ Features

if ~isfield(synth.features,'distrib')
    synth.features.distrib = 'normal';
end

if synth.features.param(2)==0
    synth.features.param(2) = eps;
end



%% VARIABLE STRUCTURE
nvar = P;
assert(mod(nvar,L)==0,'nvar should be multiple of L for groups of equal size (synthesis convention)');
tmp = repmat((1:L)',[1 nvar/L])';
groupBelonging = tmp(1:end);

theta = zeros(P,L);
for pp=1:P
    theta(pp,groupBelonging(pp)) = 1;
end


%% ORACLE FEATURES
w   = zeros(P,T);
w0  = ones(P, T);
index =randperm(P,synth.features.sparsity );
nustar = ones(P,1);
nustar(index,1)=0;
for tt=1:T
    for ss=1:S
        indi = randi(L);
        ind = groupBelonging==indi;
        w(ind,tt) = w0(ind,tt);
        w(index,tt)  = 0;
    end
end



%% DESIGN MATRICES

for tt=1:T
    
    X_trtmp = normrnd(synth.design.mean,synth.design.std,N,P);
    X_vltmp = normrnd(synth.design.mean,synth.design.std,N,P);
    X_tstmp = normrnd(synth.design.mean,synth.design.std,N,P);
    
    X.trn{tt}       = X_trtmp;
    X.val{tt}       = X_vltmp;
    X.tst{tt}       = X_tstmp;
    
    r = synth.features.order;    
    X_trn = X.trn{tt};
    X_val = X.val{tt};
    X_tst = X.tst{tt};
    for j = 1 : P
      min_k_trn = min(X_trn(:,j));
      max_k_trn = max(X_trn(:,j));
      knot_trn  = [ min_k_trn,max_k_trn];
      X_trn_spline(:,(j-1)*r+1:j*r) = bsplinebasis(X_trn(:,j), knot_trn, r);
                    
      min_k_val = min(X_val(:,j));
      max_k_val = max(X_val(:,j));
      knot_val  = [ min_k_val,max_k_val];
      X_val_spline(:,(j-1)*r+1:j*r) = bsplinebasis(X_val(:,j), knot_val, r);    
                  
      min_k_tst = min(X_tst(:,j));
      max_k_tst = max(X_tst(:,j));
      knot_tst  = [ min_k_tst,max_k_tst];
      X_tst_spline(:,(j-1)*r+1:j*r) = bsplinebasis(X_tst(:,j), knot_tst, r);
    end
      X_spline.trn{tt}       = X_trn_spline;
      X_spline.val{tt}       = X_val_spline;
      X_spline.tst{tt}       = X_tst_spline;
                
      switch synth.function
            case 'ExA'
                Xw.trn(:,tt)    = X.trn{tt}*w(:,tt);
                Xw.val(:,tt)    = X.val{tt}*w(:,tt);
                Xw.tst(:,tt)    = X.tst{tt}*w(:,tt);
            case 'ExB'    
                Xw.trn(:,tt)    = func_add (X.trn{tt},w(:,tt),nustar);
                Xw.val(:,tt)    = func_add (X.val{tt},w(:,tt),nustar);
                Xw.tst(:,tt)    = func_add (X.tst{tt},w(:,tt),nustar);   
      end
end


%% NOISY VECTORS OF OUTPUTS

switch synth.noise.distrib
    case 'normal'
        y.trn   = Xw.trn + randraw(synth.noise.distrib,synth.noise.param,[N T]);  %0.5*trnd(3,N,T);%
        y.val   = Xw.val + randraw(synth.noise.distrib,synth.noise.param,[N T]);
        y.tst   = Xw.tst + randraw(synth.noise.distrib,synth.noise.param,[N T]);    
        y.true  = Xw.tst;
    case 't'
        y.trn   = Xw.trn + randraw(synth.noise.distrib,synth.noise.degree,[N T]);  %0.5*trnd(3,N,T);%
        y.val   = Xw.val + randraw(synth.noise.distrib,synth.noise.degree,[N T]);
        y.tst   = Xw.tst + randraw(synth.noise.distrib,synth.noise.degree,[N T]);    
        y.true  = Xw.tst;
    case 'chisq'
        y.trn   = Xw.trn + randraw(synth.noise.distrib,synth.noise.degree,[N T]);  %0.5*trnd(3,N,T);%
        y.val   = Xw.val + randraw(synth.noise.distrib,synth.noise.degree,[N T]);
        y.tst   = Xw.tst + randraw(synth.noise.distrib,synth.noise.degree,[N T]);    
        y.true  = Xw.tst;
    case 'exp'
        y.trn   = Xw.trn + exprnd(2, N, T) ;  %0.5*trnd(3,N,T);%
        y.val   = Xw.val + exprnd(2, N, T) ;
        y.tst   = Xw.tst + exprnd(2, N, T) ;    
        y.true  = Xw.tst;
end

%from array to cell
ytmp = y;
clear y;
for tt=1:T
    y.trn{tt} = ytmp.trn(:,tt);
    mean_trn{tt}  = mean(ytmp.trn(:,tt));
    std_trn{tt}   = std2(ytmp.trn(:,tt));
    y.trn{tt} =  (y.trn{tt} - mean_trn{tt})/std_trn{tt};
    
    y.val{tt} = ytmp.val(:,tt);
    y.val{tt} =  (y.val{tt} - mean_trn{tt})/std_trn{tt};
    
    y.tst{tt} = ytmp.tst(:,tt);
    y.tst{tt} =  (y.tst{tt} - mean_trn{tt})/std_trn{tt};
    
    
    y.true{tt} = ytmp.true(:,tt);
    y.true{tt} =  (y.true{tt} - mean_trn{tt})/std_trn{tt};
end


end
function y_star = func_add(x,w,nu)
x = x.*nu';
index = w~=0;
y_star =sum(3*sin(x(:,1:10))*index(1:10)+2*x(:,11:20)*index(11:20)+(3*exp(x(:,21:30))+exp(-1)-1)*index(21:30)+5*(x(:,31:40)).^2*index(31:40)+3*sin(2*exp(x(:,41:50)))*index(41:50),2);
    

end
