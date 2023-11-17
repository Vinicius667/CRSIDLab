% Function TVImpRespEstimation: Estimates the time varying impulse response of a
%                               system from its input and its output, using weighted ortho-
%                               normal basis functions (Laguerre functions) and  the time 
%                               varying recursive least-square (TVRecLeastSquares.m) code 
%                               to estimate the coefficient weights.
%                   
% Usage: [th,h,nmse,y,ypred] = TVImpRespEstimation(fs,y,u,p,nbi,nbf,ndi,ndf);
% Input:
%        fs - sampling frequency
%        y - output signal
%        u - input signal
%        p - system memory
%        nbi - min order 
%        nbf - max order 
%        ndi - min delay
%        ndf - max delay
%        
% Output:
%        th - time axis OF THE SYSTEM 
%        h - time-varying impulse response
%        nmse - normalized mean square error
%        y - real output
%        ypred - predicted output
%
% Adpated from Matlab laguerest.m
% Adapted by: Andr� Luis Souto Ferreira, March 2019

function [t,th,h,nmse,y,ypred,model] = TVImpRespEstimation(fs,y,u,p,alpha,gen,nbi,nbf,ndi,ndf,idMethod)
T = 1/fs; %period
lgth = length(y);

%Impulse response parameters
M = p; %system memory [no. of samples]
th = (0:M-1)'/fs; %time vector of impulse response [sec]

%% Estimate the impulse response: 1-input linear model

IN.signal = u;
IN.nbf    = [nbi,nbf];
IN.ndelay = [ndi,ndf]; %[no. of samples]
IN.M      = M;
IN.alpha  = alpha;
%IN.gen = [min(gen), max(gen)];
if strcmpi(idMethod,'mbf')
    IN.gen = gen;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if strcmpi(idMethod,'lbf')
    [ypred,nmse,kernel,model] = nonStationaryLinear_1in1out(y,IN);
else
    [ypred,nmse,kernel,model] = nonStationaryLinear_1in1out_Meixner(y,IN);
    %[ypred,nmse,kernel,model] = statjmeixner1np_abr(y,IN);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

h = kernel{1}/T; %scale estimated impulse response by sampling period

% Removing first 25 seconds because Recursive Leas Squares algorithm
% takes approximatelly 20 seconds to stabilize - Javier Jo 2003
% h = h(:,25 * fs:end);

h_size = size(h);
t = (0:h_size(2)-1)'/fs;

end

function varargout = nonStationaryLinear_1in1out(varargin)

% [ypred,nmse,kernel,model,allmdl] = stationaryLinear_1in1out(out,in)
%
% stationaryLinear_1in1out returns the optimal impulse response determined
% by the basis function expansion technique. Use Laguerre functions as the 
% basis functions. Optimization of model parameters uses minimum 
% description length criteria.
% Model: y = h1*x1 (* denotes convolution in this case)
%
% Input arguments: [out,in]
% out = output signal of the system
% in  = input struct
%   .signal = input signal
%   .nbf = range of model order (no. of basis functions) [from, to] e.g.
%          range for x1 = [3,5] then .nbf = [3,5]
%   .ndelay = range of delays [from to] in no. of samples.
%             Positive ndelay means output LAGS input by ndelay samples.
%             Negative ndelay means output LEADS input by ndelay samples.
%             e.g. range for x1 = [-2,2] then .ndelay = [-2,2]
%   .M = system length = memory length = length of kernel [no. of samples]
%        e.g. M of x1 = 50 then .M = 50
%   .alpha = matrix of damping coefficients for Laguerre functions,
%            determine how fast BF decays 
%            e.g. alpha1 for x1 then .alpha = alpha
%
% Output arguments: [ypred,nmse,kernel,model,allmdl]
% ypred = predicted output
% nmse = normalized mean squared error of output prediction
% kernel = impulse response
% model = model-related parameters
%   .bf = optimal sets of basis functions
%   .ndelay = optimal delay [no. of samples]
%   .c = expansion coefficients
% allmdl = all combinations of model parameters and corresponding MDL


%% Check input and output arguments

[y,in1,flagRow] = checkFunccall(varargin,nargout);
if isempty(y)
    error('Incorrect function call. Check input and/or output arguments.');
end

lgth  = length(y); %length of signal [samples]
delay1 = (in1.ndelay(1):in1.ndelay(2)); %delays [no. of samples]

%% Generate BFs for all possible model orders

bf1 = cell(in1.nbf(2));
for m=in1.nbf(1):in1.nbf(2) %model order
    %Generate BFs based on specified parameters:
    %1. model order, m
    %2. damping coefficient, alpha
    %3. system length or memory, M
    bf1{m} = laguer(m, in1.alpha, in1.M);
    %bf1{m} = meixnerFilt(m,0, in1.alpha,in1.M);
end %end for m
clear m;


%% Generate Vx for all possible combinations of model parameters
%  where Vx = the convolution of BFs with the input

Vx1 = cell(in1.nbf(2), length(delay1));
for d=1:length(delay1) %delay
    
    %Adjust input signal with different delays
    xx = zeros(1,lgth);
    if delay1(d) > 0 %output LAGS input
        xx(1+delay1(d):lgth) = in1.signal(1:lgth-delay1(d));
    else %output LEADS input
        xx(1:lgth+delay1(d)) = in1.signal(1-delay1(d):lgth);
    end
    
    for m=in1.nbf(1):in1.nbf(2) %model order
        vv = zeros(length(xx),m);
        for k=1:m
            vv(:,k) = filter(bf1{m}(:,k),1,xx); %convolve each BF (from current set of BF) with input
        end
        
        %Exclude the first M points because convolution doesn't use the full length of BFs
        %if lgth>(3*in1.M)
        %    Vx1{m,d} = vv(in1.M+1:lgth,:); %get rid of the first M points because convolution doesn't use the full length of BFs
        %else
            Vx1{m,d} = vv; %use all the points due to short data length
        %end

        clear vv;
    end %end for m
    clear xx;
end %end for d
clear d m k;

%Update data length and output lgth
%if lgth>3*in1.M
%    y = y(in1.M+1:lgth);
%    lgth = lgth - in1.M;
%end


%% Optimization process

allmdl = zeros(1e6,3); %m1, d1, mdl
counter = 0;

for m1=in1.nbf(1):in1.nbf(2)
for d1=1:length(delay1)
    
    counter = counter + 1;
	  
    %Input kernel
    vv = Vx1{m1,d1}'; %input1 kernel (for model order = m1 and delay = delay1(d1))

    %Estimate expansion coefficients using Time Varying Recursive Least-Squares method
    [ypred,err,c] = TVRecLeastSquares(y,vv);
    
    %Prediction and NMSE
    nmse  = var(err)/var(y); %normalized mean squared error
    
    %Minimum Description Length
    %MDL = log(NMSE) + (no. of estimated coefficients)*log(signal length)/(signal length)
    %where NMSE = var(error)/var(output)
    mdl = log(nmse) + m1*log(lgth)/lgth;
    
    %Collect model parameters and MDL
    allmdl(counter,1) = m1;
    allmdl(counter,2) = d1;
    allmdl(counter,3) = mdl;

end %end for d1
end %end for m1

%Get rid of extra rows in allMDL
allmdl = allmdl(1:counter,:);


%% Optimization: lowest MDL

%Find optimal combination (lowest MDL)
[junk,ii] = min(allmdl(:,size(allmdl,2)));

%Optimal model parameters
m1 = allmdl(ii,1);
d1 = allmdl(ii,2);

clear junk ii;


%% Generate output

%BFs
mm1 = bf1{m1};

%Optimal delay [no. of samples]
ndelay1 = delay1(d1);

%Convolution of optimal sets of BFs with inputs
vv = Vx1{m1, d1}';

%Coefficients using Time Varying Recursive Least-Squares
[ypred,err,c] = TVRecLeastSquares(y,vv);

M = in1.M;

%Impulse responses
h1 = zeros(M,lgth);
for i = 1:1:M
    b = mm1(i,:);
    for n = 1:1:lgth
        x = c(n,:);
        h1(i,n) = x * b';
    end 
end

%Limiting size of estimated impulse response
h1 = h1(1:M,:);

%Kernel
kernel = {h1};

%Normalized mean squared error
nmse = var(err)/var(y);

%Collect model-related outputs
model.bf     = {mm1};
model.ndelay = ndelay1;
model.c      = {c};


%% Function outputs: [ypred,nmse,kernel,model,allmdl]

varargout{1} = ypred;
varargout{2} = nmse;
varargout{3} = kernel;
varargout{4} = model;
varargout{5} = allmdl;

end %end for stationaryLinear_1in1out(varargin)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MODIFICA��O DIA 05/02/2022
% CRIA��O DE NOVA FUN��O
function varargout = nonStationaryLinear_1in1out_Meixner(varargin)

% [ypred,nmse,kernel,model,allmdl] = stationaryLinear_1in1out(out,in)
%
% stationaryLinear_1in1out returns the optimal impulse response determined
% by the basis function expansion technique. Use Laguerre functions as the 
% basis functions. Optimization of model parameters uses minimum 
% description length criteria.
% Model: y = h1*x1 (* denotes convolution in this case)
%
% Input arguments: [out,in]
% out = output signal of the system
% in  = input struct
%   .signal = input signal
%   .nbf = range of model order (no. of basis functions) [from, to] e.g.
%          range for x1 = [3,5] then .nbf = [3,5]
%   .ndelay = range of delays [from to] in no. of samples.
%             Positive ndelay means output LAGS input by ndelay samples.
%             Negative ndelay means output LEADS input by ndelay samples.
%             e.g. range for x1 = [-2,2] then .ndelay = [-2,2]
%   .M = system length = memory length = length of kernel [no. of samples]
%        e.g. M of x1 = 50 then .M = 50
%   .alpha = matrix of damping coefficients for Laguerre functions,
%            determine how fast BF decays 
%            e.g. alpha1 for x1 then .alpha = alpha
%
% Output arguments: [ypred,nmse,kernel,model,allmdl]
% ypred = predicted output
% nmse = normalized mean squared error of output prediction
% kernel = impulse response
% model = model-related parameters
%   .bf = optimal sets of basis functions
%   .ndelay = optimal delay [no. of samples]
%   .c = expansion coefficients
% allmdl = all combinations of model parameters and corresponding MDL


%% Check input and output arguments

[y,in1,flagRow] = checkFunccall(varargin,nargout);
if isempty(y)
    error('Incorrect function call. Check input and/or output arguments.');
end

lgth  = length(y); %length of signal [samples]
delay1 = (in1.ndelay(1):in1.ndelay(2)); %delays [no. of samples]

%% Generate BFs for all possible model orders

bf1 = cell(in1.nbf(2),in1.gen(2)+1);
for m=in1.nbf(1):in1.nbf(2) %model order
    for og = in1.gen(1):in1.gen(2) %generalization order
        %Generate BFs based on specified parameters:
        %1. model order, m
        %2. damping coefficient, alpha
        %3. generalization order, gen
        %4. system length or memory, M
        %bf1{m} = laguer(m, in1.alpha, in1.M);
        bf1{m,og+1} = meixnerFilt(m,og,in1.alpha,in1.M);         %%VERIFICAR SE � ASSIM MESMO!!
    end %end for og
end %end for m
clear m og;


%% Generate Vx for all possible combinations of model parameters
%  where Vx = the convolution of BFs with the input

Vx1 = cell(in1.nbf(2),in1.gen(2)+1,length(delay1));
for d=1:length(delay1) %delay
    
    %Adjust input signal with different delays
    xx = zeros(1,lgth);
    if delay1(d) > 0 %output LAGS input
        xx(1+delay1(d):lgth) = in1.signal(1:lgth-delay1(d));
    else %output LEADS input
        xx(1:lgth+delay1(d)) = in1.signal(1-delay1(d):lgth);
    end
    
    for m=in1.nbf(1):in1.nbf(2) %model order
        vv = zeros(length(xx),m);
        for og = in1.gen(1):in1.gen(2)  %generalization order
            a = bf1{m,og+1};
            for k=1:m
                vv(:,k) = filter(a(:,k),1,xx); %convolve each BF (from current set of BF) with input
            end
            Vx1{m,og+1,d} = vv; %use all the points due to short data length
        end
        
        %Exclude the first M points because convolution doesn't use the full length of BFs
        %if lgth>(3*in1.M)
        %    Vx1{m,d} = vv(in1.M+1:lgth,:); %get rid of the first M points because convolution doesn't use the full length of BFs
        %else
%              Vx1{m,og+1,d} = vv; %use all the points due to short data length
        %end

        clear vv;
    end %end for m
    clear xx;
end %end for d
clear d m k og;

%Update data length and output lgth
%if lgth>3*in1.M
%    y = y(in1.M+1:lgth);
%    lgth = lgth - in1.M;
%end


%% Optimization process

allmdl = zeros(1e6,4); %m1, d1, og, mdl
counter = 0;

for m1=in1.nbf(1):in1.nbf(2)
for d1=1:length(delay1)
for og = in1.gen(1):in1.gen(2)
    
    counter = counter + 1;
	  
    %Input kernel
    vv = Vx1{m1,og+1,d1}'; %input1 kernel (for model order = m1 and delay = delay1(d1))


    %Estimate expansion coefficients using Time Varying Recursive Least-Squares method
    [ypred,err,c] = TVRecLeastSquares(y,vv);
    
    %Prediction and NMSE
    nmse  = var(err)/var(y); %normalized mean squared error
    
    %Minimum Description Length
    %MDL = log(NMSE) + (no. of estimated coefficients)*log(signal length)/(signal length)
    %where NMSE = var(error)/var(output)
    mdl = log(nmse) + m1*log(lgth)/lgth;
    
    %Collect model parameters and MDL
    allmdl(counter,1) = m1;
    allmdl(counter,2) = d1;
    allmdl(counter,3) = og;     % Adicionado
    allmdl(counter,4) = mdl;
    

end %end for og
end %end for d1
end %end for m1

%Get rid of extra rows in allMDL
allmdl = allmdl(1:counter,:);


%% Optimization: lowest MDL

%Find optimal combination (lowest MDL)
[junk,ii] = min(allmdl(:,size(allmdl,2)));

%Optimal model parameters
m1 = allmdl(ii,1);
d1 = allmdl(ii,2);
og = allmdl(ii,3);

clear junk ii;


%% Generate output

%BFs
mm1 = bf1{m1,og+1};

%Optimal delay [no. of samples]
ndelay1 = delay1(d1);

%Optimal OG
og_opt = og;

%Convolution of optimal sets of BFs with inputs
vv = Vx1{m1,og+1,d1}';

%Coefficients using Time Varying Recursive Least-Squares
[ypred,err,c] = TVRecLeastSquares(y,vv);

M = in1.M;

%Impulse responses
h1 = zeros(M,lgth);
for i = 1:1:M
    b = mm1(i,:);
    for n = 1:1:lgth
        x = c(n,:);
        h1(i,n) = x * b';
    end 
end

%Limiting size of estimated impulse response
h1 = h1(1:M,:);

%Kernel
kernel = {h1};

%Normalized mean squared error
nmse = var(err)/var(y);

%Collect model-related outputs
model.bf     = {mm1};
model.ndelay = ndelay1;
model.c      = {c};
model.GenOrd = og_opt;      %% ADICIONADO 


%% Function outputs: [ypred,nmse,kernel,model,allmdl]

varargout{1} = ypred;
varargout{2} = nmse;
varargout{3} = kernel;
varargout{4} = model;
varargout{5} = allmdl;

end %end for stationaryLinear_1in1out(varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% function varargout = statjmeixner1np_abr(varargin)
% %function[y,yn,Hx1,CD1,DD1,NMSE,minMDL,g1]=statjmeixner1np(o,x,lgth,N)
% % finds the minimum number of Basis Functions and the optimal number of 
% % lags between each input and the output (CD1) that are needed 
% % to describe the kernels Hx1 from the system with 
% % one input (x) and one output (o).
% %
% % lgth=data length 
% % N= Impulse response length (in tis research N=50 )
% % y= output
% % yn=Estimated output
% % Hx1= RSA impuse response <--actually this should be Hx2 (ABR) but I'm too lazy to change. They use the same computation anyway (ming 02/19/2009)
% % DD1=parameter n which determines how late the MBF will start to fluctuate.  
% % g1=Basis function for RSA impulse response
% 
% % 09/01/08 added c1 as an output by ming
% % 01/23/2009 Modified by Ming to compute ABR estimate (note all the parameters' names had not been changed to match ABR)
% % 02/19/2009 modify by ming to clean up confusing routines and hopefully correct errors
% % 11/10/2010 modify by ming to use only meixner-like function and use D=0
% %               to generate a set of Laguerre functions
% 
% [y,in1,flagRow] = checkFunccall(varargin,nargout);
% 
% lgth  = length(y); %length of signal [samples]
% 
% lags = (in1.ndelay(1):in1.ndelay(2));
% n_lags = length(lags);
% 
% L = cell(in1.nbf(2),in1.gen(2)+1);
% %MBf
% for k=in1.nbf(1):in1.nbf(2)
%     for D=in1.gen(1):in1.gen(2)
%      %[g] = mbf(k,D,p(k,D+1),N);
%        [g] = meixnerFilt(k,D,in1.alpha,in1.M);
%         L(k,D+1)={g} ;
%     end
% end 
% % %LF D=6 is LF
% % D=6;
% % for k=4:8
% % g=lagufn3(N,k,al(k));
% % L(k,D)={g};
% % end
% 
% %% generate all possible Vx1: for all possible numbers of Basis functions and all possible delays
% 
% cVx1 = cell(in1.nbf(2),in1.gen(2)+1,n_lags);
% 
% for ND = 1:n_lags
%     INP1 = zeros(1,lgth);
%     if lags(ND) < 0
%         INP1(1:lgth+lags(ND)) = in1.signal(1-lags(ND):lgth);
%     else
%         INP1(1+lags(ND):lgth) = in1.signal(1:lgth-lags(ND));
%     end
%     for k=in1.nbf(1):in1.nbf(2)
%         Vx1 = zeros(length(INP1),k);
%         for D=in1.gen(1):in1.gen(2)
%             a=L{k,D+1};
%             for NLF=1:k
%                 Vx1(:,NLF) = filter(a(:,NLF),1,INP1);      
%             end
%         cVx1{k,D+1,ND} = Vx1;   %input kernel for input1 with model order k, Order of generalization D, and lag = lags(ND)
%         end
%     end
%     %waitbar(ND/n_lags/4,h);
% end
% 
% %% OPTIMIZATION PROCESS: 
% minMDL=1000000000;
% 
% % for testing, ND1 = 1; k1 = 4; D1 = 1;
% for ND1=1:n_lags    %%% allow impulse response of ABR to start rising from t = 0, ming 11/09/2010
% for k1=in1.nbf(1):in1.nbf(2)
% for D1=in1.gen(1):in1.gen(2)  
%       %input kernels
%       Vx1=cVx1{k1,D1+1,ND1};
%       %basis functions 
%       L11=L{k1,D1+1}; 
%       % Parameters of the ARX model:
%       y2=Vx1';
%       c1=y*pinv(y2);
%       Hx1=c1*L11';
%       yn=c1*y2;
%       err=y-yn;
%       er=var(err);
% 
% %       corrERRx1 = abs(sum(err.*x1)/lgth/(std(x1)*std(err)));
%       MDL = log(er) + (k1)*log(lgth)/lgth;
% 
%       % Optimization Conditions: 
%       % (1) Minimum MDL
%       % (2) Correlation residuals-inputs not significant <--not using this now
%       % (3) RCC negative peak during 1st 2.5 seconds
%         if   minMDL>MDL & max(Hx1(1:10)) > max(-Hx1(1:10)) %& corrERRx1<thres_corr% Positive Peak for ABR
%                 minMDL = MDL;
%                 maxNLF1 = k1;
%                 DD1=D1;
%                 CD1=ND1;
%         end     
% end           
% end
%     %waitbar(0.25+0.5*ND1/6,h)
% end
% 
% 
% %% generate output
% 
% % if DD1<6
% %     g1 = mbf(maxNLF1,DD1,p(maxNLF1-3,DD1),N);
% % else
% %     g1=lagufn3(N,maxNLF1,al(maxNLF1));
% % end
% 
% g1 = meixnerFilt(k,D,in1.alpha,in1.M);
%     
% Vx1=cVx1{maxNLF1,DD1+1,CD1};
% y2=Vx1'; c1=y*pinv(y2);
% Hx1=c1*g1';
% % Prediction output
% yn=c1*y2;
% er=yn-y;
% NMSE=var(er)/var(y);
% % Impulse Responses:
% CD1=lags(CD1);
% 
% % M = in1.M;
% % %Limiting size of estimated impulse response
% % Hx1 = Hx1';
% % Hx1 = Hx1(1:M,:);
% % Hx1 = Hx1';
% 
% %Kernel
% kernel = {Hx1};
% 
% %Collect model-related outputs
% model.bf     = L11;
% model.ndelay = CD1;
% model.c      = c1;
% model.GenOrd = DD1;      %% ADICIONADO 
% 
% %% Function outputs: [ypred,nmse,kernel,model,allmdl]
% 
% varargout{1} = yn;
% varargout{2} = NMSE;
% varargout{3} = kernel;
% varargout{4} = model;
% varargout{5} = minMDL;
% 
% %close(h)
% end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MODIFICANDO A FUN��O DE MEIXNER PARA O MODELO VARIANTE NO TEMPO
% m = model order = no. of basis functions to be used
% alpha = damping coefficient (0 < alpha < 1)
% M = system length (memory)

function [g] = meixnerFilt(m,Delay,p,N)
% % meixnerFilt Filters data using Meixner-like filter
% %
% %   M = meixnerFilt(in,n,pole,gen,sysMem) applies the Meixner-like filter 
% %   of pole position given by 'p' (0<=p<=1), generalization order given by
% %   'gen' and filter length (system memory) given by 'sysMem' to data 'in'. 
% %   The data in must be uniformly sampled for the filter to be applied. 
% %   Returns matrix M with 'n' columns, containing the data filtered by 'n'
% %   Meixner-like filters with orders ranging from 0 to n-1.
% 
% no of Laguerre functions needed to generate 'n' Meixner-like functions
% j = max(Delay)+m+1;
% 
% % Laguerre filter
% lag = laguer(m,p,N)';
% 
% % transformation from Laguerre to Meixner
% U = eye(j-1)*p;
% U = [zeros(j-1,1) U];
% U = [U; zeros(1,j)];
% U = U+eye(j);
% U_aux = U;
% 
% fSolve = @idpack.mldividecov;
% %g = zeros(N,m,(max(Delay)-min(Delay)+1));
% %g = zeros(m+max(Delay),N);
%     
% if min(Delay)~=0
%     U = U^min(Delay);                
%     L = chol(U*U','lower');         
%     A = fSolve(L,U);
%     %g(:,:,1) = (A(1:m,:)*lag)';
%     g = (A(1:m,:)*lag)';
% else    % When gen = 0, then MBF = LBF
%     U = U^0;
%     %g(:,:,1) = lag(1:m,:)';
%     g = lag(1:m,:)';
% end
% for i = min(Delay)+1:max(Delay)
%     U = U*U_aux;
%     L = chol(U*U','lower');
%     A = fSolve(L,U);
%     g = (A(1:m,:)*lag)';
% end
% end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function [g] = meixnerFilt(m,Delay,p,N)
% meixnerFilt returns a set of Meixner basis functions.
% Input arguments:
%   m = number of model order 
%   Delay > 0, is to decrease the slope of rising time.
%   0 < p <1 is to vary the fluctuation
%   N = System length
% Return:
%   g = MBF

% Original Matlab code: Suvimol Sangkatumvong (Ming), November 2010.
% MODELING OF CARDIOVASCULAR AUTONOMIC CONTROL IN SICKLE CELL DISEASE
% Adapted by: Ayllah Ahmad Lopes, February 2022
% % 
Y = diag(p*ones(1,m-1),1)+eye(m);

%F = zeros(m,N);
lag = laguer(m,p,N)';

if Delay == 0
    A = eye(m);
    %F = lag(1:m,:);
    F = lag;
else
    X=inv(chol((Y^Delay)*(Y^Delay)','lower'));
    A = X\(Y^Delay);
    %F = (A(1:m,:)*lag);
    %F = A*lag;             % OBS: DEVE SER F = A*lag ou F = lag?
    F = lag;
end

g = (A*F)';
end

%% Ming's modification of the original mbf.m program
% try to comment and stick with notation in Brinker 1995

% in Brinker 1995, the order m starts at m=0
% n = Delay-1;
% D = p*ones(1,m+n-1);
% U = diag(p*ones(1,m-1+Delay),1)+eye(m+Delay);
% 
% F = laguer(m,p,N)';
% 
% Q = U*U';
% if Delay == 0
%     Q = eye(m+Delay);
% 
% end
% 
% % Q = (U^min(Delay))*(U^min(Delay)'); %calculate Q = U^Delay*U'^Delay
% % L = inv(chol(Q,'lower'));
% 
% for i = 1:Delay-1
%     Q = U*Q*U'; %calculate Q = U^Delay*U'^Delay
% end
% 
% L = inv(chol(Q)');
% 
% % compute A = L(n)*U^n
% A = L;
% for i = 0:Delay-1
%     A = A*U;
% end
% A = A(1:m,:);
% 
% 
% g = (A*F)';
% 
% end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% in: input
% n: data filtered
% p: pole position (0<=p<=1)  == alpha
% gen: generalization == gen
% sysMem: filter length (system memory)  == M

function b = laguer(m,alpha,M)

%laguer returns a set of Laguerre basis functions based on the selected
%model order (m) and system length (M).
%Implementation of Laguerre functions is based on Jo et al., Ann Biomed Eng
%2007 - eq. 4.
%
%Input arguments:
% m = model order = no. of basis functions to be used
%     e.g. if m = 4 then order goes from 0 to 3 i.e. has 4 functions total
% alpha = damping coefficient (0 < alpha < 1) = exponential decline of the 
%         Laguerre functions
% M = system length (memory)

b = zeros(M,m);
t = (1:M)';
b(:,1) = sqrt(alpha.^t*(1-alpha)); %b0
for mm=2:m
    b(1,mm) = sqrt(alpha)*b(1,mm-1); %initial value
    for t=2:M
        b(t,mm) = sqrt(alpha)*b(t-1,mm) + sqrt(alpha)*b(t,mm-1) - b(t-1,mm-1);  
    end
end %end for mm

%Flip sign at every odd order (1,3,5,...)
%(See Jo et al., Ann. Biomed. Eng. 2007 - eq. 3)
ii = (2:2:2*floor(m/2));
b(:,ii) = -b(:,ii);

end % end for laguer(m,alpha,M)

function [y,in,flagRow] = checkFunccall(varin,nvarout)

%Check if trying to call old function
if length(varin)>3 || nvarout>5
    warndlg({'Input and output arguments of "stationaryLinear_1in1out" function were modified (1/15/2016).';...
             'Please update the function call.'},...
            'Check input and output arguments');
    y = [];
    in = [];
    flagRow = [];
    return
end

%Split input arguments
y  = varin{1};
in = varin{2};

%Output
flagRow = 1;
if size(y,1) > size(y,2)
    %Output is a column vector
    flagRow = 0;
    y = y'; %transpose out into a row vector
end
lgth = size(y,2); %length of signal [no. of samples]

%Input
x = in.signal;
if size(x,1) > size(x,2) %Each input is a column vector
    x = x'; %transpose x into a row vector
end
nx = size(x,1); %number of inputs
if nx~=1
    error('Incorrect number of input signals (requires 1 input signal).');
end

%Check input length
if lgth<size(x,2)
    %Output length is shorter than input length --> trim input at the end
    x = x(:,1:lgth);
elseif lgth>size(x,2)
    %Output length is longer than input length --> trim output at the end
    lgth = size(x,2);
    y = y(1:lgth);
end

%Check model parameters for inputs
if size(in.nbf,1)~=nx || size(in.ndelay,1)~=nx
    error('Parameters in input struct are not correctly entered.');
end

%Update signal in input struct
in.signal = x;

end % end for checkFunccall(varin,nvarout)
