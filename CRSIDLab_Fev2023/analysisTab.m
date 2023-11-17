function analysisTab(pnAn,pFile,pSig,pSys,pMod,pTf,userOpt)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   Analysis tab
%

tbPsd = uicontrol('parent',pnAn,'style','toggle','tag','psd','string',...
    'Power Spectral Density (PSD)','units','normalized','Position',...
    [0 .9565 .15 .042]);
pnPsd = uipanel('parent',pnAn,'units','normalized','position',...
    [0 0 1 .958],'visible','on');

tbIdent = uicontrol('parent',pnAn,'style','toggle','tag','ident',...
    'string','System Identification','units','normalized','Position',...
    [.149 .9565 .11 .042]);
pnIdent = uipanel('parent',pnAn,'units','normalized','position',...
    [0 0 1 .958],'visible','off');

tbTVPsd = uicontrol('parent',pnAn,'style','toggle','tag','TVpsd','string',...
    'TV Power Spectral Density (TVPSD)','units','normalized','Position',...
    [.258 .9565 .15 .042]);
pnTVPsd = uipanel('parent',pnAn,'units','normalized','position',...
    [0 0 1 .958],'visible','off');

tbTVIdent = uicontrol('parent',pnAn,'style','toggle','tag','TVident',...
    'string','TV System Identification','units','normalized','Position',...
    [.407 .9565 .12 .042]);
pnTVIdent = uipanel('parent',pnAn,'units','normalized','position',...
    [0 0 1 .958],'visible','off');

% ---------------*---------------*---------------*--------------- 
tbFt = uicontrol('parent',pnAn,'style','toggle','tag','ft','string',...
       'Transfer Function (TF)','units','normalized','Position',...
       [0.526 .9565 .1 .042]);
pnFt = uipanel('parent',pnAn,'units','normalized','position',...
    [0 0 1 .958],'visible','off');
% ---------------*---------------*---------------*---------------

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Set callback functions
%

set(tbPsd,'callback',{@tabChange,tbPsd,pnPsd,tbIdent,pnIdent,tbFt,tbTVPsd,pnTVPsd,tbTVIdent,pnTVIdent,...
    pnFt,pFile,pSig,pSys,pMod,pTf,userOpt});
set(tbIdent,'callback',{@tabChange,tbPsd,pnPsd,tbIdent,pnIdent,tbFt,tbTVPsd,pnTVPsd,tbTVIdent,pnTVIdent,...
    pnFt,pFile,pSig,pSys,pMod,pTf,userOpt});
set(tbTVPsd,'callback',{@tabChange,tbPsd,pnPsd,tbIdent,pnIdent,tbFt,tbTVPsd,pnTVPsd,tbTVIdent,pnTVIdent,...
    pnFt,pFile,pSig,pSys,pMod,pTf,userOpt});
set(tbTVIdent,'callback',{@tabChange,tbPsd,pnPsd,tbIdent,pnIdent,tbFt,tbTVPsd,pnTVPsd,tbTVIdent,pnTVIdent,...
    pnFt,pFile,pSig,pSys,pMod,pTf,userOpt});

% ---------------*---------------*---------------*---------------
set(tbFt,'callback',{@tabChange,tbPsd,pnPsd,tbIdent,pnIdent,tbFt,tbTVPsd,pnTVPsd,tbTVIdent,pnTVIdent,...
    pnFt,pFile,pSig,pSys,pMod,pTf,userOpt});
% ---------------*---------------*---------------*---------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Set current selected tab
%

options = get(userOpt,'userData');
switch options.session.nav.an
    case 0
        set(tbPsd,'value',1);
        tabChange(tbPsd,[],tbPsd,pnPsd,tbIdent,pnIdent,tbFt,tbTVPsd,pnTVPsd,tbTVIdent,pnTVIdent,...
            pnFt,pFile,pSig,pSys,pMod,pTf,userOpt);
    case 1
        set(tbIdent,'value',1);
        tabChange(tbIdent,[],tbPsd,pnPsd,tbIdent,pnIdent,tbFt,tbTVPsd,pnTVPsd,tbTVIdent,pnTVIdent,...
            pnFt,pFile,pSig,pSys,pMod,pTf,userOpt);
    case 2
        set(tbTVPsd,'value',1);
        tabChange(tbTVPsd,[],tbPsd,pnPsd,tbIdent,pnIdent,tbFt,tbTVPsd,pnTVPsd,tbTVIdent,pnTVIdent,...
            pnFt,pFile,pSig,pSys,pMod,pTf,userOpt);
    case 3
        set(tbTVIdent,'value',1);
        tabChange(tbTVIdent,[],tbPsd,pnPsd,tbIdent,pnIdent,tbFt,tbTVPsd,pnTVPsd,tbTVIdent,pnTVIdent,...
            pnFt,pFile,pSig,pSys,pMod,pTf,userOpt);
    % ---------------*---------------*---------------*---------------
    case 4
        set(tbFt,'value',1);
        tabChange(tbFt,[],tbPsd,pnPsd,tbIdent,pnIdent,tbFt,tbTVPsd,pnTVPsd,tbTVIdent,pnTVIdent,pnFt,pFile,...
        pSig,pSys,pMod,pTf,userOpt);
    % ---------------*---------------*---------------*---------------
    
end
end
function tabChange(scr,~,tbPsd,pnPsd,tbIdent,pnIdent,tbFt,tbTVPsd,pnTVPsd,tbTVIdent,pnTVIdent,...
    pnFt,pFile,pSig,pSys,pMod,pTf,userOpt)
% changes between tabs: PSD tab & system identification tab

% verifiy if there is unsaved data in the previous tab before changing
errStat = 0; dispDialog = 0;
options = get(userOpt,'userData');
switch options.session.nav.an
    case 0                                  % PSD analysis tab
        if ~strcmp(get(scr,'tag'),'psd') && ...
                ~isempty(options.session.psd.sigLen)
            pat = get(pFile,'userData');
            signals = get(pSig,'userData');
            id = options.session.psd.sigSpec{1};
            type = options.session.psd.sigSpec{2};
            if ~options.session.psd.saved && ...
                    ((options.session.psd.cbSelection(1) && ~isequal(...
                    pat.sig.(id).(type).aligned.psd.psdFFT,...
                    signals.(id).(type).aligned.psd.psdFFT)) || ...
                    (options.session.psd.cbSelection(2) && ~isequal(...
                    pat.sig.(id).(type).aligned.psd.psdAR,...
                    signals.(id).(type).aligned.psd.psdAR)) || ...
                    (options.session.psd.cbSelection(1) && ~isequal(...
                    pat.sig.(id).(type).aligned.psd.psdWelch,...
                    signals.(id).(type).aligned.psd.psdWelch)))
                dispDialog = 1;
            end
        end
    case 1                                  % system identification tab
        if ~strcmp(get(scr,'tag'),'ident')
            switch options.session.nav.ident
                case 0                      % create new system
                    if ~options.session.sys.saved && (...
                            options.session.sys.filtered || ...
                            options.session.sys.detrended)
                        dispDialog = 1;
                    end
                case 1                      % model estimation
                    saved = 0;
                    if options.session.ident.sysLen(1) ~= 0
                        patient = get(pFile,'userData');
                        model = get(pMod,'userData');
                        sysName = options.session.ident.sysKey{...
                            options.session.ident.sysValue-1};
                        prevMod = fieldnames(patient.sys.(sysName).models);
                        if ~isempty(prevMod)
                            for i = 1:length(prevMod)
                                if isequal(patient.sys.(...
                                        sysName).models.(prevMod{...
                                        i}).Theta,model.Theta) && ...
                                        isequal(patient.sys.(...
                                        sysName).models.(prevMod{...
                                        i}).Type,model.Type)
                                    saved = 1;
                                end
                            end
                        end
                    end

                    if ~saved && options.session.ident.modelGen
                        dispDialog = 1;
                    end
            end
        end
    case 2                                  % TVPSD analysis tab
        if ~strcmp(get(scr,'tag'),'TVpsd') && ...
                ~isempty(options.session.tvpsd.sigLen)
            pat = get(pFile,'userData');
            signals = get(pSig,'userData');
            id = options.session.tvpsd.sigSpec{1};
            type = options.session.tvpsd.sigSpec{2};
            if ~options.session.tvpsd.saved && ...
                    ((options.session.tvpsd.cbSelection(1) && ~isequal(...
                    pat.sig.(id).(type).aligned.tvpsd.psdFFT,...
                    signals.(id).(type).aligned.tvpsd.psdFFT)) || ...
                    (options.session.tvpsd.cbSelection(2) && ~isequal(...
                    pat.sig.(id).(type).aligned.tvpsd.psdAR,...
                    signals.(id).(type).aligned.tvpsd.psdAR)) || ...
                    (options.session.tvpsd.cbSelection(1) && ~isequal(...
                    pat.sig.(id).(type).aligned.tvpsd.psdWelch,...
                    signals.(id).(type).aligned.tvpsd.psdWelch)))
                dispDialog = 1;
            end
        end
    case 3                                  % TV system identification tab
        if ~strcmp(get(scr,'tag'),'TVident')
            switch options.session.nav.tvident
                case 0                      % create new TV system
                    if ~options.session.tvsys.saved && (...
                            options.session.tvsys.filtered || ...
                            options.session.tvsys.detrended)
                        dispDialog = 1;
                    end
                case 1                      % TV model estimation
                    saved = 0;
                    if options.session.tvident.sysLen(1) ~= 0
                        patient = get(pFile,'userData');
                        model = get(pMod,'userData');
                        sysName = options.session.tvident.sysKey{...
                            options.session.tvident.sysValue-1};
                        prevMod = fieldnames(patient.tvsys.(sysName).models);
                        if ~isempty(prevMod)
                            for i = 1:length(prevMod)
                                if isequal(patient.tvsys.(...
                                        sysName).models.(prevMod{...
                                        i}).Theta,model.Theta) && ...
                                        isequal(patient.tvsys.(...
                                        sysName).models.(prevMod{...
                                        i}).Type,model.Type)
                                    saved = 1;
                                end
                            end
                        end
                    end

                    if ~saved && options.session.tvident.modelGen
                        dispDialog = 1;
                    end
            end
        end
end
if get(scr,'value') == 1 && dispDialog
    [selButton, dlgShow] = uigetpref('CRSIDLabPref',...
        'changeTabAnPref','Change tabs',sprintf(['Warning!\nThe ',... 
        'current data has not been saved. Any modifications will ',...
        'be lost if the tabs are switched at this point.\nAre you ',...
        'sure you wish to proceed?']),{'Yes','No'},'DefaultButton',...
        'No');
    if strcmp(selButton,'no') && dlgShow
        errStat = 1;        % set up flags if user chooses to move on
    elseif options.session.nav.an == 1      % system identification tab
        switch options.session.nav.ident
            case 0                          % create new system
                options.session.sys.filtered = 0;
                options.session.sys.detrended = 0;
            case 1                          % model estimation
                options.session.ident.modelGen = 0;
                options.session.ident.sysLen = [0 0 0];
        end
    elseif options.session.nav.an == 3      % TV system identification tab
        switch options.session.nav.tvident
            case 0                          % create new TV system
                options.session.tvsys.filtered = 0;
                options.session.tvsys.detrended = 0;
            case 1                          % TV model estimation
                options.session.tvident.modelGen = 0;
                options.session.tvident.sysLen = [0 0 0];
        end
    end  
end

% switch tabs (adjust toggle buttons and call tab script)
if get(scr,'value') == 1 && ~errStat
    set(scr,'backgroundcolor',[1 1 1]);
    switch get(scr,'tag')
        case 'psd'                          % PSD tab
            options.session.nav.an = 0;
            set(userOpt,'userData',options);
            set(tbIdent,'value',0,'backgroundcolor',[.94 .94 .94]);
            set(pnIdent,'visible','off'); delete(get(pnIdent,'children'));
            set(tbTVPsd,'value',0,'backgroundcolor',[.94 .94 .94]);
            set(pnTVPsd,'visible','off'); delete(get(pnTVPsd,'children'));
            set(tbTVIdent,'value',0,'backgroundcolor',[.94 .94 .94]);
            set(pnTVIdent,'visible','off'); delete(get(pnTVIdent,'children'));
            % ---------------*---------------*---------------*-------------
            set(tbFt,'value',0,'backgroundcolor',[.94 .94 .94]);
            set(pnFt,'visible','off'); 
            delete(get(pnFt,'children'));
            % ---------------*---------------*---------------*-------------
            psdMenu(pnPsd,pFile,pSig,userOpt);
            set(pnPsd,'visible','on');
        case 'ident'                        % system identification tab
            options.session.nav.an = 1;
            set(userOpt,'userData',options);
            set(tbPsd,'value',0,'backgroundcolor',[.94 .94 .94]);
            set(pnPsd,'visible','off'); delete(get(pnPsd,'children'));
            set(tbTVPsd,'value',0,'backgroundcolor',[.94 .94 .94]);
            set(pnTVPsd,'visible','off'); delete(get(pnTVPsd,'children'));
            set(tbTVIdent,'value',0,'backgroundcolor',[.94 .94 .94]);
            set(pnTVIdent,'visible','off'); delete(get(pnTVIdent,'children'));
            % ---------------*---------------*---------------*-------------
            set(tbFt,'value',0,'backgroundcolor',[.94 .94 .94]);
            set(pnFt,'visible','off'); delete(get(pnFt,'children'));
            % ---------------*---------------*---------------*-------------
            identTab(pnIdent,pFile,pSys,pMod,userOpt);
            set(pnIdent,'visible','on');
        case 'TVpsd'                          % TV system identification tab
            options.session.nav.an = 2;
            set(userOpt,'userData',options);
            set(tbPsd,'value',0,'backgroundcolor',[.94 .94 .94]);
            set(pnPsd,'visible','off'); delete(get(pnPsd,'children'));
            set(tbIdent,'value',0,'backgroundcolor',[.94 .94 .94]);
            set(pnIdent,'visible','off'); delete(get(pnIdent,'children'));
            set(tbTVIdent,'value',0,'backgroundcolor',[.94 .94 .94]);
            set(pnTVIdent,'visible','off'); delete(get(pnTVIdent,'children'));
            % ---------------*---------------*---------------*-------------
            set(tbFt,'value',0,'backgroundcolor',[.94 .94 .94]);
            set(pnFt,'visible','off'); delete(get(pnFt,'children'));
            % ---------------*---------------*---------------*-------------
            TVpsdMenu(pnTVPsd,pFile,pSig,userOpt);
            set(pnTVPsd,'visible','on');
        case 'TVident'                          % TV system identification tab
            options.session.nav.an = 3;
            set(userOpt,'userData',options);
            set(tbPsd,'value',0,'backgroundcolor',[.94 .94 .94]);
            set(pnPsd,'visible','off'); delete(get(pnPsd,'children'));
            set(tbIdent,'value',0,'backgroundcolor',[.94 .94 .94]);
            set(pnIdent,'visible','off'); delete(get(pnIdent,'children'));
            set(tbTVPsd,'value',0,'backgroundcolor',[.94 .94 .94]);
            set(pnTVPsd,'visible','off'); delete(get(pnTVPsd,'children'));
            % ---------------*---------------*---------------*-------------
            set(tbFt,'value',0,'backgroundcolor',[.94 .94 .94]);
            set(pnFt,'visible','off'); delete(get(pnFt,'children'));
            % ---------------*---------------*---------------*-------------
            TVidentTab(pnTVIdent,pFile,pSys,pMod,userOpt);
            set(pnTVIdent,'visible','on');
         % ---------------*---------------*---------------*-----------------
        case 'ft'
           options.session.nav.an = 4; 
           set(userOpt,'userData',options);
           set(tbPsd,'value',0,'backgroundcolor',[.94 .94 .94]);
           set(pnPsd,'visible','off'); delete(get(pnPsd,'children'));
           set(tbIdent,'value',0,'backgroundcolor',[.94 .94 .94]);
           set(pnIdent,'visible','off'); delete(get(pnIdent,'children'));
           set(tbTVPsd,'value',0,'backgroundcolor',[.94 .94 .94]);
           set(pnTVPsd,'visible','off'); delete(get(pnTVPsd,'children'));
           set(tbTVIdent,'value',0,'backgroundcolor',[.94 .94 .94]);
           set(pnTVIdent,'visible','off'); delete(get(pnTVIdent,'children'));
           ftMenu(pnFt,pFile,pSig,pTf,userOpt);
           set(pnFt,'visible','on');
        % ---------------*---------------*---------------*-----------------
            
    end
else
    if get(scr,'value') == 1
        set(scr,'value',0);
    else
        set(scr,'value',1);
    end
end
end