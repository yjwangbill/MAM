function [ opt ] = MAM( y,X,param,thetastar,nustar,inner_func)
%% initialization    
opt = struct;
[hyperGrad_aux,hyperGrad_aux_nu,theta] = initialization(param);                                 %Initialize \vartheta
nu = 0.5*ones(param.inner.nFeatures,1);                                                         %Initialize \nu 
[plt]   = optimBLGS_display_init(thetastar.*nustar,theta,param);                                %Plot  oracle varibale structure
%% Iteration
for iter=1:param.outer.itermax
      Batch_I  = randperm(param.inner.nTasks,  param.outer.batchSize);                          %Select task randomly
      [theta_hyper,nu_hyper,hyperGrad_aux,hyperGrad_aux_nu,step_theta,step_nu] = ...
      hyper_modal(X,y,Batch_I,hyperGrad_aux,hyperGrad_aux_nu,theta,nu,param,inner_func);        %The partial gradient w.r.t. \vartheta and \nu
      theta   = proj_unitSimplex(( theta - step_theta * theta_hyper)')';                        %Update \vartheta 
      nu      = proj_box(nu - step_nu*nu_hyper,eps,1);                                          %Update \nu
      optimBLGS_display_refresh( plt,  theta.*nu,param);                                        
      disp(['Please Wait......    Progress::', num2str(iter/param.outer.itermax*100),'%'])
end
optimBLGS_display_refresh( plt,  threshTheta(theta',nu),param);
%% Output
opt.theta = theta;
opt.nu = nu; 
end
%% Functions
    function [plt] = optimBLGS_display_init(thetastar,theta,param)       
            figure;
            subplot(1,2,1)
            imagesc(thetastar);
            title('Oracle Variable Structure','Interpreter','latex','fontsize',13)
            ylabel('Features','Interpreter','latex','fontsize',2)
            xlabel('Group indices','Interpreter','latex','fontsize',2)
            set(gca,'fontsize',15,'clim',[0 1])
            xticks(1:param.outer.nGroups);
            colormap(flipud(gray))
%\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
            subplot(1,2,2)
            plt=imagesc(theta);
            title('Variable Structure (MAM)','Interpreter','latex','fontsize',13)
            ylabel('Features','Interpreter','latex','fontsize',2)
            xlabel('Group indices','Interpreter','latex','fontsize',2)
            set(gca,'fontsize',15,'clim',[0 1])
            xticks(1:param.outer.nGroups);
            colormap(flipud(gray))             
    end
    function [] = optimBLGS_display_refresh( plt1,theta,param)
            plt1.CData = theta;
            refreshdata(plt1,'caller');        
            drawnow limitrate
    end

