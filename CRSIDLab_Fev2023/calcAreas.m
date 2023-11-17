function [aalf,aahf,rlfhf]=calcAreas(PSD,F,vlf,lf,hf)
% Input:    
%           PSD: power spectral density of RR interval
%           F: frequency vector
%           vlf: very low frequencies limit
%           lf: low frequencies limit
%           hf: high frequencies limit
%
% Output:   
%           aalf: absolut area of low frequencies
%           aahf: absolut area of high frequencies
%           rlfhf: ratio LF/HF
%
%
% Description: Calculates areas of the PSD plots. 
%                
% Original code: Êmille Késsy Ferreira de Souza
% Adapted by: André L. S. Ferreira


    % Calculates the number of points in the spctrum
    [nlin,ncol]=size(PSD);

    % Calculates the maximum frequency
    maxF=F(2)*nlin;

    if hf>F(end)
        hf=F(end);
        if lf>hf
            lf=F(end-1);
            if vlf>lf
                vlf=F(end-2);
            end
        end
    end

    % Calculates the limit point of each band
    indice_vlf=round(vlf*nlin/maxF)+1;
    indice_lf=round(lf*nlin/maxF)+1;
    indice_hf=round(hf*nlin/maxF)+1;
    if indice_hf>nlin,
        indice_hf=nlin;
    end

    aatotal=zeros(1,ncol);
    aavlf=zeros(1,ncol);
    aalf=zeros(1,ncol);
    aahf=zeros(1,ncol);
    rlfhf=zeros(1,ncol);

    for i=1:ncol % ncol references to time vector

        % Total energy (from 0 to hf2) in ms^2
        aatotal(i)=F(2)*sum(PSD(1:indice_hf-1,i));

        % Energy of very low frequencies (from 0 to vlf2)
        aavlf(i)=F(2)*sum(PSD(1:indice_vlf-1,i));

        % Area of low frequencies (from vlf2 to lf2)
        aalf(i)=F(2)*sum(PSD(indice_vlf:indice_lf-1,i));

        % Area of high frequencies (from lf2 to hf2)
        aahf(i)=F(2)*sum(PSD(indice_lf:indice_hf-1,i));
        
        % LF/HF ratio
        rlfhf(i)=aalf(i)/aahf(i);

        % With 4 decimal points
        rlfhf(i)=round(rlfhf(i)*10000)/10000;
    end
end




