function TVidentPlotImresp(pHandle,pMod,plotType)
% imrespPlot Plots system data in imrespMenu
%   imrespData(pHandle,pMod) plots the model's impulse response in pMod's 
%   userData property to handle pHandle. Displays the point used to 
%   calculate the quantitative indicators extracted from the impulse 
%   response.
%
% Original Matlab code: Luisa Santiago C. B. da Silva, April 2017.
% Based on plotting funtions from ECGLab (Carvalho,2001)

    model = get(pMod,'userData');
    time = model.imResp.time;
    
%     patient = get(pFile,'userData');
%     patient_ID = patient.info.ID;

    if strcmp(plotType,'Time Varying Impulse Response')   
        th = model.imResp.delay;
        imresp = model.imResp.impulse{1};

        mesh(pHandle,th,time',imresp');
        axis(pHandle,'tight');
        
        
        xlabel(pHandle,'\tau (seconds)');
        ylabel(pHandle,'Time (seconds)');
        zlabel(pHandle,[model.OutputUnit{:} '/' model.InputUnit{:}]);

        set(pHandle,'ydir','reverse');
        grid(pHandle, 'on');
        colormap(pHandle,jet);
        view(pHandle,[800 100 200]);
        
        rotate3d(pHandle,'on');
        
        
        %% Para salvar a imagem
%         fig = figure(3);
%         mesh(th,time',imresp');
%         axis('tight');
%         xlabel('\tau (sec)'); ylabel('Tempo (sec)'); zlabel('ms/mmHg');
%         
%         grid('on');
%         colormap(jet);
%         view([700 170 110]);
%         
%         zaxes = zlim();
%         xaxes = xlim();
%         yaxes = ylim();
% 
%         axis([xaxes(1) xaxes(2) yaxes(1) yaxes(2) zaxes(1) zaxes(2)]);
%         fig.Position = [722   248   906   620];
%         
%         filenameIR = ['Imagens\Laguerre_IR_' patient_ID '.fig'];
%         filenameIR_print = ['Imagens\Laguerre_IR_' patient_ID];
%         
%         savefig(fig,filenameIR);      
%         print('-f3',filenameIR_print,'-dpng','-r200');
        
%         close all;

    elseif strcmp(plotType,'Impulse Response Magnitude')
        irm = model.imResp.indicators.irm;

        plot(pHandle,time,irm);
        view(pHandle,2);
        axis(pHandle,'tight');
        set(pHandle,'ydir','normal');

        xlabel(pHandle,'Time (seconds)');
        ylabel(pHandle,[model.OutputUnit{:} '/' model.InputUnit{:}]);
        
        %% Para salvar a imagem
% %         fig = figure(3);
% %         plot(time,irm);
% %         view(2);
% %         axis('tight');
% %         
% %         xlabel('Time (seconds)'); ylabel('ms/mmHg');
% %         
% %         grid('on');
% %         
% %         filenameIR = ['Imagens\Laguerre_IRM_' patient_ID '.fig'];
% %         filenameIR_print = ['Imagens\Laguerre_IRM_' patient_ID];
% %         
% %         savefig(fig,filenameIR);      
% %         print('-f3',filenameIR_print,'-dpng','-r200');
        
%         close all;

    elseif strcmp(plotType,'Low Frequency Dynamic Gain')
        dglf = model.imResp.indicators.dg.lf;

        plot(pHandle,time,dglf);
        view(pHandle,2);
        axis(pHandle,'tight');
        set(pHandle,'ydir','normal');

        xlabel(pHandle,'Time (seconds)');
        ylabel(pHandle,[model.OutputUnit{:} '/' model.InputUnit{:}]);
        
        %% Para salvar a imagem
%         fig = figure(3);
%         plot(time,dglf);
%         view(2);
%         axis('tight');
%         
%         xlabel('Time (seconds)'); ylabel('ms/mmHg');
%         
%         grid('on');
%         
%         filenameIR = ['Imagens\Laguerre_LFDG_' patient_ID '.fig'];
%         filenameIR_print = ['Imagens\Laguerre_LFDG_' patient_ID];
%         
%         savefig(fig,filenameIR);      
%         print('-f3',filenameIR_print,'-dpng','-r200');
        
%         close all;

    elseif strcmp(plotType,'High Frequency Dynamic Gain')
        dghf = model.imResp.indicators.dg.hf;

        plot(pHandle,time,dghf);
        view(pHandle,2);
        axis(pHandle,'tight');
        set(pHandle,'ydir','normal');

        xlabel(pHandle,'Time (seconds)');
        ylabel(pHandle,[model.OutputUnit{:} '/' model.InputUnit{:}]);
        
        %% Para salvar a imagem
%         fig = figure(3);
%         plot(time,dghf);
%         view(2);
%         axis('tight');
%         
%         xlabel('Time (seconds)'); ylabel('ms/mmHg');
%         
%         grid('on');
%         
%         filenameIR = ['Imagens\Laguerre_HFDG_' patient_ID '.fig'];
%         filenameIR_print = ['Imagens\Laguerre_HFDG_' patient_ID];
%         
%         savefig(fig,filenameIR);      
%         print('-f3',filenameIR_print,'-dpng','-r200');
        
%         close all;

    elseif strcmp(plotType,'Dynamic Gain')
        dg = model.imResp.indicators.dg.total;

        plot(pHandle,time,dg);
        view(pHandle,2);
        axis(pHandle,'tight');
        set(pHandle,'ydir','normal');

        xlabel(pHandle,'Time (seconds)');
        ylabel(pHandle,[model.OutputUnit{:} '/' model.InputUnit{:}]);
        
         %% Para salvar a imagem
%         fig = figure(3);
%         plot(time,dg);
%         view(2);
%         axis('tight');
%         
%         xlabel('Time (seconds)'); ylabel('ms/mmHg');
%         
%         grid('on');
%         
%         filenameIR = ['Imagens\Laguerre_DG_' patient_ID '.fig'];
%         filenameIR_print = ['Imagens\Laguerre_DG_' patient_ID];
%         
%         savefig(fig,filenameIR);      
%         print('-f3',filenameIR_print,'-dpng','-r200');
%         
%         close all;

    elseif strcmp(plotType,'Latency')
        d = model.imResp.indicators.latency.time;

        plot(pHandle,time,d);
        view(pHandle,2);
        axis(pHandle,'tight');
        set(pHandle,'ydir','normal');

        xlabel(pHandle,'Time (seconds)');
        ylabel(pHandle,'Time (seconds)');
        
         %% Para salvar a imagem
%         fig = figure(3);
%         plot(time,d);
%         view(2);
%         axis('tight');
%         
%         xlabel('Time (seconds)'); ylabel('Time (seconds)');
%         
%         grid('on');
%         
%         filenameIR = ['Imagens\Laguerre_Latency_' patient_ID '.fig'];
%         filenameIR_print = ['Imagens\Laguerre_Latency_' patient_ID];
%         
%         savefig(fig,filenameIR);      
%         print('-f3',filenameIR_print,'-dpng','-r200');
        
%         close all;

    elseif strcmp(plotType,'Time-to-Peak')
        tpeak = model.imResp.indicators.ttp.time;

        plot(pHandle,time,tpeak);
        view(pHandle,2);
        axis(pHandle,'tight');
        set(pHandle,'ydir','normal');

        xlabel(pHandle,'Time (seconds)');
        ylabel(pHandle,'Time (seconds)');
        
        %% Para salvar a imagem
%         fig = figure(3);
%         plot(time,tpeak);
%         view(2);
%         axis('tight');
%         
%         xlabel('Time (seconds)'); ylabel('Time (seconds)');
%         
%         grid('on');
%         
%         filenameIR = ['Imagens\Laguerre_Tpeak_' patient_ID '.fig'];
%         filenameIR_print = ['Imagens\Laguerre_Tpeak_' patient_ID];
%         
%         savefig(fig,filenameIR);      
%         print('-f3',filenameIR_print,'-dpng','-r200');
        
%         close all;

    end 
end