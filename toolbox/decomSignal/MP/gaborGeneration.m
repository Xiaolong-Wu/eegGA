function [gaborSet,gaborNo,gaborShape]=gaborGeneration(N,fs,spikeShape,waveBase,fMin,SigmaMax,fBase,SigmaBase,fStep,SigmaStep,tNum)

t=(0:N-1)/fs;

gaborSet=[];
gaborShape=[];
gaborNo{1,1}='tr';
gaborNo{2,1}='mu';
gaborNo{3,1}='sigma and scale';
gaborNo{4,1}='f';

r_tr=1;
r_mu=1;
r_Sigma=1;
r_f=1;

if length(fStep)>1
    fAll=fStep;
elseif fStep==0
    fIndex=0:1:ceil(log2(fBase/fMin));
    fAll=fBase./(2.^fIndex);
else
    fAll=fBase:-fStep:fMin;
end
for f=fAll
    
    switch spikeShape
        case 'none'
            Scale=t(end);
        case 'peak'
            Scale=0.5/f;
        case 'troughPeak'
            Scale=1/f;
    end
    
    if length(SigmaStep)>1
        SigmaAll=SigmaStep;
    elseif SigmaStep==0
        SigmaIndex=0:1:floor(log2(SigmaMax/SigmaBase));
        SigmaAll=SigmaBase*2.^SigmaIndex;
    else
        SigmaAll=SigmaBase:SigmaStep:SigmaMax;
    end
    for Sigma=SigmaAll
        
        if ~strcmp(spikeShape,'none')
            if Scale/2>=3*Sigma
                continue;
            end
        end
        G=1/(sqrt(2*pi)*Sigma);
        
        muMin=-Scale/2;
        muMax=Scale/2;
        muStep=Scale/tNum;
        for mu=muMin:muStep:muMax
            
            trMid=t(end)/2;
            x=t-trMid;
            pha=2*pi*f*x;
            [Cos,setZero]=cosAndZero(pha,spikeShape,waveBase);
            
            I=-(x-mu).^2/(2*Sigma^2);
            Gauss=G*exp(I);
            
            GaborTemp=setZero.*Gauss.*Cos;
            GaborNorm=GaborTemp/(GaborTemp*GaborTemp')^0.5;
            GaborExtend=[zeros(1,N) GaborNorm zeros(1,N)];
            
            trStep=1/(tNum*f);
            translation=t(1):trStep:t(end);
            for tr=translation
                
                first=N+1+floor((trMid-tr)*fs);
                last=first-1+N;
                Gabor=GaborExtend(first:last);
                gaborSet=[gaborSet,Gabor'];
                
                gaborNo{1,2}(1,r_tr)=size(gaborSet,2);
                gaborNo{1,2}(2,r_tr)=tr;
                r_tr=r_tr+1;
            end
            
            gaborShape(:,r_mu)=GaborNorm';
            
            gaborNo{2,2}(1,r_mu)=size(gaborSet,2);
            gaborNo{2,2}(2,r_mu)=mu;
            r_mu=r_mu+1;
        end
        
        gaborNo{3,2}(1,r_Sigma)=size(gaborSet,2);
        gaborNo{3,2}(2,r_Sigma)=Sigma;
        gaborNo{3,2}(3,r_Sigma)=Scale;
        r_Sigma=r_Sigma+1;
    end
    
    gaborNo{4,2}(1,r_f)=size(gaborSet,2);
    gaborNo{4,2}(2,r_f)=f;
    r_f=r_f+1;
end
end

function [Cos,setZero]=cosAndZero(pha,spikeShape,waveBase)

switch spikeShape
    case 'none'
        setZero1=ones(size(pha));
        setZero2=ones(size(pha));
    case 'peak'
        setZero1=(pha>=-pi/2);
        setZero2=(pha<=pi/2);
    case 'troughPeak'
        setZero1=(pha>=-pi);
        setZero2=(pha<=pi);
end
setZero=setZero1.*setZero2;

switch waveBase
    case 'cos'
        switch spikeShape
            case 'troughPeak'
                Cos=cos(pha-pi/2);
            otherwise
                Cos=cos(pha);
        end
    case 'delta'
        switch spikeShape
            case 'troughPeak'
                Cos=Delta(pha-pi/2);
            otherwise
                Cos=Delta(pha);
        end
end
end

function s=Delta(pha)

s=zeros(size(pha));
tTemp=mod(pha,2*pi);

s(tTemp<=pi)=-(2/pi).*tTemp(tTemp<=pi)+1;
s(tTemp>pi)=(2/pi).*tTemp(tTemp>pi)-3;
end