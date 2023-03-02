%%

disp(' ');disp('setup: extract features');disp('<==============================>');
%% feature extraction

T=0.4; % block length, unit: second
olr=0.75; % overlap rate of signal segments

% T_window, kind of window function
% when select rectangle window: T_window='';
% or: T_window='hamming(L)', 'blackman(L)', chebwin(L,50), etc.;
T_window='hamming(L)';

% Hz
% frequency band (each row for one band), unit: Hz
% Scale
% time span (each row for one scale), unit: millisecond
% somtimes, Scale(1,2) is timeFeature No.
% Scale(3,1) is decomposition method and Scale(3:end,2) is the order No. of decomposition
% Shape
% kind of structural element's shape
% GC_alpha
% Granger causality alpha of F-test in Granger causality

% recommend
% Hz: 1    4   8   13 30 inf
% ms: 1000 250 125 77 33 0
Band=[0,8];
Scale=[0,250];
Shape='flat';
GC_alpha=0.01;
%% basic info

setup_basicInfo;
%%

meth=meth_all{input('\nfeature extraction method ===> '),1};

addpath(genpath(path_toolbox{1,1}));
addpath(genpath(path_toolbox{2,1}));
featureExtraction(path_data,n_code,n_group,fs,channelNo,T,olr,T_window,Band,Scale,Shape,GC_alpha,meth);
rmpath(genpath(path_toolbox{1,1}));
rmpath(genpath(path_toolbox{2,1}));