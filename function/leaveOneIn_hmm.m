function hmm_result=leaveOneIn_hmm(path_data,n_code,n_group,fs,channelNo,meth_all,featureSet,svm_param,cluster_K,cluster_distance,cluster_thr_replicates,cluster_thr_iter,knn_distance)
%%

r_group_negative=featureSet.groupNo_negative;
r_group_positive=featureSet.groupNo_positive;

n_group_negative=length(r_group_negative);
n_group_positive=length(r_group_positive);
%%

n_subject_negative=zeros(n_group_negative,1);
r_subject_negative=cell(n_group_negative,1);
r_subject0_negative=cell(n_group_negative,1);
r0=0;
for r=r_group_negative
    
    r0=r0+1;
    path_EEG=[path_data 'group\group_' num2code(r,n_code) '\'];
    D=dir([path_EEG '*.mat']);
    n_subject_negative(r0,1)=length(D);
    r_subject_negative{r0,1}=1:length(D);
    r_subject0_negative{r0,1}=0;
end

n_subject_positive=zeros(n_group_positive,1);
r_subject_positive=cell(n_group_positive,1);
r_subject0_positive=cell(n_group_positive,1);
r0=0;
for r=r_group_positive
    
    r0=r0+1;
    path_EEG=[path_data 'group\group_' num2code(r,n_code) '\'];
    D=dir([path_EEG '*.mat']);
    n_subject_positive(r0,1)=length(D);
    r_subject_positive{r0,1}=1:length(D);
    r_subject0_positive{r0,1}=0;
end
%%

r_subject={r_subject_negative;r_subject_positive};
r_subject_train=r_subject;

[EEG_featureVector_negative_train,EEG_featureVector_positive_train]=process_featureClassificationVector(path_data,n_code,n_group,fs,channelNo,meth_all,featureSet,r_subject_train{1,1},r_subject_train{2,1});

EEG_featureVector_negative_train_label=addLabel(EEG_featureVector_negative_train,'negative');
EEG_featureVector_positive_train_label=addLabel(EEG_featureVector_positive_train,'positive');

train_data=[EEG_featureVector_negative_train;EEG_featureVector_positive_train];
train_label=[EEG_featureVector_negative_train_label;EEG_featureVector_positive_train_label];

disp(' ');disp('Kmeans');disp('<==============================>');
opts=statset('Display','final','MaxIter',cluster_thr_iter);
[~,cluster_C]=kmeans(train_data,cluster_K,'Distance',cluster_distance,'Replicates',cluster_thr_replicates,'Options',opts);

n_group_temp=[n_group_negative;n_group_positive];
n_subject={n_subject_negative;n_subject_positive};

n_svm_param=size(svm_param,1);
for r1=1:n_svm_param
    
    hmm_result(r1).svm_param=svm_param{r1,1};
    hmm_result(r1).cluster_C=cluster_C;
    for r2=1:2
        for r3=1:n_group_temp(r2,1)
            for r4=1:n_subject{r2,1}(r3,1)
                
                r_subject0={r_subject0_negative;r_subject0_positive};
                r_subject0{r2,1}{r3,1}=r4;
                r_subject_test=r_subject0;
                
                [EEG_featureVector_negative_test,EEG_featureVector_positive_test]=process_featureClassificationVector(path_data,n_code,n_group,fs,channelNo,meth_all,featureSet,r_subject_test{1,1},r_subject_test{2,1});
                
                EEG_featureVector_negative_test_label=addLabel(EEG_featureVector_negative_test,'negative');
                EEG_featureVector_positive_test_label=addLabel(EEG_featureVector_positive_test,'positive');
                
                test_data=[EEG_featureVector_negative_test;EEG_featureVector_positive_test];
                test_label=[EEG_featureVector_negative_test_label;EEG_featureVector_positive_test_label];
                %%
                
                disp(' ');disp('HMM');disp('<==============================>');
                for r5=1:length(featureSet.svm_result)
                    
                    if strcmp(hmm_result(r1).svm_param,featureSet.svm_result(r5).svm_param)
                        break;
                    end
                end
                
                if strcmp(hmm_result(r1).svm_param,'no svm')
                    r_classifier=[];
                    nTree=[];
                    hiddenLayerSize=[];
                    trainFcn=[];
                    splitRate=[];
                    nosvm_model=[];
                    featurePlot=[];
                    lineWidth=[];
                    yLimError=[];
                    yLimMargin=[];
                    yLimImportance=[];
                    
                    setup_nosvmClassifier;
                    nosvm_model=featureSet.svm_result(r5).svm_model{r2,1}{r3,r4};
                    [predict_label,~]=nosvmClassifier(r_classifier,2,[],[],test_data,test_label,nTree,hiddenLayerSize,trainFcn,splitRate,nosvm_model,featurePlot,lineWidth,yLimError,yLimMargin,yLimImportance);
                else
                    svm_model=featureSet.svm_result(r5).svm_model{r2,1}{r3,r4};
                    [predict_label,~,~]=svmpredict(test_label,test_data,svm_model);
                end
                
                [cluster_IDX,cluster_D]=knnsearch(cluster_C,test_data,'K',cluster_K,'Distance',knn_distance);
                emission_label=cluster_IDX(:,1);
                emission_label_p=1-(cluster_D(:,1)./sum(cluster_D,2));
                
                PSEUDOE=zeros(2,cluster_K);
                PSEUDOTR=zeros(2,2);
                [estTR,estE]=hmmestimate(emission_label',predict_label'+1,'Pseudoemissions',PSEUDOE,'Pseudotransitions',PSEUDOTR);
                
                hmm_result(r1).test_label{r2,1}{r3,r4}=test_label;
                hmm_result(r1).predict_label{r2,1}{r3,r4}=predict_label;
                hmm_result(r1).emission_label{r2,1}{r3,r4}=emission_label;
                hmm_result(r1).emission_label_p{r2,1}{r3,r4}=emission_label_p;
                hmm_result(r1).estTR{r2,1}{r3,r4}=estTR;
                hmm_result(r1).estE{r2,1}{r3,r4}=estE;
            end
        end
    end
end
end
%%

function Label=addLabel(featureVector,type)

if isempty(featureVector)
    Label=[];
else
    switch type
        case 'negative'
            Label=zeros(size(featureVector,1),1);
        case 'positive'
            Label=ones(size(featureVector,1),1);
    end
end
end