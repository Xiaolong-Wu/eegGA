tic
% close all;clear all;clc;
%%

disp(' ');disp('classify feature');disp('<==============================>');
%% feature classification

% name_result='1s(0.8)orig(1,3)ch(01)'; % creat a new one based on these parameters, if the result is not exist
large_result=1;

pca_show=0;
center_show=0;
hmm_show=0;

C_range=[-3 3];

colorbar_show=0;
title_show=1;
c_rateNaN=0.8;
%% SVM

rOld_delect=0; % delect the No. rOld_delect result, and rOld_delect=0 when no delect
svm_data=0;
% -s svm_type, set type of SVM:
% 0 -- C-SVC (default)
% 1 -- nu-SVC
% 2 -- one-class SVM
% 3 -- epsilon-SVR
% 4 -- nu-SVR
svm_type=0;

% -t kernel_type, set type of kernel function:
% 0 -- linear: u'*v
% 1 -- polynomial: (gamma*u'*v + coef0)^degree
% 2 -- radial basis function: exp(-gamma*|u-v|^2) (default)
% 3 -- sigmoid: tanh(gamma*u'*v + coef0)
svm_kernel=2;

% -d degree: set degree in kernel function (default 3)
% -g gamma: set gamma in kernel function (default 1/num_features)
% -r coef0: set coef0 in kernel function (default 0)
% -c cost: set the parameter C of C-SVC, epsilon-SVR, and nu-SVR (default 1)
% -n nu: set the parameter nu of nu-SVC, one-class SVM, and nu-SVR (default 0.5)
% -p epsilon: set the epsilon in loss function of epsilon-SVR (default 0.1)
% -m cachesize: set cache memory size in MB (default 100)
% -e epsilon: set tolerance of termination criterion (default 0.001)
% -h shrinking: whether to use the shrinking heuristics, 0 or 1 (default 1)
% -b probability_estimates: whether to train a SVC or SVR model for probability estimates, 0 or 1 (default 0)
% -wi weight: set the parameter C of class i to weight*C, for C-SVC (default 1)

% eg:
% svm_param_more={
%     '-c 1'
%     '-c 1 -g 1'
%     };
% which can be empty or several rows

% suggest using 'for' loop to achieve assignment of svm_para_more, eg:
% r0=0;
% for r1=-4:1:1
%     for r2=-4:1:1
%         
%         c_temp=2^r1;
%         g_temp=2^r2;
%         
%         r0=r0+1;
%         svm_param_more{r0,1}=['-c ',num2str(c_temp),' -g ', num2str(g_temp)];
%     end
% end
svm_param_more={};
%% Hidden Markov Model

cluster_K=26;
cluster_distance='sqeuclidean'; % see function kmeans
cluster_thr_replicates=5;
cluster_thr_iter=100;
knn_distance='seuclidean'; % see function knnsearch

test_alphaEst=0.01;
test_tailEst='both'; % 'both', 'right', 'left'; and 'ftest' if f-test (anova)
test_plotEst='bar'; % 'bar' or 'box'
%% LSTM data

LSTM_data=1;
LSTM_step=2; % 1 % the sampling step size in LSTM data, an integer not less than 1
LSTM_window=cluster_K; % 1 % the window size in LSTM data, an integer not less than LSTM_step
LSTM_testRate=0.2; % The rate of test samples to total samples
%% basic info

setup_basicInfo;
%%

addpath(genpath(path_toolbox{1,1}));
addpath(genpath(path_toolbox{2,1}));
featureClassification(path_data,n_code,n_group,fs,channelNo,meth_all,name_result,large_result,pca_show,center_show,hmm_show,C_range,colorbar_show,title_show,c_rateNaN,rOld_delect,svm_data,svm_type,svm_kernel,svm_param_more,cluster_K,cluster_distance,cluster_thr_replicates,cluster_thr_iter,knn_distance,test_alphaEst,test_tailEst,test_plotEst,LSTM_data,LSTM_step,LSTM_window,LSTM_testRate)
rmpath(genpath(path_toolbox{1,1}));
rmpath(genpath(path_toolbox{2,1}));
toc