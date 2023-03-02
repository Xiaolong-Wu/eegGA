function [alpha_v,F_v,F_p] = granger_cause(x,y,alpha,max_lag)
% [alpha_v,F_v,F_p] = granger_cause(x,y,alpha,max_lag)
% Granger Causality test
% Does Y Granger Cause X?

% User-Specified Inputs:
%   x -- A column vector of data
%   y -- A column vector of data
%   alpha -- the significance level specified by the user
%   max_lag -- the maximum number of lags to be considered
% User-requested Output:
%   alpha_v -- The critical value from the F-distribution
%   F_v -- The value of the F-statistic
%   F_p -- The significance level of F_v

% The lag length selection is chosen using the Bayesian information
% Criterion
% Note that if F > c_v we reject the null hypothesis that y does not
% Granger Cause x

% Chandler Lutz, UCR 2009
% Questions/Comments: chandler.lutz@email.ucr.edu
% $Revision: 1.0.0 $  $Date: 09/30/2009 $
% $Revision: 1.0.1 $  $Date: 10/20/2009 $
% $Revision: 1.0.2 $  $Date: 03/18/2009 $

% References:
% [1] Granger, C.W.J., 1969. "Investigating causal relations by econometric
%     models and cross-spectral methods". Econometrica 37 (3), 424?38.

% Acknowledgements:
%   I would like to thank Mads Dyrholm for his helpful comments and
%   suggestions
%
%   Wu Xiaolong made some changes to this function on December 20, 2020
%%

%Make sure x & y are the same length
if (length(x) ~= length(y))
    error('x and y must be the same length');
end

%Make sure x is a column vector
[a,b] = size(x);
if (b>a)
    %x is a row vector -- fix this
    x = x';
end

%Make sure y is a column vector
[a,b] = size(y);
if (b>a)
    %y is a row vector -- fix this
    y = y';
end

%Make sure max_lag is >= 1
if max_lag < 1
    error('max_lag must be greater than or equal to one');
end

T = length(x);

%Make sure z_lag is >= 1
if max_lag>floor((T-2)/2)
    max_lag=floor((T-2)/2);
end
%%

%First find the proper model specification using the Bayesian Information
%Criterion for the number of lags of x
BIC = zeros(max_lag,1);

%Specify a matrix for the restricted RSS
RSS_R = zeros(max_lag,1);

i = 1;
while i <= max_lag
    ystar = x(i+1:T,:);
    xstar = [ones(T-i,1) zeros(T-i,i)];
    %Populate the xstar matrix with the corresponding vectors of lags
    j = 1;
    while j <= i
        xstar(:,j+1) = x(i+1-j:T-j);
        j = j+1;
    end
    %Apply the regress function. b = betahat, bint corresponds to the 95%
    %confidence intervals for the regression coefficients and r = residuals
    [b,bint,r] = regress(ystar,xstar);
    
    %Find the bayesian information criterion
    BIC(i,:) = T*log(r'*r/T) + (i+1)*log(T);
    
    %Put the restricted residual sum of squares in the RSS_R vector
    RSS_R(i,:) = r'*r;
    
    i = i+1;
    
end

[dummy,x_lag] = min(BIC);
%%

%First find the proper model specification using the Bayesian Information
%Criterion for the number of lags of y
BIC = zeros(max_lag,1);

%Specify a matrix for the unrestricted RSS
RSS_U = zeros(max_lag,1);

i = 1;
while i <= max_lag
    
    ystar = x(i+x_lag+1:T,:);
    xstar = [ones(T-(i+x_lag),1) zeros(T-(i+x_lag),x_lag+i)];
    %Populate the xstar matrix with the corresponding vectors of lags of x
    j = 1;
    while j <= x_lag
        xstar(:,j+1) = x(i+x_lag+1-j:T-j,:);
        j = j+1;
    end
    %Populate the xstar matrix with the corresponding vectors of lags of y
    j = 1;
    while j <= i
        xstar(:,x_lag+j+1) = y(i+x_lag+1-j:T-j,:);
        j = j+1;
    end
    %Apply the regress function. b = betahat, bint corresponds to the 95%
    %confidence intervals for the regression coefficients and r = residuals
    [b,bint,r] = regress(ystar,xstar);
    
    %Find the bayesian information criterion
    BIC(i,:) = T*log(r'*r/T) + (i+1)*log(T);
    
    RSS_U(i,:) = r'*r;
    
    i = i+1;
    
end

[dummy,y_lag] =min(BIC);
%%

z_lag=T-(x_lag+y_lag+1);

%The numerator of the F-statistic
F_num = ((RSS_R(x_lag,:) - RSS_U(y_lag,:))/y_lag);

%The denominator of the F-statistic
F_den = RSS_U(y_lag,:)/z_lag;

%The F-Statistic
alpha_v = finv(1-alpha,y_lag,z_lag);
F_v = F_num/F_den;
F_p = fcdf(F_v,y_lag,z_lag,'upper');

if isnan(F_p)
    keyboard;
end
end