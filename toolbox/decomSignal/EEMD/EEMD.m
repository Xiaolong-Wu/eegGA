%%
% This is an EMD/EEMD program
%
% function [allmode,c,io]=EEMD(X,Nstd,NE,T,e)
%
% INPUT:
%       X: Inputted data;
%       Nstd: ratio of the standard deviation of the added noise and that of X;
%       NE: Ensemble number for the EEMD;
%       T: Set the max-times of envelope;
%       e: Set the inaccuracy ratio (the mean of imf's final upper and lower envelop divided by the mean of the X's abs).
% OUTPUT:
%       allmode: A matrix of N*(M+2) matrix, where N is the length of the input data X, and M=fix(log2(N))-1 is the number of imfs. Column 1 is the original data (within white nosie), columns 2, 3, ..., (M+1) are the IMFs from high to low frequency, and comlumn (M+2) is the residual (over all trend).
%       c: The M*1 vector of relative cross-correlation sequence of X and it's imfs. M is the number of imfs.
%       io: Index of orthogonality to imfs.
% NOTE:
%       It should be noted that when Nstd is set to 0 and NE is set to 1, the program degenerates to a EMD program.
%
% code author: WJF
function [allmode,c,io]=EEMD(X,Nstd,NE,T,e)
N=length(X);
A=mean(abs(X));
t=1:1:N;

Xstd=std(X);
X=X/Xstd;

M=fix(log2(N))-1;
allmode=zeros(N,M+2);

for i=1:1:NE,
    mode=zeros(N,M+2);
    X_n=X+randn(1,N)*Nstd;
    Xr=X_n;
    mode(:,1) = X_n';
    m=2;
    while m<=M+1,
        imf = Xr;
        j=0;
        [inaccuracy,dif]=imf_judge(imf,A);
        while ((j<=T) && (abs(inaccuracy)>=e || abs(dif)>1) ),
            [spmax, spmin, flag]=envelop(imf);
            if flag==1
                upper= spline(spmax(:,1),spmax(:,2),t);
                lower= spline(spmin(:,1),spmin(:,2),t);
                mean_envelop= (upper + lower)/2;
                imf = imf - mean_envelop;
                [inaccuracy,dif]=imf_judge(imf,A);
                j=j+1;
            elseif flag==0
                fprintf('NE：%g,imf：%g\n',i,m-1);
                fprintf('最后一阶分量\n');
                j=T+2;
            end
        end
        if j==T+1
            fprintf('NE：%g,imf：%g\n',i,m-1);
            fprintf('误差率：%g，极值点数与零点数之差：%g\n',inaccuracy,dif);
        end
        mode(:,m) = imf';
        Xr = Xr - imf;
        if flag==1
            m=m+1;
        elseif flag==0
            m=M+1;
            m=m+1;
        end
    end
    mode(:,m)=Xr';
    allmode=allmode+mode;
end
allmode=allmode/NE;
io=orthogonality(allmode,X);
c=imfX_cov(allmode);
allmode=allmode*Xstd;
end
%%
% function [p_max, p_min, flag]= envelop(X)
%
% INPUT:
%       X: Inputted data, a time series to be sifted;
% OUTPUT:
%       p_max: The locations (col 1) of the maxima and its corresponding values (col 2)
%       p_min: The locations (col 1) of the minima and its corresponding values (col 2)
function [p_max, p_min, flag]= envelop(X)
flag=1;
N=length(X);
%上包络
p_max(1,1)=1;
p_max(1,2)=X(1);
p=2;
for i=2:1:N-1,
    if ( X(i-1)<=X(i) && X(i)>=X(i+1) )
        p_max(p,1) = i;
        p_max(p,2) = X (i);
        p = p+1;
    end
end
p_max(p,1)=N;
p_max(p,2)=X(N);
%上包络端点效应
if p>=4
    slope_left=(p_max(2,2)-p_max(3,2))/(p_max(2,1)-p_max(3,1));
    temp_left=slope_left*(p_max(1,1)-p_max(2,1))+p_max(2,2);
    if temp_left>p_max(1,2)
        p_max(1,2)=temp_left;
    end
    slope_right=(p_max(p-1,2)-p_max(p-2,2))/(p_max(p-1,1)-p_max(p-2,1));
    temp_right=slope_right*(p_max(p,1)-p_max(p-1,1))+p_max(p-1,2);
    if temp_right>p_max(p,2)
        p_max(p,2)=temp_right;
    end
elseif p<3
    flag=0;
end
%下包络
p_min(1,1)=1;
p_min(1,2)=X(1);
p=2;
for i=2:1:N-1,
    if ( X(i-1)>=X(i) && X(i)<=X(i+1))
        p_min(p,1) = i;
        p_min(p,2) = X (i);
        p = p+1;
    end
end
p_min(p,1)=N;
p_min(p,2)=X(N);
%下包络端点效应
if p>=4
    slope_left=(p_min(2,2)-p_min(3,2))/(p_min(2,1)-p_min(3,1));
    temp_left=slope_left*(p_min(1,1)-p_min(2,1))+p_min(2,2);
    if temp_left<p_min(1,2)
        p_min(1,2)=temp_left;
    end
    slope_right=(p_min(p-1,2)-p_min(p-2,2))/(p_min(p-1,1)-p_min(p-2,1));
    temp_right=slope_right*(p_min(p,1)-p_min(p-1,1))+p_min(p-1,2);
    if temp_right<p_min(p,2)
        p_min(p,2)=temp_right;
    end
elseif p<3
    flag=0;
end
end
%%
function [inaccuracy,dif,max,min,zero,same]=imf_judge(imf,A)
N=length(imf);
t=1:N;
[spmax, spmin]=envelop(imf);
upper= spline(spmax(:,1),spmax(:,2),t);
lower= spline(spmin(:,1),spmin(:,2),t);
inaccuracy=(mean(upper+lower))/A;
max=0;
min=0;
zero=0;
same=0;
for i=2:1:N-1,
    if (imf(i-1)<=imf(i) && imf(i)>=imf(i+1))
        max=max+1;
    end
    if (imf(i-1)>=imf(i) && imf(i)<=imf(i+1))
        min=min+1;
    end
    if ((imf(i-1)*imf(i)<0) || (imf(i-1)==0))
        zero=zero+1;
    end
    if (imf(i-1)==imf(i))
        same=same+1;
    end
end
if ((imf(i)*imf(N)<0) || (imf(i)==0))
    zero=zero+1;
end
if (imf(N)==0)
    zero=zero+1;
end
if (imf(i)==imf(N))
    same=same+1;
end
dif=max+min-zero-same;
end
%%
function c=imfX_cov(allmode)
M=size(allmode,2)-2;
c=zeros(1,M);
for i=2:M+1
    c(1,i-1)=max(xcorr(allmode(:,i),allmode(:,1)))/max(xcorr(allmode(:,1)));
end
end
%%
function io=orthogonality(allmode,X)
M=size(allmode,2)-2;
X_c=X*X';
io=0;
for i=2:M
    for j=i+1:M+1
        imfs_c=allmode(:,i)'*allmode(:,j);
        io=io+abs(imfs_c);
    end
end
io=io/X_c;
end