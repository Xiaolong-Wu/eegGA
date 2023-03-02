function  [EEG_feature,file_name]=process_featureExtraction(s,fs,Band,Scale,Shape,GC_alpha,meth)

[n_channel,n_t]=size(s);

switch meth
    case {'bandPower';'correlation';'mscohere';'PLV'}
        file_name=[meth '(' num2str(Band(1,1)) ',' num2str(Band(1,2)) ')Hz'];
    case 'morphology'
        file_name=[meth '(' num2str(Band(1,1)) ',' num2str(Band(1,2)) ')Hz(' num2str(Scale(1,1)) ',' num2str(Scale(1,2)) ')ms(' Shape ')'];
    case {'morpCorrelation';'morphMscohere';'morphPLV'}
        file_name=[meth '(' num2str(Band(1,1)) ',' num2str(Band(1,2)) ')Hz(' num2str(Scale(1,1)) ')ms(' Shape ')'];
    case 'GC'
        file_name=[meth '(' num2str(Band(1,1)) ',' num2str(Band(1,2)) ')Hz(' num2str(GC_alpha) ')'];
    case 'morphGC'
        file_name=[meth '(' num2str(Band(1,1)) ',' num2str(Band(1,2)) ')Hz(' num2str(Scale(1,1)) ')ms(' Shape ')(' num2str(GC_alpha) ')'];
    case {'CFC_bandPowerRate';'CFC_AAC';'CFC_PAC'}
        file_name=[meth '(' num2str(Band(1,1)) ',' num2str(Band(1,2)) ')-(' num2str(Band(2,1)) ',' num2str(Band(2,2)) ')Hz'];
    case 'CFC_morphologyRate'
        file_name=[meth '(' num2str(Band(1,1)) ',' num2str(Band(1,2)) ')-(' num2str(Band(2,1)) ',' num2str(Band(2,2)) ')Hz(' num2str(Scale(1,1)) ',' num2str(Scale(1,2)) ')-(' num2str(Scale(2,1)) ',' num2str(Scale(2,2)) ')ms(' Shape ')'];
    case {'CFC_morphAAC';'CFC_morphPAC'}
        file_name=[meth '(' num2str(Band(1,1)) ',' num2str(Band(1,2)) ')-(' num2str(Band(2,1)) ',' num2str(Band(2,2)) ')Hz(' num2str(Scale(1,1)) ')-(' num2str(Scale(2,1)) ')ms(' Shape ')'];
    case 'CFC_GC'
        file_name=[meth '(' num2str(Band(1,1)) ',' num2str(Band(1,2)) ')-(' num2str(Band(2,1)) ',' num2str(Band(2,2)) ')Hz(' num2str(GC_alpha) ')'];
    case 'CFC_morphGC'
        file_name=[meth '(' num2str(Band(1,1)) ',' num2str(Band(1,2)) ')-(' num2str(Band(2,1)) ',' num2str(Band(2,2)) ')Hz(' num2str(Scale(1,1)) ')-(' num2str(Scale(2,1)) ')ms(' Shape ')(' num2str(GC_alpha) ')'];
    case 'timeFeature'
        file_name=[meth '(' num2str(Band(1,1)) ',' num2str(Band(1,2)) ')Hz(' num2str(Scale(1,2)) ')'];
    case 'morphTimeFeature'
        file_name=[meth '(' num2str(Band(1,1)) ',' num2str(Band(1,2)) ')Hz(' num2str(Scale(1,1)) ')ms(' Shape ')(' num2str(Scale(1,2)) ')'];
end

if size(Scale,1)>2 && Scale(3,1)~=0
    
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
    block_name=['decom_' meth_decom_temp '(' orderNo_str ')'];
else
    block_name='block';
end

if ~strcmp(block_name,'block')
    file_name=[block_name file_name];
end
%%

if fs==0
    EEG_feature=0;
else
    n_band=fix(2*Band(1,:)*fix(n_t/2)/fs);
    if n_band(1,1)<1
        n_band(1,1)=1;
    end
    if n_band(1,2)>fix(n_t/2)
        n_band(1,2)=fix(n_t/2);
    end
    
    switch meth
        case 'bandPower'
            
            EEG_feature=cell(1,1);
            
            feature_matrix=zeros(1,n_channel);
            if Band(1,2)>fs/2
                Band(1,2)=fs/2;
            end
            for r=1:n_channel
                
                feature_matrix(1,r)=bandpower(s(r,:),fs,Band(1,:));
            end
            EEG_feature{1,1}=feature_matrix;
        case 'morphology'
            
            EEG_feature=cell(2,1);
            
            feature_matrix=zeros(2,n_channel);
            for r=1:n_channel
                
                [PS,~]=wave_PS(s(r,:),fs,Band(1,:),Scale(1,:)/1000,Shape);
                feature_matrix(:,r)=PS;
            end
            for r=1:2
                
                EEG_feature{r,1}=feature_matrix(r,:);
            end
        case 'correlation'
            
            EEG_feature=cell(1,1);
            
            feature_matrix=zeros(n_channel,n_channel);
            s_filter=zeros(n_channel,n_t);
            for r=1:n_channel
                
                [~,s_PS]=wave_PS(s(r,:),fs,Band(1,:),[0 0],'flat');
                s_filter(r,:)=s_PS{1,1}(1,:);
            end
            for r1=1:n_channel
                for r2=1:n_channel
                    
                    feature_matrix(r1,r2)=corr(s_filter(r1,:)',s_filter(r2,:)');
                end
            end
            EEG_feature{1,1}=feature_matrix;
        case 'morphCorrelation'
            
            EEG_feature=cell(2,1);
            
            feature_matrix=zeros(n_channel,n_channel);
            s_open=zeros(n_channel,n_t);
            s_close=zeros(n_channel,n_t);
            for r=1:n_channel
                
                [~,s_PS]=wave_PS(s(r,:),fs,Band(1,:),([0 Scale(1,1)])/1000,Shape);
                s_open(r,:)=s_PS{1,1}(1,:)-s_PS{1,1}(2,:);
                s_close(r,:)=s_PS{2,1}(1,:)-s_PS{2,1}(2,:);
            end
            for r1=1:2
                for r2=1:n_channel
                    for r3=1:n_channel
                        
                        if r1==1
                            feature_matrix(r2,r3)=corr(s_open(r2,:)',s_open(r3,:)');
                        elseif r1==2
                            feature_matrix(r2,r3)=corr(s_close(r2,:)',s_close(r3,:)');
                        end
                    end
                end
                EEG_feature{r1,1}=feature_matrix;
            end
        case 'mscohere'
            
            EEG_feature=cell(1,1);
            
            feature_matrix=zeros(n_channel,n_channel);
            s_filter=zeros(n_channel,n_t);
            for r=1:n_channel
                
                [~,s_PS]=wave_PS(s(r,:),fs,Band(1,:),[0 0],'flat');
                s_filter(r,:)=s_PS{1,1}(1,:);
            end
            for r1=1:n_channel
                for r2=1:n_channel
                    
                    feature_matrix_temp=mscohere(s_filter(r1,:)',s_filter(r2,:)',[],[],n_t,fs);
                    feature_matrix(r1,r2)=mean(feature_matrix_temp(n_band(1,1):n_band(1,2)));
                end
            end
            EEG_feature{1,1}=feature_matrix;
        case 'morphMscohere'
            
            EEG_feature=cell(2,1);
            
            feature_matrix=zeros(n_channel,n_channel);
            s_open=zeros(n_channel,n_t);
            s_close=zeros(n_channel,n_t);
            for r=1:n_channel
                
                [~,s_PS]=wave_PS(s(r,:),fs,Band(1,:),([0 Scale(1,1)])/1000,Shape);
                s_open(r,:)=s_PS{1,1}(1,:)-s_PS{1,1}(2,:);
                s_close(r,:)=s_PS{2,1}(1,:)-s_PS{2,1}(2,:);
            end
            for r1=1:2
                for r2=1:n_channel
                    for r3=1:n_channel
                        
                        if r1==1
                            feature_matrix_temp=mscohere(s_open(r2,:)',s_open(r3,:)',[],[],n_t,fs);
                            feature_matrix(r2,r3)=mean(feature_matrix_temp(n_band(1,1):n_band(1,2)));
                        elseif r1==2
                            feature_matrix_temp=mscohere(s_close(r2,:)',s_close(r3,:)',[],[],n_t,fs);
                            feature_matrix(r2,r3)=mean(feature_matrix_temp(n_band(1,1):n_band(1,2)));
                        end
                    end
                end
                EEG_feature{r1,1}=feature_matrix;
            end
        case 'PLV'
            
            EEG_feature=cell(1,1);
            
            feature_matrix=zeros(n_channel,n_channel);
            p_filter=zeros(n_channel,n_t);
            for r=1:n_channel
                
                [~,s_PS]=wave_PS(s(r,:),fs,Band(1,:),[0 0],'flat');
                s_filter=s_PS{1,1}(1,:);
                
                p_filter(r,:)=angle(hilbert(s_filter));
            end
            for r1=1:n_channel
                for r2=1:n_channel
                    
                    feature_matrix(r1,r2)=plv([p_filter(r1,:);p_filter(r2,:)]);
                end
            end
            EEG_feature{1,1}=feature_matrix;
        case 'morphPLV'
            
            EEG_feature=cell(2,1);
            
            feature_matrix=zeros(n_channel,n_channel);
            p_open=zeros(n_channel,n_t);
            p_close=zeros(n_channel,n_t);
            for r=1:n_channel
                
                [~,s_PS]=wave_PS(s(r,:),fs,Band(1,:),([0 Scale(1,1)])/1000,Shape);
                s_open=s_PS{1,1}(1,:)-s_PS{1,1}(2,:);
                s_close=s_PS{2,1}(1,:)-s_PS{2,1}(2,:);
                
                p_open(r,:)=angle(hilbert(s_open));
                p_close(r,:)=angle(hilbert(s_close));
            end
            for r1=1:2
                for r2=1:n_channel
                    for r3=1:n_channel
                        
                        if r1==1
                            feature_matrix(r2,r3)=plv([p_open(r2,:);p_open(r3,:)]);
                        elseif r1==2
                            feature_matrix(r2,r3)=plv([p_close(r2,:);p_close(r3,:)]);
                        end
                    end
                end
                EEG_feature{r1,1}=feature_matrix;
            end
        case 'GC'
            
            EEG_feature=cell(1,1);
            
            feature_matrix=zeros(n_channel,n_channel);
            s_filter=zeros(n_channel,n_t);
            for r=1:n_channel
                
                [~,s_PS]=wave_PS(s(r,:),fs,Band(1,:),[0 0],'flat');
                s_filter(r,:)=s_PS{1,1}(1,:);
            end
            for r1=1:n_channel
                for r2=1:n_channel
                    
                    [~,~,feature_matrix_temp]=resampleGC(s_filter(r1,:)',s_filter(r2,:)',GC_alpha,fs,Band(1,2));
                    feature_matrix(r1,r2)=1-feature_matrix_temp;
                end
            end
            EEG_feature{1,1}=feature_matrix;
        case 'morphGC'
            
            EEG_feature=cell(2,1);
            
            feature_matrix=zeros(n_channel,n_channel);
            s_open=zeros(n_channel,n_t);
            s_close=zeros(n_channel,n_t);
            for r=1:n_channel
                
                [~,s_PS]=wave_PS(s(r,:),fs,Band(1,:),([0 Scale(1,1)])/1000,Shape);
                s_open(r,:)=s_PS{1,1}(1,:)-s_PS{1,1}(2,:);
                s_close(r,:)=s_PS{2,1}(1,:)-s_PS{2,1}(2,:);
            end
            for r1=1:2
                for r2=1:n_channel
                    for r3=1:n_channel
                        
                        if r1==1
                            [~,~,feature_matrix_temp]=resampleGC(s_open(r2,:)',s_open(r3,:)',GC_alpha,fs,Band(1,2));
                            feature_matrix(r2,r3)=1-feature_matrix_temp;
                        elseif r1==2
                            [~,~,feature_matrix_temp]=resampleGC(s_close(r2,:)',s_close(r3,:)',GC_alpha,fs,Band(1,2));
                            feature_matrix(r2,r3)=1-feature_matrix_temp;
                        end
                    end
                end
                EEG_feature{r1,1}=feature_matrix;
            end
        case 'CFC_bandPowerRate'
            
            EEG_feature=cell(1,1);
            
            feature_matrix=zeros(1,n_channel);
            if Band(1,2)>fs/2
                Band(1,2)=fs/2;
            end
            if Band(2,2)>fs/2
                Band(2,2)=fs/2;
            end
            for r=1:n_channel
                
                feature_matrix(1,r)=bandpower(s(r,:),fs,Band(1,:))/bandpower(s(r,:),fs,Band(2,:));
            end
            EEG_feature{1,1}=feature_matrix;
        case 'CFC_morphologyRate'
            
            EEG_feature=cell(2,1);
            
            feature_matrix=zeros(2,n_channel);
            for r=1:n_channel
                
                [PS_x,~]=wave_PS(s(r,:),fs,Band(1,:),Scale(1,:)/1000,Shape);
                [PS_y,~]=wave_PS(s(r,:),fs,Band(2,:),Scale(2,:)/1000,Shape);
                feature_matrix(:,r)=PS_x./PS_y;
            end
            for r=1:2
                
                EEG_feature{r,1}=feature_matrix(r,:);
            end
        case 'CFC_AAC'
            
            EEG_feature=cell(1,1);
            
            feature_matrix=zeros(n_channel,n_channel);
            s_filter_x=zeros(n_channel,n_t);
            s_filter_y=zeros(n_channel,n_t);
            for r=1:n_channel
                
                [~,s_PS_x]=wave_PS(s(r,:),fs,Band(1,:),[0 0],'flat');
                [~,s_PS_y]=wave_PS(s(r,:),fs,Band(2,:),[0 0],'flat');
                
                s_filter_x(r,:)=s_PS_x{1,1}(1,:);
                s_filter_y(r,:)=s_PS_y{1,1}(1,:);
            end
            for r1=1:n_channel
                for r2=1:n_channel
                    
                    feature_matrix(r1,r2)=CFC_aac(s_filter_x(r1,:),s_filter_y(r2,:));
                end
            end
            EEG_feature{1,1}=feature_matrix;
        case 'CFC_morphAAC'
            
            EEG_feature=cell(2,1);
            
            feature_matrix=zeros(n_channel,n_channel);
            s_open_x=zeros(n_channel,n_t);
            s_open_y=zeros(n_channel,n_t);
            s_close_x=zeros(n_channel,n_t);
            s_close_y=zeros(n_channel,n_t);
            for r=1:n_channel
                
                [~,s_PS_x]=wave_PS(s(r,:),fs,Band(1,:),([0 Scale(1,1)])/1000,Shape);
                [~,s_PS_y]=wave_PS(s(r,:),fs,Band(2,:),([0 Scale(2,1)])/1000,Shape);
                
                s_open_x(r,:)=s_PS_x{1,1}(1,:)-s_PS_x{1,1}(2,:);
                s_open_y(r,:)=s_PS_y{1,1}(1,:)-s_PS_y{1,1}(2,:);
                s_close_x(r,:)=s_PS_x{2,1}(1,:)-s_PS_x{2,1}(2,:);
                s_close_y(r,:)=s_PS_y{2,1}(1,:)-s_PS_y{2,1}(2,:);
            end
            for r1=1:2
                for r2=1:n_channel
                    for r3=1:n_channel
                        
                        if r1==1
                            feature_matrix(r2,r3)=CFC_aac(s_open_x(r2,:),s_open_y(r3,:));
                        elseif r1==2
                            feature_matrix(r2,r3)=CFC_aac(s_close_x(r2,:),s_close_y(r3,:));
                        end
                    end
                end
                EEG_feature{r1,1}=feature_matrix;
            end
        case 'CFC_PAC'
            
            EEG_feature=cell(1,1);
            
            feature_matrix=zeros(n_channel,n_channel);
            s_filter_x=zeros(n_channel,n_t);
            s_filter_y=zeros(n_channel,n_t);
            for r=1:n_channel
                
                [~,s_PS_x]=wave_PS(s(r,:),fs,Band(1,:),[0 0],'flat');
                [~,s_PS_y]=wave_PS(s(r,:),fs,Band(2,:),[0 0],'flat');
                
                s_filter_x(r,:)=s_PS_x{1,1}(1,:);
                s_filter_y(r,:)=s_PS_y{1,1}(1,:);
            end
            for r1=1:n_channel
                for r2=1:n_channel
                    
                    feature_matrix(r1,r2)=CFC_pac(s_filter_x(r1,:),s_filter_y(r2,:),fs,Band(2,:));
                end
            end
            EEG_feature{1,1}=feature_matrix;
        case 'CFC_morphPAC'
            
            EEG_feature=cell(2,1);
            
            feature_matrix=zeros(n_channel,n_channel);
            s_open_x=zeros(n_channel,n_t);
            s_open_y=zeros(n_channel,n_t);
            s_close_x=zeros(n_channel,n_t);
            s_close_y=zeros(n_channel,n_t);
            for r=1:n_channel
                
                [~,s_PS_x]=wave_PS(s(r,:),fs,Band(1,:),([0 Scale(1,1)])/1000,Shape);
                [~,s_PS_y]=wave_PS(s(r,:),fs,Band(2,:),([0 Scale(2,1)])/1000,Shape);
                
                s_open_x(r,:)=s_PS_x{1,1}(1,:)-s_PS_x{1,1}(2,:);
                s_open_y(r,:)=s_PS_y{1,1}(1,:)-s_PS_y{1,1}(2,:);
                s_close_x(r,:)=s_PS_x{2,1}(1,:)-s_PS_x{2,1}(2,:);
                s_close_y(r,:)=s_PS_y{2,1}(1,:)-s_PS_y{2,1}(2,:);
            end
            for r1=1:2
                for r2=1:n_channel
                    for r3=1:n_channel
                        
                        if r1==1
                            feature_matrix(r2,r3)=CFC_pac(s_open_x(r2,:),s_open_y(r3,:),fs,Band(2,:));
                        elseif r1==2
                            feature_matrix(r2,r3)=CFC_pac(s_close_x(r2,:),s_close_y(r3,:),fs,Band(2,:));
                        end
                    end
                end
                EEG_feature{r1,1}=feature_matrix;
            end
        case 'CFC_GC'
            
            EEG_feature=cell(1,1);
            
            feature_matrix=zeros(n_channel,n_channel);
            s_filter_x=zeros(n_channel,n_t);
            s_filter_y=zeros(n_channel,n_t);
            for r=1:n_channel
                
                [~,s_PS_x]=wave_PS(s(r,:),fs,Band(1,:),[0 0],'flat');
                [~,s_PS_y]=wave_PS(s(r,:),fs,Band(2,:),[0 0],'flat');
                
                s_filter_x(r,:)=s_PS_x{1,1}(1,:);
                s_filter_y(r,:)=s_PS_y{1,1}(1,:);
            end
            for r1=1:n_channel
                for r2=1:n_channel
                    
                    [~,~,feature_matrix_temp]=resampleGC(s_filter_x(r1,:)',s_filter_y(r2,:)',GC_alpha,fs,max(Band(:,2)));
                    feature_matrix(r1,r2)=1-feature_matrix_temp;
                end
            end
            EEG_feature{1,1}=feature_matrix;
        case 'CFC_morphGC'
            
            EEG_feature=cell(2,1);
            
            feature_matrix=zeros(n_channel,n_channel);
            s_open_x=zeros(n_channel,n_t);
            s_open_y=zeros(n_channel,n_t);
            s_close_x=zeros(n_channel,n_t);
            s_close_y=zeros(n_channel,n_t);
            for r=1:n_channel
                
                [~,s_PS_x]=wave_PS(s(r,:),fs,Band(1,:),([0 Scale(1,1)])/1000,Shape);
                [~,s_PS_y]=wave_PS(s(r,:),fs,Band(2,:),([0 Scale(2,1)])/1000,Shape);
                
                s_open_x(r,:)=s_PS_x{1,1}(1,:)-s_PS_x{1,1}(2,:);
                s_open_y(r,:)=s_PS_y{1,1}(1,:)-s_PS_y{1,1}(2,:);
                s_close_x(r,:)=s_PS_x{2,1}(1,:)-s_PS_x{2,1}(2,:);
                s_close_y(r,:)=s_PS_y{2,1}(1,:)-s_PS_y{2,1}(2,:);
            end
            for r1=1:2
                for r2=1:n_channel
                    for r3=1:n_channel
                        
                        if r1==1
                            [~,~,feature_matrix_temp]=resampleGC(s_open_x(r2,:)',s_open_y(r3,:)',GC_alpha,fs,max(Band(:,2)));
                            feature_matrix(r2,r3)=1-feature_matrix_temp;
                        elseif r1==2
                            [~,~,feature_matrix_temp]=resampleGC(s_close_x(r2,:)',s_close_y(r3,:)',GC_alpha,fs,max(Band(:,2)));
                            feature_matrix(r2,r3)=1-feature_matrix_temp;
                        end
                    end
                end
                EEG_feature{r1,1}=feature_matrix;
            end
        case 'timeFeature'
            
            EEG_feature=cell(1,1);
            
            feature_matrix=zeros(1,n_channel);
            s_filter=zeros(n_channel,n_t);
            for r=1:n_channel
                
                [~,s_PS]=wave_PS(s(r,:),fs,Band(1,:),[0 0],'flat');
                s_filter(r,:)=s_PS{1,1}(1,:);
            end
            for r=1:n_channel
                
                feature_matrix(1,r)=timeFeature(s_filter(r,:),Scale(1,2));
            end
            EEG_feature{1,1}=feature_matrix;
        case 'morphTimeFeature'
            
            EEG_feature=cell(2,1);
            
            feature_matrix=zeros(1,n_channel);
            s_open=zeros(n_channel,n_t);
            s_close=zeros(n_channel,n_t);
            for r=1:n_channel
                
                [~,s_PS]=wave_PS(s(r,:),fs,Band(1,:),([0 Scale(1,1)])/1000,'flat');
                s_open(r,:)=s_PS{1,1}(1,:)-s_PS{1,1}(2,:);
                s_close(r,:)=s_PS{2,1}(1,:)-s_PS{2,1}(2,:);
            end
            for r1=1:2
                for r2=1:n_channel
                    
                    if r1==1
                        feature_matrix(1,r)=timeFeature(s_open(r,:),Scale(1,2));
                    elseif r1==2
                        feature_matrix(1,r)=timeFeature(s_close(r,:),Scale(1,2));
                    end
                end
                EEG_feature{r1,1}=feature_matrix;
            end
    end
end

end
%%

function p=plv(phase_all)

% Phase Locking Value
% size(phase_all,1)==2

n_t=size(phase_all,2);
e=exp(1i*(phase_all(1,:)-phase_all(2,:)));
p=abs(sum(e))/n_t;
end
%%

function p=CFC_aac(x,y)

xA=abs(hilbert(x));
p_xA=angle(hilbert(xA));

yA=abs(hilbert(y));
p_yA=angle(hilbert(yA));

p=plv([p_xA;p_yA]);
end
%%

function p=CFC_pac(x,y,fs,band_y)

xA=abs(hilbert(x));
[~,xA_PS]=wave_PS(xA,fs,band_y,[0 0],'flat');
xA_filter=xA_PS{1,1}(1,:);
p_xA_filter=angle(hilbert(xA_filter));

p_y=angle(hilbert(y));

p=plv([p_xA_filter;p_y]);
end
%%

function [alpha_v,F_v,F_p]=resampleGC(x,y,alpha,fs,f_max)

n_multiple=5; % the resampling frequency is n_multiple times the highest concerned frequency
t_lag=250; % t_lag: unit is m-sec, yet never more than the half of total time span of x (or y)

n_t=length(x); % n_t=length(y);
t_lag=min([t_lag,1000*n_t/(2*fs)]);

fs_temp=n_multiple*f_max;

if fs_temp<fs
    interval=floor(fs/fs_temp);
    n_resample=1:interval:n_t;
    
    n_t_re=length(n_resample);
    fs_re=fs*n_t_re/n_t;
    
    x_re=x(n_resample);
    y_re=y(n_resample);
else
    fs_re=fs;
    
    x_re=x;
    y_re=y;
end

max_lag=ceil(fs_re*(t_lag/1000));
[alpha_v,F_v,F_p]=granger_cause(x_re,y_re,alpha,max_lag);
end
%%

function p=timeFeature(s,methTimeFeature)

% methTimeFeature
% 1: mean, 2: std, 3: rms, 4: peak, 5: crestfactor, 6: kurtosis, 7: shapefactor, 8: impulsefactor, 9: marginfactor
if methTimeFeature==1
    p=mean(s);
elseif methTimeFeature==2
    p=std(s);
elseif methTimeFeature==3
    p=rms(s);
elseif methTimeFeature==4
    p=peak(s);
elseif methTimeFeature==5
    p=crestfactor(s);
elseif methTimeFeature==6
    p=kurtosis(s);
elseif methTimeFeature==7
    p=shapefactor(s);
elseif methTimeFeature==8
    p=impulsefactor(s);
elseif methTimeFeature==9
    p=marginfactor(s);
end

    function p=peak(s)
        p=max(s)-min(s);
    end
    function p=crestfactor(s)
        p=peak(s)/rms(s);
    end
    function p=shapefactor(s)
        p=rms(s)/mean(abs(s));
    end
    function p=impulsefactor(s)
        p=peak(s)/mean(abs(s));
    end
    function p=marginfactor(s)
        p=peak(s)/mean(sqrt(abs(s)))^2;
    end
end