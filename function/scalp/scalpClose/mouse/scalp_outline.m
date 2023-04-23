function scalp_outline(res,cmax)

if nargin<2
    res=1000;
    cmax=0;
end

R=0.45;
L_bergma=0.3;
phi=pi/12;
nose=0.7;
w=(2/3)*pi;

theta(:,1)=-pi/2:pi/res:phi;
theta(:,2)=(pi-phi):pi/res:3*pi/2;
A=R*cos(theta);
B=-L_bergma+R*sin(theta);
earR=0.3+0.1*cos(theta);
earL=-0.3+0.1*cos(theta);
earM=-L_bergma+0.2*sin(theta);

p1=R*cos(phi);
p2=-L_bergma+R*sin(phi);
t=-p1:2*p1/res:p1;
% p2=b+a*cos(w*p1)
% nose=b+a*cos(w*0)
a=(p2-nose)/(cos(w*p1)-1);
b=nose-a;

hold on;
plot(0,0,'.k');
hold on;
plot3(A,B,cmax*ones(1,length(theta)),'-k','LineWidth',2);
hold on;
plot3(earR,earM,cmax*ones(1,length(theta)),'-k','LineWidth',2);
hold on;
plot3(earL,earM,cmax*ones(1,length(theta)),'-k','LineWidth',2);

hold on;
plot3(t,b+a*cos(w*t),cmax*ones(1,length(t)),'-k','LineWidth',2);

wm=1;
tm=-0.15:0.2/res:0.15;
am=[5;1;-3];
bm=nose-am;
for r=1:3
hold on;
plot3(tm,bm(r,1)+am(r,1)*cos(wm*tm),cmax*ones(1,length(tm)),'-k','LineWidth',2);
end

end