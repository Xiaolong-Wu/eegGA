function x = wave_erode(s, se)

% �ж��źźͽṹԪ��������������������
flag = 0;
if size(se,1)>size(se,2)
    se = se';
end
if size(s,1)>size(s,2)
    s = s';
    flag = 1;
end

% ���ź����˸�����һ��ṹԪ�س��ȵ����������������ʴ������źų��ȿ��Ա��ֲ���
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

% ��ʴ�������
x_temp=zeros(n,m);
for i=1:n   
    x_temp(i,:)=s(i:i+m-1)-se(i);
end
x=min(x_temp,[],1);
%%

% ��������ı��źŵ��������ʣ��ָ�ԭ״
if flag
    x = x';
end
end