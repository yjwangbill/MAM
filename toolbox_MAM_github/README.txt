Multi-task Additive Models (MAM)

*****************************************************************************************************************
* Author: Yingjie Wang					
* Date: Oct 14 2020   	         						                             	*
* This toolbox is designed to work with Matlab 2018b   *
*********************************************************
------------------------------------------------------------------------------------------------------------------------------------------------
DESCRIPTION:
This toolbox provides an efficient way to learn the variable structure shared in multiple tasks. 
------------------------------------------------------------------------------------------------------------------------------------------------
Specifications for Using MAM

One demo file 'demo_simulation.m' is proposed to illustrate the principle of the method with dynamic displays     
-----------------------------------------------------------------------------------------------------------------------------------------------
Experimental settings
   
Example A:                              synth.function                    =                  'ExA';                               
Example B:                              synth.function                    =                  'ExB'; 
Gaussian Noise:    	                synth.noise.distrib               =               'normal';
Student   Noise:                        synth.noise.distrib               =                    't';
Chi-square Noise:               	synth.noise.distrib		  =                'chisq';
Exponential Noise:     	        	synth.noise.distrib               =   	             'exp';
The number of inactive variables  	synth.features.sparsity           =               0  or  5;  
------------------------------------------------------------------------------------------------------------------------------------------------
Train

To train the model(s) in the paper, run MAM.m;
-----------------------------------------------------------------------------------------------------------------------------------------------
Evaluation

To evaluate the model(s) in the paper, run evaluation.m;
------------------------------------------------------------------------------------------------------------------------------------------------
Results: 

Absolute Error for Test Set ::                      	        MAM::0.8191 	           mGAM::0.82084
Absolute True Error for Test Set ::                             MAM::0.79799               mGAM::0.8004
The Width of Prediction Intervals ::                            MAM::0.21024               mGAM::0.21067
The Sample Coverage Probability ::                              MAM::0.10284               mGAM::0.10292
------------------------------------------------------------------------------------------------------------------------------------------------
Related Publication:

# Yingjie Wang, Hong Chen, Feng Zheng, Chen Xu, Tie Liang, Yanhong Chen.
Multi-task additive model for robust estimation and automatic structure discovery
Accepted to the Thirty-Fourth Annual Conference on Neural Information Processing Systems (NeurIPS 2020)

---------------------------------------------------------------------------------------------------------------------------
Main Reference：

 J. Frecon, S. Salzo, and M. Pontil. Bilevel learning of the group lasso structure. NIPS  2018.