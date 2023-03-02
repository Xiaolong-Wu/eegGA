function EEG_featureGroup=prosess_featureAnalysisGather(path_data,n_code,T,olr,T_window,meth,file_name,r_group,r_subject,r_channel)
%%

[n_dim,n_channel]=size(r_channel);
r0=0;
r_group_index=0;
for r1=r_group
    
    r_group_index=r_group_index+1;
    if isempty(r_subject{r_group_index,1}) || sum(r_subject{r_group_index,1})~=0
        path_EEG=[path_data 'group\group_' num2code(r1,n_code) '\'];
        D=dir([path_EEG '*.mat']);
        
        path_block=([path_data num2str(T) 's(' num2str(olr) ')' T_window '\block\group_' num2code(r1,n_code) '\']);
        
        path_feature=([path_data num2str(T) 's(' num2str(olr) ')' T_window '\' file_name '\group_' num2code(r1,n_code) '\']);
        if isempty(r_subject{r_group_index,1})
            r_subject{r_group_index,1}=1:length(D);
        end
        
        for r2=r_subject{r_group_index,1}
            
            load([path_block D(r2).name]);
            load([path_feature D(r2).name]);
            for r3=1:size(block,1)
                for r4=1:size(block{r3,1},2)
                    
                    r0=r0+1;
                    EEG_feature=sample{r3,1}{1,r4};
                    n_feature=size(EEG_feature,1);
                    for r5=1:n_feature
                        for r6=1:n_channel
                            
                            switch meth
                                case {'bandPower';'morphology';'CFC_bandPowerRate';'CFC_morphologyRate';'timeFeature';'morphTimeFeature'}
                                    EEG_featureAll{r5,1}{1,r6}(r0,1)=EEG_feature{r5,1}(1,r_channel(1,r6));
                                otherwise
                                    if n_dim==1
                                        for r7=1:n_channel
                                            
                                            EEG_featureAll{r5,1}{r6,r7}(r0,1)=EEG_feature{r5,1}(r_channel(r6),r_channel(r7));
                                        end
                                    else
                                        EEG_featureAll{r5,1}{1,r6}(r0,1)=EEG_feature{r5,1}(r_channel(1,r6),r_channel(2,r6));
                                    end
                            end
                        end
                    end
                end
            end
        end
    end
end
%%

n_feature=size(EEG_featureAll,1);
for r1=1:n_feature
    for r2=1:n_channel
        
        switch meth
            case {'bandPower';'morphology';'CFC_bandPowerRate';'CFC_morphologyRate';'timeFeature';'morphTimeFeature'}
                EEG_featureAllMedian{r1,1}(1,r2)=median(EEG_featureAll{r1,1}{1,r2});
                EEG_featureAllMean{r1,1}(1,r2)=mean(EEG_featureAll{r1,1}{1,r2});
                EEG_featureAllStd{r1,1}(1,r2)=std(EEG_featureAll{r1,1}{1,r2},0,1);
            otherwise
                if n_dim==1
                    for r3=1:n_channel
                        
                        EEG_featureAllMedian{r1,1}(r2,r3)=median(EEG_featureAll{r1,1}{r2,r3});
                        EEG_featureAllMean{r1,1}(r2,r3)=mean(EEG_featureAll{r1,1}{r2,r3});
                        EEG_featureAllStd{r1,1}(r2,r3)=std(EEG_featureAll{r1,1}{r2,r3},0,1);
                    end
                else
                    EEG_featureAllMedian{r1,1}(1,r2)=median(EEG_featureAll{r1,1}{1,r2});
                    EEG_featureAllMean{r1,1}(1,r2)=mean(EEG_featureAll{r1,1}{1,r2});
                    EEG_featureAllStd{r1,1}(1,r2)=std(EEG_featureAll{r1,1}{1,r2},0,1);
                end
        end
    end
end

EEG_featureGroup.all=EEG_featureAll;
EEG_featureGroup.median=EEG_featureAllMedian;
EEG_featureGroup.mean=EEG_featureAllMean;
EEG_featureGroup.std=EEG_featureAllStd;
end