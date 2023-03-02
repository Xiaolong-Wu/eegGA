function [EEG_featureVector_negative,EEG_featureVector_positive]=process_featureClassificationVector(path_data,n_code,n_group,fs,channelNo,meth_all,featureSet,r_subject_negative,r_subject_positive)

n_channel=sum(channelNo~=0);
%%

T=featureSet.T;
olr=featureSet.olr;

group4analysis={
    featureSet.groupNo_negative;
    featureSet.groupNo_positive;
    };
%%

r_group_negative=sort(group4analysis{1,1});
r_group_positive=sort(group4analysis{2,1});

flag_negative=0;
flag_positive=0;
for r2=1:length(r_group_negative)
    
    if isempty(r_subject_negative{r2,1}) || sum(r_subject_negative{r2,1})~=0
        flag_negative=1;
        break;
    end
end
for r2=1:length(r_group_positive)
    
    if isempty(r_subject_positive{r2,1}) || sum(r_subject_positive{r2,1})~=0
        flag_positive=1;
        break;
    end
end

EEG_featureVector_negative=[];
EEG_featureVector_positive=[];
for r1=1:length(featureSet.featureSelection)
    
    T_window=featureSet.featureSelection(r1).T_window;
    meth=meth_all{featureSet.featureSelection(r1).methNo,1};
    Band=featureSet.featureSelection(r1).band;
    Scale=featureSet.featureSelection(r1).scale;
    Shape=featureSet.featureSelection(r1).shape;
    GC_alpha=featureSet.featureSelection(r1).gc_alpha;
    featureExtraction(path_data,n_code,n_group,fs,channelNo,T,olr,T_window,Band,Scale,Shape,GC_alpha,meth);
    [~,file_name]=process_featureExtraction(0,0,Band,Scale,Shape,GC_alpha,meth);
    
    r_channel=featureSet.featureSelection(r1).r_channel;
    test_alpha=featureSet.featureSelection(r1).test_alpha;
    test_tail=featureSet.featureSelection(r1).test_tail;
    
    code_all=featureAnalysis(path_data,n_code,channelNo,T,olr,T_window,Band,Scale,Shape,GC_alpha,meth,group4analysis,test_alpha,test_tail);
    path_analysis_temp=([path_data num2str(T) 's(' num2str(olr) ')' T_window '\' file_name '\analysis(group' code_all{1,1} ')(group' code_all{2,1} ')(' num2str(test_alpha) ')' test_tail '.mat']);
    load(path_analysis_temp);
    
    n_feature=size(EEG_featureComparison.h,1);
    if isempty(r_channel)
        r_channel_all=cell(n_feature,1);
        for r2=1:n_feature
            
            r0=0;
            r_channel_temp=[];
            for r3=1:n_channel
                
                if ismember(1,EEG_featureComparison.h{r2,1}(:,r3))
                    r0=r0+1;
                    r_channel_temp(1,r0)=r3;
                end
            end
            r_channel_all{r2,1}=r_channel_temp;
        end
        
        r_channel=r_channel_all{1,1};
        if n_feature>1
            for r2=2:n_feature
                
                r_channel=sort(intersect(r_channel,r_channel_all{r2,1}));
            end
        end
        
        switch meth
            case {'bandPower';'morphology';'CFC_bandPowerRate';'CFC_morphologyRate';'timeFeature';'morphTimeFeature'}
                EEG_featureComparison=[];
            otherwise
                r_channel=1:n_channel;
                switch meth
                    case {'correlation';'morphCorrelation';'mscohere';'morphMscohere';'PLV';'morphPLV';'GC';'morphGC'}
                        for r2=1:n_feature
                            for r3=1:n_channel
                                
                                EEG_featureComparison.h{r2,1}(r3,r3)=0;
                            end
                        end
                end
        end
    else
        EEG_featureComparison=[];
    end
    
    standardization=featureSet.featureSelection(r1).standardization;
    
    if flag_negative
        EEG_featureGroup_negative=prosess_featureAnalysisGather(path_data,n_code,T,olr,T_window,meth,file_name,r_group_negative,r_subject_negative,r_channel);
        EEG_featureVector_negative=[EEG_featureVector_negative,gatherReshape(EEG_featureGroup_negative,EEG_featureComparison,standardization)];
    end
    
    if flag_positive
        EEG_featureGroup_positive=prosess_featureAnalysisGather(path_data,n_code,T,olr,T_window,meth,file_name,r_group_positive,r_subject_positive,r_channel);
        EEG_featureVector_positive=[EEG_featureVector_positive,gatherReshape(EEG_featureGroup_positive,EEG_featureComparison,standardization)];
    end
end
end