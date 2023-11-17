% Function calcAreasFreqBand: Calculates areas of low frequencies, high
%                             frequencies and low and high frequencies
%                   
% Usage: [aalf,aahf,aalfhf] =
%        calcAreasFreqBand(Tvector,transferFunc,F,vlf,lf,hf,filename,x,x1);
%
% Input:
%        Tvector - time axis
%        transferFunc - transfer function obtained from F(h(t))
%        F - frequency axis 
%        vlf - frequency limit of vrey low frequencies
%        lf - frequency limit of low frequencies
%        hf - frequency limit of high frequencies
%        filename - file to save data 
%        x - tilt's begin
%        x1 - tilt's end
%
% Output:
%        aalf - low frequency area 
%        aahf - high frequency area 
%        aalfhf - low and high frequency area 
%
% Original Matlab code: André Luis Souto Ferreira, April 2019

function [aalf,aahf,aalfhf] = calcAreasFreqBand(transferFunc,maxF,vlf,lf,hf)
   
    % Size of variable
    [nlin,ncol]=size(transferFunc);

    % Defines limit of each band frequency
    indice_vlf=round(vlf*nlin/maxF)+1;
    indice_lf=round(lf*nlin/maxF)+1;
    indice_hf=round(hf*nlin/maxF)+1;
    
    % Vector of frequency area 
    aalf=zeros(1,ncol);
    aahf=zeros(1,ncol);
    aalfhf=zeros(1,ncol);

    for i=1:ncol 

        % Calculating average magnitude for selected frequency frames
        aalf(i) = sum(transferFunc(indice_vlf:indice_lf-1,i))/((indice_lf-1)-indice_vlf);
        aahf(i) = sum(transferFunc(indice_lf:indice_hf-1,i))/((indice_hf-1)-indice_lf);
        aalfhf(i) = sum(transferFunc(indice_vlf:indice_hf-1,i))/((indice_hf-1)-indice_vlf);
        
    end
end




