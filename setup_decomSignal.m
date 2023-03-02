%%

disp(' ');disp('setup: decomposition');disp('<==============================>');
%% signal decomposition

Band_decom=[0,inf]; % filter, unit: Hz
%%

% EEMD:
% Nstd: ratio of the standard deviation of the added noise and that of X
% NE: Ensemble number for the EEMD
% Times: Set the max-times of envelope
% Err: Set the inaccuracy ratio (the mean of imf's final upper and lower envelop divided by the mean of the X's abs)
Nstd=0.01;
NE=100;
Times=10;
Err=0.01;

% MP:
% errPerL2: decomposition stopped when the error less than (errPerL2)%
errPerL2=5; 
%%

meth_decom={
    'EEMD';
    'MP'
    };

meth_decom_temp=meth_decom{Scale(3,1),1};

disp(' ');
disp(['decomposition method ===> ' meth_decom_temp]);