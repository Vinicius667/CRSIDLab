function ftMenu(pnFt,pFile,pSig,pTf,userOpt)
% By: Amanda dos Santos Pereira
% Date: 07/24/2022
% Control and Automation Engineering - UnB

var = struct; 
var.out = []; 
var.in = []; 
var.fs = [];
uicVar = uicontrol('visible','off','userData',var); 

ft = dataPkg.ftUnit;
pFt = uicontrol('visible','off','userData',ft);
%-------*-------*-------*-------*-------*-------*-------*-------*-------*--
% Entries
%-------*-------*-------*-------*-------*-------*-------*-------*-------*--
uicEntries = struct;
uicontrol('parent',pnFt,'style','text','string','Select registers:',...
          'hor','left','units','normalized','position',[.032 .93 .1 .03]);
uicEntries.out = uicontrol('parent',pnFt,'style','popupmenu','tag',...
                           'out','string',...
                           {'Output variable','No data available'},...
                           'userData',1,'backgroundColor',[1 1 1],...
                           'units','normalized','position',...
                           [.13 .93 .2 .04]);
uicontrol('parent',pnFt,'style','text','string','and','units',...
          'normalized','position',[.34 .93 .05 .03]);
uicEntries.in = uicontrol('parent',pnFt,'style','popupmenu','tag',...
                          'in','string',...
                          {'Input variable','No data available'},...
                          'userData',1,'backgroundColor',[1 1 1],...
                          'units','normalized','position',[.4 .93 .2 .04]);
%-------*-------*-------*-------*-------*-------*-------*-------*-------*--
% Graphics
%-------*-------*-------*-------*-------*-------*-------*-------*-------*--        
graphics = struct;
graphics.module = axes('parent',pnFt,'tag','module','visible','on',...
                       'Units','normalized','Position',...
                       [.057 .66 .6 .22],'nextPlot','replaceChildren');
graphics.angle = axes('parent',pnFt,'tag','angle','visible','on',...
                      'Units','normalized','Position',...
                      [.057 .398 .6 .22],'nextPlot','replaceChildren');
graphics.coherence = axes('parent',pnFt,'tag','coherence','visible',...
                          'on','Units','normalized','Position',...
                          [.057 .14 .6 .22],'nextPlot','replaceChildren');
%-------*-------*-------*-------*-------*-------*-------*-------*-------*--
% Windows
%-------*-------*-------*-------*-------*-------*-------*-------*-------*--
uicWindows = struct;
pnWindow = uipanel('parent',pnFt,'Units','Normalized','Position',...
                     [.825 .66 .16 .20]);
uicontrol('parent',pnWindow,'Style','text','String','Window:','Units',...
          'Normalized','Position',[.05 .76 .9 .2]);
uicWindows.Rectangular = uicontrol('parent',pnWindow,'Style','radio',...
                                   'tag','window','String',...
                                   'Rectangular','userData',0,'Units',...
                                   'Normalized','Position',...
                                   [.05 .52 .4 .2]);
uicWindows.Bartlett = uicontrol('parent',pnWindow,'Style','radio','tag',...
                                'window','String','Bartlett',...
                                'userData',1,'Units','Normalized',...
                                'Position',[.05 .28 .4 .2]);
uicWindows.Hamming = uicontrol('parent',pnWindow,'Style','radio','tag',...
                               'window','String','Hamming','userData',2,...
                               'Units','Normalized','Position',...
                               [.05 .04 .4 .2]);
uicWindows.Hanning = uicontrol('parent',pnWindow,'Style','radio','tag',...
                               'window','String','Hanning','userData',3,...
                               'Units','Normalized','Position',...
                               [.55 .52 .4 .2]);
uicWindows.Blackman = uicontrol('parent',pnWindow,'Style','radio','tag',...
                                'window','String','Blackman',...
                                'userData',4,'Units','Normalized',...
                                'Position',[.55 .28 .4 .2]);
%-------*-------*-------*-------*-------*-------*-------*-------*-------*--
% Scale
%-------*-------*-------*-------*-------*-------*-------*-------*-------*--
uicScales = struct;
pnScale = uipanel('parent',pnFt,'Units','Normalized','Position',...
                  [.912 .49 .074 .17]);
uicontrol('parent',pnScale,'Style','text','String','Scale:','Units',...
          'Normalized','Position',[.1 .76 .8 .2]);
uicScales.Normal = uicontrol('parent',pnScale,'Style','radio','tag',...
                             'scale','String','Normal','userData',0,...
                             'Units','Normalized','Position',...
                             [.1 .52 .8 .2]);
uicScales.Monolog = uicontrol('parent',pnScale,'Style','radio','tag',...
                              'scale','String','Monolog','userData',1,...
                              'Units','Normalized','Position',...
                              [.1 .28 .8 .2]);
uicScales.Loglog = uicontrol('parent',pnScale,'Style','radio','tag',...
                             'scale','String','Log-Log','userData',2,...
                             'Units','Normalized','Position',...
                             [.1 .04 .8 .2]);
%-------*-------*-------*-------*-------*-------*-------*-------*-------*--
% Coherence
%-------*-------*-------*-------*-------*-------*-------*-------*-------*--
pnCoherence = uipanel('parent',pnFt,'Units','Normalized','Position',...
                      [.825 .49 .086 .17]);
uicontrol('parent',pnCoherence,'Style','text','String',...
          'Coherence (threshold):','Units','Normalized','Position',...
          [.1 .51 .8 .3]);
uicCoherence = uicontrol('parent',pnCoherence,'Style','edit','tag',...
                         'coherence','Units','Normalized','Position',...
                         [.27 .23 .45 .22],'backgroundColor',[1 1 1]);
%-------*-------*-------*-------*-------*-------*-------*-------*-------*--
% Overlapping                                                             
%-------*-------*-------*-------*-------*-------*-------*-------*-------*--
pnOverlapping  = uipanel('parent',pnFt,'Units','Normalized','Position',...
                        [.825 .42 .16 .07]);
uicontrol('parent',pnOverlapping,'Style','text','String','Overlapping:',...
          'Units','Normalized','Position',[.005 .35 .5 .35]);
uicOverlapping  = uicontrol('parent',pnOverlapping,'Style','edit','tag',...
                            'overlapping','Units','Normalized',...
                            'Position',[.43 .22 .25 .6],...
                            'backgroundColor',[1 1 1]);
uicontrol('parent',pnOverlapping,'Style','text','String','%',...
          'Units','Normalized','Position',[.68 .35 .10 .35]);
%-------*-------*-------*-------*-------*-------*-------*-------*-------*--
% Frequency band definition (LF and HF)                                                            
%-------*-------*-------*-------*-------*-------*-------*-------*-------*--
uicBands = struct;
pnBands = uipanel('parent',pnFt,'Units','Normalized','Position',...
                  [.825 .27 .16 .15]);
% Very Low Frequency (VLF) 
uicontrol('parent',pnBands,'Style','text','String','Very Low Freq.:',...
          'hor','left','Units','Normalized','Position',[.05 .685 .5 .26]);
uicontrol('parent',pnBands,'Style','text','string','0','Units',...
          'Normalized','Position',[.45 .685 .15 .26]);
uicontrol('parent',pnBands,'Style','text','String','to','Units',...
          'Normalized','Position',[.6 .685 .1 .26]);
uicBands.editVLF = uicontrol('parent',pnBands,'Style','edit','tag',...
                             'vlf','Units','Normalized','Position',...
                             [.7 .685 .15 .26],'BackgroundColor',[1 1 1]);
uicontrol('parent',pnBands,'Style','text','String','Hz','Units',...
          'Normalized','Position',[.85 .685 .1 .26]);
% Low Frequency (LF) 
uicontrol('parent',pnBands,'Style','text','String','Low Freq.:',...
    'hor','left','Units','Normalized','Position',[.05 .37 .5 .26]);
uicBands.textLF = uicontrol('parent',pnBands,'Style','text','Units',...
                            'normalized','Position',[.45 .37 .15 .26]);
uicontrol('parent',pnBands,'Style','text','String','to','Units',...
          'Normalized','Position',[.6 .37 .1 .26]);
uicBands.editLF = uicontrol('parent',pnBands,'Style','edit','tag','lf',...
                            'Units','Normalized','Position',...
                            [.7 .37 .15 .26],'BackgroundColor',[1 1 1]);
uicontrol('parent',pnBands,'Style','text','String','Hz','Units',...
          'Normalized','Position',[.85 .37 .1 .26]);
% High Frequency (HF) 
uicontrol('parent',pnBands,'Style','text','String','High Freq.:',...
          'hor','left','Units','Normalized','Position',[.05 .055 .4 .26]);
uicBands.textHF = uicontrol('parent',pnBands,'Style','text','Units',...
                            'Normalized','Position',[.45 .055 .15 .26]);
uicontrol('parent',pnBands,'Style','text','String','to','Units',...
    'Normalized','Position',[.6 .055 .1 .26]);
uicBands.editHF = uicontrol('parent',pnBands,'Style','edit','tag','hf',...
                            'units','Normalized','Position',...
                            [.7 .055 .15 .26],'BackgroundColor',[1 1 1]);
uicontrol('parent',pnBands,'Style','text','String','Hz','Units',...
    'Normalized','Position',[.85 .055 .1 .26]);
%-------*-------*-------*-------*-------*-------*-------*-------*-------*--
% Axes                                                           
%-------*-------*-------*-------*-------*-------*-------*-------*-------*--
uicAxes = struct;
pnAxes = uipanel('parent',pnFt,'Units','Normalized','Position',...
                 [.825 .17 .16 .10]);
uicontrol('parent',pnAxes,'Style','text','String','Frequency Axis:',...
          'Units','Normalized','Position',[.05 .65 .9 .3]);
uicontrol('parent',pnAxes,'Style','text','String','Freq. From:','hor',...
          'left','Units','Normalized','Position',[.05 .2 .3 .3]);
uicAxes.minFreq = uicontrol('parent',pnAxes,'Style','edit','tag','minF',...
                            'Units','Normalized','Position',...
                            [.36 .2 .15 .4],'BackgroundColor',[1 1 1]);
uicontrol('parent',pnAxes,'Style','text','String','to:',...
          'Units','Normalized','Position',[.53 .2 .15 .28]);
uicAxes.maxFreq = uicontrol('parent',pnAxes,'Style','edit','tag',...
                            'maxF','Units','Normalized','Position',...
                            [.7 .2 .15 .4],'BackgroundColor',[1 1 1]);
uicontrol('parent',pnAxes,'Style','text','String','Hz',...
          'Units','Normalized','Position',[.85 .2 .15 .28]);
%-------*-------*-------*-------*-------*-------*-------*-------*-------*--
% Export Areas & Save                                                         
%-------*-------*-------*-------*-------*-------*-------*-------*-------*--
uicEnd = struct;
pnExportSave = uipanel('parent',pnFt,'Units','Normalized','Position',...
                   [.825 .1 .16 .07]);
uicEnd.export = uicontrol('parent',pnExportSave,'Style','push','String',...
                         'Export Areas','Units','Normalized','Position',...
                         [.3 .2 .4 .7]);
%uicEnd.save = uicontrol('parent',pnExportSave,'Style','push','String',...
                        %'Save TF','Units','Normalized','Position',...
                        %[.3 .2 .4 .7]);
%-------*-------*-------*-------*-------*-------*-------*-------*-------*--
% Results                                                           
%-------*-------*-------*-------*-------*-------*-------*-------*-------*--
pnResults = uipanel('parent',pnFt,'Units','Normalized','Position',...
                    [.675 .1 .15 .76]);
areasString = sprintf('---');
uicResults = uicontrol('parent',pnResults,'Style','text','String',...
                       areasString,'FontName','Courier New',...
                       'FontSize',9,'hor','left','Units','Normalized',...
                       'Position',[.05 .05 .9 .9]);  
%-------*-------*-------*-------*-------*-------*-------*-------*-------*--
% Callbacks                                                         
%-------*-------*-------*-------*-------*-------*-------*-------*-------*--
set(uicEntries.out,'callback',...
    {@changeVar,userOpt,pFile,pSig,pFt,uicEntries,graphics,uicVar,...
     uicResults});
set(uicEntries.in,'callback',...
    {@changeVar,userOpt,pFile,pSig,pFt,uicEntries,graphics,uicVar,...
     uicResults});
 
set(uicWindows.Rectangular,'callback',...
    {@changeWindow,userOpt,pFt,uicVar,uicWindows,uicResults,graphics});
set(uicWindows.Bartlett,'callback',...
    {@changeWindow,userOpt,pFt,uicVar,uicWindows,uicResults,graphics});
set(uicWindows.Hamming,'callback',...
    {@changeWindow,userOpt,pFt,uicVar,uicWindows,uicResults,graphics});
set(uicWindows.Hanning,'callback',...
    {@changeWindow,userOpt,pFt,uicVar,uicWindows,uicResults,graphics});
set(uicWindows.Blackman,'callback',...
    {@changeWindow,userOpt,pFt,uicVar,uicWindows,uicResults,graphics});

set(uicScales.Normal,'callback',...
    {@changeScale,userOpt,pFt,uicScales,graphics});
set(uicScales.Monolog,'callback',...
    {@changeScale,userOpt,pFt,uicScales,graphics});
set(uicScales.Loglog,'callback',...
    {@changeScale,userOpt,pFt,uicScales,graphics});

set(uicCoherence,'callback',...
    {@changeCoherence,userOpt,pFt,uicResults,uicVar});

set(uicOverlapping,'callback',...
    {@changeOverlapping,userOpt,pFt,uicResults,uicVar,graphics});

set(uicBands.editVLF,'callback',...
    {@changeBands,userOpt,pFt,uicResults,uicVar,graphics,uicBands});
set(uicBands.editLF,'callback',...
    {@changeBands,userOpt,pFt,uicResults,uicVar,graphics,uicBands});
set(uicBands.editHF,'callback',...
    {@changeBands,userOpt,pFt,uicResults,uicVar,graphics,uicBands});

set(uicAxes.minFreq,'callback',...
    {@changeLimits,userOpt,pFt,uicAxes,graphics,uicVar});
set(uicAxes.maxFreq,'callback',...
    {@changeLimits,userOpt,pFt,uicAxes,graphics,uicVar});

%set(uicEnd.save,'callback',...
    %{@saveSignal,userOpt,pFile,pFt});
set(uicEnd.export,'callback',...
    {@exportAreas,userOpt});

%-------*-------*-------*-------*-------*-------*-------*-------*-------*--
% Finally o/                                                         
%-------*-------*-------*-------*-------*-------*-------*-------*-------*--
openFnc(userOpt,pFile,pSig,pFt,uicEntries,graphics,uicWindows,uicScales,...
        uicCoherence,uicOverlapping,uicBands,uicAxes,uicResults,uicVar)

end

function openFnc(userOpt,pFile,pSig,pFt,uicEntries,graphics,uicWindows,...
                 uicScales,uicCoherence,uicOverlapping,uicBands,...
                 uicAxes,uicResults,uicVar)
          
options = get(userOpt,'userData');
patient = get(pFile,'userData');
% String for variable selection PopUpMenu from available patient data
stringPopUp = cell(5,1);
id = {'ecg','bp','rsp'};
count = 1;

for i = 1:3
    
    if i == 1
        var = {'rri'};
    elseif i == 2
        var = {'sbp','dbp'};
    else
        var = {'ilv','filt'};
    end
    
    for j = 1:length(var)
        if ~isempty(patient.sig.(id{i}).(var{j}).aligned.data)
            stringPopUp{count} = ...
            patient.sig.(id{i}).(var{j}).aligned.specs.tag;
            count = count+1;
        end
    end
    
end

stringPopUp = stringPopUp(~cellfun(@isempty,stringPopUp));
if isempty(stringPopUp)
    stringPopUp{1} = 'No aligned & resampled data available';
end

aux = {'out','in'};
popUpID = {'Output variable','Input variable'};
for i = 1:2
    % Adjust selection value if the variables list has changed
    if ~isequal(options.session.ft.varString.(aux{i}),stringPopUp)                      
        if ~isempty(options.session.ft.varString.(aux{i}))
            if ismember(options.session.ft.varString.(aux{i}){...
                        options.session.ft.varValue.(aux{i})},stringPopUp)
                options.session.ft.varValue.(aux{i}) = find(ismember(...
                stringPopUp,options.session.ft.varString.(aux{i}){...
                options.session.ft.varValue.(aux{i})}))+1;
            else
                options.session.ft.varValue.(aux{i}) = 1;
            end
        end
        options.session.ft.varString.(aux{i}) = [popUpID(i);stringPopUp];
        
    end
    
    set(uicEntries.(aux{i}),...
        'string',options.session.ft.varString.(aux{i}));
    set(uicEntries.(aux{i}),...
        'value',options.session.ft.varValue.(aux{i}));
    set(uicEntries.(aux{i}),...
        'userData',options.session.ft.varValue.(aux{i}));
    
end

set(userOpt,'userData',options);
setup(userOpt,pFile,uicVar);

% Setup options
options.session.ft.vlf = checkLim(userOpt,options.session.ft.vlf,'vlf',...
                                  uicVar);
set(uicBands.editVLF,'string',num2str(options.session.ft.vlf));
set(uicBands.textLF,'string',num2str(options.session.ft.vlf));

options.session.ft.lf = checkLim(userOpt,options.session.ft.lf,'lf',...
                                 uicVar);
set(uicBands.editLF,'string',num2str(options.session.ft.lf));
set(uicBands.textHF,'string',num2str(options.session.ft.lf));

options.session.ft.hf = checkLim(userOpt,options.session.ft.hf,'hf',...
                                 uicVar);
set(uicBands.editHF,'string',num2str(options.session.ft.hf));

options.session.ft.minF = checkLim(userOpt,options.session.ft.minF,...
                                   'minF',uicVar);
set(uicAxes.minFreq,'string',num2str(options.session.ft.minF));

options.session.ft.maxF = checkLim(userOpt,options.session.ft.maxF,...
                                   'maxF',uicVar);
set(uicAxes.maxFreq,'string',num2str(options.session.ft.maxF));

options.session.ft.coherence = checkLim(userOpt,...
                          options.session.ft.coherence,'coherence',uicVar);
set(uicCoherence,'string',num2str(options.session.ft.coherence));

options.session.ft.overlapping = checkLim(userOpt,...
                      options.session.ft.overlapping,'overlapping',uicVar);
set(uicOverlapping,'String',num2str(options.session.ft.overlapping));

set(uicWindows.Rectangular,'value',0); 
set(uicWindows.Bartlett,'value',0); 
set(uicWindows.Hamming,'value',0);
set(uicWindows.Hanning,'value',0); 
set(uicWindows.Blackman,'value',0);
if options.session.ft.window == 0, set(uicWindows.Rectangular,'value',1);
elseif options.session.ft.window == 1, set(uicWindows.Bartlett,'value',1);
elseif options.session.ft.window == 2, set(uicWindows.Hamming,'value',1);
elseif options.session.ft.window == 3, set(uicWindows.Hanning,'value',1);
elseif options.session.ft.window == 4, set(uicWindows.Blackman,'value',1);
end

set(uicScales.Normal,'value',0); 
set(uicScales.Monolog,'value',0); 
set(uicScales.Loglog,'value',0);
if options.session.ft.scale == 0, set(uicScales.Normal,'value',1);
elseif options.session.ft.scale == 1, set(uicScales.Monolog,'value',1);
elseif options.session.ft.scale == 2, set(uicScales.Loglog,'value',1);
end   

set(userOpt,'userData',options);

ftCalc(userOpt,uicVar,pFt);
ftPlot(pFt,userOpt,graphics);
calcAreas(userOpt,pFt,uicResults);

end

function setup(userOpt,pFile,uicVar)

options = get(userOpt,'userData');

uicVarLocal = get(uicVar,'userData');
uicVarLocal.out = []; uicVarLocal.in = []; uicVarLocal.fs = [];

% Identify selected data
opt = {'out','in'};
id = cell(2,1); 
type = cell(2,1);
for i = 1:2
    auxVar = options.session.ft.varString.(opt{i}){...
             options.session.ft.varValue.(opt{i})};
    if contains(auxVar,'RRI')
        id{i} = 'ecg'; type{i} = 'rri'; 
    elseif contains(auxVar,'HR')
        id{i} = 'ecg'; type{i} = 'hr'; 
    elseif contains(auxVar,'SBP')
        id{i} = 'bp'; type{i} = 'sbp';
    elseif contains(auxVar,'DBP')
        id{i} = 'bp'; type{i} = 'dbp';
    elseif contains(auxVar,'Filtered')
        id{i} = 'rsp'; type{i} = 'filt';
    elseif contains(auxVar,'ILV')
        id{i} = 'rsp'; type{i} = 'ilv';
    end
end

options.session.ft.sigSpec = {id, type};
for i = 1:length(type)
    if strcmp(type{i},'hr')
        type{i} = 'rri';
    end
end

% Open data and setup options
if ~isempty(type{1}) || ~isempty(type{2})
    patient = get(pFile,'userData');
    % Adjust optional inputs
    opt = {'out','in'};
    for i = 1:2
        if ~isempty(type{i})
            uicVarLocal.(opt{i}) = patient.sig.(id{i}).(type{i})...
                                   .aligned.data;
            options.session.ft.sigLen = length(uicVarLocal.in);
            if isempty(uicVarLocal.fs)
                if ~isempty(patient.sig.(id{i}).(type{i}).aligned.fs)
                    uicVarLocal.fs = patient.sig.(id{i}).(type{i})...
                                     .aligned.fs;
                end
            end
        end
    end
end

set(uicVar,'userData',uicVarLocal);
set(userOpt,'userData',options);

end

function changeVar(scr,~,userOpt,pFile,pSig,pFt,uicEntries,graphics,...
                   uicVar,uicResults)

% Change variable to create new system
errStat = 0;
oldValue = get(scr,'userData');
newValue = get(scr,'value');
options = get(userOpt,'userData');

if oldValue ~= newValue
    if (strcmp(get(scr,'tag'),'in') && ...
            options.session.ft.varValue.out == 1)
        uiwait(errordlg(['Variables must be selected in the correct ',...
            'order! Please indicate first the output variable, then ',...
            'the input variable.'],...
            'Variables must be selected in the correct order','modal'));
        set(scr,'value',1);
        errStat = 1;
    elseif (strcmp(get(scr,'tag'),'out') && newValue == 1 && ...
            options.session.ft.varValue.in ~= 1)
        uiwait(errordlg(['Variables must be eliminated in the correct ',...
            'order! Please eliminate first the input variable, then ',...
            'the output variable.'],...
            'Variables must be eliminated in the correct order','modal'));
        set(scr,'value',oldValue);
        errStat = 1;
    end
else
    errStat = 1;
end

if ~errStat && ~strcmp(get(scr,'tag'),'out')
    % Read data from the variable
    id = []; type = [];
    auxVar = options.session.ft.varString.in;
    if contains(auxVar,'RRI')
        id = 'ecg'; type = 'rri'; 
    elseif contains(auxVar,'HR')
        id = 'ecg'; type = 'hr'; 
    elseif contains(auxVar,'SBP')
        id = 'bp'; type = 'sbp';
    elseif contains(auxVar,'DBP')
        id = 'bp'; type = 'dbp';
    elseif contains(auxVar,'Filtered')
        id = 'rsp'; type = 'filt';
    elseif contains(auxVar,'ILV')
        id = 'rsp'; type = 'ilv';
    end
    if ~isempty(id)
        patient = get(pFile,'userData');
        fs = patient.sig.(id).(type).aligned.fs;
        dataLen = length(patient.sig.(id).(type).aligned.time);
        % Reference data (output)
        uicVarLocal = get(uicVar,'userData');
        if uicVarLocal.fs ~= fs
            uiwait(errordlg(['Variables must have the same sampling ',...
                'frequency! The variable indicated as output has a ',...
                num2str(uicVarLocal.fs),' Hz sampling frequency while',...
                ' the variable selected has a ',num2str(fs),' Hz ',...
                'sampling frequency. A system must be composed of ',...
                'variables with aligned samples.'],...
                'Different sampling frequencies','modal'));
            set(scr,'value',oldValue);
            errStat = 1;
        elseif length(uicVarLocal.out) ~= dataLen
            uiwait(errordlg(['Variables must have the same length! The',...
                ' variable indicated as output has ',num2str(length(...
                uicVarLocal.out)),' samples while the variable ',...
                'selected has ',num2str(dataLen),' samples. A system ',...
                'must be composed of variables with the same time',...
                'axis.'],...
                'Different lengths','modal'));
            set(scr,'value',oldValue);
            errStat = 1;
        end
    end
end

if ~errStat
    
    options.session.ft.varValue.(get(scr,'tag')) = newValue;
    set(scr,'userData',newValue);    
    set(userOpt,'userData',options);

    setup(userOpt,pFile,uicVar);
    
    options = get(userOpt,'userData');
    options.session.ft.saved = 0;
    set(userOpt,'userData',options);
    
    ftCalc(userOpt,uicVar,pFt);
    ftPlot(pFt,userOpt,graphics);
    calcAreas(userOpt,pFt,uicResults);
    
else
    set(scr,'value',oldValue);
end
end

function value = checkLim(userOpt,value,tag,uicVar)

options = get(userOpt,'userData');
var = get(uicVar,'userData');

switch tag
    case 'vlf'
        lowLim = 0; 
        highLim = options.session.ft.lf;
    case 'lf'
        lowLim = options.session.ft.vlf;
        highLim = options.session.ft.hf;
    case 'hf'
        lowLim = options.session.ft.lf;
        highLim = options.session.ft.maxF;
    case 'minF'
        lowLim = 0; 
        highLim = options.session.ft.maxF;
    case 'maxF'
        lowLim = options.session.ft.minF;
        if ~isempty(var.fs)
            highLim = var.fs/2;
        else
            highLim = 2;
        end
    case 'coherence'
        lowLim = 0; 
        highLim = 1; 
    case 'overlapping'
        lowLim = 20;
        highLim = 80;
end

if value < lowLim, value = lowLim; end
if value > highLim, value = highLim; end
end

function ftCalc(userOpt,uicVar,pFt)

options = get(userOpt,'userData');
var = get(uicVar,'userData');
ft = get(pFt,'userData');

% Clean previous values
ft.ftHW = []; 
ft.ftCW = [];
ft.ftFreq = [];

if options.session.ft.sigLen > 0
   
    divisor = 4.5;
    window_size = round(options.session.ft.sigLen/divisor);
    noverlap = ceil((options.session.ft.overlapping/100)*window_size);
    u = detrend(var.in);
    y = detrend(var.out);
    fs = var.fs;
    
    switch options.session.ft.window
        case 0
            window = rectwin(window_size);
        case 1
            window = bartlett(window_size);
        case 2
            window = hamming(window_size);
        case 3
            window = hanning(window_size);
        case 4
            window = blackman(window_size);  
    end
    
    [SuuW,fw1] = cpsd(u,u,window,noverlap,[],fs);
    [SyyW,fw2] = cpsd(y,y,window,noverlap,[],fs);
    [SuyW,fw3] = cpsd(u,y,window,noverlap,[],fs);
   
    ft.ftHW = SuyW./SuuW;
    ft.ftCW = abs(SuyW).^2./(SuuW.*SyyW);
    ft.ftFreq = fw1;
  
end

set(pFt,'userData',ft);

end

function ftPlot(pFt,userOpt,graphics)

options = get(userOpt,'userData');
ft = get(pFt,'userData');

graphs = {'module','angle','coherence'};
labels = {'Gain(H)','Phase(H)','Coherence'};
colors = {'#0072BD','#EDB120','#A2142F'};

h = {};

if options.session.ft.sigLen > 0
    
    for i = 1:3
        plot(graphics.(graphs{i}),0,0); 
    end
    
    switch options.session.ft.scale
        case 0
            h{1}=plot(graphics.module,ft.ftFreq,abs(ft.ftHW));
            h{2}=plot(graphics.angle,ft.ftFreq,angle(ft.ftHW)*180/pi);
            h{3}=plot(graphics.coherence,ft.ftFreq,ft.ftCW);
        case 1
            h{1}=semilogy(graphics.module,ft.ftFreq,abs(ft.ftHW));
            h{2}=plot(graphics.angle,ft.ftFreq,angle(ft.ftHW)*180/pi);
            h{3}=plot(graphics.coherence,ft.ftFreq,ft.ftCW);
        case 2
            h{1}=loglog(graphics.module,ft.ftFreq,abs(ft.ftHW)); 
            h{2}=semilogx(graphics.angle,ft.ftFreq,angle(ft.ftHW)*180/pi);
            h{3}=semilogx(graphics.coherence,ft.ftFreq,ft.ftCW);
    end
    
    for i = 1:3
        xlim(graphics.(graphs{i}),[options.session.ft.minF ...
                             options.session.ft.maxF]);
        ylabel(graphics.(graphs{i}),labels{i});
        grid(graphics.(graphs{i}),'on'); 
        set(h{i},'linewidth',1.2);
        set(h{i},'color',colors{i});
    end
    
else
    
    for i = 1:3
        plot(graphics.(graphs{i}),0,0);
        ylabel(graphics.(graphs{i}),labels{i});
        grid(graphics.(graphs{i}),'on'); 
    end
    
end
end

function calcAreas(userOpt,pFt,uicResults)

options = get(userOpt,'userData');
ft = get(pFt,'userData');

if options.session.ft.sigLen > 0
    
    HW_lf_c = zeros(size(ft.ftHW));
    HW_hf_c = zeros(size(ft.ftHW));
    HW_lf = zeros(size(ft.ftHW));
    HW_hf = zeros(size(ft.ftHW));

    for i = 1:length(ft.ftHW)
        if (ft.ftFreq(i) >= options.session.ft.vlf) && ...
           (ft.ftFreq(i) <= options.session.ft.lf) && ...
           (ft.ftCW(i) > options.session.ft.coherence)
            HW_lf_c(i) = abs(ft.ftHW(i));
        else
            HW_lf_c(i) = 0;
        end
        if (ft.ftFreq(i) > options.session.ft.lf) && ...
           (ft.ftFreq(i) <= options.session.ft.hf) && ...
           (ft.ftCW(i) > options.session.ft.coherence)
            HW_hf_c(i) = abs(ft.ftHW(i));
        else
            HW_hf_c(i) = 0;
        end
    end
    
    aux = 0;
    for i = 1:length(ft.ftCW)
        if ft.ftCW(i) > options.session.ft.coherence
            aux = aux + 1;
        end
    end
    
    for i = 1:length(ft.ftHW)
        if (ft.ftFreq(i) >= options.session.ft.vlf) && ...
           (ft.ftFreq(i) <= options.session.ft.lf)
            HW_lf(i) = abs(ft.ftHW(i));
        else
            HW_lf(i) = 0;
        end
        if (ft.ftFreq(i) > options.session.ft.lf) && ...
           (ft.ftFreq(i) <= options.session.ft.hf)
            HW_hf(i) = abs(ft.ftHW(i));
        else
            HW_hf(i) = 0;
        end
    end

    options.session.ft.areas.lf_c = trapz(HW_lf_c);
    options.session.ft.areas.hf_c = trapz(HW_hf_c);
    options.session.ft.areas.percentage = (aux/length(ft.ftCW))*100;
    options.session.ft.areas.lf = trapz(HW_lf);
    options.session.ft.areas.hf = trapz(HW_hf);
    set(userOpt,'userData',options);
    
    areasStr = sprintf(['Absolute Areas',...
                        '\nLF_c: ',...
                        num2str(options.session.ft.areas.lf_c),...
                        '\nHF_c: ',...
                        num2str(options.session.ft.areas.hf_c),...
                        '\nTotal_c: ',...
                        num2str(options.session.ft.areas.lf_c + ...
                                options.session.ft.areas.hf_c),...
                        '\nPercentage above the coherence limit: ',...
                        num2str(options.session.ft.areas.percentage),...
                        '%%\n\nAbsolute Areas',...
                        '\nLF: ',...
                        num2str(options.session.ft.areas.lf),...
                        '\nHF: ',...
                        num2str(options.session.ft.areas.hf),...
                        '\nTotal: ',...
                        num2str(options.session.ft.areas.lf + ...
                                options.session.ft.areas.hf)]);
    set(uicResults,'string',areasStr);
    
else
    
    options.session.ft.areas.lf_c = [];
    options.session.ft.areas.hf_c = [];
    options.session.ft.areas.percentage = [];
    options.session.ft.areas.lf = [];
    options.session.ft.areas.hf = [];
    set(userOpt,'userData',options);
    
   areasStr = sprintf(['Absolute Areas\nLF_c:  ----\nHF_c:  ----\n'...
                       'Total_c: ----\nPercentage above the '...
                       'coherence limit: ----\n\nAbsolute Areas\nLF'...
                       ': ----\nHF: ----\nTotal: ----']);
    set(uicResults,'string',areasStr);
    
end
end

function changeWindow(scr,~,userOpt,pFt,uicVar,uicWindows,uicResults,...
                      graphics)

number = get(scr,'userData');
options = get(userOpt,'userData');

switch number
    case 0
        set(uicWindows.Rectangular,'value',1); 
        set(uicWindows.Bartlett,'value',0); 
        set(uicWindows.Hamming,'value',0);
        set(uicWindows.Hanning,'value',0); 
        set(uicWindows.Blackman,'value',0);
        options.session.ft.window = number;
    case 1
        set(uicWindows.Rectangular,'value',0); 
        set(uicWindows.Bartlett,'value',1); 
        set(uicWindows.Hamming,'value',0);
        set(uicWindows.Hanning,'value',0); 
        set(uicWindows.Blackman,'value',0);
        options.session.ft.window = number;
    case 2
        set(uicWindows.Rectangular,'value',0); 
        set(uicWindows.Bartlett,'value',0); 
        set(uicWindows.Hamming,'value',1);
        set(uicWindows.Hanning,'value',0); 
        set(uicWindows.Blackman,'value',0);
        options.session.ft.window = number;
    case 3
        set(uicWindows.Rectangular,'value',0); 
        set(uicWindows.Bartlett,'value',0); 
        set(uicWindows.Hamming,'value',0);
        set(uicWindows.Hanning,'value',1); 
        set(uicWindows.Blackman,'value',0);
        options.session.ft.window = number;
    case 4
        set(uicWindows.Rectangular,'value',0); 
        set(uicWindows.Bartlett,'value',0); 
        set(uicWindows.Hamming,'value',0);
        set(uicWindows.Hanning,'value',0); 
        set(uicWindows.Blackman,'value',1);
        options.session.ft.window = number;
end

set(userOpt,'userData',options);
    
ftCalc(userOpt,uicVar,pFt);
ftPlot(pFt,userOpt,graphics);
calcAreas(userOpt,pFt,uicResults);

end

function changeScale(scr,~,userOpt,pFt,uicScales,graphics)

number = get(scr,'userData');
options = get(userOpt,'userData');

switch number
    case 0
        set(uicScales.Normal,'value',1); 
        set(uicScales.Monolog,'value',0);
        set(uicScales.Loglog,'value',0);
        options.session.ft.scale = number;
    case 1
        set(uicScales.Normal,'value',0); 
        set(uicScales.Monolog,'value',1);
        set(uicScales.Loglog,'value',0);
        options.session.ft.scale = number;   
    case 2
        set(uicScales.Normal,'value',0); 
        set(uicScales.Monolog,'value',0);
        set(uicScales.Loglog,'value',1);
        options.session.ft.scale = number; 
end

set(userOpt,'userData',options);
    
ftPlot(pFt,userOpt,graphics);

end

function changeCoherence(scr,~,userOpt,pFt,uicResults,uicVar)

options = get(userOpt,'userData');
coherence = str2double(get(scr,'string'));

if ~isnan(coherence)
    options.session.ft.coherence = checkLim(userOpt,...
                                   coherence,'coherence',uicVar);
    set(userOpt,'userData',options);                          
    set(scr,'string',num2str(options.session.ft.coherence));
    
    calcAreas(userOpt,pFt,uicResults);
else
    set(scr,'string',num2str(options.session.ft.coherence));
end

end

function changeOverlapping(scr,~,userOpt,pFt,uicResults,uicVar,graphics)

options = get(userOpt,'userData');
overlapping = str2double(get(scr,'string'));

if ~isnan(overlapping)
    options.session.ft.overlapping = checkLim(userOpt,...
                                     overlapping,'overlapping',uicVar);
    set(userOpt,'userData',options);                          
    set(scr,'string',num2str(options.session.ft.overlapping));
    
    ftCalc(userOpt,uicVar,pFt);
    ftPlot(pFt,userOpt,graphics);
    calcAreas(userOpt,pFt,uicResults);
    
else
    set(scr,'string',num2str(options.session.ft.overlapping));
end

end

function changeBands(scr,~,userOpt,pFt,uicResults,uicVar,graphics,uicBands)

options = get(userOpt,'userData');
band = str2double(get(scr,'string'));
tag = get(scr,'tag');

if ~isnan(band)
    
    switch tag
        case 'vlf'
            options.session.ft.vlf = checkLim(userOpt,band,'vlf',uicVar);        
            set(scr,'string',num2str(options.session.ft.vlf));
            set(uicBands.textLF,'string',num2str(options.session.ft.vlf));
        case 'lf'
            options.session.ft.lf = checkLim(userOpt,band,'lf',uicVar);        
            set(scr,'string',num2str(options.session.ft.lf));
            set(uicBands.textHF,'string',num2str(options.session.ft.lf));
        case 'hf'
            options.session.ft.hf = checkLim(userOpt,band,'hf',uicVar);        
            set(scr,'string',num2str(options.session.ft.hf));
    end
    
    set(userOpt,'userData',options);
    
    ftCalc(userOpt,uicVar,pFt);
    ftPlot(pFt,userOpt,graphics);
    calcAreas(userOpt,pFt,uicResults);
    
else
    switch tag
        case 'vlf'
            set(scr,'string',num2str(options.session.ft.vlf));
        case 'lf'
            set(scr,'string',num2str(options.session.ft.lf));
        case 'hf'
            set(scr,'string',num2str(options.session.ft.hf));
    end 
end

end

function changeLimits(scr,~,userOpt,pFt,uicAxes,graphics,uicVar)

options = get(userOpt,'userData');
limit = str2double(get(scr,'string'));
tag = get(scr,'tag');

if ~isnan(limit)
    switch tag
        case 'minF'
           options.session.ft.minF = checkLim(userOpt,limit,'minF',uicVar);        
           set(scr,'string',num2str(options.session.ft.minF));
           set(uicAxes.minFreq,'string',num2str(options.session.ft.minF));
        case 'maxF'
           options.session.ft.maxF = checkLim(userOpt,limit,'maxF',uicVar);        
           set(scr,'string',num2str(options.session.ft.maxF));
           set(uicAxes.maxFreq,'string',num2str(options.session.ft.maxF));
    end
    set(userOpt,'userData',options);
    ftPlot(pFt,userOpt,graphics);
else
    switch tag
        case 'minF'
            set(scr,'string',num2str(options.session.ft.minF));
        case 'maxF'
            set(scr,'string',num2str(options.session.ft.maxF));
    end 
end
end

function saveSignal(~,~,userOpt,pFile,pFt)

end

function exportAreas(src,~,userOpt)
options = get(userOpt,'userData');
if options.session.ft.sigLen > 0
    areas=sprintf(['HW_lf\t',num2str(options.session.ft.areas.lf),...
                   '\nHW_hf\t',num2str(options.session.ft.areas.hf),...
                   '\nHW_lfc\t',num2str(options.session.ft.areas.lf_c),...
                   '\nHW_hfc\t',num2str(options.session.ft.areas.hf_c),...
                   '\n\n\n']);
    if options.session.ft.window == 0, strWindow = 'Rectangular'; 
    elseif options.session.ft.window == 1, strWindow = 'Bartlett';
    elseif options.session.ft.window == 2, strWindow = 'Hamming';
    elseif options.session.ft.window == 3, strWindow = 'Hanning';
    elseif options.session.ft.window == 4, strWindow = 'Blackman';
    end
    strSignalIn = options.session.ft.varString.in...
                 {options.session.ft.varValue.in};
    strSignalOut = options.session.ft.varString.out...
                  {options.session.ft.varValue.out};;
    strPercentage = num2str(options.session.ft.areas.percentage);
    strCoherence = num2str(options.session.ft.coherence);
    strOverlapping = num2str(options.session.ft.overlapping);
    strVlf = num2str(options.session.ft.vlf);
    strLf = num2str(options.session.ft.lf);
    strHf = num2str(options.session.ft.hf);
    configurations = sprintf(['Information',...
                              '\nSignal(in): ',strSignalIn,...
                              '\nSignal(out): ',strSignalOut,...
                              '\nPercentage above the coherence ',...
                              'limit: ', strPercentage,' percent',...
                              '\nWindow: ', strWindow,...
                              '\nCoherence: ', strCoherence,'\n',...
                              'Overlapping: ',strOverlapping,' percent',...
                              '\nVLF: 0 to ', strVlf, ' Hz',...
                              '\nLF: ', strVlf, ' to ', strLf, ' Hz',...
                              '\nHF: ', strLf, ' to ', strHf, ' Hz']);
    text = sprintf([areas,configurations]);
    [path,name,~] = fileparts(options.session.filename);
    filename = fullfile(path,[name,'_tf.txt']);
    [fid, message] = fopen(filename,'w');
    if fid == -1
        uiwait(errordlg(['Could not create file: ',message,...
                         '. Verify if the file is opened in ',...
                         'another program or try again with a ',...
                         'different filename.'],...
                         'TXT export error','modal'));
    else
        fprintf(fid,text,'char');
        uiwait(msgbox('Saved!'));
        fclose(fid);
    end
end
end