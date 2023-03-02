function se=wave_se(m,shape)

if strcmp(shape,'flat')
    se=zeros(1,m);
elseif strcmp(shape(1:3),'cos')
    t=-pi:2*pi/(m-1):pi;
    A=str2double(shape(4:end));
    
    se=A*cos(t);
else
    disp(' ');
    disp('please redefine SE!');
    keyboard;
end
end