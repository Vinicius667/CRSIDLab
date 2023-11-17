% Function TVRecLeastSquares: Estimation of time-varying linear model using RLS algorithm
%                             y(n) = theta(n)*u + e(n)
%                             theta(n): vector of parameters at time n;
% 
%                             Assume the vectors of output y and input u are in workspace
%                             y is N x 1, u is N x np
%                   
% Usage: [ypred2, e, theta] = TVRecLeastSquares(y, u);
% Input:
%        y - output signal
%        u - input signal
%        
% Output:
%        ypred2 - best predicted output
%        e - best vector of a posteriori errors
%        theta - best matrix of coefficients
%        
% Adpated from Matlab TVmodel_RLS.m
% Adapted by: André Luis Souto Ferreira, March 2019

function [ypred2, e, theta] = TVRecLeastSquares(y, u)
    
%%
    y = y';
    u = u';
    
    [row,col] = size(u);
    
%%   
    lambda = 0.97;
    
    % Struct with values of best results from determined lambda
    best.ypred2 = [];
    best.e = [];
    best.theta = [];
    best.lambda = lambda;
    
    while lambda ~= 0.996
        
        % input number of parameters to be estimated
        np = col;%input(' Enter number of parameters/coeffs to be estimated >>');
        N = row; % Total number of data points

        % Initialization
        x = zeros(np,1);    % vector containing input values at current time

        t = [1:1:N]';
        theta = zeros(N,np);  %tv parameter vector
        Perrvar = zeros(N,np);  %tv parameter error variance 
        P0 = 1000; % Initial parameter error variance - give it a very large number
        P = zeros(np,np);
        for i=1:np
            P(i,i) = P0;
        end;    % Initialize parameter error covariance matrix
        eprior = zeros(N,1); %Initialize vector of prior errors
        e = zeros(N,1);   %Initialize vector of updated errors

        for i=1:N,

        % Form x-vector
           x = u(i,:)'; 
        % Change in Predicted Output based on previous model parameter estimates
           if i==1
              ypred = y(i);
           else
              ypred = theta(i-1,:)*x;
           end;       
        % Error(difference) between y and model prediction
        %  where prediction uses prior values of model parameters
           eprior(i) = y(i) - ypred;

        % Update gain vector
           den = lambda + x'*P*x;
           K = P*x/den;

        %  Update parameter error covariance matrix
           P = (P - P*x*x'*P/den)/lambda;
           for k=1:np
              Perrvar(i,k) = P(k,k); %store updated P-var results
           end;
        % Update parameter vector with new parameter values and updated Kalman gain
           if i>1
            theta(i,:) = theta(i-1,:) + K'*eprior(i);
           end; 
        % Updated prediction (using updated parameter values)and error
           if i==1
              ypred2(i) = y(i);
           else
              ypred2(i) = theta(i,:)*x;
           end;  
           e(i) = y(i) - ypred2(i);

        end; % for i=1:N
        
        if lambda == 0.97            
            best.ypred2 = ypred2;
            best.e = e;
            best.theta = theta;
            best.lambda = lambda;
        else  
            corr = find(e < best.e);
            [erow,ecol] = size(e);
            [crow,ccol] = size(corr);
            
            if crow > erow/2
                best.ypred2 = ypred2;
                best.e = e;
                best.theta = theta;
                best.lambda = lambda;
            end
        end
        
        lambda = lambda + 0.001;
        
    end; % while lambda ~= 0.996
    
    ypred2 = best.ypred2;
    e = best.e;
    theta = best.theta;
    best.lambda;
    
end



