function TVidentTab(pnTVIdent,pFile,pSys,pMod,userOpt)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   Time Varying System identification tab
%

tbSystem = uicontrol('parent',pnTVIdent,'style','toggle','tag','system',...
    'string','Create new system','value',1,'units','normalized',...
    'Position',[0 .9515 .11 .0435],'backgroundcolor',[1 1 1]);
pnSystem = uipanel('parent',pnTVIdent,'units','normalized','position',...
    [0 0 1 .953],'visible','on');

tbModel = uicontrol('parent',pnTVIdent,'style','toggle','tag','model',...
    'string','System model','units','normalized','Position',...
    [.1095 .9515 .08 .0435]);
pnModel = uipanel('parent',pnTVIdent,'units','normalized','position',...
    [0 0 1 .9565],'visible','off');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Set callback functions
%

set(tbSystem,'callback',{@tabChange,tbSystem,pnSystem,tbModel,pnModel,...
    pFile,pSys,pMod,userOpt});
set(tbModel,'callback',{@tabChange,tbSystem,pnSystem,tbModel,pnModel,...
    pFile,pSys,pMod,userOpt});

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Set current selected tab
%

options = get(userOpt,'userData');
switch options.session.nav.tvident
    case 0
        set(tbSystem,'value',1);
        tabChange(tbSystem,[],tbSystem,pnSystem,tbModel,pnModel,pFile,...
            pSys,pMod,userOpt);
    case 1
        set(tbModel,'value',1);
        tabChange(tbModel,[],tbSystem,pnSystem,tbModel,pnModel,pFile,...
            pSys,pMod,userOpt);
end
end

function tabChange(scr,~,tbSystem,pnSystem,tbModel,pnModel,pFile,pSys,...
    pMod,userOpt)

errStat = 0; dispDialog = 0;
options = get(userOpt,'userData');
switch options.session.nav.tvident
    case 0
        if ~strcmp(get(scr,'tag'),'system') && ~options.session.tvsys.saved...
                && (options.session.tvsys.filtered || ...
                options.session.tvsys.detrended)
            dispDialog = 1;
        end
    case 1
        if ~strcmp(get(scr,'tag'),'model')
            saved = 0;
            if options.session.tvident.sysLen(1) ~= 0
                patient = get(pFile,'userData');
                model = get(pMod,'userData');
                sysName = options.session.tvident.sysKey{...
                    options.session.tvident.sysValue-1};
                prevMod = fieldnames(patient.tvsys.(sysName).models);
                if ~isempty(prevMod)
                    for i = 1:length(prevMod)
                        if isequal(patient.tvsys.(sysName).models.(...
                                prevMod{i}).Theta,model.Theta) && ...
                                isequal(patient.tvsys.(sysName).models.(...
                                prevMod{i}).Type,model.Type)
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
if get(scr,'value') == 1 && dispDialog
    [selButton, dlgShow] = uigetpref('CRSIDLabPref',...
        'changeTabIdentPref','Change tabs',sprintf(['Warning!\nThe ',... 
        'current data has not been saved. Any modifications will ',...
        'be lost if the tabs are switched at this point.\nAre you ',...
        'sure you wish to proceed?']),{'Yes','No'},'DefaultButton',...
        'No');
    if strcmp(selButton,'no') && dlgShow
        errStat = 1;
    end  
end

if get(scr,'value') == 1 && ~errStat
    set(scr,'backgroundcolor',[1 1 1]);
    options = get(userOpt,'userData');
    switch get(scr,'tag')
        case 'system'
            options.session.nav.tvident = 0;
            set(userOpt,'userData',options);
            set(tbModel,'value',0,'backgroundcolor',[.94 .94 .94]);
            set(pnModel,'visible','off'); delete(get(pnModel,'children'));
            TVsystemMenu(pnSystem,pFile,userOpt);
            set(pnSystem,'visible','on');
        case 'model'
            options.session.nav.tvident = 1;
            set(userOpt,'userData',options);
            set(tbSystem,'value',0,'backgroundcolor',[.94 .94 .94]);
            set(pnSystem,'visible','off');delete(get(pnSystem,'children'));
            TVidentMenu(pnModel,pFile,pSys,pMod,userOpt);
            set(pnModel,'visible','on');
    end
else
    if get(scr,'value') == 1
        set(scr,'value',0);
    else
        set(scr,'value',1);
    end
end
end