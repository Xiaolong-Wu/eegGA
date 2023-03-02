function featureClassification(path_data,n_code,n_group,fs,channelNo,meth_all,name_result,large_result,pca_show,center_show,hmm_show,C_range,colorbar_show,title_show,c_rateNaN,rOld_delect,svm_data,svm_type,svm_kernel,svm_param_more,cluster_K,cluster_distance,cluster_thr_replicates,cluster_thr_iter,knn_distance,test_alphaEst,test_tailEst,test_plotEst,LSTM_data,LSTM_step,LSTM_window,LSTM_testRate)
%%

axisBeautyRate=0.01; % slightly greater than 0, so that the ROC does not reconnect with the axis when ploting

path_result=[path_data name_result '\'];
if ~exist(path_result,'dir')
    mkdir(path_result);
end

path_result_temp=[path_result 'result.mat'];
if ~exist(path_result_temp,'file')
    load('featureSet.mat');
    
    disp(' ');
    disp('please reset the variate (struct): featureSet');
    disp('and then input [return] in the command window, click Enter');
    keyboard;
else
    load(path_result_temp);
end

if rOld_delect~=0
    featureSet.svm_result(rOld_delect)=[];
    featureSet.hmm_result(rOld_delect)=[];
    
    if large_result
        save(path_result_temp,'featureSet','-v7.3');
    else
        save(path_result_temp,'featureSet');
    end
end
%% pca
r_group_negative=featureSet.groupNo_negative;
r_group_positive=featureSet.groupNo_positive;

n_group_negative=length(r_group_negative);
n_group_positive=length(r_group_positive);

if pca_show || hmm_show
    [EEG_featureVector_negative,EEG_featureVector_positive]=process_featureClassificationVector(path_data,n_code,n_group,fs,channelNo,meth_all,featureSet,cell(n_group_negative,1),cell(n_group_positive,1));
    
    n_negative=size(EEG_featureVector_negative,1);
    n_positive=size(EEG_featureVector_positive,1);
    EEG_featureVector=[EEG_featureVector_negative;EEG_featureVector_positive];
else
    EEG_featureVector=[];
end

if pca_show
    [~,princ,eigenvalue]=princomp(EEG_featureVector);
    rate=sum(eigenvalue(1:3))/sum(eigenvalue);
    
    figure
    for r=1:n_negative
        
        hold on;
        plot3(princ(r,1),princ(r,2),princ(r,3),'Marker','.','MarkerEdgeColor','g','MarkerSize',5);
    end
    for r=n_negative+1:n_negative+n_positive
        
        hold on;
        plot3(princ(r,1),princ(r,2),princ(r,3),'Marker','.','MarkerEdgeColor','r','MarkerSize',5);
    end
    xlabel('P1');ylabel('P2');zlabel('P3');
    if title_show
        title({'weight ratio of eigenvalues in';['3D projection (PCA): ' num2str(100*rate) '%']});
    end
    grid on;
    view(20,50);
end
%% svm and hmm

n_svm_param_more=size(svm_param_more,1);
if svm_data==0 || ~n_svm_param_more
    n_svmGroup=1;
else
    n_svmGroup=n_svm_param_more;
end

svm_param=cell(n_svmGroup,1);
for r=1:n_svmGroup
    
    if svm_data==0
        svm_param{r,1}='no svm';
    elseif ~n_svm_param_more
        svm_param{r,1}=['-s ',num2str(svm_type),' -t ',num2str(svm_kernel)];
    else
        svm_param{r,1}=['-s ',num2str(svm_type),' -t ',num2str(svm_kernel),' ',svm_param_more{r,1}];
    end
end

if ~isfield(featureSet,'svm_result')
    svm_result=leaveOneOut_svm(path_data,n_code,n_group,fs,channelNo,meth_all,featureSet,svm_param);
    featureSet.svm_result=svm_result;
    
    hmm_result=leaveOneIn_hmm(path_data,n_code,n_group,fs,channelNo,meth_all,featureSet,svm_param,cluster_K,cluster_distance,cluster_thr_replicates,cluster_thr_iter,knn_distance);
    featureSet.hmm_result=hmm_result;
    
    if large_result
        save(path_result_temp,'featureSet','-v7.3');
    else
        save(path_result_temp,'featureSet');
    end
else
    n_svmGroup_already=length(featureSet.svm_result);
    svm_param_pick=ones(n_svmGroup,1);
    for r1=1:n_svmGroup
        for r2=1:n_svmGroup_already
            
            if strcmp(svm_param{r1,1},featureSet.svm_result(r2).svm_param)
                svm_param_pick(r1,1)=0;
            end
        end
    end
    
    n_svmGroup_temp=sum(svm_param_pick);
    if n_svmGroup_temp~=0
        svm_param_temp=cell(n_svmGroup_temp,1);
        r0=0;
        for r=1:n_svmGroup
            
            if svm_param_pick(r,1)
                r0=r0+1;
                svm_param_temp{r0,1}=svm_param{r,1};
            end
        end
        svm_result_temp=leaveOneOut_svm(path_data,n_code,n_group,fs,channelNo,meth_all,featureSet,svm_param_temp);
        featureSet.svm_result=[featureSet.svm_result svm_result_temp];
        
        hmm_result_temp=leaveOneIn_hmm(path_data,n_code,n_group,fs,channelNo,meth_all,featureSet,svm_param_temp,cluster_K,cluster_distance,cluster_thr_replicates,cluster_thr_iter,knn_distance);
        featureSet.hmm_result=[featureSet.hmm_result hmm_result_temp];
        
        if large_result
            save(path_result_temp,'featureSet','-v7.3');
        else
            save(path_result_temp,'featureSet');
        end
    end
end
%% show svm & hmm

R_result=[];
svm_result=featureSet.svm_result;
n_svmGroup_all=length(svm_result);
for r1=1:n_svmGroup
    for r2=1:n_svmGroup_all
        
        if strcmp(svm_param{r1,1},svm_result(r2).svm_param)
            
            % svm
            [fpr,tpr,~,AUC]=perfcurve(svm_result(r2).targets,svm_result(r2).outputs,1);
            
            if AUC<0.5
                inv_temp=1;
            else
                inv_temp=0;
            end
            
            if featureSet.svm_result(r2).inv~=inv_temp
                featureSet.svm_result(r2).inv=inv_temp;
                
                if large_result
                    save(path_result_temp,'featureSet','-v7.3');
                else
                    save(path_result_temp,'featureSet');
                end
            end
            
            if center_show
                figure
                
                if featureSet.svm_result(r2).inv
                    plotroc(svm_result(r2).targets,1-svm_result(r2).outputs);
                else
                    plotroc(svm_result(r2).targets,svm_result(r2).outputs);
                end
                % plot(fpr,tpr);
                set(gca,'LineWidth',2);
                box on;
                xlim([0-1*axisBeautyRate 1+1*axisBeautyRate]);
                ylim([0-1*axisBeautyRate 1+1*axisBeautyRate]);
                xlabel('FPR','Fontweight','bold');
                ylabel('TPR','Fontweight','bold');
                title([]);
                
                if title_show
                    targets=svm_result(r2).targets;
                    outputs=svm_result(r2).outputs;
                    if featureSet.svm_result(r2).inv
                        targets=1-targets;
                    end
                    outputs_error=abs(targets-outputs);
                    
                    n_svm_temp=size(outputs_error,2);
                    r_targets_negative=[];
                    r_targets_positive=[];
                    for r3=1:n_svm_temp
                        
                        if targets(1,r3)==featureSet.svm_result(r2).inv
                            r_targets_negative=[r_targets_negative,r3];
                        else
                            r_targets_positive=[r_targets_positive,r3];
                        end
                    end
                    
                    specificity=mean(1-outputs_error(r_targets_negative));
                    sensitivity=mean(1-outputs_error(r_targets_positive));
                    
                    title({[svm_result(r2).svm_param];['[mean] Specificity (1-FPR): ' num2str(specificity) '; Sensitivity (TPR): ' num2str(sensitivity)]});
                end
                
                if featureSet.svm_result(r2).inv
                    AUC=1-AUC;
                    suptitle(['AUC = ' num2str(AUC) ' (inv)']);
                else
                    suptitle(['AUC = ' num2str(AUC)]);
                end
                
                % hmm
                leafOrder=process_featureClassificationClusterShow(path_data,n_code,channelNo,meth_all,featureSet,r2,1:cluster_K,knn_distance,C_range,colorbar_show,title_show,c_rateNaN);
                classificationShowHmmEst(title_show,featureSet,r2,cluster_K,test_alphaEst,test_tailEst,test_plotEst,leafOrder)
            end
            
            R_result=[R_result r2];
            break;
        end
    end
end
%% show time sequence and creat LSTM data

classificationShowTimeSeq(path_data,n_code,n_group,fs,channelNo,meth_all,name_result,featureSet,r_group_negative,r_group_positive,n_group_negative,n_group_positive,EEG_featureVector,R_result,hmm_show,title_show,cluster_K,LSTM_data,LSTM_step,LSTM_window,LSTM_testRate);
end