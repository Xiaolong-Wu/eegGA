%%

disp(' ');disp('setup: analyse features');disp('<==============================>');
%% feature analysis

% size(group4analysis,1)==1, one group analysis
% size(group4analysis,1)==2, two group comparison
% group4analysis{x,1} the original group/s gather in one new group
group4analysis={
    [1];
    [5]
    };

% hypothesis testing
test_alpha=0.02;
test_tail='both'; % 'both', 'right', 'left'; and 'ftest' if f-test (anova)
%% feature extraction

setup_featureExtraction;
%%

addpath(genpath(path_toolbox{1,1}));
code_all=featureAnalysis(path_data,n_code,channelNo,T,olr,T_window,Band,Scale,Shape,GC_alpha,meth,group4analysis,test_alpha,test_tail);
rmpath(genpath(path_toolbox{1,1}));