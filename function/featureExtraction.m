function featureExtraction(path_data,n_code,n_group,fs,channelNo,T,olr,T_window,Band,Scale,Shape,GC_alpha,meth)

n_t=fix(T*fs);
n_olr=fix(olr*n_t);
fun_window=strrep(T_window,'L','n_t');
n_channel=sum(channelNo~=0);
%%

disp(' ');
for r1=1:n_group
    
    path_EEG=[path_data 'group\group_' num2code(r1,n_code) '\'];
    D=dir([path_EEG '*.mat']);
    
    path_block=([path_data num2str(T) 's(' num2str(olr) ')' T_window '\block\group_' num2code(r1,n_code) '\']);
    if ~exist(path_block,'dir')
        mkdir(path_block);
    end
    
    for r2=1:length(D)
        
        path_block_temp=[path_block D(r2).name];
        if exist(path_block_temp,'file')
            disp([path_block_temp ' exist, skip.']);
        else
            load([path_EEG D(r2).name]);
            
            n_EEG=size(EEG,1);
            block=cell(n_EEG,1);
            for r3=1:n_EEG
                
                EEG_temp=EEG{r3,1};
                n_t_temp=size(EEG_temp,2);
                EEG_tempExchange=zeros(n_channel,n_t_temp);
                for r4=1:size(EEG_temp,1)
                    
                    if channelNo(1,r4)~=0
                        EEG_tempExchange(channelNo(1,r4),:)=EEG_temp(r4,:);
                    end
                end
                
                first=1;
                for r4=1:n_t_temp
                    
                    last=first+n_t-1;
                    if last>n_t_temp
                        break;
                    end
                    eval_EEG_ori=EEG_tempExchange(:,first:last)';
                    eval_EEG_window=eval_EEG_ori;
                    if ~isempty(T_window)
                        for r5=1:n_channel
                            
                            eval(['eval_EEG_window(:,r5)=eval_EEG_ori(:,r5).*' fun_window ';']);
                        end
                    end
                    block{r3,1}{1,r4}=eval_EEG_window';
                    
                    first=last+1-n_olr;
                end
            end
            
            save(path_block_temp,'block');
            disp([path_block_temp ' have been done.']);
        end
    end
end
%%

if size(Scale,1)>2 && Scale(3,1)~=0
    
    Band_decom=[];
    meth_decom_temp=[];
    Nstd=[];
    NE=[];
    Times=[];
    Err=[];
    errPerL2=[];
    
    orderNo=Scale(3:end,2);
    orderNo_str=[];
    for r=1:size(orderNo,1)
        
        if r==1
            orderNo_str=num2str(orderNo(r,1));
        else
            orderNo_diff=diff(orderNo);
            if sum(abs(diff(orderNo_diff)))==0
                orderNo_str=[num2str(min(orderNo)) '+(' num2str(abs(orderNo_diff(1))) ')+' num2str(max(orderNo))];
            else
                orderNo_str=[orderNo_str '+' num2str(orderNo(r,1))];
            end
        end
    end
    
    setup_decomSignal;
    block_name_decom=['decom_' meth_decom_temp];
    block_name=['decom_' meth_decom_temp '(' orderNo_str ')'];
    path_decom=([path_data num2str(T) 's(' num2str(olr) ')' T_window '\' block_name_decom '\']);
    
    disp(' ');
    for r1=1:n_group
        
        path_EEG=[path_data 'group\group_' num2code(r1,n_code) '\'];
        D=dir([path_EEG '*.mat']);
        
        path_block_old=([path_data num2str(T) 's(' num2str(olr) ')' T_window '\block\group_' num2code(r1,n_code) '\']);
        path_block_decom=([path_data num2str(T) 's(' num2str(olr) ')' T_window '\' block_name_decom '\group_' num2code(r1,n_code) '\']);
        path_block=([path_data num2str(T) 's(' num2str(olr) ')' T_window '\' block_name '\group_' num2code(r1,n_code) '\']);
        
        if ~exist(path_block_decom,'dir')
            mkdir(path_block_decom);
        end
        
        for r2=1:length(D)
            
            path_block_temp=[path_block_decom D(r2).name];
            if exist(path_block_temp,'file')
                disp([path_block_temp ' exist, skip.']);
            else
                load([path_block_old D(r2).name]);
                
                n_block=size(block,1);
                block_all=cell(n_block,1);
                for r3=1:n_block
                    for r4=1:size(block{r3,1},2)
                        
                        s=block{r3,1}{1,r4};
                        for r5=1:n_channel
                            block_all{r3,1}{1,r4}{r5,1}=decomSignal(path_decom,Band_decom,meth_decom_temp,s(r5,:),fs,Nstd,NE,Times,Err,errPerL2);
                        end
                    end
                end
                
                save(path_block_temp,'block_all');
                disp([path_block_temp ' have been done.']);
            end
        end
        
        if ~exist(path_block,'dir')
            mkdir(path_block);
        end
        
        for r2=1:length(D)
            
            path_block_temp=[path_block D(r2).name];
            if exist(path_block_temp,'file')
                disp([path_block_temp ' exist, skip.']);
            else
                load([path_block_decom D(r2).name]);
                
                n_block=size(block_all,1);
                block=cell(n_block,1);
                for r3=1:n_block
                    for r4=1:size(block_all{r3,1},2)
                        
                        s=block_all{r3,1}{1,r4};
                        for r5=1:n_channel
                            block{r3,1}{1,r4}(r5,:)=sum(s{r5,1}(orderNo,:),1);
                        end
                    end
                end
                
                save(path_block_temp,'block');
                disp([path_block_temp ' have been done.']);
            end
        end
    end
else
    block_name='block';
end
%%

disp(' ');
disp(['feature extraction method of ' meth ':']);
[~,file_name]=process_featureExtraction(0,0,Band,Scale,Shape,GC_alpha,meth);

for r1=1:n_group
    
    path_EEG=[path_data 'group\group_' num2code(r1,n_code) '\'];
    D=dir([path_EEG '*.mat']);
    
    path_block=([path_data num2str(T) 's(' num2str(olr) ')' T_window '\' block_name '\group_' num2code(r1,n_code) '\']);
    
    path_feature=([path_data num2str(T) 's(' num2str(olr) ')' T_window '\' file_name '\group_' num2code(r1,n_code) '\']);
    if ~exist(path_feature,'dir')
        mkdir(path_feature);
    end
    
    for r2=1:length(D)
        
        path_feature_temp=[path_feature D(r2).name];
        if exist(path_feature_temp,'file')
            disp([path_feature_temp ' exist, skip.']);
        else
            load([path_block D(r2).name]);
            
            n_block=size(block,1);
            sample=cell(n_block,1);
            for r3=1:n_block
                for r4=1:size(block{r3,1},2)
                    
                    s=block{r3,1}{1,r4};
                    sample{r3,1}{1,r4}=process_featureExtraction(s,fs,Band,Scale,Shape,GC_alpha,meth);
                end
            end
            
            save(path_feature_temp,'sample');
            disp([path_feature_temp ' have been done.']);
        end
    end
end
end