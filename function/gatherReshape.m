function EEG_featureVector=gatherReshape(EEG_featureGroup,EEG_featureComparison,standardization)

n_feature=size(EEG_featureGroup.all,1);
EEG_featureVector_all=cell(n_feature,1);
for r1=1:n_feature
    
    EEG_featureVector_temp=[];
    for r2=1:size(EEG_featureGroup.all{r1,1},1);
        for r3=1:size(EEG_featureGroup.all{r1,1},2);
            
            if isempty(EEG_featureComparison)
                EEG_featureVector_temp=[EEG_featureVector_temp,EEG_featureGroup.all{r1,1}{r2,r3}];
            else
                EEG_featureVector_temp=[EEG_featureVector_temp,EEG_featureGroup.all{r1,1}{r2,r3}*EEG_featureComparison.h{r1,1}(r2,r3)];
            end
        end
    end
    
    if standardization
        m_temp=mean(EEG_featureVector_temp,2);
        d_temp=std(EEG_featureVector_temp,0,2);
        for r2=1:size(EEG_featureVector_temp,1)
            
            EEG_featureVector_temp(r2,:)=(EEG_featureVector_temp(r2,:)-m_temp(r2))/d_temp(r2);
        end
    end
    
    EEG_featureVector_all{r1,1}=EEG_featureVector_temp;
end

EEG_featureVector=[];
for r=1:n_feature
    
    EEG_featureVector=[EEG_featureVector EEG_featureVector_all{r,1}];
end
end