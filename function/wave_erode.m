function x = wave_erode(s, se)

% 判断信号和结构元素是行向量还是列向量
flag = 0;
if size(se,1)>size(se,2)
    se = se';
end
if size(s,1)>size(s,2)
    s = s';
    flag = 1;
end

% 在信号两端各补齐一半结构元素长度的正无穷大，这样做腐蚀运算后信号长度可以保持不变
m = length(s);
n = length(se);
if rem(n,2)
    temp = inf * ones(1,(n-1)/2);
    s = [temp s temp];
else
    temp1 = inf * ones(1,n/2-1);
    temp2 = inf * ones(1,n/2);
    s = [temp1 s temp2];
end
%%

% 腐蚀运算过程
x_temp=zeros(n,m);
for i=1:n   
    x_temp(i,:)=s(i:i+m-1)-se(i);
end
x=min(x_temp,[],1);
%%

% 如果曾经改变信号的行列性质，恢复原状
if flag
    x = x';
end
end