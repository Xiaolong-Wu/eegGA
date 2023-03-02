function featureShow(path_data,n_code,n_group,fs,channelNo,T,olr,T_window,Band,Scale,Shape,GC_alpha,meth,r_group,r_subject,r_block,r_channel,kindShow,fShow,w,Voltage_range,Voltage_range_f,Frequency_range,C_range,colorbar_show,title_show)

n_t=fix(T*fs);
n_channel=sum(channelNo~=0);
[~,file_name]=process_featureExtraction(0,0,Band,Scale,Shape,GC_alpha,meth);
%%

for r1=r_group
    
    disp(' ');
    disp(['a total of ' num2str(n_group) ' groups, show group ' num2str(r1)]);
    if r1>n_group
        keyboard;
    end
    
    path_EEG=[path_data 'group\group_' num2code(r1,n_code) '\'];
    D=dir([path_EEG '*.mat']);
    
    path_block=([path_data num2str(T) 's(' num2str(olr) ')' T_window '\block\group_' num2code(r1,n_code) '\']);
    
    path_feature=([path_data num2str(T) 's(' num2str(olr) ')' T_window '\' file_name '\group_' num2code(r1,n_code) '\']);
    
    n_subject=length(D);
    for r2=r_subject
        
        disp(['a total of ' num2str(n_subject) ' subjects, show subject ' num2str(r2)]);
        if r2>n_subject
            keyboard;
        end
        
        load([path_block D(r2).name]);
        load([path_feature D(r2).name]);
        
        n_block=size(block,1);
        for r3=1:size(r_block,1)
            
            disp(['a total of ' num2str(n_block) ' blocks, show block ' num2str(r_block{r3,1})]);
            if r_block{r3,1}>n_block
                keyboard;
            end
            
            n_segment=size(block{r_block{r3,1},1},2);
            for r4=1:length(r_block{r3,2})
                
                disp(['a total of ' num2str(n_segment) ' segments, show segment ' num2str(r_block{r3,2}(r4))]);
                if r_block{r3,2}(r4)>n_segment
                    keyboard;
                end
                
                EEG_block=block{r_block{r3,1},1}{1,r_block{r3,2}(r4)};
                EEG_feature=sample{r_block{r3,1},1}{1,r_block{r3,2}(r4)};
                
                Title=['group ' num2str(r1) ' subject ' num2str(r2) ' block ' num2str(r_block{r3,1}) ' segment ' num2str(r_block{r3,2}(r4))];
                if ismember(1,kindShow) || ismember(2,kindShow)
                    process_featureShowEEGblock(EEG_block,fs,n_t,n_channel,Band,Scale,Shape,meth,r_channel,kindShow,fShow,w,Voltage_range,Voltage_range_f,Frequency_range,colorbar_show,title_show,Title);
                end
                if ismember(3,kindShow)
                    process_featureShowEEGfeature(EEG_feature,[],meth,C_range,colorbar_show,title_show,Title);
                end
            end
        end
    end
end
end