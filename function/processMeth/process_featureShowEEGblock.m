function process_featureShowEEGblock(EEG_block,fs,n_t,n_channel,Band,Scale,Shape,meth,r_channel,kindShow,fShow,w,Voltage_range,Voltage_range_f,Frequency_range,colorbar_show,title_show,Title)

fc=scal2frq(fs,w,1/fs);
scale=(fs*fc)./fShow;
seconds=(1:n_t)/fs;
f=(1:fix(n_t/2))*fs/n_t;

for r5=r_channel
    
    disp(['a total of ' num2str(n_channel) ' channels, show channel ' num2str(r5)]);
    if r5>n_channel
        keyboard;
    end
    
    Title_temp=[Title ' channel ' num2str(r5)];
    str={' morphology_o_p_e_n';' morphology_c_l_o_s_e'};
    s1=EEG_block(r5,:);
    %% cwt
    
    if ismember(1,kindShow)
        H=figure;
        [coefs,sgram]=cwt(s1,scale,w,'scal');
        close(H);
        
        figure
        subplot(10,1,1:2);
        plot(seconds,s1,'k','LineWidth',2);
        ylim(Voltage_range);
        ylabel('Voltage/ \muV','Fontweight','bold');
        if title_show
            title(Title_temp);
        end
        
        % Z=coefs;
        Z=sgram;
        
        fLog=log(fShow);
        fSet=[4,8,13,30,60,120];
        fInd=1;
        r0=1;
        for r_fInd=1:sum(fSet<fShow(end))
            
            if fSet(1,r_fInd)>fShow(1)
                [~,fInd_temp]=min(abs(fShow-fSet(1,r_fInd)));
                if fInd_temp>1
                    r0=r0+1;
                    fInd(1,r0)=fInd_temp;
                end
            end
        end
        fInd=[fInd,length(fShow)];
        subplot(10,1,5:10);
        % imagesc(Z);
        
        [X,Y]=meshgrid(seconds,fLog);
        surf(X,Y,Z,'EdgeColor','none');view(0,90);
        colorbar([0.925 0.11 0.02 0.48]);
        if ~colorbar_show
            colorbar off;
        end
        set(gca,'YTick',fLog(fInd),'YTickLabel',fShow(fInd));
        axis([seconds(1) seconds(end) fLog(1) fLog(end)]);
        xlabel('time (sec)','Fontweight','bold');
        ylabel('frequency/ Hz','Fontweight','bold');
        title('Percentage of energy for each wavelet coeffcient in CWT');
    end
    %% meth
    
    if ismember(2,kindShow)
        if ~strcmp('CFC_',meth(1:4))
            n_Band=1;
        else
            n_Band=2;
        end
        
        for r_Band=1:n_Band
            
            n_band=fix(2*Band(r_Band,:)*fix(n_t/2)/fs);
            if n_band(1,1)<1
                n_band(1,1)=1;
            end
            if n_band(1,2)>fix(n_t/2)
                n_band(1,2)=fix(n_t/2);
            end
            toZero=zeros(1,fix(n_t/2));
            toZero(n_band(1,1):n_band(1,2))=1;
            
            switch meth
                case {'morphology';'CFC_morphologyRate'}
                    [~,s_PS]=wave_PS(s1,fs,Band(r_Band,:),(Scale(r_Band,:))/1000,Shape);
                otherwise
                    [~,s_PS]=wave_PS(s1,fs,Band(r_Band,:),([0 Scale(r_Band,1)])/1000,Shape);
            end
            
            if Band(r_Band,1)>0 || Band(r_Band,2)<fs/2
                s2=s_PS{1,1}(1,:); % s2=s_PS{2,1}(1,:);
            else
                s2=[];
            end
            
            switch meth
                case {'bandPower';'correlation';'mscohere';'PLV';'GC';'CFC_bandPowerRate';'CFC_AAC';'CFC_PAC';'CFC_GC';'timeFeature'}
                    s3=[];
                otherwise
                    s3=[s_PS{1,1}(1,:)-s_PS{1,1}(2,:);s_PS{2,1}(1,:)-s_PS{2,1}(2,:)];
            end
            
            if isempty(s3)
                figure
                
                subplot(3,1,1);
                plot(seconds,s1,'k','LineWidth',2);
                if ~isempty(s2)
                    hold on;
                    plot(seconds,s2,'r','LineWidth',2);
                end
                xlabel('Time/ s','Fontweight','bold');
                ylim(Voltage_range);
                ylabel('Voltage/ \muV','Fontweight','bold');
                
                subplot(3,1,2);
                f1=cpsd(s1,s1,[],[],n_t,fs)/(n_t/fs);
                plot(f,f1(1:fix(n_t/2)),'k','LineWidth',2);
                if ~isempty(s2)
                    hold on;
                    plot([Band(r_Band,1) Band(r_Band,1)],Voltage_range_f,'r','LineWidth',2);
                    hold on;
                    plot([Band(r_Band,2) Band(r_Band,2)],Voltage_range_f,'r','LineWidth',2);
                    hold on;
                    f2=cpsd(s2,s2,[],[],n_t,fs)/(n_t/fs);
                    plot(f,f2(1:fix(n_t/2)),'r','LineWidth',2);
                end
                xlim(Frequency_range);
                xlabel('Hz','Fontweight','bold');
                ylim(Voltage_range_f);
                ylabel('Power/ 10^-^6\muW','Fontweight','bold');
                
                subplot(3,1,3);
                p1_temp=fft(s1,n_t)/n_t;
                p1=angle(p1_temp(1:fix(n_t/2)));
                plot(f,p1,'k','LineWidth',2);
                if ~isempty(s2)
                    hold on;
                    f2_temp=fft(s2,n_t)/n_t;
                    f2=angle(f2_temp(1:fix(n_t/2))).*toZero;
                    plot(f,f2,'r','LineWidth',2);
                end
                xlim(Frequency_range);
                xlabel('Hz','Fontweight','bold');
                ylim([-pi pi]);
                ylabel('angle/ rad','Fontweight','bold');
                
                if title_show
                    suptitle(Title_temp);
                end
            else
                for r6=1:2
                    
                    figure
                    
                    subplot(3,1,1);
                    plot(seconds,s1,'k','LineWidth',2);
                    if ~isempty(s2)
                        hold on;
                        plot(seconds,s2,'r','LineWidth',2);
                    end
                    hold on;
                    plot(seconds,s3(r6,:),'g','LineWidth',2);
                    xlabel('Time/ s','Fontweight','bold');
                    ylim(Voltage_range);
                    ylabel('Voltage/ \muV','Fontweight','bold');
                    
                    subplot(3,1,2);
                    f1=cpsd(s1,s1,[],[],n_t,fs)/(n_t/fs);
                    plot(f,f1(1:fix(n_t/2)),'k','LineWidth',2);
                    if ~isempty(s2)
                        hold on;
                        plot([Band(r_Band,1) Band(r_Band,1)],Voltage_range_f,'r','LineWidth',2);
                        hold on;
                        plot([Band(r_Band,2) Band(r_Band,2)],Voltage_range_f,'r','LineWidth',2);
                        hold on;
                        f2=cpsd(s2,s2,[],[],n_t,fs)/(n_t/fs);
                        plot(f,f2(1:fix(n_t/2)),'r','LineWidth',2);
                    end
                    hold on;
                    f3=cpsd(s3(r6,:),s3(r6,:),[],[],n_t,fs)/(n_t/fs);
                    plot(f,f3(1:fix(n_t/2)),'g','LineWidth',2);
                    xlim(Frequency_range);
                    xlabel('Hz','Fontweight','bold');
                    ylim(Voltage_range_f);
                    ylabel('Power/ 10^-^6\muW','Fontweight','bold');
                    
                    subplot(3,1,3);
                    p1_temp=fft(s1,n_t)/n_t;
                    p1=angle(p1_temp(1:fix(n_t/2)));
                    plot(f,p1,'k','LineWidth',2);
                    if ~isempty(s2)
                        hold on;
                        p2_temp=fft(s2,n_t)/n_t;
                        p2=angle(p2_temp(1:fix(n_t/2))).*toZero;
                        plot(f,p2,'r','LineWidth',2);
                    end
                    hold on;
                    p3_temp=fft(s3(r6,:),n_t)/n_t;
                    p3=angle(p3_temp(1:fix(n_t/2))).*toZero;
                    plot(f,p3,'g','LineWidth',2);
                    xlim(Frequency_range);
                    xlabel('Hz','Fontweight','bold');
                    ylim([-pi pi]);
                    ylabel('angle/ rad','Fontweight','bold');
                    
                    if title_show
                        suptitle([Title_temp str{r6,1}]);
                    end
                end
            end
        end
    end
end
end