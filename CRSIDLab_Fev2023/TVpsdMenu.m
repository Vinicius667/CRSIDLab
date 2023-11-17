function TVpsdMenu(pnTVPsd,pFile,pSig,userOpt)
% TVPsdMenu - CRSIDLab
%   The TVpsdMenu presents options for Time Variant PSD analysis of any available
%   resampled variable: R-R interval (RRI), heart rate (HR), systolic blood
%   pressure (SBP), diastolic blood pressure (DBP) and instantaneous lung
%   volume (ILV). PSD can be estimated through the Fourier transform, the
%   Welch method and/or the AR model. Absolute, relative and normalized
%   areas are given as a measure of power on three frequency bands, that
%   can be delimited by the user.
%
% Original Matlab code: Luisa Santiago C. B. da Silva, April 2017.
% Adapted by: André L. S. Ferreira, March 2019.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Data visualization and slider
%

uicontrol('parent',pnTVPsd,'style','text','string','Select register:',...
    'hor','left','units','normalized','position',[.032 .93 .1 .03]);
puVar = uicontrol('parent',pnTVPsd,'style','popupmenu','string',...
    'No data available','value',1,'backgroundColor',[1 1 1],'units',...
    'normalized','position',[.13 .93 .2 .04]);

pHandle = axes('parent',pnTVPsd,'Units','pixels','Units','normalized',...
    'Position',[.057 .14 .515 .74]);

uicontrol('parent',pnTVPsd,'style','text','hor','right','string',...
    '','fontSize',10,'units','normalized','position',...
    [.476 .06 .1 .035]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Time Varying PSD Parameters
%

pnParams = uipanel('parent',pnTVPsd,'Units','Normalized','Position',...
    [.748 .67 .23 .21]);

uicontrol('parent',pnParams,'Style','text','String',['Spectrogram ',...
    'parameters:'],'Units','Normalized','Position',[.05 .825 .9 .13]);

% # of points for fourier transform
uicontrol('parent',pnParams,'Style','text','String','# of Points:',...
    'hor','left','Units','Normalized','Position',[.05 .63 .3 .15]);

teN = uicontrol('parent',pnParams,'Style','edit','tag','N','Units',...
    'Normalized','Position',[.3 .63 .15 .15],'backgroundColor',[1 1 1]);

txN = uicontrol('parent',pnParams,'Style','text','String',...
    '(Suggested: -) ','hor','right','Units','Normalized','Position',...
    [.45 .63 .5 .15]);

% AR model order
uicontrol('parent',pnParams,'Style','text','String','AR Order:','hor',...
    'left','Units','Normalized','Position',[.05 .435 .3 .15]);

teArOrder = uicontrol('parent',pnParams,'Style','edit','tag','arOrder',...
    'Units','Normalized','Position',[.3 .435 .15 .15],'backgroundColor',...
    [1 1 1]);

% # of overlapping samples
uicontrol('parent',pnParams,'Style','text','String',['Overlapping ',...
    'samples:'],'hor','left','Units','Normalized','Position',...
    [.05 .045 .5 .15]);

txOverlap = uicontrol('parent',pnParams,'Style','text','String',...
    '(max: ----) ','hor','right','Units','Normalized','Position',...
    [.7 .045 .3 .15]);

teOverlap = uicontrol('parent',pnParams,'Style','edit','tag','overlap',...
    'Units','Normalized','Position',[.55 .045 .15 .15],...
    'backgroundColor',[1 1 1]);

% # of samples per segment
uicontrol('parent',pnParams,'Style','text','String',['Samples per ',...
    'segment:'],'hor','left','Units','Normalized','Position',...
    [.05 .24 .5 .15]);

txSegments = uicontrol('parent',pnParams,'Style','text','String',...
    '(max: ----) ','hor','right','Units','Normalized','Position',...
    [.7 .24 .3 .15]);

teSegments = uicontrol('parent',pnParams,'Style','edit','tag',...
    'segments','Units','Normalized','Position',[.55 .24 .15 .15],...
    'backgroundColor',[1 1 1]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Window
%

pnWindow = uipanel('parent',pnTVPsd,'Units','Normalized','Position',...
    [.748 .53 .23 .14]);

uicontrol('parent',pnWindow,'Style','text','String','Window:','Units',...
    'Normalized','Position',[.05 .76 .9 .2]);

rbRec = uicontrol('parent',pnWindow,'Style','radio','tag','window',...
    'String','Rectangular','userData',0,'Units','Normalized','Position',...
    [.05 .52 .4 .2]);

rbBar = uicontrol('parent',pnWindow,'Style','radio','tag','window',...
    'String','Bartlett','userData',1,'Units','Normalized','Position',...
    [.05 .28 .4 .2]);

rbHam = uicontrol('parent',pnWindow,'Style','radio','tag','window',...
    'String','Hamming','userData',2,'Units','Normalized','Position',...
    [.05 .04 .4 .2]);

rbHan = uicontrol('parent',pnWindow,'Style','radio','tag','window',...
    'String','Hanning','userData',3,'Units','Normalized','Position',...
    [.55 .52 .4 .2]);

rbBla = uicontrol('parent',pnWindow,'Style','radio','tag','window',...
    'String','Blackman','userData',4,'Units','Normalized','Position',...
    [.55 .28 .4 .2]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Time Varying PSD methods (STFT, TV Welch, TV AR model)
%

pnMethod = uipanel('parent',pnTVPsd,'Units','Normalized','Position',...
    [.748 .39 .230 .14]);

uicontrol('parent',pnMethod,'Style','text','String','Method:','Units',...
    'Normalized','Position',[.05 .76 .9 .2]);

cbDft = uicontrol('parent',pnMethod,'Style','radio','String',['Short Time',...
    ' Fourier Transform'],'userData',1,'Units','Normalized','Position',...
    [.05 .52 .9 .2]);

cbWelch = uicontrol('parent',pnMethod,'Style','radio','String',['Time Varying',...
    ' Welch Method'],'userData',2,'Units','Normalized','Position',...
    [.05 .28 .9 .2]);

cbAR = uicontrol('parent',pnMethod,'Style','radio','String','Time Varying AR Model',...
    'userData',3,'Units','Normalized','Position',[.05 .04 .9 .2]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Data Visualization (PSD, LF and HF, LF/HF)
%

pnVis = uipanel('parent',pnTVPsd,'Units','Normalized','Position',...
    [.593 .67 .155 .21]);

uicontrol('parent',pnVis,'Style','text','String','Data Visualization:','Units',...
    'Normalized','Position',[.05 .76 .9 .2]);

cbPsd = uicontrol('parent',pnVis,'Style','radio','String',['Power Spectral',...
    ' Density (PSD)'],'userData',1,'Units','Normalized','Position',...
    [.05 .58 .9 .2]);

cbLFHF = uicontrol('parent',pnVis,'Style','radio','String',['LF and HF',...
    ' Variations'],'userData',2,'Units','Normalized','Position',...
    [.05 .40 .9 .2]);

cbLFHFRatio = uicontrol('parent',pnVis,'Style','radio','String','LF/HF Ratio Variations',...
    'userData',3,'Units','Normalized','Position',[.05 .22 .9 .2]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Axes limits
%

frAxes = uipanel('parent',pnTVPsd,'Units','Normalized','Position',...
    [.748 .275 .23 .115]);

uicontrol('parent',frAxes,'Style','text','String','Plot axes:','Units',...
    'Normalized','Position',[.05 .75 .9 .2]);

txVar = uicontrol('parent',frAxes,'Style','text','String','Freq. From:','hor',...
    'left','Units','Normalized','Position',[.05 .4 .3 .3]);

teMinF = uicontrol('parent',frAxes,'Style','edit','tag','minF','Units',...
    'Normalized','Position',[.32 .4 .15 .3],'BackgroundColor',[1 1 1]);

txVarUnit = uicontrol('parent',frAxes,'Style','text','String','Hz             To:',...
    'Units','Normalized','Position',[.47 .4 .35 .28]);

teMaxF = uicontrol('parent',frAxes,'Style','edit','tag','maxF','Units',...
    'Normalized','Position',[.8 .4 .15 .3],'BackgroundColor',[1 1 1]);

uicontrol('parent',frAxes,'Style','text','String','Time From:','hor',...
    'left','Units','Normalized','Position',[.05 .05 .3 .3]);

teMinP = uicontrol('parent',frAxes,'Style','edit','tag','minP',...
    'Callback',{@teCallback,userOpt,pHandle,pSig},'Units','Normalized',...
    'Position',[.32 .05 .15 .3],'BackgroundColor',[1 1 1]);

txUnit = uicontrol('parent',frAxes,'Style','text','string',['s        ',...
    '   To:'],'Units','Normalized','Position',[.47 .05 .35 .28]);

teMaxP = uicontrol('parent',frAxes,'Style','edit','tag','maxP',...
    'Callback',{@teCallback,userOpt,pHandle,pSig},'Units','Normalized',...
    'Position',[.8 .05 .15 .3],'BackgroundColor',[1 1 1]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Frequency band definition (VLF,LF and HF)
%

pnBands = uipanel('parent',pnTVPsd,'Units','Normalized','Position',...
    [.748 .145 .23 .13]);

% very low frequency (VLF) upper limit
uicontrol('parent',pnBands,'Style','text','String','Very  Low Freqs.:',...
    'hor','left','Units','Normalized','Position',[.05 .685 .4 .26]);
uicontrol('parent',pnBands,'Style','text','string','0','Units',...
    'Normalized','Position',[.45 .685 .15 .26]);
uicontrol('parent',pnBands,'Style','text','String','to','Units',...
    'Normalized','Position',[.6 .685 .1 .26]);
teVlf = uicontrol('parent',pnBands,'Style','edit','tag','vlf','Units',...
    'Normalized','Position',[.7 .685 .15 .26],'BackgroundColor',[1 1 1]);
uicontrol('parent',pnBands,'Style','text','String','Hz','Units',...
    'Normalized','Position',[.85 .685 .1 .26]);

% low frequency (LF) upper limit
uicontrol('parent',pnBands,'Style','text','String','Low Frequencies:',...
    'hor','left','Units','Normalized','Position',[.05 .37 .4 .26]);
txLf = uicontrol('parent',pnBands,'Style','text','Units','normalized',...
    'Position',[.45 .37 .15 .26]);
uicontrol('parent',pnBands,'Style','text','String','to','Units',...
    'Normalized','Position',[.6 .37 .1 .26]);
teLf = uicontrol('parent',pnBands,'Style','edit','tag','lf','Units',...
    'Normalized','Position',[.7 .37 .15 .26],'BackgroundColor',[1 1 1]);
uicontrol('parent',pnBands,'Style','text','String','Hz','Units',...
    'Normalized','Position',[.85 .37 .1 .26]);

% high frequency (HF) upper limit
uicontrol('parent',pnBands,'Style','text','String','High Frequencies:',...
    'hor','left','Units','Normalized','Position',[.05 .055 .4 .26]);
txHf = uicontrol('parent',pnBands,'Style','text','Units','Normalized',...
    'Position',[.45 .055 .15 .26]);
uicontrol('parent',pnBands,'Style','text','String','to','Units',...
    'Normalized','Position',[.6 .055 .1 .26]);
teHf = uicontrol('parent',pnBands,'Style','edit','tag','hf','units',...
    'Normalized','Position',[.7 .055 .15 .26],'BackgroundColor',[1 1 1]);
uicontrol('parent',pnBands,'Style','text','String','Hz','Units',...
    'Normalized','Position',[.85 .055 .1 .26]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Save spectrogram
%

pnButtons = uipanel('parent',pnTVPsd,'Units','Normalized','Position',...
    [.748 .06 .23 .085]);

uicontrol('parent',pnButtons,'Style','push','String','Save Spectrogram',...
    'CallBack',{@saveSig,userOpt,pFile,pSig},'Units','Normalized',...
    'Position',[.30 .2 .430 .6]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Set final callbacks and call opening function (setup)
%

set(teMinF,'Callback',{@teCallback,userOpt,pHandle,pSig,[],[],teMinP,...
    teMaxP,teMinF,teMaxF,txVar,txVarUnit});
set(teMaxF,'Callback',{@teCallback,userOpt,pHandle,pSig,[],[],teMinP,...
    teMaxP,teMinF,teMaxF,txVar,txVarUnit});

set(teMinP,'Callback',{@teCallback,userOpt,pHandle,pSig,[],[],teMinF,...
    teMaxF,teMinF,teMaxF,txVar,txVarUnit});
set(teMaxP,'Callback',{@teCallback,userOpt,pHandle,pSig,[],[],teMinF,...
    teMaxF,teMinF,teMaxF,txVar,txVarUnit});


set(teN,'Callback',{@teCallback,userOpt,pHandle,pSig,[],[],...
    teMinP,teMaxP,teMinF,teMaxF,txVar,txVarUnit});
set(teArOrder,'Callback',{@teCallback,userOpt,pHandle,pSig,[],...
    [],teMinP,teMaxP,teMinF,teMaxF,txVar,txVarUnit});
set(teOverlap,'Callback',{@teCallback,userOpt,pHandle,pSig,...
    txOverlap,[],teMinP,teMaxP,teMinF,teMaxF,txVar,txVarUnit});
set(teSegments,'Callback',{@teCallback,userOpt,pHandle,pSig,...
    txOverlap,teOverlap,teMinP,teMaxP,teMinF,teMaxF,txVar,txVarUnit});

set(teVlf,'Callback',{@teCallback,userOpt,pHandle,pSig,txLf,[],...
    teMinP,teMaxP,teMinF,teMaxF,txVar,txVarUnit});
set(teLf,'Callback',{@teCallback,userOpt,pHandle,pSig,txHf,[],...
    teMinP,teMaxP,teMinF,teMaxF,txVar,txVarUnit});
set(teHf,'Callback',{@teCallback,userOpt,pHandle,pSig,[],[],...
    teMinP,teMaxP,teMinF,teMaxF,txVar,txVarUnit});

set(rbRec,'Callback',{@rbCallback,userOpt,pHandle,pSig,teMinP,...
    teMaxP,teMinF,teMaxF,txVar,txVarUnit,rbBar,rbHam,rbHan,rbBla});
set(rbBar,'Callback',{@rbCallback,userOpt,pHandle,pSig,teMinP,...
    teMaxP,teMinF,teMaxF,txVar,txVarUnit,rbRec,rbHam,rbHan,rbBla});
set(rbHam,'Callback',{@rbCallback,userOpt,pHandle,pSig,teMinP,...
    teMaxP,teMinF,teMaxF,txVar,txVarUnit,rbRec,rbBar,rbHan,rbBla});
set(rbHan,'Callback',{@rbCallback,userOpt,pHandle,pSig,teMinP,...
    teMaxP,teMinF,teMaxF,txVar,txVarUnit,rbRec,rbBar,rbHam,rbBla});
set(rbBla,'Callback',{@rbCallback,userOpt,pHandle,pSig,teMinP,...
    teMaxP,teMinF,teMaxF,txVar,txVarUnit,rbRec,rbBar,rbHam,rbHan});

set(cbAR,'Callback',{@cbCallback,userOpt,pHandle,pSig,...
    teMinP,teMaxP,teMinF,teMaxF,txVar,txVarUnit,cbDft,cbWelch});
set(cbDft,'Callback',{@cbCallback,userOpt,pHandle,pSig,...
    teMinP,teMaxP,teMinF,teMaxF,txVar,txVarUnit,cbAR,cbWelch});
set(cbWelch,'Callback',{@cbCallback,userOpt,pHandle,pSig,...
    teMinP,teMaxP,teMinF,teMaxF,txVar,txVarUnit,cbDft,cbAR});

set(cbPsd,'Callback',{@cbVisCallback,userOpt,pHandle,pSig,...
    teMinP,teMaxP,teMinF,teMaxF,txVar,txVarUnit,cbLFHF,cbLFHFRatio});
set(cbLFHF,'Callback',{@cbVisCallback,userOpt,pHandle,pSig,...
    teMinP,teMaxP,teMinF,teMaxF,txVar,txVarUnit,cbPsd,cbLFHFRatio});
set(cbLFHFRatio,'Callback',{@cbVisCallback,userOpt,pHandle,pSig,...
    teMinP,teMaxP,teMinF,teMaxF,txVar,txVarUnit,cbLFHF,cbPsd});

set(puVar,'callback',{@changeVar,userOpt,pFile,pSig,teMinP,teMaxP,...
    teMinF,teMaxF,txVar,txVarUnit,teSegments,txSegments,teOverlap,...
    txOverlap,cbPsd,cbLFHF,cbLFHFRatio,txN,txUnit,pHandle});

openFnc(userOpt,pFile,pSig,puVar,teN,txN,teArOrder,teSegments,...
    txSegments,teOverlap,txOverlap,cbDft,cbAR,cbWelch,cbPsd,...
    cbLFHF,cbLFHFRatio,rbRec,rbBar,rbHam,...
    rbHan,rbBla,teVlf,txLf,teLf,txHf,teHf,...
    teMinP,teMaxP,teMinF,teMaxF,txUnit,txVar,txVarUnit,pHandle);
end

function openFnc(userOpt,pFile,pSig,puVar,teN,txN,teArOrder,teSegments,...
    txSegments,teOverlap,txOverlap,cbDft,cbAR,cbWelch,cbPsd,...
    cbLFHF,cbLFHFRatio,rbRec,rbBar,rbHam,...
    rbHan,rbBla,teVlf,txLf,teLf,txHf,teHf,...
    teMinP,teMaxP,teMinF,teMaxF,txUnit,txVar,txVarUnit,pHandle)
% adjust initial values of objects

options = get(userOpt,'userData');
patient = get(pFile,'userData');

% string for variable selection popupmenu from available patient data
stringPU = cell(5,1);
id = {'ecg','bp','rsp'};
count = 1;
for i = 1:3
    if i == 1, var = {'rri'};
    elseif i == 2, var = {'sbp','dbp'};
    else var = {'ilv','filt'}; 
    end
    for j = 1:length(var)
        if ~isempty(patient.sig.(id{i}).(var{j}).aligned.data)
            stringPU{count} = patient.sig.(id{i}).(var{j}).aligned.specs.tag;
            count = count+1;
        end
    end
end
stringPU = stringPU(~cellfun(@isempty,stringPU));
if isempty(stringPU)
    stringPU{1} = 'No aligned & resampled data available';
end

% adjust selection value if the variables list has changed
if ~isequal(options.session.tvpsd.varString,stringPU)
    if ~isempty(options.session.tvpsd.varString)
        if ismember(options.session.tvpsd.varString{...
                options.session.tvpsd.varValue},stringPU)
            options.session.tvpsd.varValue = find(ismember(stringPU,...
                options.session.tvpsd.varString{...
                options.session.tvpsd.varValue}));
        else
            options.session.tvpsd.varValue = 1;
        end
    end
    options.session.tvpsd.varString = stringPU;
end

set(puVar,'string',options.session.tvpsd.varString);
set(puVar,'value',options.session.tvpsd.varValue);
set(puVar,'userData',options.session.tvpsd.varValue);

% open data and setup options that depend on the data
set(userOpt,'userData',options);
setup(userOpt,pFile,pSig,teSegments,txSegments,teOverlap,txOverlap,txN,...
    txUnit);
options = get(userOpt,'userData');

options.session.tvpsd.vlf = checkLim(userOpt,options.session.tvpsd.vlf,'vlf');
set(teVlf,'string',num2str(options.session.tvpsd.vlf));
set(txLf,'string',num2str(options.session.tvpsd.vlf));
options.session.tvpsd.lf = checkLim(userOpt,options.session.tvpsd.lf,'lf');
set(teLf,'string',num2str(options.session.tvpsd.lf));
set(txHf,'string',num2str(options.session.tvpsd.lf));
options.session.tvpsd.hf = checkLim(userOpt,options.session.tvpsd.hf,'hf');
set(teHf,'string',num2str(options.session.tvpsd.hf));
options.session.tvpsd.minP = checkLim(userOpt,options.session.tvpsd.minP,...
    'minP');
set(teMinP,'string',num2str(options.session.tvpsd.minP));
options.session.tvpsd.maxP = checkLim(userOpt,options.session.tvpsd.maxP,...
    'maxP');
set(teMaxP,'string',num2str(options.session.tvpsd.maxP));
options.session.tvpsd.minF = checkLim(userOpt,options.session.tvpsd.minF,...
    'minF');
set(teMinF,'string',num2str(options.session.tvpsd.minF));
options.session.tvpsd.maxF = checkLim(userOpt,options.session.tvpsd.maxF,...
    'maxF');
set(teMaxF,'string',num2str(options.session.tvpsd.maxF));
options.session.tvpsd.arOrder = checkLim(...
    userOpt,options.session.tvpsd.arOrder,'arOrder');
set(teArOrder,'string',num2str(options.session.tvpsd.arOrder));
options.session.tvpsd.N = checkLim(userOpt,options.session.tvpsd.N,'N');
set(teN,'String',num2str(options.session.tvpsd.N));

set(cbDft,'value',options.session.tvpsd.cbSelection(1));
set(cbWelch,'value',options.session.tvpsd.cbSelection(2));
set(cbAR,'value',options.session.tvpsd.cbSelection(3));

set(cbPsd,'value',options.session.tvpsd.cbVisSelection(1));
set(cbLFHF,'value',options.session.tvpsd.cbVisSelection(2));
set(cbLFHFRatio,'value',options.session.tvpsd.cbVisSelection(3));

if puVar.Value ~= 1
    set(cbLFHFRatio,'value',0);
    set(cbLFHFRatio,'enable','off');
end

set(rbRec,'value',0); set(rbBar,'value',0); set(rbHam,'value',0);
set(rbHan,'value',0); set(rbBla,'value',0);
if options.session.tvpsd.rbWindow == 0, set(rbRec,'value',1);
elseif options.session.tvpsd.rbWindow == 1, set(rbBar,'value',1);
elseif options.session.tvpsd.rbWindow == 2, set(rbHam,'value',1);
elseif options.session.tvpsd.rbWindow == 3, set(rbHan,'value',1);
elseif options.session.tvpsd.rbWindow == 4, set(rbBla,'value',1);
end

set(userOpt,'userData',options);
TVpsdCalc(userOpt,pSig,teMinP,teMaxP,teMinF,teMaxF,txVar,txVarUnit);
TVpsdPlot(pHandle,pSig,userOpt);
end

function setup(userOpt,pFile,pSig,teSegments,txSegments,teOverlap,...
    txOverlap,txN,txUnit)
% open data and setup options that depend on the data

options = get(userOpt,'userData');

% identify selected data
auxVar = options.session.tvpsd.varString{options.session.tvpsd.varValue};
options.session.tvpsd.sigLen = [];
options.session.tvpsd.sigSpec = [];
id = ''; type = '';
if ~isempty(strfind(auxVar,'RRI')) || ~isempty(strfind(auxVar,'HR'))
    id = 'ecg'; type = 'rri';
elseif ~isempty(strfind(auxVar,'BP'))
    id = 'bp';
    if ~isempty(strfind(auxVar,'SBP'))
        type = 'sbp';
    else
        type = 'dbp';
    end
elseif ~isempty(strfind(auxVar,'ILV'))
    id = 'rsp';
    if ~isempty(strfind(auxVar,'Filtered'))
        type = 'filt';
    else
        type = 'ilv';
    end
end

% open data and setup options
if ~isempty(type)
    options.session.tvpsd.sigSpec = {id, type};
    patient = get(pFile,'userData');
    signals = get(pSig,'userData');

    % adjust optional inputs
    if isempty(patient.sig.(id).(type).aligned.fs)
        if ~isempty(patient.sig.(id).(type).aligned.time)
            patient.sig.(id).(type).aligned.fs = round(1 / ...
                mean(diff(patient.sig.(id).(type).aligned.time))); 
        else
            patient.sig.(id).(type).aligned.fs = 1;
        end
    end
    if isempty(patient.sig.(id).(type).aligned.time)
        patient.sig.(id).(type).aligned.time = ...
            (0:(length(patient.sig.(id).(type).aligned.data)-1))/...
            patient.sig.(id).(type).aligned.fs;
    end 
    signals.(id).(type).aligned = patient.sig.(id).(type).aligned;
    options.session.tvpsd.fs = signals.(id).(type).aligned.fs;
    
    options.session.tvpsd.sigLen = length(signals.(id).(type).aligned.data);
    
    if options.session.tvpsd.segments > options.session.tvpsd.sigLen
        options.session.tvpsd.segments = options.session.tvpsd.sigLen;
    elseif options.session.tvpsd.segments <= 0
        options.session.tvpsd.segments = 1;
    end
    set(txSegments,'string',['(max: ',num2str(...
        options.session.tvpsd.sigLen),') ']);
    
    if options.session.tvpsd.overlap < 0
        options.session.tvpsd.overlap = 0;
    elseif options.session.tvpsd.overlap > options.session.tvpsd.segments-1
        options.session.tvpsd.overlap = options.session.tvpsd.segments-1;
    end
    set(txOverlap,'string',['(max: ',num2str(...
        options.session.tvpsd.segments-1),') ']);
    
    set(txN,'String',['(Suggested: ',num2str(2^nextpow2(...
        options.session.tvpsd.sigLen)),') ']);
    
    if strcmp(id,'ecg')
        if ~isfield(signals.(id).(type).aligned.specs,'type')
            signals.(id).(type).aligned.specs.type = 'rri';
        end
        if strcmp(signals.(id).(type).aligned.specs.type,'rri')
            set(txUnit,'string','Sec            To:');
        else
            set(txUnit,'string','bpm²/Hz    To:');
        end
    else
        set(txUnit,'string','Sec            To:');
    end
    
    options.session.tvpsd.saved = 0;
    set(userOpt,'userData',options);
    set(pFile,'userData',patient);
    set(pSig,'userData',signals);
end

set(teSegments,'string',num2str(options.session.tvpsd.segments));
set(teOverlap,'string',num2str(options.session.tvpsd.overlap));
set(userOpt,'userData',options);
end

function changeVar(scr,~,userOpt,pFile,pSig,teMinP,teMaxP,teMinF,teMaxF,...
    txVar,txVarUnit,teSegments,txSegments,teOverlap,txOverlap,cbPsd,...
    cbLFHF,cbLFHFRatio,txN,txUnit,pHandle)
% change record for variable extraction

errStat = 0;
oldValue = get(scr,'userData');
newValue = get(scr,'value');
options = get(userOpt,'userData');

if newValue ~= 1
    set(cbLFHFRatio,'value',0);
    set(cbLFHF,'value',0);
    set(cbPsd,'value',1);
    set(cbLFHFRatio,'enable','off');
    
    options.session.tvpsd.cbVisSelection = [1,0,0];
else
    set(cbLFHFRatio,'enable','on');    
end

if oldValue ~= newValue
    if ~isempty(options.session.tvpsd.sigLen)
        pat = get(pFile,'userData');
        signals = get(pSig,'userData');
        id = options.session.tvpsd.sigSpec{1};
        type = options.session.tvpsd.sigSpec{2};
        if ~options.session.tvpsd.saved && ...
                ((options.session.tvpsd.cbSelection(1) && ~isequal(...
                pat.sig.(id).(type).aligned.tvpsd.psdFFT,...
                signals.(id).(type).aligned.tvpsd.psdFFT)) || ...
                (options.session.tvpsd.cbSelection(2) && ~isequal(...
                pat.sig.(id).(type).aligned.tvpsd.psdWelch,...
                signals.(id).(type).aligned.tvpsd.psdWelch)) || ...
                (options.session.tvpsd.cbSelection(3) && ~isequal(...
                pat.sig.(id).(type).aligned.tvpsd.psdAR,...
                signals.(id).(type).aligned.tvpsd.psdAR)))
            [selButton, dlgShow] = uigetpref('CRSIDLabPref',...
                'changeVarPsdPref','Change data',sprintf([...
                'Warning!','\nThe current data has not been saved. Any',...
                ' modifications will be lost if other data is opened ',...
                'before saving.\nAre you sure you wish to proceed?']),...
                {'Yes','No'},'DefaultButton','No');
            if strcmp(selButton,'no') && dlgShow
                errStat = 1;
            end  
        end
    end
    if ~errStat
        options.session.tvpsd.varValue = newValue;
        set(scr,'userData',newValue);
        set(userOpt,'userData',options);

        setup(userOpt,pFile,pSig,teSegments,txSegments,teOverlap,...
            txOverlap,txN,txUnit);
        options = get(userOpt,'userData');
        if ~isempty(options.session.tvpsd.sigLen)
            TVpsdCalc(userOpt,pSig,teMinP,teMaxP,teMinF,teMaxF,txVar,txVarUnit);
            TVpsdPlot(pHandle,pSig,userOpt);
        else
            set(get(pHandle,'children'),'visible','off');
        end
    else
        set(scr,'value',oldValue);
    end
end
end

function saveSig(~,~,userOpt,pFile,pSig)
% save selected data

options = get(userOpt,'userData');
if ~isempty(options.session.tvpsd.sigLen)
    
    errStat = 0; saved = 0;
    id = options.session.tvpsd.sigSpec{1};
    type = options.session.tvpsd.sigSpec{2};
    
    % verify if there's already PSD data saved
    patient = get(pFile,'userData');
    signals = get(pSig,'userData');
    psdType = {'psdFFT','psdAR','psdWelch'};
    for i = 1:3
        if ~isempty(patient.sig.(id).(type).aligned.tvpsd.(psdType{i})) &&...
                ~isempty(signals.(id).(type).aligned.tvpsd.(psdType{i}))
            saved = 1;
        end
    end
    
    if saved
        fftString = ''; arString = ''; welchString = '';
        if ~isempty(patient.sig.(id).(type).aligned.tvpsd.(psdType{1})) &&...
                ~isempty(signals.(id).(type).aligned.tvpsd.(psdType{1}))
            fftString = '\n Short Time Fourier Transform';
        end
        if ~isempty(patient.sig.(id).(type).aligned.tvpsd.(psdType{2})) &&...
                ~isempty(signals.(id).(type).aligned.tvpsd.(psdType{2}))
            arString = '\n Time Variant AR Model';
        end
        if ~isempty(patient.sig.(id).(type).aligned.tvpsd.(psdType{3})) &&...
                ~isempty(signals.(id).(type).aligned.tvpsd.(psdType{3}))
            welchString = '\n Time Variant Welch method';
        end
        psdString = [fftString,arString,welchString];
        [selButton, dlgShow] = uigetpref('CRSIDLabPref',...
            'savePsdOWPref','Saving PSD data',sprintf([...
            'Warning!','\nIt appears that there''s already data saved',...
            ' for the following PSD(s) generated:',psdString,'\nAre ',...
            'you sure you wish to overwrite it?']),{'Yes','No'},...
            'DefaultButton','No');
        if strcmp(selButton,'no') && dlgShow
            errStat = 1;
        end     
    end
    
    if ~errStat
        filename = options.session.filename;
        
        % data specifications
        spec = struct;
        
        spec.N = options.session.tvpsd.N;
        switch options.session.tvpsd.rbWindow
            case 0
                spec.window = 'Rectangular';
            case 1
                spec.window = 'Bartlett';
            case 2
                spec.window = 'Hamming';
            case 3
                spec.window = 'Hanning';
            case 4
                spec.window = 'Blackman';
        end
        spec.vlf = [0 options.session.tvpsd.vlf];
        spec.lf = [options.session.tvpsd.vlf options.session.tvpsd.lf];
        spec.hf = [options.session.tvpsd.lf options.session.tvpsd.hf];
        spec.segments = options.session.tvpsd.segments;
        spec.overlap = options.session.tvpsd.overlap;
        
        % Saving LF, HF and LF/HF graphics
        lfVar = {'lfFFT','lfWelch','lfAR'};
        hfVar = {'hfFFT','hfWelch','hfAR'};
        lfhfVar = {'lfhfFFT','lfhfWelch','lfhfAR'};
        
        for i = 1:3
            if options.session.tvpsd.cbSelection(i)
                spec.alf = signals.(id).(type).aligned.tvpsd.(lfVar{i});
                spec.ahf = signals.(id).(type).aligned.tvpsd.(hfVar{i});
                spec.rlfhf = signals.(id).(type).aligned.tvpsd.(lfhfVar{i});
            end
        end
  
        if ~isempty(signals.(id).(type).aligned.tvpsd.(psdType{2}))
            spec.arOrder = options.session.tvpsd.arOrder;
        end
        
        % save data
        signals.(id).(type).aligned.tvpsd.specs = spec;
        patient.sig.(id).(type).aligned.tvpsd = ...
            signals.(id).(type).aligned.tvpsd;
        
        options.session.tvpsd.saved = 1;
        set(userOpt,'userData',options);
        set(pSig,'userData',signals);
        set(pFile,'userData',patient);
        
        save(filename,'patient');
        
        stringFFT = []; stringWelch = []; stringAR = [];
        if options.session.tvpsd.cbSelection(1)
            stringFFT = '\n Short Time Fourier Transform';
        end
        if options.session.tvpsd.cbSelection(2)
            stringWelch = '\n Time Variant Welch Method';
        end
        if options.session.tvpsd.cbSelection(3)
            stringAR = '\n Time Variant AR Model';
        end
        saveConfig(userOpt);
        msgString = [stringFFT,stringAR,stringWelch];
        uiwait(msgbox(sprintf(['The following PSDs have been ',...
            'saved:',msgString]),'PSDs saved','modal'));
    end
end
end

function teCallback(scr,~,userOpt,pHandle,pSig,tx,te,teMinP,teMaxP,teMinF,teMaxF,txVar,txVarUnit)
% set VLF, LF and HF upper limits, axes limits, # of points for fourier
% transform, AR model order and # of samples per segment and # of
% overlapping samples for Welch method

errStat = 0;
options = get(userOpt,'userData');
if ~isempty(options.session.tvpsd.sigLen)
    A=str2double(get(scr,'string'));
    
    if ~isnan(A)
        % set boundries according to text edit tag
        switch get(scr,'tag')
            case 'vlf'
                loLim = 0; hiLim = options.session.tvpsd.lf-0.01;
                varName = 'very low frequency limit';
            case 'lf'
                loLim = options.session.tvpsd.vlf+0.01; 
                hiLim = options.session.tvpsd.hf-0.01;
                varName = 'low frequency limit';
            case 'hf'
                loLim = options.session.tvpsd.lf+0.01; 
                hiLim = options.session.tvpsd.maxF;
                varName = 'high frequency limit';
            case 'minF'
                loLim = 0; hiLim = options.session.tvpsd.maxF-0.05;
                varName = 'minimum frequency';
            case 'maxF'
                loLim = options.session.tvpsd.minF+0.05; 
                hiLim = (options.session.tvpsd.fs/2);
                varName = 'maximum frequency';
            case 'minP'
                loLim = 0; hiLim = options.session.tvpsd.maxP/10;
                varName = 'minimum power';
            case 'maxP'
                loLim = options.session.tvpsd.minP*10; hiLim = inf;
                varName = 'maximum power';
            case 'N'
                loLim = 32; hiLim = 2^18; A = round(A);
                varName = 'number of points';
            case 'arOrder'
                loLim = 1; hiLim = 150; A = round(A);
                varName = 'AR order';
            case 'segments'
                loLim = 1; hiLim = options.session.tvpsd.sigLen;
                varName = 'number of samples per segment';
                A = round(A);
            case 'overlap'
                loLim = 0; hiLim = options.session.tvpsd.segments - 1;
                varName = 'number of overlapping samples';
                A = round(A);
        end

        if A >= loLim && A <= hiLim
            value = A;
        else
            uiwait(errordlg(['Value out of bounds! Please set the ',...
                varName,' between ',num2str(loLim),' and ',...
                num2str(hiLim),'.'],'Value out of bounds','modal'));
            errStat = 1;
        end
    
        if ~errStat
            % condition value according to text edit tag and set 
            % corresponding variables
            if strcmp(get(scr,'tag'),'N')
                value = 2.^ceil(log(value)/log(2));
            end
            options.session.tvpsd.(get(scr,'tag')) = value;

            % adjust maximum overlapping samples value when number of 
            % samples per segment is updated
            if strcmp(get(scr,'tag'),'segments')
                if options.session.tvpsd.overlap >= value
                    options.session.tvpsd.overlap = value-1;
                    set(te,'string',num2str(options.session.tvpsd.overlap));
                end
                if strcmp(get(scr,'tag'),'segments')
                    set(tx,'string',['(max: ',num2str(value-1),') ']);
                end
            end

            set(userOpt,'userData',options);
            set(scr,'string',num2str(value));

            % recalculate areas if the altered values affect the PSD
            if ismember(get(scr,'tag'),{'vlf','lf','hf','N','arOrder',...
                    'segments','overlap'})
                TVpsdCalc(userOpt,pSig,teMinP,teMaxP,teMinF,teMaxF,txVar,txVarUnit);
                if ismember(get(scr,'tag'),{'vlf','lf'})
                    set(tx,'string',num2str(value));
                end
            end     
            
            if ismember(get(scr,'tag'),{'minF','maxF'})
                calcPSDlim(userOpt,pSig,teMinP,teMaxP,teMinF,teMaxF,txVar,txVarUnit);
            end
            
            TVpsdPlot(pHandle,pSig,userOpt);
        end
    end
    set(scr,'string',num2str(options.session.tvpsd.(get(scr,'tag'))));
end
end

function rbCallback(scr,~,userOpt,pHandle,pSig,teMinP,teMaxP,teMinF,teMaxF,txVar,txVarUnit,...
    rb1,rb2,rb3,rb4)
% set window for time-variant PSD methods

options = get(userOpt,'userData');

options.session.tvpsd.rbWindow = get(scr,'userData');

set(rb3,'value',0);
set(rb4,'value',0);
set(scr,'value',1);
set(rb1,'value',0);
set(rb2,'value',0);

set(userOpt,'userData',options);

if strcmp(get(scr,'tag'),'window')
    TVpsdCalc(userOpt,pSig,teMinP,teMaxP,teMinF,teMaxF,txVar,txVarUnit);
else
    calcPSDlim(userOpt,pSig,teMinP,teMaxP,teMinF,teMaxF,txVar,txVarUnit);
end      
TVpsdPlot(pHandle,pSig,userOpt);
end

function cbCallback(scr,~,userOpt,pHandle,pSig,teMinP,...
    teMaxP,teMinF,teMaxF,txVar,txVarUnit,cb1,cb2)
% select methods to calculate PSD to be shown on plot

options = get(userOpt,'userData');

if strcmp(get(scr,'String'),'Time Varying Welch Method')
    cbSel = [0,1,0];
elseif strcmp(get(scr,'String'),'Short Time Fourier Transform')
    cbSel = [1,0,0];
elseif strcmp(get(scr,'String'),'Time Varying AR Model')
    cbSel = [0,0,1];
end

options.session.tvpsd.cbSelection = cbSel;
set(userOpt,'userData',options);

set(scr,'value',1);
set(cb1,'value',0);
set(cb2,'value',0');

id = options.session.tvpsd.sigSpec{1};
type = options.session.tvpsd.sigSpec{2};
sig = get(pSig,'userData');

if strcmp(get(scr,'String'),'Short Time Fourier Transform') && ...
          isempty(sig.(id).(type).aligned.tvpsd.psdFFT)
      
      TVpsdCalc(userOpt,pSig,teMinP,teMaxP,teMinF,teMaxF,txVar,txVarUnit);

elseif strcmp(get(scr,'String'),'Time Varying Welch Method') && ...
          isempty(sig.(id).(type).aligned.tvpsd.psdWelch)
      
      TVpsdCalc(userOpt,pSig,teMinP,teMaxP,teMinF,teMaxF,txVar,txVarUnit);

elseif strcmp(get(scr,'String'),'Time Varying AR Model') && ...
          isempty(sig.(id).(type).aligned.tvpsd.psdAR)
      
      TVpsdCalc(userOpt,pSig,teMinP,teMaxP,teMinF,teMaxF,txVar,txVarUnit);
end

TVpsdPlot(pHandle,pSig,userOpt);
end

function cbVisCallback(scr,~,userOpt,pHandle,pSig,teMinP,...
    teMaxP,teMinF,teMaxF,txVar,txVarUnit,cb1,cb2)
% select graphics to be shown (PSD, LF/HF or LF and HF)

options = get(userOpt,'userData');

if strcmp(get(scr,'String'),'LF and HF Variations')
    cbVisSel = [0,1,0];
elseif strcmp(get(scr,'String'),'Power Spectral Density (PSD)')
    cbVisSel = [1,0,0];
elseif strcmp(get(scr,'String'),'LF/HF Ratio Variations')
    cbVisSel = [0,0,1];
end

options.session.tvpsd.cbVisSelection = cbVisSel;
set(userOpt,'userData',options);

set(scr,'value',1);
set(cb1,'value',0);
set(cb2,'value',0');

id = options.session.tvpsd.sigSpec{1};
type = options.session.tvpsd.sigSpec{2};
sig = get(pSig,'userData');

if strcmp(get(scr,'String'),'Power Spectral Density (PSD)') && ...
          isempty(sig.(id).(type).aligned.tvpsd.psdFFT) || ...
          isempty(sig.(id).(type).aligned.tvpsd.psdAR) || ...
          isempty(sig.(id).(type).aligned.tvpsd.psdWelch)
      
      TVpsdCalc(userOpt,pSig,teMinP,teMaxP,teMinF,teMaxF,txVar,txVarUnit);

elseif strcmp(get(scr,'String'),'LF and HF Variations') && ...
          isempty(sig.(id).(type).aligned.tvpsd.lfFFT) || ...
          isempty(sig.(id).(type).aligned.tvpsd.lfAR) || ...
          isempty(sig.(id).(type).aligned.tvpsd.lfWelch)
      
      TVpsdCalc(userOpt,pSig,teMinP,teMaxP,teMinF,teMaxF,txVar,txVarUnit);

elseif strcmp(get(scr,'String'),'LF/HF Ratio Variations') && ...
          isempty(sig.(id).(type).aligned.tvpsd.lfhfFFT) || ...
          isempty(sig.(id).(type).aligned.tvpsd.lfhfAR) || ...
          isempty(sig.(id).(type).aligned.tvpsd.lfhfWelch)
      
      TVpsdCalc(userOpt,pSig,teMinP,teMaxP,teMinF,teMaxF,txVar,txVarUnit);
end

TVpsdPlot(pHandle,pSig,userOpt);
end

function TVpsdCalc(userOpt,pSig,teMinP,teMaxP,teMinF,teMaxF,txVar,txVarUnit)
options = get(userOpt,'userData');

if ~isempty(options.session.tvpsd.sigLen)
    id = options.session.tvpsd.sigSpec{1};
    type = options.session.tvpsd.sigSpec{2};
    sig = get(pSig,'userData');
    signal = sig.(id).(type).aligned.data;
    
    % remove mean before performing PSD
    signal = signal-mean(signal);
    sigw = signal;
        
    % calculate PSD according to methods selected
    % sig.(id).(type).aligned.tvpsd = dataPkg.tvpsdUnit;
    if options.session.tvpsd.cbSelection(1)
        [sig.(id).(type).aligned.tvpsd.timeFFT,...
            sig.(id).(type).aligned.tvpsd.freqFFT,...
            sig.(id).(type).aligned.tvpsd.psdFFT] = stft(signal,options.session.tvpsd.segments,...
            options.session.tvpsd.fs,...
            options.session.tvpsd.N,...
            options.session.tvpsd.overlap,...
            options.session.tvpsd.rbWindow);
        
        [sig.(id).(type).aligned.tvpsd.lfFFT,...
            sig.(id).(type).aligned.tvpsd.hfFFT,...
            sig.(id).(type).aligned.tvpsd.lfhfFFT] = calcAreas(sig.(id).(type).aligned.tvpsd.psdFFT,...
                                                  sig.(id).(type).aligned.tvpsd.freqFFT,...
                                                  options.session.tvpsd.vlf,...
                                                  options.session.tvpsd.lf,...
                                                  options.session.tvpsd.hf);

    end
    if options.session.tvpsd.cbSelection(2)
        [sig.(id).(type).aligned.tvpsd.timeWelch,...
            sig.(id).(type).aligned.tvpsd.freqWelch,...
            sig.(id).(type).aligned.tvpsd.psdWelch] = welchtv(signal,options.session.tvpsd.segments,...
            options.session.tvpsd.fs,...
            options.session.tvpsd.N,...
            options.session.tvpsd.overlap,...
            options.session.tvpsd.rbWindow,...
            sig.(id).(type).aligned.time);

        [sig.(id).(type).aligned.tvpsd.lfWelch,...
            sig.(id).(type).aligned.tvpsd.hfWelch,...
            sig.(id).(type).aligned.tvpsd.lfhfWelch] = calcAreas(sig.(id).(type).aligned.tvpsd.psdWelch,...
                                                  sig.(id).(type).aligned.tvpsd.freqWelch,...
                                                  options.session.tvpsd.vlf,...
                                                  options.session.tvpsd.lf,...
                                                  options.session.tvpsd.hf);
    end
    if options.session.tvpsd.cbSelection(3)
        [sig.(id).(type).aligned.tvpsd.timeAR,...
            sig.(id).(type).aligned.tvpsd.freqAR,...
            sig.(id).(type).aligned.tvpsd.psdAR] = artv(sigw,options.session.tvpsd.segments,...
            options.session.tvpsd.fs,...
            options.session.tvpsd.N,...
            options.session.tvpsd.overlap,...
            options.session.tvpsd.rbWindow,...
            sig.(id).(type).aligned.time,...
            options.session.tvpsd.arOrder);

        [sig.(id).(type).aligned.tvpsd.lfAR,...
            sig.(id).(type).aligned.tvpsd.hfAR,...
            sig.(id).(type).aligned.tvpsd.lfhfAR] = calcAreas(sig.(id).(type).aligned.tvpsd.psdAR,...
                                                  sig.(id).(type).aligned.tvpsd.freqAR,...
                                                  options.session.tvpsd.vlf,...
                                                  options.session.tvpsd.lf,...
                                                  options.session.tvpsd.hf);
    end 
    
    set(pSig,'userData',sig);
    set(userOpt,'userData',options);
    calcPSDlim(userOpt,pSig,teMinP,teMaxP,teMinF,teMaxF,txVar,txVarUnit);
end
end

function calcPSDlim(userOpt,pSig,teMinP,teMaxP,teMinF,teMaxF,txVar,txVarUnit)
options = get(userOpt,'userData');

if ~isempty(options.session.tvpsd.sigLen)
    id = options.session.tvpsd.sigSpec{1};
    type = options.session.tvpsd.sigSpec{2};
    sig = get(pSig,'userData');
    
    % Set frequency, ratio and amplitude axis range to define min and max values
    lfVar = {'lfFFT','lfWelch','lfAR'};
    hfVar = {'hfFFT','hfWelch','hfAR'};
    lfhfVar = {'lfhfFFT','lfhfWelch','lfhfAR'};
    timeVar = {'timeFFT','timeWelch','timeAR'};

    for i = 1:3
        if options.session.tvpsd.cbSelection(i)
            if options.session.tvpsd.cbVisSelection == [1,0,0]
                set(txVar,'string','Freq. From:');
                set(txVarUnit,'string', 'Hz              To:');
                
                if options.session.tvpsd.maxF >= 0.5
                    maxF = 0.5;
                else
                    maxF = options.session.tvpsd.maxF;
                end

                if options.session.tvpsd.minF <= 0.0
                    minF = 0;
                else
                    minF = options.session.tvpsd.minF;
                end
                
            elseif options.session.tvpsd.cbVisSelection == [0,1,0]
                set(txVar,'string','Ampl. From:');
                if strcmp(id,'ecg')
                    set(txVarUnit,'string', 'ms²            To:');
                elseif strcmp(id,'bp')
                    set(txVarUnit,'string', 'mmHg²        To:');
                else
                    set(txVarUnit,'string', 'L²             To:');
                end  
  
                minF = min(sig.(id).(type).aligned.tvpsd.(lfVar{i}));
                maxF = max(sig.(id).(type).aligned.tvpsd.(lfVar{i}));

                minF = min([minF sig.(id).(type).aligned.tvpsd.(hfVar{i})]);
                maxF = max([maxF sig.(id).(type).aligned.tvpsd.(hfVar{i})]);

                if minF > 0
                    minF = 0;
                end

            elseif options.session.tvpsd.cbVisSelection == [0,0,1]
                set(txVar,'string','Ratio From:');
                set(txVarUnit,'string', '                   To:');

                minF = min(sig.(id).(type).aligned.tvpsd.(lfhfVar{i}));
                maxF = max(sig.(id).(type).aligned.tvpsd.(lfhfVar{i}));
                
                if minF > 0
                    minF = 0;
                end
            end
            
            if minF < options.session.tvpsd.minF
                options.session.tvpsd.minF = minF;
            end
            
            options.session.tvpsd.maxF = maxF;

            set(teMinF,'string',num2str(options.session.tvpsd.minF));
            set(teMaxF,'string',num2str(options.session.tvpsd.maxF));

        end
    end

    % Set time axis range to define min and max values
    for i = 1:3
        if options.session.tvpsd.cbSelection(i)
            minP = min(sig.(id).(type).aligned.tvpsd.(timeVar{i}));
            maxP = max(sig.(id).(type).aligned.tvpsd.(timeVar{i}));
            
            if minP > options.session.tvpsd.minP
                options.session.tvpsd.minP = minP;
            end
            if maxP < options.session.tvpsd.maxP
                options.session.tvpsd.maxP = maxP;
            end

            set(teMinP,'string',num2str(options.session.tvpsd.minP));
            set(teMaxP,'string',num2str(options.session.tvpsd.maxP));
        end
    end

    set(userOpt,'userData',options);

end
end

function value = checkLim(userOpt,value,tag)

options = get(userOpt,'userData');
switch tag
    case 'vlf'
        loLim = 0; hiLim = options.session.tvpsd.lf;
    case 'lf'
        loLim = options.session.tvpsd.vlf;
        hiLim = options.session.tvpsd.hf;
    case 'hf'
        loLim = options.session.tvpsd.lf;
        hiLim = options.session.tvpsd.maxF;
    case 'minF'
        loLim = 0; hiLim = options.session.tvpsd.maxF;
    case 'maxF'
        loLim = options.session.tvpsd.minF;
        hiLim = options.session.tvpsd.fs/2;
    case 'minP'
        loLim = 0; hiLim = options.session.tvpsd.maxP;
    case 'maxP'
        loLim = options.session.tvpsd.minP; hiLim = inf;
    case 'N'
        loLim = 32; hiLim = 2^18; value = round(value);
    case 'arOrder'
        loLim = 1; hiLim = 150; value = round(value);
end

if value < loLim, value = loLim; end
if value > hiLim, value = hiLim; end
end

function saveConfig(userOpt)
% save session configurations for next session

options = get(userOpt,'userData');
options.tvpsd.vlf = options.session.tvpsd.vlf;
options.tvpsd.lf = options.session.tvpsd.lf;
options.tvpsd.hf = options.session.tvpsd.hf;
options.tvpsd.minP = options.session.tvpsd.minP;
options.tvpsd.maxP = options.session.tvpsd.maxP;
options.tvpsd.minF = options.session.tvpsd.minF;
options.tvpsd.maxF = options.session.tvpsd.maxF;
options.tvpsd.arOrder = options.session.tvpsd.arOrder;
options.tvpsd.N = options.session.tvpsd.N;
options.tvpsd.cbSelection = options.session.tvpsd.cbSelection;
options.tvpsd.cbVisSelection = options.session.tvpsd.cbVisSelection;
options.tvpsd.rbWindow = options.session.tvpsd.rbWindow;
options.tvpsd.rbScale = options.session.tvpsd.rbScale;
options.tvpsd.segments = options.session.tvpsd.segments;
options.tvpsd.overlap = options.session.tvpsd.overlap;
options.tvpsd.fill = options.session.tvpsd.fill;
set(userOpt,'userData',options);
end