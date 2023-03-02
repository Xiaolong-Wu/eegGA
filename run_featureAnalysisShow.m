tic
close all;clear all;clc;
%%

disp(' ');disp('show feature analysis');disp('<==============================>');
%% feature analysis show

stats_kind='median'; % 'median', 'mean'
r_channel=[]; % channel No. for show, r_channel==[] if none

stats_show=1; % whether show stats
std_show=0; % whether show std
violin_show=0; % whether show violin
anova_show=1; % whether show anova
barweb_show=0; % whether show mean bargraph with std error bars

C_range=[0 5]; % feature value range of EEG for show

colorbar_show=0; % whether show colorbar in each figure
title_show=0; % whether show title in each figure
c_rateNaN=0.8;% default: 0.8, the color of feature value when ploting
%% feature analysis

setup_featureAnalysis;
%%

addpath(genpath(path_toolbox{1,1}));
featureAnalysisShow(path_data,channelNo,T,olr,T_window,Band,Scale,Shape,GC_alpha,meth,group4analysis,test_alpha,test_tail,code_all,stats_kind,r_channel,stats_show,std_show,violin_show,anova_show,barweb_show,C_range,colorbar_show,title_show,c_rateNaN);
rmpath(genpath(path_toolbox{1,1}));
toc