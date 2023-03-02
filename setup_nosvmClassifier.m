%%

disp(' ');disp('setup: no svm classifier');disp('<==============================>');
%% classifier

% 0: no classifier
% 1: TreeBagger
% 2: PatternNet
r_classifier=0;
%%

nTree=12;
%%
% Create a Pattern Recognition Network
hiddenLayerSize=[10];

% Scaled conjugate gradient backpropagation.
% 'trainlm' is usually fastest.
% 'trainbr' takes longer but may be better for challenging problems.
% 'trainscg' uses less memory. Suitable in low memory situations.
trainFcn='trainscg';

% split for validation
splitRate=0.2;
%%

featurePlot=1;

lineWidth=2;
yLimError=[0,0.4];
yLimMargin=[0,1];
yLimImportance=[-1,2];