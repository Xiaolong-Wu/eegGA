function svm_result=leaveOneOut_svm(path_data,n_code,n_group,fs,channelNo,meth_all,featureSet,svm_param)
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

n_group_temp=[n_group_negative;n_group_positive];
n_subject={n_subject_negative;n_subject_positive};

n_svm_param=size(svm_param,1);
for r1=1:n_svm_param
    
    svm_result(r1).svm_param=svm_param{r1,1};
    
    r0=0;
    for r2=1:2
        for r3=1:n_group_temp(r2,1)
            for r4=1:n_subject{r2,1}(r3,1)
                
                r_subject={r_subject_negative;r_subject_positive};
                r_subject{r2,1}{r3,1}(r4)=[];
                r_subject_train=r_subject;
                
                [EEG_featureVector_negative_train,EEG_featureVector_positive_train]=process_featureClassificationVector(path_data,n_code,n_group,fs,channelNo,meth_all,featureSet,r_subject_train{1,1},r_subject_train{2,1});
                
                EEG_featureVector_negative_train_label=addLabel(EEG_featureVector_negative_train,'negative');
                EEG_featureVector_positive_train_label=addLabel(EEG_featureVector_positive_train,'positive');
                
                train_data=[EEG_featureVector_negative_train;EEG_featureVector_positive_train];
                train_label=[EEG_featureVector_negative_train_label;EEG_featureVector_positive_train_label];
                
                r_subject0={r_subject0_negative;r_subject0_positive};
                r_subject0{r2,1}{r3,1}=r4;
                r_subject_test=r_subject0;
                
                [EEG_featureVector_negative_test,EEG_featureVector_positive_test]=process_featureClassificationVector(path_data,n_code,n_group,fs,channelNo,meth_all,featureSet,r_subject_test{1,1},r_subject_test{2,1});
                
                EEG_featureVector_negative_test_label=addLabel(EEG_featureVector_negative_test,'negative');
                EEG_featureVector_positive_test_label=addLabel(EEG_featureVector_positive_test,'positive');
                
                test_data=[EEG_featureVector_negative_test;EEG_featureVector_positive_test];
                test_label=[EEG_featureVector_negative_test_label;EEG_featureVector_positive_test_label];
                %%
                
                r0=r0+1;
                n_test=size(test_data,1);
                if strcmp(svm_result(r1).svm_param,'no svm')
                    
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
                    disp(' ');disp('no SVM');disp('<==============================>');
                    [~,nosvm_model]=nosvmClassifier(r_classifier,1,train_data,train_label,[],[],nTree,hiddenLayerSize,trainFcn,splitRate,nosvm_model,featurePlot,lineWidth,yLimError,yLimMargin,yLimImportance);
                    svm_result(r1).svm_model{r2,1}{r3,r4}=nosvm_model;
                    [predict_label,~]=nosvmClassifier(r_classifier,2,[],[],test_data,test_label,nTree,hiddenLayerSize,trainFcn,splitRate,nosvm_model,featurePlot,lineWidth,yLimError,yLimMargin,yLimImportance);
                else
                    
                    disp(' ');disp('SVM');disp('<==============================>');
                    svm_model=svmtrain(train_label,train_data,svm_result(r1).svm_param);
                    [predict_label,~,~]=svmpredict(test_label,test_data,svm_model);
                    
                    svm_result(r1).svm_model{r2,1}{r3,r4}=svm_model;
                end
                %%
                
                rate_positive_precict=sum(predict_label)/n_test;
                
                % TP: ture positive
                % FP: false positive
                % FN: false negative
                % TN: ture negative
                % FPR=FP/(FP+TN): false positive rate (LOOCV: FPR only in negative subject, and =rate_positive_precict)
                % TPR=TP/(TP+FN): ture positive rate (LOOCV: TPR only in positive subject, and =rate_positive_precict)
                % however, rate_positive_precict just regarded as the score here
                
                if sum(test_label)==0
                    svm_result(r1).targets(r0)=0;
                elseif sum(test_label)==n_test
                    svm_result(r1).targets(r0)=1;
                else
                    disp(['there is a test sample (No. ' num2str(r0) ') not pure in leave one out method!']);
                    keyboard;
                end
                svm_result(r1).outputs(r0)=rate_positive_precict;
            end
        end
    end
    svm_result(r1).inv=0;
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