function  [PS,s_PS]=wave_PS(s,fs,band,Scale,shape)
%%
n_order=3;

n_t=length(s);
t=(1:n_t)/fs;

Wn_temp=2*band/fs;

flag_filter=1;
if Wn_temp(1)<=0 && Wn_temp(2)>=1
    flag_filter=0;
elseif Wn_temp(1)<=0
    Wn=Wn_temp(2);
    
    n_order=2*n_order;
    ftype='low';
elseif Wn_temp(2)>=1
    Wn=Wn_temp(1);
    
    n_order=2*n_order;
    ftype='high';
else
    Wn=Wn_temp;
    
    ftype='bandpass';
end

if flag_filter
    [filter_b,filter_a]=butter(n_order,Wn,ftype); % figure;freqz(filter_b,filter_a);
    s_filter=filtfilt(filter_b,filter_a,s);
else
    s_filter=s;
end
%%

s_min=min(s_filter);
x=s_filter-s_min;

x_open=zeros(2,n_t);
x_close=zeros(2,n_t);

PSo_temp=zeros(1,2);
PSc_temp=zeros(1,2);
for r=1:2
    
    m=fix(Scale(r)*fs);
    if m<=1
        x_open(r,:)=x;
        x_close(r,:)=x;
    else
        se=wave_se(m,shape);
        x_open(r,:)=wave_open(x,se);
        x_close(r,:)=wave_close(x,se);
    end
    
    PSo_temp(1,r)=trapz(t,x_open(r,:));
    PSc_temp(1,r)=trapz(t,x_close(r,:));
end
%%

PSo=-diff(PSo_temp);
PSc=diff(PSc_temp);
PS=[PSo;PSc]/(n_t/fs);

s_PS{1,1}=x_open+s_min;
s_PS{2,1}=x_close+s_min;
end