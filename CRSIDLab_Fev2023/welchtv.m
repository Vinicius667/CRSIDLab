function [Tvector,F,Pxx]= welchtv(signal,wsegment,fs,N,noverlap,wtype,t)
% Input:    
%           signal - values of the signal
%           wsegment - size of each window segment
%           fs - sampling frequency
%           N - number of DFT points
%           noverlap - number of overlapping samples
%           wtype - window type (ex.: hanning, hamming, ...)
%           t - time vector
% Output:   
%           F - frequency vector
%           Tvector - time vector
%           Pxx - power spectral density
%
%
% Description: Performs time variant welch to compute power spectral
%              density of input signal.
%                
% Original code: Êmille Késsy Ferreira de Souza
% Adapted by: André L. S. Ferreira

    % Applying detrend
    T = length(signal);
    lambda = 300;
    I = speye(T);
    D2 = spdiags(ones(T-2,1)*[1 -2 1],[0:2],T-2,T);
    z_stat = (I-inv(I+lambda^2*D2'*D2))*signal;

    % Spectrogram sampling 
    nfft = N;
    step = wsegment - noverlap;
    wsegmentTV = round(wsegment*0.9);

    % Window type 
    switch wtype
        case 0
            winTV = rectwin(wsegmentTV);
        case 1
            winTV = bartlett(wsegmentTV);
        case 2
            winTV = hamming(wsegmentTV);
        case 3
            winTV = hanning(wsegmentTV);
        case 4
            winTV = blackman(wsegmentTV);
    end

    noverlapTV = round(wsegmentTV-step); % Window inside the columns


    % Split the signal vector into segments of size winlen and saves it 
    % in a matrix where each column is a segment of data
    matSeg = buffer(z_stat,wsegment,noverlap,'nodelay');

    ncol = size(matSeg,2);

        for nn = 1:ncol

               [Pxx(:,nn),F] = pwelch(matSeg(:,nn),winTV,noverlapTV,nfft,fs);

        end

    incr = wsegment-noverlap;

    [a,b] = size(Pxx);
    tlength = t(end)-t(1);
    steplength = (incr /length(z_stat)*tlength);
    winlength = (wsegment /length(z_stat)*tlength);
    Tvector = ((0:b-1)') * steplength +winlength/2 ;

end 