function codeNum=num2code(originalNum,N)

Num=fix(originalNum);
strNum=num2str(Num);
N_temp=length(strNum);
if N<N_temp
    disp('the str length N is too small, plaese increase it!');
    keyboard;
else
    codeNum=[];
    
    N_diff=N-N_temp;
    if N_diff
        for r=1:N_diff
            
            codeNum=[codeNum num2str(0)];
        end
    end
    codeNum=[codeNum strNum];
end
end