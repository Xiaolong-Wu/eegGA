function prosess_featureAnalysisShowAnova(EEG_featureGroup,meth,n_channel,r_channel,C_range,title_show,Title)

str={' morphology_o_p_e_n';' morphology_c_l_o_s_e'};

load(['scalp(' num2str(n_channel) ').mat']);
n_feature=size(EEG_featureGroup.all,1);
for r1=1:n_feature
    
    r0=0;
    x=[];
    Labels=[];
    figure
    for r2=r_channel
        
        switch meth
            case {'bandPower';'morphology';'CFC_bandPowerRate';'CFC_morphologyRate';'timeFeature';'morphTimeFeature'}
                r0=r0+1;
                x(:,r0)=EEG_featureGroup.all{r1,1}{1,r2};
                Labels{1,r0}=coordinate_name{r2,1};
            case {'correlation';'morphCorrelation'}
                C_range=[-1 1];
                for r3=r_channel
                    
                    if r3>r2
                        r0=r0+1;
                        x(:,r0)=EEG_featureGroup.all{r1,1}{r2,r3};
                        Labels{1,r0}=[coordinate_name{r2,1} '-' coordinate_name{r3,1}];
                    end
                end
            case {'mscohere';'morphMscohere';'PLV';'morphPLV'}
                C_range=[0 1];
                for r3=r_channel
                    
                    if r3>r2
                        r0=r0+1;
                        x(:,r0)=EEG_featureGroup.all{r1,1}{r2,r3};
                        Labels{1,r0}=[coordinate_name{r2,1} '-' coordinate_name{r3,1}];
                    end
                end
            case {'GC';'morphGC'}
                C_range=[0 1];
                for r3=r_channel
                    
                    if r3~=r2
                        r0=r0+1;
                        x(:,r0)=EEG_featureGroup.all{r1,1}{r2,r3};
                        Labels{1,r0}=[coordinate_name{r2,1} '-' coordinate_name{r3,1}];
                    end
                end
            otherwise
                C_range=[0 1];
                for r3=r_channel
                    
                    r0=r0+1;
                    x(:,r0)=EEG_featureGroup.all{r1,1}{r2,r3};
                    Labels{1,r0}=[coordinate_name{r2,1} '-' coordinate_name{r3,1}];
                end
        end
    end
    
    boxplot(x,'Labels',Labels,'colors','k','Notch','off','plotstyle','compact','boxstyle','outline','medianstyle','line');
    ylim(C_range);
    
    if title_show
        if n_feature==1
            title(Title);
        else
            title([Title str{r1,1}]);
        end
    end
end
end