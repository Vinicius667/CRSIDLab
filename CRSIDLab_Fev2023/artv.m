function [time_vector,F,PSDmat] = artv(ecg_RRI,winlen,fs,N,noverlap,wtype,t,nn)
% Input:    
%           ecg_RRI - values of the signal
%           winlen - size of each window segment
%           fs - sampling frequency
%           N - number of DFT points
%           noverlap - number of overlapping samples
%           wtype - window type (ex.: hanning, hamming, ...)
%           t - time vector
%           nn - model order
% Output:   
%           F - frequency vector
%           time_vector - time vector
%           PSDmat - power spectral density
%
%
% Description: Performs time variant AR to compute power spectral
%              density of input signal.
%                
% Original code: Êmille Késsy Ferreira de Souza
% Adapted by: André L. S. Ferreira

    % PSD is calculated by windowing 
    T = length(ecg_RRI);
    lambda = 300;
    I = speye(T);
    D2 = spdiags(ones(T-2,1)*[1 -2 1],[0:2],T-2,T);
    z_stat = (I-inv(I+lambda^2*D2'*D2))*ecg_RRI;

    % Window type
    switch wtype
        case 0
            winTV = rectwin(winlen);
        case 1
            winTV = bartlett(winlen);
        case 2
            winTV = hamming(winlen);
        case 3
            winTV = hanning(winlen);
        case 4
            winTV = blackman(winlen);
    end

    % Spectrogram sampling
    nfft = N;
    step = winlen - noverlap;

    RRIlen = length(z_stat);

    j = 1;

    for i=1:step:(RRIlen-winlen+1)
                seg_RRI = z_stat(i:i+winlen-1).*winTV; 
                [ARcoef, var_err] = arburg(seg_RRI,nn);
                [H,F] = freqz(1,ARcoef,nfft,fs);
                PSD = (abs(H).^2)*var_err*1/fs;
                PSDmat(:,j) = PSD; % Each column corresponds to a time j
                j = j+1;

    end

    timelen = (length(t)-1)/fs; % In sec
    steplen = (step/RRIlen)*timelen; % In sec
    winlenS = (winlen/RRIlen)*timelen; % In sec
    ncol = size(PSDmat,2); % Number of columns
    time_vector = (((0:ncol-1)*steplen)+winlenS/2)';
    time_vector = time_vector';

end

