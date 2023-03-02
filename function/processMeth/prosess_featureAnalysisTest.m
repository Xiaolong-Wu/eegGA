function EEG_featureComparison=prosess_featureAnalysisTest(meth,path_group_temp1,path_group_temp2,n_channel,test_alpha,test_tail)
%%

groupX=load(path_group_temp1);
groupY=load(path_group_temp2);
%%

n_feature=size(groupX.EEG_featureGroup.all,1);
for r1=1:n_feature
    for r2=1:n_channel
        
        switch meth
            case {'bandPower';'morphology';'CFC_bandPowerRate';'CFC_morphologyRate';'timeFeature';'morphTimeFeature'}
                x=groupX.EEG_featureGroup.all{r1,1}{1,r2};
                y=groupY.EEG_featureGroup.all{r1,1}{1,r2};
                
                if strcmp(test_tail,'ftest')
                    [p,tbl,stats]=anova1([x,y],{'1','2'},'off');
                    EEG_featureComparison.h{r1,1}(1,r2)=double(p<test_alpha);
                    EEG_featureComparison.p{r1,1}(1,r2)=p;
                    EEG_featureComparison.tbl{r1,1}{1,r2}=tbl;
                    EEG_featureComparison.stats{r1,1}{1,r2}=stats;
                else
                    [h,p,ci,stats]=ttest2(x,y,'Alpha',test_alpha,'Tail',test_tail,'Vartype','unequal');
                    EEG_featureComparison.h{r1,1}(1,r2)=h;
                    EEG_featureComparison.p{r1,1}(1,r2)=p;
                    EEG_featureComparison.ci{r1,1}{1,r2}=ci;
                    EEG_featureComparison.stats{r1,1}{1,r2}=stats;
                end
            otherwise
                for r3=1:n_channel
                    
                    x=groupX.EEG_featureGroup.all{r1,1}{r2,r3};
                    y=groupY.EEG_featureGroup.all{r1,1}{r2,r3};
                    
                    if strcmp(test_tail,'ftest')
                        [p,tbl,stats]=anova1([x,y],{'1','2'},'off');
                        EEG_featureComparison.h{r1,1}(r2,r3)=double(p<test_alpha);
                        EEG_featureComparison.p{r1,1}(r2,r3)=p;
                        EEG_featureComparison.tbl{r1,1}{r2,r3}=tbl;
                        EEG_featureComparison.stats{r1,1}{r2,r3}=stats;
                    else
                        [h,p,ci,stats]=ttest2(x,y,'Alpha',test_alpha,'Tail',test_tail,'Vartype','unequal');
                        EEG_featureComparison.h{r1,1}(r2,r3)=h;
                        EEG_featureComparison.p{r1,1}(r2,r3)=p;
                        EEG_featureComparison.ci{r1,1}{r2,r3}=ci;
                        EEG_featureComparison.stats{r1,1}{r2,r3}=stats;
                    end
                end
        end
    end
end
end