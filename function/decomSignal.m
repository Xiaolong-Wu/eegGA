function sAll=decomSignal(path_decom,Band_decom,meth_decom_temp,s,fs,Nstd,NE,Times,Err,errPerL2)
%%

n_order=3;

Wn_temp=2*Band_decom/fs;

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

switch meth_decom_temp
    case 'EEMD'
        [allmode,c,io]=EEMD(s_filter,Nstd,NE,Times,Err);
        sAll=allmode';
    case 'MP'
        [sparseCodeFull,sparseCode,sRecom,sFitManual,sFit,qual]=mpSparseCode(path_decom,s_filter,fs,errPerL2);
        sAll=sparseCodeFull;
end
end