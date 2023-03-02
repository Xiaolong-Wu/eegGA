function [sparseCodeFull,sparseCode,sRecom,sFitManual,sFit,qual]=mpSparseCode(path_decom,s,fs,errPerL2)
% spikeShape: 'none', 'peak', 'troughPeak'
% waveBase: 'cos', 'delta'
% fMin:
% SigmaMax:
% fBase:
% SigmaBase:
% fStep:
% SigmaStep:
% tNum: >=4, the higher the value, the more accurate but slower the calculation

% if fStep or SigmaStep not 0, it will be [fMin:fStep:fBase] and [SigmaBase:SigmaStep:SigmaMax], otherwise the extend with fMin or SigmaBase *2^[1,2,3,...]
%%

N=length(s);
if ~exist(path_decom,'dir')
    mkdir(path_decom);
end

path_decom_temp=[path_decom '\mpdictSet.mat'];
if ~exist(path_decom_temp,'file')
    load('mpdictSet.mat');
    
    disp(' ');
    disp('please reset the variate (struct): mpdictSet');
    disp('and then input [return] in the command window, click Enter');
    keyboard;
    
    spikeShape=mpdictSet.spikeShape;
    waveBase=mpdictSet.waveBase;
    fMin=mpdictSet.fMin;
    SigmaMax=mpdictSet.SigmaMax;
    fBase=mpdictSet.fBase;
    SigmaBase=mpdictSet.SigmaBase;
    fStep=mpdictSet.fStep;
    SigmaStep=mpdictSet.SigmaStep;
    tNum=mpdictSet.tNum;
    [gaborSet,gaborNo,gaborShape]=gaborGeneration(N,fs,spikeShape,waveBase,fMin,SigmaMax,fBase,SigmaBase,fStep,SigmaStep,tNum);
    nID=size(gaborShape,2);
    
    sparseMu=zeros(nID,1);
    sparseSigma=zeros(nID,1);
    sparseScale=zeros(nID,1);
    sparseF=zeros(nID,1);
    for IDInd=1:nID
        
        muInd=gaborNo{2,2}(1,IDInd);
        sigmaInd=sum(gaborNo{3,2}(1,:)<muInd)+1;
        fInd=sum(gaborNo{4,2}(1,:)<muInd)+1;
        
        muTemp=gaborNo{2,2}(2,IDInd);
        sigmaTemp=gaborNo{3,2}(2,sigmaInd);
        scaleTemp=gaborNo{3,2}(3,sigmaInd);
        fTemp=gaborNo{4,2}(2,fInd);
        
        sparseMu(IDInd,1)=muTemp;
        sparseSigma(IDInd,1)=sigmaTemp;
        sparseScale(IDInd,1)=scaleTemp;
        sparseF(IDInd,1)=fTemp;
    end
    
    mpdictSet.gaborSet=gaborSet;
    mpdictSet.gaborNo=gaborNo;
    mpdictSet.gaborShape=gaborShape;
    mpdictSet.sparseMu=sparseMu;
    mpdictSet.sparseSigma=sparseSigma;
    mpdictSet.sparseScale=sparseScale;
    mpdictSet.sparseF=sparseF;
    save(path_decom_temp,'mpdictSet');
else
    load(path_decom_temp);
    
    spikeShape=mpdictSet.spikeShape;
    gaborSet=mpdictSet.gaborSet;
    gaborNo=mpdictSet.gaborNo;
    gaborShape=mpdictSet.gaborShape;
end
mpdictSet=[];
nID=size(gaborShape,2);
%%

% MP of original, Strict==0
% MP of no normalization mpdict, Strict==1
% MP of no normalization mpdict and no negative mpdict, Strict==2

switch spikeShape
    case 'none'
        Strict=0;
    case 'peak'
        Strict=1;
    case 'troughPeak'
        Strict=1;
end

mpdict=gaborSet;
iterMax=floor(N/2);
maxErr={'L2',errPerL2};
[sFit,sRes,coeff,iopt,qual]=wmpalgStrict(Strict,'MP',s,mpdict,'itermax',iterMax,'onceflag',1,'maxerr',maxErr);

[~,Ind]=sort(iopt);
nIter=length(Ind);
ErrL2=100*(norm(sRes)/norm(s));
disp(['iter: ' num2str(nIter) ', error: ' num2str(ErrL2) '%.']);

sparseCode=zeros(nID,N);
sparseCodeFull=sparseCode;
for r=1:nIter
    
    trInd=sum(gaborNo{1,2}(1,:)<iopt(Ind(r)))+1;
    muInd=sum(gaborNo{2,2}(1,:)<iopt(Ind(r)))+1;
    sigmaInd=sum(gaborNo{3,2}(1,:)<iopt(Ind(r)))+1;
    
    trTemp=gaborNo{1,2}(2,trInd);
    scaleTemp=gaborNo{3,2}(3,sigmaInd);
    
    IDInd=muInd;
    nTrInd=ceil(trTemp*fs)+1;
    nScale=floor(scaleTemp*fs);
    first=max(1,nTrInd-floor(nScale/2));
    last=min(N,first+nScale);
    
    sparseCode(IDInd,nTrInd)=coeff(Ind(r));
    sparseCodeFull(IDInd,first:last)=sparseCodeFull(IDInd,first:last)+coeff(Ind(r));
end
%%

sFitManual=mpdict(:,iopt(Ind))*coeff(Ind);

sTemp=zeros(nID,N);
for r0=1:nID
    
    sTemp(r0,:)=conv(sparseCode(r0,:),gaborShape(:,r0),'same');
end
sRecom=sum(sTemp)';
end