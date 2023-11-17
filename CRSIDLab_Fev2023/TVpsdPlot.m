function TVpsdPlot(pHandle,pSig,userOpt)
% TVpsdPlot Plots a segment of TV data in psdMenu
%   TVpsdPlot(pHandle,pSig,userOpt) shows a segment of the time-
%   variant psd in psdMenu. As well, It plots LF and HF varia-
%   tions and LF/HF ratio variations. 
%
% Original code: Luisa Santiago C. B. da Silva, April 2017.
% Adapted by: André L. S. Ferreira, March 2019.

    options = get(userOpt,'userData');

    if ~isempty(options.session.tvpsd.sigLen)
        id = options.session.tvpsd.sigSpec{1};
        type = options.session.tvpsd.sigSpec{2};
        sig = get(pSig,'userData');

        % PSD's information (method, frequency, time, LF, HF and LF/HF)
        psdType = {'psdFFT','psdWelch','psdAR'};
        freqType = {'freqFFT','freqWelch','freqAR'};
        timeType = {'timeFFT','timeWelch','timeAR'};
        lfType = {'lfFFT','lfWelch','lfAR'};
        hfType = {'hfFFT','hfWelch','hfAR'};
        lfhfType = {'lfhfFFT','lfhfWelch','lfhfAR'};

        % Plotting PSD according to the selected method
        if options.session.tvpsd.cbVisSelection(1)
            for i = 1:3
                if options.session.tvpsd.cbSelection(i)

                    % Log of the PSD, to highlight the peaks
                    logpsd = log10(sig.(id).(type).aligned.tvpsd.(psdType{i}));
                    logpsd(find(logpsd<0))=0;
                    
                    % Plotting Power Spectral Density 
                    surf(pHandle,sig.(id).(type).aligned.tvpsd.(timeType{i}),...
                        sig.(id).(type).aligned.tvpsd.(freqType{i}),...
                        logpsd);   

                    axis tight;
                    view(0,90);
                    shading interp;

                    h = colorbar;
                    if strcmp(id, 'bp')
                        ylabel(h,'PSD (mmHg²/Hz)');
                    elseif strcmp(id, 'ecg')
                        ylabel(h,'PSD (ms²/Hz)');
                    else
                        ylabel(h,'PSD (L²/Hz)');
                    end
                        
                    xlabel('Time (s)');
                    ylabel('Frequency (Hz)');
                    
                    ylim([options.session.tvpsd.minF ...
                          options.session.tvpsd.maxF]);
                    
                    xlim([options.session.tvpsd.minP ...
                          options.session.tvpsd.maxP]);

                    set(gcf, 'PaperPositionMode', 'manual');
                    set(gcf, 'PaperPosition', [0 0 8 3]);

                    break;
                end
            end
        % Plotting LF and HF variations or LF/HF ratio according to the selected method
        else
            for i = 1:3
                if options.session.tvpsd.cbSelection(i)

                    % Plot LF and HF 
                    if options.session.tvpsd.cbVisSelection(2)
                        
                        plot(sig.(id).(type).aligned.tvpsd.(timeType{i}),...
                                sig.(id).(type).aligned.tvpsd.(lfType{i}),...
                                'b','Linewidth',1);
                        hold on;
                        plot(sig.(id).(type).aligned.tvpsd.(timeType{i}),...
                                sig.(id).(type).aligned.tvpsd.(hfType{i}),...
                                'k','Linewidth',1);
    
                        xlabel('Time (s)');
                        if strcmp(id, 'bp')
                            ylabel('Power (mmHg²)');
                        elseif strcmp(id, 'ecg')
                            ylabel('Power (ms²)');
                        else
                            ylabel('Power (L²)');
                        end
                        legend('LF Power','HF Power');
            
                    % Plot LF/HF
                    elseif options.session.tvpsd.cbVisSelection(3)
                        
                        plot(sig.(id).(type).aligned.tvpsd.(timeType{i}),...
                                sig.(id).(type).aligned.tvpsd.(lfhfType{i}),...
                                'k','Linewidth',1);
                        hold on;

                        xlabel('Time (s)');
                        ylabel('Ratio LF/HF');
   
                    end
                    
                    ylim([options.session.tvpsd.minF ...
                          options.session.tvpsd.maxF]);
                    
                    xlim([options.session.tvpsd.minP ...
                          options.session.tvpsd.maxP]);
                    
                    axis tight;
                    hold off;

                    grid(pHandle,'on');
                    break;
                end
            end
        end

        set(pSig,'userData',sig);
        set(userOpt,'userData',options);
        set(get(pHandle,'children'),'visible','on');
    else
        ylabel(pHandle,'');
        set(get(pHandle,'children'),'visible','off');
    end
end