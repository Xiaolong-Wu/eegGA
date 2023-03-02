function code_all=featureAnalysis(path_data,n_code,channelNo,T,olr,T_window,Band,Scale,Shape,GC_alpha,meth,group4analysis,test_alpha,test_tail)

n_channel=sum(channelNo~=0);
[~,file_name]=process_featureExtraction(0,0,Band,Scale,Shape,GC_alpha,meth);
%%

n_analysis=size(group4analysis,1);
code_all=cell(n_analysis,1);
for r1=1:n_analysis
    
    r_group=sort(group4analysis{r1,1});
    r0=0;
    n_subject=[];
    for r2=r_group
        
        r0=r0+1;
        path_EEG=[path_data 'group\group_' num2code(r2,n_code) '\'];
        D=dir([path_EEG '*.mat']);
        
        n_subject(r0,1)=length(D);
    end
    
    if sum(abs(diff(n_subject)))~=0
        disp('the number of subjects in each group of negative/positive data in the hypothesis test should be the same.');
        disp('which is not yet and will affect subsequent analysis, such as HMM.');
        keyboard;
    end
    
    code_all_temp=[];
    for r2=r_group
        
        code_all_temp=[code_all_temp '_' num2code(r2,n_code)];
    end
    code_all{r1,1}=code_all_temp;
    
    disp(' ');
    disp(['feature gather of group' code_all{r1,1} ':']);
    path_group_temp=([path_data num2str(T) 's(' num2str(olr) ')' T_window '\' file_name '\group' code_all{r1,1} '.mat']);
    if exist(path_group_temp,'file')
        disp([path_group_temp ' exist, skip.']);
    else
        EEG_featureGroup=prosess_featureAnalysisGather(path_data,n_code,T,olr,T_window,meth,file_name,r_group,cell(length(r_group),1),1:n_channel);
        save(path_group_temp,'EEG_featureGroup');
        disp([path_group_temp ' have been done.']);
    end
end
%%

disp(' ');
disp('feature analysis of all groups:');
path_analysis_temp=([path_data num2str(T) 's(' num2str(olr) ')' T_window '\' file_name '\analysis(group' code_all{1,1} ')(group' code_all{2,1} ')(' num2str(test_alpha) ')' test_tail '.mat']);
if exist(path_analysis_temp,'file')
    disp([path_analysis_temp ' exist, skip.']);
else
    path_group_temp1=([path_data num2str(T) 's(' num2str(olr) ')' T_window '\' file_name '\group' code_all{1,1} '.mat']);
    path_group_temp2=([path_data num2str(T) 's(' num2str(olr) ')' T_window '\' file_name '\group' code_all{2,1} '.mat']);
    
    EEG_featureComparison=prosess_featureAnalysisTest(meth,path_group_temp1,path_group_temp2,n_channel,test_alpha,test_tail);
    save(path_analysis_temp,'EEG_featureComparison');
    disp([path_analysis_temp ' have been done.']);
end
end