%------------------------------------------------------------------------------------------------------------
clearvars;
close all;
addpath(genpath('functions'))
%\\\\\ Synthesis parameters                          
param.N                     =        50;                                   %The number of samples
param.P                     =        50;                                   %The dimension of features
param.T                     =       500;                                   %The number of tasks
param.L                     =         5;                                   %The number of groups, 1 <= L <= P
param.G                     =         2;                                   %The number of non-zero groups per task
param.sigma                 =         2;                                   %The bandwidth of modal kernel      
param.lambda                =      0.01;                                   %The regularization parameter (0.0001,0.001,0.01,0.1)
param.mu                    =     0.001;                                   %The smooth parameter for \mu/2\|\beta\|_2^2
param.alpha                 =       0.9;                                   %The confidence level 
synth.noise.distrib         =     'exp';                                   %'normal', 'chisq', 't' or 'exp';   
synth.noise.degree          =         2;                                   %The freedom of Chi-square distribution or t distribution 
synth.noise.param           =  [0 0.05];                                   %Mean 'param(1)' and var 'param(2)' for Gaussian noise
synth.features.distrib      =  'normal';                                   %The distribution of features
synth.features.sparsity     =         0;                                   %|V|, the number of inactive variables
synth.features.order        =         3;                                   %the order of spline basis
synth.features.param        =   [0,0.5];                                   %mean 'param(1)' and var 'param(2)'
synth.design.mean           =         0;                            
synth.design.std            =       0.5;
synth.function              =     'ExA';                                   %linear function ('ExA') or additive function ('ExB')
%\\\\\\\\\\\\\\\\\\Data-generating
[y,X,X_spline,thetastar,wstar,Xwstar,nustar] = synthesizeDataset(param,synth);                                      %Data-generating
%\\\\\\\\ The parameters for inner problem
% - Inner problem
param.inner.modalIter       =                  5;                          %M:  Max-Iter of HQ
param.inner.sigma           =        param.sigma;                          %The bandwidth of modal kernel
param.inner.nTasks          =            param.T;                          %The number of tasks
param.inner.nObs            =            param.N;                          %The number of samples
param.inner.nFeatures       =            param.P;                          %The dimension of features
param.inner.nGroups         =            param.L;                          %The number of groups, 1 <= L <= P
param.inner.itermax         =                100;                          %Q: Max-Iter of DFBB  
param.inner.saveIterates    =               true;
%\\\\\\\\\\\\\\\\\\\\The parameter for outer problem
param.outer.sigma           =       param.sigma;                           %The bandwidth of outer problem
param.outer.nTasks          =           param.T;                           %The number of tasks
param.outer.nFeatures       =           param.P;                           %The dimension of features
param.outer.fixedPointHG    =              true;                           %Fixed-point approach for computing the hypergradient
param.outer.projection      =         'simplex';                           %Space Theta (see also, 'posSphere' and 'box')
param.outer.itermax         =              2000;                           %Number of outer iterations
param.outer.nGroups         =           param.L;                           %Number of groups
param.outer.batchSize       =                 1;                           %Batch size for stochastic optimization (see below) 
param.outer.displayOnline   =              true;                           %Online display of groups
%\\\\\\\\ Initialize the functions in HQ-DFBB
inner_function              = inner_setting (param);                      
%% ANALYSIS
 for i =1 :1
         if strcmp(synth.function, 'ExB') == 1            
               [opt_MAM]          =      MAM(y,X_spline,param,thetastar,nustar,inner_function);   %\\training MAM  for Example B                 
               [error_val_MAM,error_tst_MAM,width_MAM,coverage_MAM]        = ...                   %\\Evaluate MAM
                                  evaluation(X_spline,y,opt_MAM.theta,opt_MAM.nu,param,inner_function); 
               [error_val_mGAM,error_tst_mGAM,width_mGAM,coverage_mGAM]    = ...                   %\\Evaluate mGAM
                                  evaluation(X_spline,y,thetastar,nustar,param,inner_function);   
         else
               [opt_MAM]          =      MAM(y,X,param,thetastar,nustar,inner_function);          %\\training MAM   for Example A   
               [error_val_MAM,error_tst_MAM,width_MAM,coverage_MAM]        =...                    %\\Evaluate MAM
                          evaluation(X,y,opt_MAM.theta,opt_MAM.nu,param,inner_function); 
               [error_val_mGAM,error_tst_mGAM,width_mGAM,coverage_mGAM]    =...                    %\\Evaluate mGAM
                          evaluation(X,y,thetastar,nustar,param,inner_function);   
         end
 end       
%% Results
disp('Absolute Error for Test Set ::')
disp(['MAM::',num2str(error_val_MAM),    '  mGAM::',num2str(error_val_mGAM) ])
disp('Absolute True Error for Test Set ::')
disp(['  MAM::',num2str(error_tst_MAM), '  mGAM::',num2str(error_tst_mGAM)])
disp('The Width of Prediction Intervals ::')
disp(['MAM::',num2str(width_MAM),         '  mGAM::',num2str(width_mGAM)])
disp('The Sample Coverage Probability ::')
disp(['MAM ::',num2str(coverage_MAM),     '  mGAM ::',num2str(coverage_mGAM)])
