function leafOrder=process_featureClassificationClusterShow(path_data,n_code,channelNo,meth_all,featureSet,r_result,r_center,knn_distance,C_range,colorbar_show,title_show,c_rateNaN)

n_channel=sum(channelNo~=0);
%%

T=featureSet.T;
olr=featureSet.olr;

group4analysis={
    featureSet.groupNo_negative;
    featureSet.groupNo_positive;
    };
%%

cluster_C=featureSet.hmm_result(r_result).cluster_C;
tree_C=linkage(cluster_C(r_center,:),'average');
leafOrder=optimalleaforder(tree_C,pdist(cluster_C(r_center,:),knn_distance));

figure
dendrogram(tree_C,'Reorder',leafOrder);
set(gca,'YTick',[]);
box on;

for r1=r_center
    
    center=cluster_C(r1,:);
    r_center_first=1;
    for r2=1:length(featureSet.featureSelection)
        
        T_window=featureSet.featureSelection(r2).T_window;
        meth=meth_all{featureSet.featureSelection(r2).methNo,1};
        Band=featureSet.featureSelection(r2).band;
        Scale=featureSet.featureSelection(r2).scale;
        Shape=featureSet.featureSelection(r2).shape;
        GC_alpha=featureSet.featureSelection(r2).gc_alpha;
        [~,file_name]=process_featureExtraction(0,0,Band,Scale,Shape,GC_alpha,meth);
        
        r_channel=featureSet.featureSelection(r2).r_channel;
        test_alpha=featureSet.featureSelection(r2).test_alpha;
        test_tail=featureSet.featureSelection(r2).test_tail;
        
        code_all=featureAnalysis(path_data,n_code,channelNo,T,olr,T_window,Band,Scale,Shape,GC_alpha,meth,group4analysis,test_alpha,test_tail);
        path_analysis_temp=([path_data num2str(T) 's(' num2str(olr) ')' T_window '\' file_name '\analysis(group' code_all{1,1} ')(group' code_all{2,1} ')(' num2str(test_alpha) ')' test_tail '.mat']);
        load(path_analysis_temp);
        
        n_feature=size(EEG_featureComparison.h,1);
        if isempty(r_channel)
            r_channel_all=cell(n_feature,1);
            for r3=1:n_feature
                
                r0=0;
                r_channel_temp=[];
                for r4=1:n_channel
                    
                    if ismember(1,EEG_featureComparison.h{r3,1}(:,r4))
                        r0=r0+1;
                        r_channel_temp(1,r0)=r4;
                    end
                end
                r_channel_all{r3,1}=r_channel_temp;
            end
            
            r_channel=r_channel_all{1,1};
            if n_feature>1
                for r3=2:n_feature
                    
                    r_channel=sort(intersect(r_channel,r_channel_all{r3,1}));
                end
            end
            
            switch meth
                case {'bandPower';'morphology';'CFC_bandPowerRate';'CFC_morphologyRate';'timeFeature';'morphTimeFeature'}
                    
                otherwise
                    r_channel=1:n_channel;
            end
        end
        
        [n_dim,n_channel_temp]=size(r_channel);
        EEG_feature_center=cell(n_feature,1);
        for r3=1:n_feature
            
            switch meth
                case {'bandPower';'morphology';'CFC_bandPowerRate';'CFC_morphologyRate';'timeFeature';'morphTimeFeature'}
                    r_center_last=r_center_first+n_channel_temp-1;
                otherwise
                    if n_dim==1
                        r_center_last=r_center_first+n_channel_temp^2-1;
                    else
                        r_center_last=r_center_first+n_channel_temp-1;
                    end
            end
            
            center_temp=center(r_center_first:r_center_last);
            r_center_first=r_center_last+1;
            
            [n4,n5]=size(EEG_featureComparison.h{r3,1});
            
            r0=1;
            center_temp_reshape=zeros(n4,n5);
            if n_dim==1
                for r4=1:n4
                    for r5=1:n5
                        
                        if (n4==1 || ismember(r4,r_channel)) && ismember(r5,r_channel)
                            center_temp_reshape(r4,r5)=center_temp(1,r0);
                            r0=r0+1;
                        elseif n4==1
                            center_temp_reshape(r4,r5)=C_range(1)-(C_range(2)-C_range(1));
                        else
                            center_temp_reshape(r4,r5)=0;
                        end
                    end
                end
            else
                for r4=1:n_channel_temp
                    
                    center_temp_reshape(r_channel(1,r0),r_channel(2,r0))=center_temp(1,r0);
                    r0=r0+1;
                end
            end
            
            EEG_feature_center{r3,1}=center_temp_reshape;
        end
        
        Title_center=strrep(['center No.' num2str(r1) ': (group' code_all{1,1} ')(group' code_all{2,1} ') featureSelection No.' num2str(r2)],'_','-');
        h=process_featureShowEEGfeature(EEG_feature_center,[],meth,C_range,colorbar_show,title_show,Title_center);
        for r3=1:length(h)
            
            figure(h(r3,1));
            colormap_temp=colormap;
            switch meth
                case {'bandPower';'morphology';'CFC_bandPowerRate';'CFC_morphologyRate';'timeFeature';'morphTimeFeature'}
                    colormap_temp(1,:)=c_rateNaN*ones(1,3);
                otherwise
                    colormap_temp(1+floor(size(colormap_temp,1)/2),:)=c_rateNaN*ones(1,3);
            end
            colormap(colormap_temp);
        end
    end
end
end