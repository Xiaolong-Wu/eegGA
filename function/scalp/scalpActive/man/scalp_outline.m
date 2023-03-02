function scalp_outline(res,cmax)

if nargin<2
    res=1000;
    cmax=0;
end

theta=0:2*pi/res:2*pi;
A=cos(theta);
B=sin(theta);
a_r=1.1+0.1*cos(theta);
a_l=-1.1+0.1*cos(theta);
b=0.2*sin(theta);

hold on;
plot3(A,B,cmax*ones(1,length(theta)),'-k','LineWidth',2);
hold on;
plot3(a_r,b,cmax*ones(1,length(theta)),'-k','LineWidth',2);
hold on;
plot3(a_l,b,cmax*ones(1,length(theta)),'-k','LineWidth',2);

nose=0.15;
hold on;
plot3([nose 0],[sqrt(1-nose^2) 1+nose],[cmax cmax],'-k','LineWidth',2);
hold on;
plot3([-nose 0],[sqrt(1-nose^2) 1+nose],[cmax cmax],'-k','LineWidth',2);
end