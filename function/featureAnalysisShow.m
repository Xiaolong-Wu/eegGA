function featureAnalysisShow(path_data,channelNo,T,olr,T_window,Band,Scale,Shape,GC_alpha,meth,group4analysis,test_alpha,test_tail,code_all,stats_kind,r_channel,stats_show,std_show,violin_show,anova_show,barweb_show,C_range,colorbar_show,title_show,c_rateNaN)

n_channel=sum(channelNo~=0);
[~,file_name]=process_featureExtraction(0,0,Band,Scale,Shape,GC_alpha,meth);
%%

n_analysis=size(group4analysis,1);
for r1=1:n_analysis
    
    path_group_temp=([path_data num2str(T) 's(' num2str(olr) ')' T_window '\' file_name '\group' code_all{r1,1} '.mat']);
    load(path_group_temp);
    switch stats_kind
        case 'median'
            EEG_feature=EEG_featureGroup.median;
        case 'mean'
            EEG_feature=EEG_featureGroup.mean;
    end
    EEG_feature_buff=EEG_featureGroup.std;
    
    if stats_show
        Title=strrep([stats_kind ': group' code_all{r1,1}],'_','-');
        process_featureShowEEGfeature(EEG_feature,r_channel,meth,C_range,colorbar_show,title_show,Title);
    end
    
    if std_show
        Title=strrep(['std: group' code_all{r1,1}],'_','-');
        process_featureShowEEGfeature(EEG_feature_buff,r_channel,meth,C_range,colorbar_show,title_show,Title);
    end
    
    if violin_show && ~isempty(r_channel)
        Title=strrep(['group' code_all{r1,1}],'_','-');
        prosess_featureAnalysisShowViolin(EEG_featureGroup,meth,n_channel,r_channel,C_range,title_show,Title);
    end
    
    if anova_show && ~isempty(r_channel)
        Title=strrep(['group' code_all{r1,1}],'_','-');
        prosess_featureAnalysisShowAnova(EEG_featureGroup,meth,n_channel,r_channel,C_range,title_show,Title);
    end
    if barweb_show && ~isempty(r_channel)
        Title=strrep(['group' code_all{r1,1}],'_','-');
        prosess_featureAnalysisShowBarweb(EEG_featureGroup,meth,n_channel,r_channel,C_range,title_show,Title);
    end
end

disp(' ');
path_analysis_temp=([path_data num2str(T) 's(' num2str(olr) ')' T_window '\' file_name '\analysis(group' code_all{1,1} ')(group' code_all{2,1} ')(' num2str(test_alpha) ')' test_tail '.mat']);
load(path_analysis_temp);
load(['scalp(' num2str(n_channel) ').mat']);

Title=strrep(['(group' code_all{1,1} ')(group' code_all{2,1} ')(' num2str(test_alpha) ')' test_tail],'_','-');

n_feature=size(EEG_featureComparison.h,1);
r_channel_test=cell(n_feature,1);
EEG_feature_h=cell(n_feature,1);
EEG_feature_h_mult=cell(n_feature,1);
for r1=1:n_feature
    
    disp('test H1 channels:');
    [n1,n2]=size(EEG_featureComparison.h{r1,1});
    if n1==1
        EEG_feature_h{r1,1}=nan(n1,n2);
        r0=0;
        r_channel_test{r1,1}=[];
        for r2=1:n_channel
            
            if EEG_featureComparison.h{r1,1}(1,r2)
                r0=r0+1;
                r_channel_test{r1,1}(r0)=r2;
                fprintf([coordinate_name{r2} ' ']);
            end
        end
    else
        EEG_feature_h{r1,1}=EEG_featureComparison.h{r1,1};
        r_channel_test{r1,1}=[];
        for r2=1:n_channel
            
            if size(meth,2)>4 && ~strcmp('CFC_',meth(1:4))
                EEG_feature_h{r1,1}(r2,r2)=0;
            end
            for r3=1:n_channel
                
                if EEG_feature_h{r1,1}(r2,r3)
                    fprintf([coordinate_name{r2} '-' coordinate_name{r3} ' ']);
                end
            end
        end
    end
    disp(' ');
end

if stats_show
    h=cell(n_feature,1);
    for r1=1:n_feature
        
        h{r1,1}=process_featureShowEEGfeature(EEG_feature_h,r_channel_test{r1,1},meth,[0 1],0,title_show,Title);
        for r2=1:length(h{r1,1})
            
            if r1~=r2
                close(h{r1,1}(r2,1));
            else
                figure(h{r1,1}(r2,1));
                colormap(hot);
                caxis([0,1]);
            end
        end
    end
    
    for r1=1:2
        
        path_group_temp=([path_data num2str(T) 's(' num2str(olr) ')' T_window '\' file_name '\group' code_all{r1,1} '.mat']);
        load(path_group_temp);
        switch stats_kind
            case 'median'
                EEG_feature=EEG_featureGroup.median;
            case 'mean'
                EEG_feature=EEG_featureGroup.mean;
        end
        
        for r2=1:n_feature
            EEG_feature_h_mult{r2,1}=EEG_feature{r2,1};
            if n1==1
                EEG_feature_h_mult{r2,1}(EEG_featureComparison.h{r2,1}==0)=C_range(1)-(C_range(2)-C_range(1));
            else
                EEG_feature_h_mult{r2,1}(EEG_feature_h{r2,1}==0)=nan;
            end
        end
        
        Title_h_mult=strrep([stats_kind ': group' code_all{r1,1}],'_','-');
        h=process_featureShowEEGfeature(EEG_feature_h_mult,r_channel,meth,C_range,colorbar_show,title_show,Title_h_mult);
        for r2=1:length(h)
            
            figure(h(r2,1));
            colormap_temp=colormap;
            colormap_temp(1,:)=c_rateNaN*ones(1,3);
            colormap(colormap_temp);
        end
    end
end
end