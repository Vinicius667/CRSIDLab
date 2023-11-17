function [t,f,psd] = stft(signal,wsegment,fs,N,noverlap,wtype)
% Input:    
%           signal - values of the signal
%           wsegment - size of each window segment (in samples)
%           fs - sampling frequency
%           N - number of DFT points
%           noverlap - number of overlapping samples
%           wtype - window type (ex.: hanning, hamming, ...)
% Output:   
%           f - frequency vector
%           t - time vector
%           psd - power spectral density
%
%
% Description: Performs short time fourier transform to compute 
%              power spectral density of input signal.
%                
% Original code: Êmille Késsy Ferreira de Souza
% Adapted by: André L. S. Ferreira

    % Applying detrend 
    T = length(signal);
    lambda = 300;
    I = speye(T);
    D2 = spdiags(ones(T-2,1)*[1 -2 1],[0:2],T-2,T);
    z_stat = (I-inv(I+lambda^2*D2'*D2))*signal;

    % STFT
    nfft = N;

    % Window type (wsegment in samples)
    switch wtype
        case 0
            window = rectwin(wsegment);
        case 1
            window = bartlett(wsegment);
        case 2
            window = hamming(wsegment);
        case 3
            window = hanning(wsegment);
        case 4
            window = blackman(wsegment);
    end

    [s,f,t,psd] = spectrogram(z_stat,window,noverlap,nfft*2,fs,'yaxis');

end