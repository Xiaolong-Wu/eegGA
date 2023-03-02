function classificationShowTimeSeq(path_data,n_code,n_group,fs,channelNo,meth_all,name_result,featureSet,r_group_negative,r_group_positive,n_group_negative,n_group_positive,EEG_featureVector,R_result,hmm_show,title_show,cluster_K,LSTM_data,LSTM_step,LSTM_window,LSTM_testRate)
%% show feature space

if hmm_show || LSTM_data
    T=featureSet.T;
    olr=featureSet.olr;
    T_window=featureSet.featureSelection(1).T_window;
    
    if hmm_show
        num_feature=size(EEG_featureVector,2);
        m_temp=mean(EEG_featureVector,1);
        d_temp=std(EEG_featureVector,0,1);
    end
    
    n_subject=cell(2,1);
    for r1=1:2
        
        if r1==1
            r_group=r_group_negative;
        elseif r1==2
            r_group=r_group_positive;
        end
        
        r0=0;
        for r2=r_group
            
            path_EEG=[path_data 'group\group_' num2code(r2,n_code) '\'];
            D=dir([path_EEG '*.mat']);
            
            r0=r0+1;
            n_subject{r1,1}(r0,1)=length(D);
        end
    end
    
    if LSTM_data
        r_group=union(r_group_negative,r_group_positive);
    else
        disp(' ');
        fprintf('negative group(s) No: ');
        for r=1:n_group_negative
            fprintf([' ' num2str(r_group_negative(r))]);
        end
        
        disp(' ');
        fprintf('positive group(s) No: ');
        for r=1:n_group_positive
            fprintf([' ' num2str(r_group_positive(r))]);
        end
        
        disp(' ');
        r_group=input('choose group(s):\n');
    end
    
    for r_result=R_result
        for r1=r_group
            
            path_EEG=[path_data 'group\group_' num2code(r1,n_code) '\'];
            D=dir([path_EEG '*.mat']);
            
            path_block=([path_data num2str(T) 's(' num2str(olr) ')' T_window '\block\group_' num2code(r1,n_code) '\']);
            
            if LSTM_data
                r_subject=1:length(D);
            else
                disp(' ');
                disp([num2str(length(D)) ' subject(s) in group_' num2code(r1,n_code)]);
                r_subject=input('choose subject(s):\n');
            end
            
            path_LSTM=([path_data name_result '\group_' num2code(r1,n_code) '\']);
            if ~exist(path_LSTM,'dir')
                mkdir(path_LSTM);
            end
            
            if ismember(r1,r_group_negative);
                r_temp1=1;
                r_temp2=find(r_group_negative==r1);
            end
            if ismember(r1,r_group_positive);
                r_temp1=2;
                r_temp2=find(r_group_positive==r1);
            end
            
            for r2=r_subject
                
                load([path_block D(r2).name]);
                
                r0=0;
                n_segment=[];
                for r3=1:size(block,1)
                    r0=r0+1;
                    n_segment(r0,1)=size(block{r3,1},2);
                end
                
                emission_label=featureSet.hmm_result(r_result).emission_label{r_temp1,1}{r_temp2,r2};
                predict_label=featureSet.hmm_result(r_result).predict_label{r_temp1,1}{r_temp2,r2};
                if featureSet.svm_result(r_result).inv
                    predict_label=1-predict_label;
                end
                
                r_subject_negative_temp=cell(n_group_negative,1);
                r_subject_positive_temp=cell(n_group_positive,1);
                for r3=1:n_group_negative
                    
                    if r_temp1==1 && r3==r_temp2
                        r_subject_negative_temp{r3,1}=r2;
                    else
                        r_subject_negative_temp{r3,1}=0;
                    end
                end
                for r3=1:n_group_positive
                    
                    if r_temp1==2 && r3==r_temp2
                        r_subject_positive_temp{r3,1}=r2;
                    else
                        r_subject_positive_temp{r3,1}=0;
                    end
                end
                
                if hmm_show
                    [EEG_featureVector_negative_temp,EEG_featureVector_positive_temp]=process_featureClassificationVector(path_data,n_code,n_group,fs,channelNo,meth_all,featureSet,r_subject_negative_temp,r_subject_positive_temp);
                    EEG_featureVector_temp=[EEG_featureVector_negative_temp;EEG_featureVector_positive_temp];
                end
                
                if r_result==R_result(1)
                    path_LSTM_temp=[path_LSTM D(r2).name];
                    if exist(path_LSTM_temp,'file')
                        disp([path_LSTM_temp ' exist, skip.']);
                    else
                        
                        if ~hmm_show
                            [EEG_featureVector_negative_temp,EEG_featureVector_positive_temp]=process_featureClassificationVector(path_data,n_code,n_group,fs,channelNo,meth_all,featureSet,r_subject_negative_temp,r_subject_positive_temp);
                            EEG_featureVector_temp=[EEG_featureVector_negative_temp;EEG_featureVector_positive_temp];
                        end
                        first=1;
                        data=cell(r0,1);
                        label=zeros(r0,1);
                        for r3=1:r0
                            last=sum(n_segment(1:r3));
                            
                            data{r3,1}=EEG_featureVector_temp(first:last,:);
                            label(r3,1)=r_temp1-1;
                            first=last+1;
                        end
                        
                        save(path_LSTM_temp,'data','label');
                        disp([path_LSTM_temp ' have been done.']);
                    end
                end
                
                if hmm_show
                    for r3=1:num_feature
                        
                        EEG_featureVector_temp(:,r3)=(EEG_featureVector_temp(:,r3)-m_temp(r3))/d_temp(r3);
                    end
                    EEG_featureVector_temp(isnan(EEG_featureVector_temp))=0;
                    
                    figure
                    subplot(7,1,1:5);
                    imagesc(EEG_featureVector_temp');
                    if r0>1
                        for r3=1:r0-1
                            
                            t_temp=sum(n_segment(1:r3));
                            hold on;
                            plot([t_temp+0.5 t_temp+0.5],[0.5 0.5+num_feature],'w');
                        end
                    end
                    set(gca,'Visible','off');
                    caxis([-3,3]);
                    
                    subplot(7,1,6);
                    imagesc([emission_label,emission_label]');
                    set(gca,'Visible','off');
                    caxis([1,cluster_K]);
                    
                    subplot(7,1,7);
                    imagesc([predict_label,predict_label]');
                    
                    n_temp_diff=ceil(size(n_segment,1)/6);
                    n_segment_t=T+(1-olr)*T*(n_segment-1);
                    n_segment_nc=cumsum(n_segment);
                    n_segment_tc=cumsum(n_segment_t);
                    
                    n_temp=fliplr(size(n_segment,1):-n_temp_diff:1);
                    set(gca,'XTick',[1;n_segment_nc(n_temp)],'XTickLabel',{0;n_segment_tc(n_temp)});
                    set(gca,'YTick',[]);
                    box off;
                    xlabel('time (s)');
                    caxis([0,1]);
                    
                    if title_show
                        if r_temp1==1
                            str='negative';
                        elseif r_temp1==2
                            str='positive';
                        end
                        suptitle({['subject ' num2str(r2) ' in group ' num2str(r1)];['(' str ' group)']});
                    end
                end
            end
        end
    end
end
%% LSTM data

if LSTM_data
    disp(' ');
    for r1=r_group
        
        path_EEG=[path_data 'group\group_' num2code(r1,n_code) '\'];
        D=dir([path_EEG '*.mat']);
        
        path_LSTM=([path_data name_result '\group_' num2code(r1,n_code) '\']);
        
        path_LSTM_window=([path_data name_result '\' num2str(T) 's(' num2str(olr) ')LSTM(' num2str(LSTM_step) ',' num2str(LSTM_window) ')\group_' num2code(r1,n_code) '\']);
        if ~exist(path_LSTM_window,'dir')
            mkdir(path_LSTM_window);
        end
        
        for r2=1:length(D)
            
            path_LSTM_window_temp=[path_LSTM_window D(r2).name];
            if exist(path_LSTM_window_temp,'file')
                disp([path_LSTM_window_temp ' exist, skip.']);
            else
                data=[];
                label=[];
                path_LSTM_temp=[path_LSTM D(r2).name];
                load(path_LSTM_temp);
                
                n_segment=size(data,1);
                data_window=[];
                label_window=[];
                r0=0;
                for r3=1:n_segment
                    
                    data_temp=data{r3,1};
                    n_t=size(data_temp,1);
                    first=1;
                    for r4=1:n_t
                        
                        last=first+LSTM_window-1;
                        if last>n_t
                            break;
                        end
                        r0=r0+1;
                        data_window{r0,1}=data_temp(first:last,:);
                        label_window(r0,1)=label(r3,1);
                        
                        first=first+LSTM_step;
                    end
                end
                
                save(path_LSTM_window_temp,'data_window','label_window');
                disp([path_LSTM_window_temp ' have been done.']);
            end
        end
    end
    
    disp(' ');
    path_LSTM_data=([path_data name_result '\' num2str(T) 's(' num2str(olr) ')LSTM(' num2str(LSTM_step) ',' num2str(LSTM_window) ')\' num2str(T) 's(' num2str(olr) ')LSTM(' num2str(LSTM_step) ',' num2str(LSTM_window) ').mat']);
    if exist(path_LSTM_data,'file')
        disp([path_LSTM_data ' exist, skip.']);
    else
        r_split=0;
        r0_train=0;
        r0_test=0;
        train_data=[];
        train_label=[];
        test_data=[];
        test_label=[];
        for r1=r_group
            
            path_EEG=[path_data 'group\group_' num2code(r1,n_code) '\'];
            D=dir([path_EEG '*.mat']);
            
            path_LSTM_window=([path_data name_result '\' num2str(T) 's(' num2str(olr) ')LSTM(' num2str(LSTM_step) ',' num2str(LSTM_window) ')\group_' num2code(r1,n_code) '\']);
            
            for r2=1:length(D)
                
                data_window=[];
                label_window=[];
                path_LSTM_window_temp=[path_LSTM_window D(r2).name];
                load(path_LSTM_window_temp);
                
                n_segment=size(data_window,1);
                if n_segment>0
                    for r3=1:n_segment
                        
                        r_split_temp=floor(r_split);
                        r_split=r_split+LSTM_testRate;
                        if floor(r_split)>r_split_temp
                            r0_test=r0_test+1;
                            test_data{r0_test,1}=data_window{r3,1};
                            test_label(r0_test,1)=label_window(r3,1);
                        else
                            r0_train=r0_train+1;
                            train_data{r0_train,1}=data_window{r3,1};
                            train_label(r0_train,1)=label_window(r3,1);
                        end
                    end
                end
            end
        end
        
        save(path_LSTM_data,'train_data','train_label','test_data','test_label');
        disp([path_LSTM_data ' have been done.']);
    end
end
end