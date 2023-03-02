tic
close all;clear all;clc;
%%

disp(' ');disp('show features');disp('<==============================>');
%% feature show

r_group=[4 8]; % group No. for show
r_subject=[1]; % subject No. for show

% block No. for show
% r_block{1,:}, a single No. of block
% r_block{x,2}, a series No. of segment
for r=1
    
    r_block{r,1}=r;
    r_block{r,2}=2;
end

r_channel=[5]; % channel No. for show

kindShow=[1 3]; % kindShow: 1, cwt; 2, filter; 3, corr or scalp

fShow=4:0.1:30; % frequency range and its resolution for show
w='morl'; % wavelet type
Voltage_range=[-50 50]; % time-domain voltage range of EEG for show
Voltage_range_f=[0 1]; % frequency-domain voltage range of EEG for show
Frequency_range=[0 50]; % frequency range of EEG for show

C_range=[0 9]; % feature value range of EEG for show

colorbar_show=1; % whether show colorbar in each figure
title_show=1; % whether show title in each figure
%% feature extraction

setup_featureExtraction;
%%

addpath(genpath(path_toolbox{1,1}));
featureShow(path_data,n_code,n_group,fs,channelNo,T,olr,T_window,Band,Scale,Shape,GC_alpha,meth,r_group,r_subject,r_block,r_channel,kindShow,fShow,w,Voltage_range,Voltage_range_f,Frequency_range,C_range,colorbar_show,title_show);
rmpath(genpath(path_toolbox{1,1}));
toc