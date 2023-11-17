function TVidentMenu(pnModel,pFile,pSys,pMod,userOpt)
% IdentMenu - CRSIDLab
%   Menu for cardiorespiratory system identification. The systems are the
%   ones created on SystemMenu, composed of cardiorespiratory variables 
%   such as R-R interval (RRI) or heart rate (HR) extracted from
%   electrocardiogram (ECG) and/or systolic blood pressure (SBP) or
%   diastolic blood pressure (DBP) extracted from continuous blood pressure
%   (BP) and/or instantaneous lung volume (ILV) which may be extracted from
%   airflow data. The following parametric models are available for the 
%   user to choose from: Autoregressive (AR), Autoregressive with Exogenous
%   Input(s) (ARX), Laguerre Basis Function (LBF) or Meixner Basis Function
%   (MBF) model. AR models can only be applied to systems with no inputs, 
%   or may be simulated on systems with inputs by selecting the ARX model 
%   and setting the input(s) order(s) to zero. LBF and MBF models do not 
%   have an autoregressive component and can only be applied to systems 
%   that have at least one input. Presents model parametrization and an 
%   estimation of fit between the estimated and measured outputs.
%
% Original Matlab code: Luisa Santiago C. B. da Silva, April 2017.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Data visualization
%

pHandle = struct;

uicontrol('parent',pnModel,'style','text','string','Select system:',...
    'hor','left','units','normalized','position',[.032 .93 .1 .03]);
puVar = uicontrol('parent',pnModel,'style','popupmenu','tag','ecg',...
    'string','Indicate system','value',1,'userData',1,'units',...
    'normalized','position',[.13 .93 .35 .04],'backgroundColor',[1 1 1]);

pHandle.single = axes('parent',pnModel,'Units','normalized','Position',...
    [.047 .14 .53 .74],'nextPlot','replaceChildren','visible','on');
pHandle.double1 = axes('parent',pnModel,'Units','normalized',...
    'Position',[.057 .53 .53 .35],'nextPlot','replaceChildren',...
    'visible','off');
pHandle.double2 = axes('parent',pnModel,'Units','normalized',...
    'Position',[.057 .14 .53 .35],'nextPlot','replaceChildren',...
    'visible','off');
pHandle.triple1 = axes('parent',pnModel,'Units','normalized',...
    'Position',[.057 .66 .53 .22],'nextPlot','replaceChildren',...
    'visible','off');
pHandle.triple2 = axes('parent',pnModel,'Units','normalized',...
    'Position',[.057 .4 .53 .22],'nextPlot','replaceChildren',...
    'visible','off');
pHandle.triple3 = axes('parent',pnModel,'Units','normalized',...
    'Position',[.057 .14 .53 .22],'nextPlot','replaceChildren',...
    'visible','off');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Choose identification method
%

pnMethod = uipanel('parent',pnModel,'Units','normalized','Position',...
    [.768 .706 .095 .174]);

uicontrol('parent',pnMethod,'Style','text','String',['Identificati',...
    'on method'],'Units','normalized','Position',[.05 .6 .9 .35]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
rbArx = uicontrol('parent',pnMethod,'Style','radio','tag','model',...
    'userData',0,'String','ARX','Units','Normalized','Position',...
    [.1 .4 .8 .15],'Enable','off');
% rbArx = uicontrol('parent',pnMethod,'Style','radio','tag','model',...
%     'userData',0,'String','ARX','Units','Normalized','Position',...
%     [.1 .4 .8 .15]);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

rbLbf = uicontrol('parent',pnMethod,'Style','radio','tag','model',...
    'userData',1,'String','LBF','Units','Normalized','Position',...
    [.1 .225 .8 .15]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MODIFICAÇÃO REALIZADA DIA 31/01/2022
% rbMbf = uicontrol('parent',pnMethod,'Style','radio','tag','model',...
%     'userData',2,'String','MBF','Units','Normalized','Position',...
%     [.1 .05 .8 .15],'Enable','off');

rbMbf = uicontrol('parent',pnMethod,'Style','radio','tag','model',...
    'userData',2,'String','MBF','Units','Normalized','Position',...
    [.1 .05 .8 .15]);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Choose parameters criteria
%

pnParam = uipanel('parent',pnModel,'Units','Normalized','Position',...
    [.863 .706 .115 .174]);

txParam = uicontrol('parent',pnParam,'Style','text','String',...
    'Criteria for selection of parameters order:','Units','Normalized',...
    'Position',[.05 .6 .9 .35]);

rbMdl = uicontrol('parent',pnParam,'Style','radio','tag','criteria',...
    'userData',0,'String','MDL','Units','Normalized','Position',...
    [.1 .4 .8 .15]);

rbAic = uicontrol('parent',pnParam,'Style','radio','tag','criteria',...
    'userData',1,'String','AIC','Units','Normalized','Position',...
    [.1 .225 .8 .15],'Enable','off');

rbBF = uicontrol('parent',pnParam,'Style','radio','tag','criteria',...
    'userData',2,'String','Best Fit','CallBack',{@rbCallback,...
    userOpt,rbMdl,rbAic},'Units','Normalized','Position',...
    [.1 .05 .8 .15],'Enable','off');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Choose parameters order search or orders directly
%

pnOrder = uipanel('parent',pnModel,'Units','Normalized','Position',...
    [.768 .408 .21 .298]);

uicontrol('parent',pnOrder,'Style','text','String','Orders and Delays',...
    'Units','Normalized','Position',[.05 .85 .9 .1]);

rbParam = uicontrol('parent',pnOrder,'Style','radio','tag','orMax',...
    'userData',0,'String','Choose limit values for parameters testing',...
    'Units','Normalized','Position',[.05 .7 .9 .1]);

rbOrder = uicontrol('parent',pnOrder,'Style','radio','tag','orMax',...
    'userData',1,'String','Choose parameters directly','Units',...
    'Normalized','Position',[.05 .575 .9 .1]);

txNa = uicontrol('parent',pnOrder,'Style','text','hor','left','string',...
    'na:','Units','Normalized','Position',[.05 .4 .1 .1]);
teNaMin = uicontrol('parent',pnOrder,'Style','edit','tag','naMin',...
    'userData',1,'CallBack',{@teCallback,userOpt},'Units','Normalized',...
    'Position',[.165 .4 .12 .12],'BackgroundColor',[1 1 1]);
txNa2 = uicontrol('parent',pnOrder,'Style','text','String','to','Units',...
    'Normalized','Position',[.285 .4 .06 .1]);
teNaMax = uicontrol('parent',pnOrder,'Style','edit','tag','naMax',...
    'userData',2,'CallBack',{@teCallback,userOpt},'Units','Normalized',...
    'Position',[.35 .4 .12 .12],'BackgroundColor',[1 1 1]);

txNb1 = uicontrol('parent',pnOrder,'Style','text','hor','left','string',...
    'nb1:','Units','Normalized','Position',[.05 .225 .1 .1]);
teNb1Min = uicontrol('parent',pnOrder,'Style','edit','tag','nb1Min',...
    'userData',3,'CallBack',{@teCallback,userOpt},'Units','Normalized',...
    'Position',[.165 .225 .12 .12],'BackgroundColor',[1 1 1]);
txNb12 = uicontrol('parent',pnOrder,'Style','text','String','to',...
    'Units','Normalized','Position',[.285 .225 .06 .1]);
teNb1Max = uicontrol('parent',pnOrder,'Style','edit','tag','nb1Max',...
    'userData',4,'CallBack',{@teCallback,userOpt},'Units','Normalized',...
    'Position',[.35 .225 .12 .12],'BackgroundColor',[1 1 1]);

txNb2 = uicontrol('parent',pnOrder,'Style','text','hor','left','String',...
    'nb2:','Units','Normalized','Position',[.05 .05 .1 .1]);
teNb2Min = uicontrol('parent',pnOrder,'Style','edit','tag','nb2Min',...
    'userData',5,'CallBack',{@teCallback,userOpt},'Units','Normalized',...
    'Position',[.165 .05 .12 .12],'BackgroundColor',[1 1 1]);
txNb22 = uicontrol('parent',pnOrder,'Style','text','String','to',...
    'Units','Normalized','Position',[.285 .05 .06 .1]);
teNb2Max = uicontrol('parent',pnOrder,'Style','edit','tag','nb2Max',...
    'userData',6,'CallBack',{@teCallback,userOpt},'Units','Normalized',...
    'Position',[.35 .05 .12 .12],'BackgroundColor',[1 1 1]);

txNk1 = uicontrol('parent',pnOrder,'Style','text','hor','left','String',...
    'nk1:','Units','Normalized','Position',[.525 .225 .1 .1]);
teNk1Min = uicontrol('parent',pnOrder,'Style','edit','tag','nk1Min',...
    'userData',7,'CallBack',{@teCallback,userOpt},'Units','Normalized',...
    'Position',[.64 .225 .12 .12],'BackgroundColor',[1 1 1]);
txNk12 = uicontrol('parent',pnOrder,'Style','text','String','to',...
    'Units','Normalized','Position',[.76 .225 .06 .1]);
teNk1Max = uicontrol('parent',pnOrder,'Style','edit','tag','nk1Max',...
    'userData',8,'CallBack',{@teCallback,userOpt},'Units','Normalized',...
    'Position',[.83 .225 .12 .12],'BackgroundColor',[1 1 1]);

txNk2 = uicontrol('parent',pnOrder,'Style','text','hor','left','String',...
    'nk2:','Units','Normalized','Position',[.525 .05 .1 .1]);
teNk2Min = uicontrol('parent',pnOrder,'Style','edit','tag','nk2Min',...
    'userData',9,'CallBack',{@teCallback,userOpt},'Units','Normalized',...
    'Position',[.64 .05 .12 .12],'BackgroundColor',[1 1 1]);
txNk22 = uicontrol('parent',pnOrder,'Style','text','String','to',...
    'Units','Normalized','Position',[.76 .05 .06 .1]);
teNk2Max = uicontrol('parent',pnOrder,'Style','edit','tag','nk2Max',...
    'userData',10,'CallBack',{@teCallback,userOpt},'Units','Normalized',...
    'Position',[.83 .05 .12 .12],'BackgroundColor',[1 1 1]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Laguerre/Meixner options
%

pnLag = uipanel('parent',pnModel,'Units','Normalized','Position',...
    [.768 .22 .21 .188]);

txLag = uicontrol('parent',pnLag,'Style','text','String',['Laguerre/',...
    'Meixner parameters:'],'Units','Normalized','Position',...
    [.05 .775 .9 .15]);

txPole = uicontrol('parent',pnLag,'Style','text','String',['Pole ',...
    '(0<p<1):'],'hor','left','Units','Normalized','Position',...
    [.05 .57 .61 .15]);
tePole = uicontrol('parent',pnLag,'Style','edit','tag','pole',...
    'callback',{@teCallback,userOpt},'Units','Normalized','Position',...
    [.64 .55 .12 .2],'BackgroundColor',[1 1 1]);

txSysMem = uicontrol('parent',pnLag,'Style','text','hor','left',...
    'String','System memory length:','Units','Normalized','Position',...
    [.05 .335 .61 .15]);
teSysMem = uicontrol('parent',pnLag,'Style','edit','tag','sysMem',...
    'CallBack',{@teCallback,userOpt},'Units','Normalized','Position',...
    [.64 .3 .12 .2],'BackgroundColor',[1 1 1]);

txGen = uicontrol('parent',pnLag,'Style','text','hor','left','String',...
    'Generalization order:','Units','Normalized','Position',...
    [.05 .075 .6 .15]);
teGenMin = uicontrol('parent',pnLag,'Style','edit','tag','genMin',...
    'userData',1,'CallBack',{@teCallback,userOpt},'Units','Normalized',...
    'Position',[.64 .05 .12 .2],'BackgroundColor',[1 1 1]);
txGen2 = uicontrol('parent',pnLag,'Style','text','String','to',...
    'Units','Normalized','Position',[.76 .075 .06 .15]);
teGenMax = uicontrol('parent',pnLag,'Style','edit','tag','genMax',...
    'userData',2,'CallBack',{@teCallback,userOpt},'Units','Normalized',...
    'Position',[.83 .05 .12 .2],'BackgroundColor',[1 1 1]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Buttons (view system variables / model structure / basis functions
%

pnView = uipanel('parent',pnModel,'Units','Normalized','Position',...
    [.768 .14 .21 .08]);

%view model structure
pbStruc = uicontrol('parent',pnView,'style','push','String',['Model ',...
    'structure'],'CallBack',{@pbModelStructure,userOpt},'Units',...
    'normalized','position',[.05 .15 .425 .7]);

%view basis functions
pbBF = uicontrol('parent',pnView,'style','push','String',['Basis ',...
    'functions'],'CallBack',{@pbBasisFunction,userOpt,teSysMem,tePole,...
    teGenMin,teGenMax,teNb1Min,teNb1Max,teNb2Min,teNb2Max},'Units',...
    'normalized','position',[.525 .15 .425 .7]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Buttons (estimate model, save)
%

pnSave = uipanel('parent',pnModel,'Units','normalized','Position',...
    [.768 .06 .21 .08]);

% generate model
pbMod = uicontrol('parent',pnSave,'Style','push','String',['Estimate ',...
    'Model'],'Units','Normalized','Position',[.05 .15 .425 .7]);

% save
uicontrol('parent',pnSave,'Style','push','String','SAVE','CallBack',...
    {@saveMod,userOpt,pFile,pMod,puVar},'Units','Normalized',...
    'Position',[.525 .15 .425 .7]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Model and impulse response information display
%

txInfo = struct;
pnInfo = uipanel('parent',pnModel,'Units','Normalized','Position',...
    [.603 .22 .165 .66]);

tbMod = uicontrol('parent',pnModel,'Style','toggle','tag','model',...
    'String','Model','value',1,'Units','Normalized','Position',...
    [.603 .875 .05 .05],'backgroundColor',[1 1 1]);
txInfo.model = uicontrol('parent',pnInfo,'Style','edit','hor','left',...
    'Units','normalized','position',[0 .128 1 .87],'max',2,'enable',...
    'inactive');

tbIm =uicontrol('parent',pnModel,'Style','toggle','tag','imresp',...
    'String','Impulse response','value',0,'Units','Normalized',...
    'Position',[.6515 .875 .1 .05]);
pnImResp = uipanel('parent',pnInfo,'Units','Normalized','Position',...
    [0 .128 1 .87]);

pbInfo=uicontrol('parent',pnInfo,'style','push','String','Export to TXT',...
    'CallBack',{@exportTxt,userOpt,pMod,pFile,txInfo},'Units',...
    'normalized','position',[.1 .02 .8 .078]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Buttons (TV Impulse Response, Dynamic Gain,...)
%

uicontrol('parent',pnImResp,'Style','text','String','Impulse Response Information'...
    ,'Units','Normalized','Position',[0 .128 1 .87]);

rbIR = uicontrol('parent',pnImResp,'Style','radio','tag','',...
    'String','Time Varying Impulse Response','userData',0,'Units','Normalized',...
    'Position',[.05 .80 .9 .1]);

rbIRM = uicontrol('parent',pnImResp,'Style','radio','tag','window',...
    'String','Impulse Response Magnitude','userData',1,'Units','Normalized',...
    'Position',[.05 .70 .9 .1]);

rbDGL = uicontrol('parent',pnImResp,'Style','radio','tag','window',...
    'String','Low Frequency Dynamic Gain','userData',2,'Units','Normalized',...
    'Position',[.05 .60 .9 .1]);

rbDGH = uicontrol('parent',pnImResp,'Style','radio','tag','window',...
    'String','High Frequency Dynamic Gain','userData',3,'Units','Normalized',...
    'Position',[.05 .50 .9 .1]);

rbDG = uicontrol('parent',pnImResp,'Style','radio','tag','window',...
    'String','Dynamic Gain','userData',2,'Units','Normalized',...
    'Position',[.05 .40 .9 .1]);

rbD = uicontrol('parent',pnImResp,'Style','radio','tag','window',...
    'String','Latency','userData',4,'Units','Normalized','Position',...
    [.05 .30 .9 .1]);

rbTPeak = uicontrol('parent',pnImResp,'Style','radio','tag','window',...
    'String','Time-to-Peak','userData',4,'Units','Normalized','Position',...
    [.05 .20 .9 .1]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Plot legend
%

pnPlot = uipanel('parent',pnModel,'Units','Normalized','Position',...
    [.603 .06 .165 .16]);

plotLeg = uicontrol('parent',pnPlot,'style','text','string',...
    'Plot Legend:','Units','Normalized','Position',[.05 .75 .9 .2]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Set final callbacks and call opening function (setup)
%

set(rbArx,'callback',{@rbCallback,userOpt,rbLbf,rbMbf,txNa,teNaMin,...
    txNa2,teNaMax,txLag,txPole,tePole,txSysMem,teSysMem,txGen,teGenMin,...
    txGen2,teGenMax,pbStruc,pbBF});
set(rbLbf,'callback',{@rbCallback,userOpt,rbArx,rbMbf,txNa,teNaMin,...
    txNa2,teNaMax,txLag,txPole,tePole,txSysMem,teSysMem,txGen,teGenMin,...
    txGen2,teGenMax,pbStruc,pbBF});
set(rbMbf,'callback',{@rbCallback,userOpt,rbArx,rbLbf,txNa,teNaMin,...
    txNa2,teNaMax,txLag,txPole,tePole,txSysMem,teSysMem,txGen,teGenMin,...
    txGen2,teGenMax,pbStruc,pbBF});

set(rbMdl,'callback',{@rbCallback,userOpt,rbAic,rbBF});
set(rbAic,'callback',{@rbCallback,userOpt,rbMdl,rbBF});

set(rbIR,'callback',{@cbVisCallback,userOpt,pHandle,pMod,...
    rbIRM,rbDG,rbDGL,rbDGH,rbD,rbTPeak});
set(rbIRM,'callback',{@cbVisCallback,userOpt,pHandle,pMod,...
    rbIR,rbDG,rbDGL,rbDGH,rbD,rbTPeak});
set(rbDG,'callback',{@cbVisCallback,userOpt,pHandle,pMod,...
    rbIRM,rbIR,rbDGL,rbDGH,rbD,rbTPeak});
set(rbDGL,'callback',{@cbVisCallback,userOpt,pHandle,pMod,...
    rbIRM,rbDG,rbIR,rbDGH,rbD,rbTPeak});
set(rbDGH,'callback',{@cbVisCallback,userOpt,pHandle,pMod,...
    rbIRM,rbDG,rbDGL,rbIR,rbD,rbTPeak});
set(rbD,'callback',{@cbVisCallback,userOpt,pHandle,pMod,...
    rbIRM,rbDG,rbDGL,rbDGH,rbIR,rbTPeak});
set(rbTPeak,'callback',{@cbVisCallback,userOpt,pHandle,pMod,...
    rbIRM,rbDG,rbDGL,rbDGH,rbD,rbIR});

set(rbParam,'callback',{@rbCallback,userOpt,rbOrder,[],txParam,rbMdl,...
    rbAic,rbBF,txNk12,teNk1Max,txNb12,teNb1Max,txNk22,teNk2Max,txNb22,...
    teNb2Max,txNa2,teNaMax,txGen2,teGenMax});
set(rbOrder,'callback',{@rbCallback,userOpt,rbParam,[],txParam,rbMdl,...
    rbAic,rbBF,txNk12,teNk1Max,txNb12,teNb1Max,txNk22,teNk2Max,txNb22,...
    teNb2Max,txNa2,teNaMax,txGen2,teGenMax});

set(pbMod,'callback',{@generateModel,userOpt,pSys,pMod,pFile,txInfo,...
    pHandle,rbIR,rbIRM,rbDG,rbDGL,rbDGH,rbD,rbTPeak});

set(tbMod,'callback',{@tabChange,txInfo.model,tbIm,pnImResp,pbInfo,...
    plotLeg,userOpt,pSys,pMod,pHandle,rbIR,rbIRM,rbDG,rbDGL,rbDGH,...
    rbD,rbTPeak});
set(tbIm,'callback',{@tabChange,pnImResp,tbMod,txInfo.model,pbInfo,...
    plotLeg,userOpt,pSys,pMod,pHandle,rbIR,rbIRM,rbDG,rbDGL,rbDGH,...
    rbD,rbTPeak});

set(puVar,'callback',{@changeVar,userOpt,pFile,pSys,pMod,rbArx,rbLbf,...
    rbMbf,txNa,teNaMin,txNa2,teNaMax,txNb1,teNb1Min,txNb12,teNb1Max,...
    txNb2,teNb2Min,txNb22,teNb2Max,txNk1,teNk1Min,txNk12,teNk1Max,txNk2,...
    teNk2Min,txNk22,teNk2Max,txLag,txPole,tePole,txSysMem,teSysMem,...
    txGen,teGenMin,txGen2,teGenMax,pbStruc,pbBF,tbMod,tbIm,pnImResp,txInfo,...
    pbInfo,plotLeg,pHandle,rbIR,rbIRM,rbDG,rbDGL,rbDGH,rbD,rbTPeak});

openFnc(userOpt,pFile,pSys,pMod,puVar,rbArx,rbLbf,rbMbf,rbMdl,rbAic,...
    rbBF,rbParam,rbOrder,txNa,teNaMin,txNa2,teNaMax,txNb1,teNb1Min,...
    txNb12,teNb1Max,txNb2,teNb2Min,txNb22,teNb2Max,txNk1,teNk1Min,...
    txNk12,teNk1Max,txNk2,teNk2Min,txNk22,teNk2Max,txLag,txPole,tePole,...
    txSysMem,teSysMem,txGen,teGenMin,txGen2,teGenMax,pbStruc,tbMod,...
    tbIm,pnImResp,txInfo,pbInfo,plotLeg,pbBF,pHandle,rbIR,rbIRM,rbDG,...
    rbDGL,rbDGH,rbD,rbTPeak);
end

function plotFcn(pHandle,pSys,userOpt,pMod)
% adjust handles visibility and plot all selected signals

options = get(userOpt,'userData');
if options.session.tvident.sysLen(1) == 3 && ~options.session.tvident.modelGen
    
    legend(pHandle.single,'off');
    legend(pHandle.double1,'off');
    legend(pHandle.double2,'off');
    legend(pHandle.triple3,'off');
    legend(pHandle.triple3,'off');
    legend(pHandle.triple3,'off');
    
    set(pHandle.single,'visible','off');
    set(get(pHandle.single,'children'),'visible','off');
    set(pHandle.double1,'visible','off');
    set(get(pHandle.double1,'children'),'visible','off');
    set(pHandle.double2,'visible','off');
    set(get(pHandle.double2,'children'),'visible','off');
    
    set(pHandle.triple1,'visible','on');
    set(get(pHandle.triple1,'children'),'visible','on');
    set(pHandle.triple2,'visible','on');
    set(get(pHandle.triple2,'children'),'visible','on');
    set(pHandle.triple3,'visible','on');
    set(get(pHandle.triple3,'children'),'visible','on');
    
    set(pHandle.triple1,'tag','out');
    set(pHandle.triple2,'tag','in1');
    set(pHandle.triple3,'tag','in2');
    TVidentPlotData(pHandle.triple1,pSys,userOpt);
    TVidentPlotData(pHandle.triple2,pSys,userOpt);
    TVidentPlotData(pHandle.triple3,pSys,userOpt);
elseif (options.session.tvident.sysLen(1) == 2 && ...
        ~options.session.tvident.modelGen) || ...
        (options.session.tvident.modelGen && ...
        (options.session.tvident.sysLen(2) == 2 && ...
        ~options.session.nav.tvimresp) || ...
        options.session.tvident.sysLen(1) == 3 && ...
        options.session.nav.tvimresp)
    
    legend(pHandle.single,'off');
    legend(pHandle.double1,'off');
    legend(pHandle.double2,'off');
    legend(pHandle.triple3,'off');
    legend(pHandle.triple3,'off');
    legend(pHandle.triple3,'off');
    
    set(pHandle.single,'visible','off');
    set(get(pHandle.single,'children'),'visible','off');
    set(pHandle.triple1,'visible','off');
    set(get(pHandle.triple1,'children'),'visible','off');
    set(pHandle.triple2,'visible','off');
    set(get(pHandle.triple2,'children'),'visible','off');
    set(pHandle.triple3,'visible','off');
    set(get(pHandle.triple3,'children'),'visible','off');
    
    set(pHandle.double1,'visible','on');
    set(get(pHandle.double1,'children'),'visible','on');
    set(pHandle.double2,'visible','on');
    set(get(pHandle.double2,'children'),'visible','on');
    
    if options.session.tvident.modelGen
        if options.session.nav.tvimresp
            set(pHandle.double1,'tag','in1');
            set(pHandle.double2,'tag','in2');
            TVidentPlotImresp(pHandle.double1,pMod,...
                              'Time Varying Impulse Response');
            TVidentPlotImresp(pHandle.double2,pMod,...
                              'Time Varying Impulse Response');
        else
            set(pHandle.double1,'tag','est');
            set(pHandle.double2,'tag','val');
            TVidentPlotModel(pHandle.double1,pMod,userOpt);
            TVidentPlotModel(pHandle.double2,pMod,userOpt);
        end
    else
        set(pHandle.double1,'tag','out');
        set(pHandle.double2,'tag','in1');
        TVidentPlotData(pHandle.double1,pSys,userOpt);
        TVidentPlotData(pHandle.double2,pSys,userOpt);
    end
else
    
    legend(pHandle.single,'off');
    legend(pHandle.double1,'off');
    legend(pHandle.double2,'off');
    legend(pHandle.triple3,'off');
    legend(pHandle.triple3,'off');
    legend(pHandle.triple3,'off');
    
    set(pHandle.double1,'visible','off');
    set(get(pHandle.double1,'children'),'visible','off');
    set(pHandle.double2,'visible','off');
    set(get(pHandle.double2,'children'),'visible','off');
    set(pHandle.triple1,'visible','off');
    set(get(pHandle.triple1,'children'),'visible','off');
    set(pHandle.triple2,'visible','off');
    set(get(pHandle.triple2,'children'),'visible','off');
    set(pHandle.triple3,'visible','off');
    set(get(pHandle.triple3,'children'),'visible','off');
    
    set(pHandle.single,'visible','on');
    
    if options.session.tvident.sysLen(1) ~= 0
        if options.session.tvident.modelGen
            if options.session.nav.tvimresp
                set(pHandle.single,'tag','in1');
                TVidentPlotImresp(pHandle.single,pMod,'Time Varying Impulse Response');
            else
                set(pHandle.single,'tag','est');
                TVidentPlotModel(pHandle.single,pMod,userOpt);
            end
        else
            set(pHandle.single,'tag','out');
            TVidentPlotData(pHandle.single,pSys,userOpt);
        end
        set(get(pHandle.single,'children'),'visible','on');
    else
        ylabel(pHandle.single,'');
        set(get(pHandle.single,'children'),'visible','off');
    end
end
end

function openFnc(userOpt,pFile,pSys,pMod,puVar,rbArx,rbLbf,rbMbf,rbMdl,...
    rbAic,rbBF,rbParam,rbOrder,txNa,teNaMin,txNa2,teNaMax,txNb1,...
    teNb1Min,txNb12,teNb1Max,txNb2,teNb2Min,txNb22,teNb2Max,txNk1,...
    teNk1Min,txNk12,teNk1Max,txNk2,teNk2Min,txNk22,teNk2Max,txLag,...
    txPole,tePole,txSysMem,teSysMem,txGen,teGenMin,txGen2,teGenMax,...
    pbStruc,tbMod,tbIm,pnImResp,txInfo,pbInfo,plotLeg,pbBF,pHandle,...
    rbIR,rbIRM,rbDG,rbDGL,rbDGH,rbD,rbTPeak)
% adjust initial values of objects

options = get(userOpt,'userData');
patient = get(pFile,'userData');

% string for system selection popupmenu from available patient data
prevSys = fieldnames(patient.tvsys);
noModels = 0;
for i = 1:length(prevSys)
    prevMod = fieldnames(patient.tvsys.(prevSys{i}).models);
    noModels = noModels + length(prevMod);
end
sysKey = cell(length(prevSys)+noModels,2);
stringPU = cell((length(prevSys)+noModels)+1,1);
stringPU{1} = 'Indicate system';
noModels = 0;
for i = 1:length(prevSys)
    stringPU{i+1+noModels} = patient.tvsys.(prevSys{i}).data.Note;
    prevMod = fieldnames(patient.tvsys.(prevSys{i}).models);
    sysKey{i+noModels,1} = prevSys{i};
    for j = 1:length(prevMod)
        noModels = noModels+1;
        stringPU{i+1+noModels} = ['    ' patient.tvsys.(prevSys{i}).models.(...
            prevMod{j}).Notes];
        sysKey{i+noModels,1} = prevSys{i};
        sysKey{i+noModels,2} = prevMod{j};
    end
end
if isempty(prevSys)
    stringPU{2} = 'No systems available';
end

% adjust selection value if the variables list has changed
if ~isequal(options.session.tvident.sysString,stringPU)
    if ~isempty(options.session.tvident.sysString)
        if ismember(options.session.tvident.sysString{...
                options.session.tvident.sysValue},stringPU)
            options.session.tvident.sysValue = find(ismember(stringPU,...
                options.session.tvident.sysString{...
                options.session.tvident.sysValue}));
        else
            options.session.tvident.sysValue = 1;
        end
    end
    options.session.tvident.sysString = stringPU;
    options.session.tvident.sysKey = sysKey;
end

set(puVar,'string',options.session.tvident.sysString);
set(puVar,'value',options.session.tvident.sysValue);
set(puVar,'userData',options.session.tvident.sysValue);

% set previous limits (used in setup)
options.session.tvident.param(1) = checkLim(userOpt,...
    options.session.tvident.param(1),'naMin');
set(teNaMin,'string',num2str(options.session.tvident.param(1)));
options.session.tvident.param(2) = checkLim(userOpt,...
    options.session.tvident.param(2),'naMax');
set(teNaMax,'string',num2str(options.session.tvident.param(2)));
options.session.tvident.param(3) = checkLim(userOpt,...
    options.session.tvident.param(3),'nb1Min');
set(teNb1Min,'string',num2str(options.session.tvident.param(3)));
options.session.tvident.param(4) = checkLim(userOpt,...
    options.session.tvident.param(4),'nb1Max');
set(teNb1Max,'string',num2str(options.session.tvident.param(4)));
options.session.tvident.param(5) = checkLim(userOpt,...
    options.session.tvident.param(5),'nb2Min');
set(teNb2Min,'string',num2str(options.session.tvident.param(5)));
options.session.tvident.param(6) = checkLim(userOpt,...
    options.session.tvident.param(6),'nb2Max');
set(teNb2Max,'string',num2str(options.session.tvident.param(6)));
options.session.tvident.param(7) = checkLim(userOpt,...
    options.session.tvident.param(7),'nk1Min');
set(teNk1Min,'string',num2str(options.session.tvident.param(7)));
options.session.tvident.param(8) = checkLim(userOpt,...
    options.session.tvident.param(8),'nk1Max');
set(teNk1Max,'string',num2str(options.session.tvident.param(8)));
options.session.tvident.param(9) = checkLim(userOpt,...
    options.session.tvident.param(9),'nk2Min');
set(teNk2Min,'string',num2str(options.session.tvident.param(9)));
options.session.tvident.param(10) = checkLim(userOpt,...
    options.session.tvident.param(10),'nk2Max');
set(teNk2Max,'string',num2str(options.session.tvident.param(10)));

% open data and setup options that depend on the data
set(userOpt,'userData',options);
setup(userOpt,pFile,pSys,rbArx,rbLbf,rbMbf,txNa,teNaMin,txNa2,teNaMax,...
    txNb1,teNb1Min,txNb12,teNb1Max,txNb2,teNb2Min,txNb22,teNb2Max,txNk1,...
    teNk1Min,txNk12,teNk1Max,txNk2,teNk2Min,txNk22,teNk2Max,txLag,...
    txPole,tePole,txSysMem,teSysMem,txGen,teGenMin,txGen2,teGenMax,...
    pbStruc,pbBF,tbMod,tbIm,pnImResp,txInfo,pbInfo,plotLeg,pMod,pHandle,...
    rbIR,rbIRM,rbDG,rbDGL,rbDGH,rbD,rbTPeak);
options = get(userOpt,'userData');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ESSA PARTE DIZ RESPEITO AOS CRITÉRIOS MDL, AIC E BF.

% setup options that don't depend on the data
set(rbMdl,'value',0);
set(rbAic,'value',0);
set(rbBF,'value',0);
if options.session.tvident.criteria == 0, set(rbMdl,'value',1);
elseif options.session.tvident.criteria == 1, set(rbAic,'value',1);
else set(rbBF,'value',1);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

set(rbParam,'value',0);
set(rbOrder,'value',0);
if options.session.tvident.orMax == 0
    set(rbParam,'value',1);
else
    set(rbOrder,'value',1);
end

options.session.tvident.pole = checkLim(userOpt,...
    options.session.tvident.pole,'pole');
set(tePole,'string',num2str(options.session.tvident.pole));
options.session.tvident.gen(1) = checkLim(userOpt,...
    options.session.tvident.gen(1),'genMin');
set(teGenMin,'string',num2str(options.session.tvident.gen(1)));
options.session.tvident.gen(2) = checkLim(userOpt,...
    options.session.tvident.gen(2),'genMax');
set(teGenMax,'string',num2str(options.session.tvident.gen(2)));

set(userOpt,'userData',options);
end

function setup(userOpt,pFile,pSys,rbArx,rbLbf,rbMbf,txNa,teNaMin,txNa2,...
    teNaMax,txNb1,teNb1Min,txNb12,teNb1Max,txNb2,teNb2Min,txNb22,...
    teNb2Max,txNk1,teNk1Min,txNk12,teNk1Max,txNk2,teNk2Min,txNk22,...
    teNk2Max,txLag,txPole,tePole,txSysMem,teSysMem,txGen,teGenMin,...
    txGen2,teGenMax,pbStruc,pbBF,tbMod,tbIm,pnImResp,txInfo,pbInfo,plotLeg,...
    pMod,pHandle,rbIR,rbIRM,rbDG,rbDGL,rbDGH,rbD,rbTPeak)

% open data and setup options that depend on the data

options = get(userOpt,'userData');

% identify selected data
auxSys = options.session.tvident.sysString{options.session.tvident.sysValue};
options.session.tvident.sysLen = [0 0 0];

% open data and setup options
if ~strcmp(auxSys,'Indicate system') && ...
        ~strcmp(auxSys,'No systems available')
    sysKey = options.session.tvident.sysKey{...
        options.session.tvident.sysValue-1,1};
    modKey = options.session.tvident.sysKey{...
        options.session.tvident.sysValue-1,2};
    patient = get(pFile,'userData');
    system = get(pSys,'userData');
    
    system.data = patient.tvsys.(sysKey).data;
    options.session.tvident.sysLen = [size(system.data(:,:,:,1).u,2)+1,...
        length(system.data.ExperimentName) length(system.data(:,:,:,1).y)];
    % no registers / no experiments / data length
    
    set(pFile,'userData',patient);
    set(pSys,'userData',system);
    if ~isempty(modKey)
        set(pMod,'userData',patient.tvsys.(sysKey).models.(modKey));
        if isempty(patient.tvsys.(sysKey).models.(modKey).imResp.impulse)
            set(userOpt,'userData',options);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ESSA PARTE REALIZA A SELEÇÃO DOS MODELOS ARX, LBF E MBF

            if strcmp(patient.tvsys.(sysKey).models.(modKey).Type,'ARX')
%                 arxModel(pMod,[],[],[],1,txInfo.imresp,userOpt);
            else
                obfModel(pMod,[],[],[],[],[],[],[],1,userOpt);
            end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            options = get(userOpt,'userData');
        end
        options.session.tvident.modelGen = 1;
        options.session.tvident.saved = 1;
    else
        options.session.tvident.modelGen = 0;
        options.session.tvident.saved = 0;
    end
end

if isempty(strfind(auxSys,'model'))
    set(rbIR,'enable','off');
    set(rbIRM,'enable','off');
    set(rbDG,'enable','off');
    set(rbDGL,'enable','off');
    set(rbDGH,'enable','off');
    set(rbD,'enable','off');
    set(rbTPeak,'enable','off');
else
    set(rbIR,'enable','on');
    set(rbIRM,'enable','on');
    set(rbDG,'enable','on');
    set(rbDGL,'enable','on');
    set(rbDGH,'enable','on');
    set(rbD,'enable','on');
    set(rbTPeak,'enable','on');
end

if options.session.tvident.sysLen(1) > 1, statNb1 = 'on';
else statNb1 = 'off';
end
if options.session.tvident.sysLen(1) == 3, statNb2 = 'on';
else statNb2 = 'off';
end
if options.session.tvident.orMax == 0 && options.session.tvident.sysLen(1) > 1
    statNb1Max = 'on';
else
    statNb1Max = 'off';
end
if options.session.tvident.orMax == 0 && options.session.tvident.sysLen(1) == 3
    statNb2Max = 'on';
else
    statNb2Max = 'off';
end
set(txNb1,'enable',statNb1); set(teNb1Min,'enable',statNb1);
set(txNb12,'enable',statNb1Max); set(teNb1Max,'enable',statNb1Max);
set(txNk1,'enable',statNb1); set(teNk1Min,'enable',statNb1);
set(txNk12,'enable',statNb1Max); set(teNk1Max,'enable',statNb1Max);
set(txNb2,'enable',statNb2); set(teNb2Min,'enable',statNb2);
set(txNb22,'enable',statNb2Max); set(teNb2Max,'enable',statNb2Max);
set(txNk2,'enable',statNb2); set(teNk2Min,'enable',statNb2);
set(txNk22,'enable',statNb2Max); set(teNk2Max,'enable',statNb2Max);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ESSA PARTE REALIZA A SELEÇÃO DOS MODELOS ARX, LBF E MBF

% if there's only output, only AR model can be selected
if options.session.tvident.sysLen(1) == 1
    set(rbArx,'string','AR');
    set(rbLbf,'enable','off');
    set(rbMbf,'enable','off');
    if options.session.tvident.model ~= 0
        options.session.tvident.model = 0;
    end
else
    set(rbArx,'string','ARX');
    set(rbLbf,'enable','on');
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % MODIFICADO DIA 31/02/2022
    %set(rbMbf,'enable','off');
    set(rbMbf,'enable','on');
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end
set(rbArx,'value',0);
set(rbLbf,'value',0);
set(rbMbf,'value',0);
if options.session.tvident.model == 0
    set(rbArx,'value',1);
    statNa = 'on'; statLag = 'off'; statMeix = 'off';
    options.session.tvident.param(1) = str2double(get(teNaMin,'string'));
    options.session.tvident.param(2) = str2double(get(teNaMax,'string'));
else
    statNa = 'off'; statLag = 'on';
    if options.session.tvident.model == 1
        set(rbLbf,'value',1); statMeix = 'off';
    else
        set(rbMbf,'value',1); statMeix = 'on';
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if options.session.tvident.sysLen(1) == 2
    options.session.tvident.param(3) =str2double(get(teNb1Min,'string'));
    options.session.tvident.param(4) =str2double(get(teNb1Max,'string'));
elseif options.session.tvident.sysLen(1) == 3
    options.session.tvident.param(3) = str2double(get(teNb1Min,'string'));
    options.session.tvident.param(4) = str2double(get(teNb1Max,'string'));
    options.session.tvident.param(5) = str2double(get(teNb2Min,'string'));
    options.session.tvident.param(6) = str2double(get(teNb2Max,'string'));
end
    
if options.session.tvident.orMax == 0 && options.session.tvident.model == 0
    statNaMax = 'on';
else
    statNaMax = 'off';
end
if options.session.tvident.orMax == 0 && options.session.tvident.model == 2
    statMeixMax = 'on';
else
    statMeixMax = 'off';
end
set(txNa,'enable',statNa); set(teNaMin,'enable',statNa);
set(txNa2,'enable',statNaMax); set(teNaMax,'enable',statNaMax);
set(txLag,'enable',statLag);
set(txPole,'enable',statLag); set(tePole,'enable',statLag);
set(txSysMem,'enable',statLag); set(teSysMem,'enable',statLag);
set(txGen,'enable',statMeix); set(teGenMin,'enable',statMeix);
set(txGen2,'enable',statMeixMax); set(teGenMax,'enable',statMeixMax);

if options.session.tvident.sysLen(1)>0
    set(pbStruc,'enable','on');
    if options.session.tvident.model >= 1
        set(pbBF,'enable','on');
    else
        set(pbBF,'enable','off');
    end
    if options.session.tvident.sysMem > options.session.tvident.sysLen(3)
        options.session.tvident.sysMem = options.session.tvident.sysLen(3);
    end
else
    set(pbStruc,'enable','off');
    set(pbBF,'enable','off');
end
set(teSysMem,'string',num2str(options.session.tvident.sysMem));

set(userOpt,'userData',options);
switch options.session.nav.tvimresp
    case 0
        set(tbMod,'value',1);
        tabChange(tbMod,[],txInfo.model,tbIm,pnImResp,pbInfo,...
            plotLeg,userOpt,pSys,pMod,pHandle,rbIR,rbIRM,rbDG,...
            rbDGL,rbDGH,rbD,rbTPeak);
    case 1
        set(tbIm,'value',1);
        tabChange(tbIm,[],pnImResp,tbMod,txInfo.model,pbInfo,...
            plotLeg,userOpt,pSys,pMod,pHandle,rbIR,rbIRM,rbDG,...
            rbDGL,rbDGH,rbD,rbTPeak);
end

modelInfoString(userOpt,pMod,txInfo.model)
imrespInfoString(userOpt,pMod);
end

function changeVar(scr,~,userOpt,pFile,pSys,pMod,rbArx,rbLbf,rbMbf,txNa,...
    teNaMin,txNa2,teNaMax,txNb1,teNb1Min,txNb12,teNb1Max,txNb2,teNb2Min,...
    txNb22,teNb2Max,txNk1,teNk1Min,txNk12,teNk1Max,txNk2,teNk2Min,...
    txNk22,teNk2Max,txLag,txPole,tePole,txSysMem,teSysMem,txGen,...
    teGenMin,txGen2,teGenMax,pbStruc,pbBF,tbMod,tbIm,pnImResp,txInfo,pbInfo,...
    plotLeg,pHandle,rbIR,rbIRM,rbDG,rbDGL,rbDGH,rbD,rbTPeak)

% Disable rotate 3D image
rotate3d(pHandle,'off');

% change system selected to generate model
errStat = 0;
oldValue = get(scr,'userData');
newValue = get(scr,'value');
if oldValue ~= newValue
    options = get(userOpt,'userData');
    
    % verify if there's a similar system saved
    saved = 0;
    if options.session.tvident.sysLen(1) ~= 0
        patient = get(pFile,'userData');
        model = get(pMod,'userData');
        sysName = options.session.tvident.sysKey{...
            options.session.tvident.sysValue-1};
        prevMod = fieldnames(patient.tvsys.(sysName).models);
        if ~isempty(prevMod)
            for i = 1:length(prevMod)
                if isequal(patient.tvsys.(sysName).models.(prevMod{...
                        i}).Theta,model.Theta) && isequal(patient.tvsys.(...
                        sysName).models.(prevMod{i}).Type,model.Type)
                    saved = 1;
                end
            end
        end
    end
    
    if ~saved && ~options.session.tvident.saved && ...
            options.session.tvident.modelGen
        [selButton, dlgShow] = uigetpref('CRSIDLabPref',...
            'changeModIdentPref','Change model',sprintf([...
            'Warning!','\nThe current model has not been saved. Any ',...
            'modifications will be lost if other models are opened ',...
            'before saving.\nAre you sure you wish to proceed?']),...
            {'Yes','No'},'DefaultButton','No');
        if strcmp(selButton,'no') && dlgShow
            errStat = 1;
        end  
    end
    if ~errStat
        options.session.tvident.sysValue = newValue;
        set(scr,'userData',newValue);
        set(userOpt,'userData',options);

        setup(userOpt,pFile,pSys,rbArx,rbLbf,rbMbf,txNa,teNaMin,txNa2,...
            teNaMax,txNb1,teNb1Min,txNb12,teNb1Max,txNb2,teNb2Min,...
            txNb22,teNb2Max,txNk1,teNk1Min,txNk12,teNk1Max,txNk2,...
            teNk2Min,txNk22,teNk2Max,txLag,txPole,tePole,txSysMem,...
            teSysMem,txGen,teGenMin,txGen2,teGenMax,pbStruc,pbBF,tbMod,...
            tbIm,pnImResp,txInfo,pbInfo,plotLeg,pMod,pHandle,rbIR,...
            rbIRM,rbDG,rbDGL,rbDGH,rbD,rbTPeak)
    else
        set(scr,'value',oldValue);
    end
end
end

function saveMod(~,~,userOpt,pFile,pMod,puVar)
% save model

options = get(userOpt,'userData');
if options.session.tvident.modelGen
    
    sysName = options.session.tvident.sysKey{...
        options.session.tvident.sysValue-1};
    model = get(pMod,'userData');
    patient = get(pFile,'userData');
    prevMod = fieldnames(patient.tvsys.(sysName).models);
    if ~isempty(prevMod), lastNo = str2double(prevMod{end}(6:end));
    else lastNo = 0;
    end
    modName = ['model',num2str(lastNo+1)];
    
    if options.session.tvident.model == 0
        noteString = [modName,' (',model.Type,'): Parametrization [',...
            num2str(model.Order),']; Delays [',num2str(model.Delay),']'];
    elseif options.session.tvident.model == 1
        noteString = [modName,' (',model.Type,'): Parametrization [',...
            num2str(model.Order),']; Delays [',num2str(model.Delay),...
            ']; Mem. length (',num2str(model.SysMem),'); Pole (',...
            num2str(model.Pole),')'];
    else
        noteString = [modName,' (',model.Type,'): Parametrization [',...
            num2str(model.Order),']; Delays [',num2str(model.Delay),...
            ']; Mem. length (',num2str(model.SysMem),'); Pole (',...
            num2str(model.Pole),'); Gen. order (',num2str(model.GenOrd),...
            ')'];
    end
    
    model.Name = modName;
    model.Notes = noteString;
    
    % verify if there's a similar model saved
    saved = 0;
    if ~isempty(prevMod)
        for i = 1:length(prevMod)
            if isequal(patient.tvsys.(sysName).models.(prevMod{i}).Theta,...
                    model.Theta) && isequal(...
                    patient.tvsys.(sysName).models.(prevMod{i}).Type,...
                    model.Type)
                saved = 1;
            end
        end
    end
    
    if saved
        uiwait(errordlg(['Model already saved! It appears that ',...
            'there''s already a model identical to this one saved for ',...
            'this system. Duplicate models are not allowed.'],...
            'Model already saved','modal'));
    end
    
    if ~saved
        filename = options.session.filename;
        patient.tvsys.(sysName).models.(modName) = model;
        set(pFile,'userData',patient);
        save(filename,'patient');
        options.session.tvident.saved = 1;
        
        % adjust popupmenu
        allSys = find(~cellfun(@isempty,strfind(...
            options.session.tvident.sysString,'sys'))~=0);
        curSys = find(~cellfun(@isempty,strfind(...
            options.session.tvident.sysString,sysName))~=0);
        if ~isempty(find(allSys>curSys,1))
            newValue = allSys(find(allSys>curSys,1));
            options.session.tvident.sysString(newValue+1:end+1) = ...
                options.session.tvident.sysString(newValue:end);
            options.session.tvident.sysKey(newValue:end+1,:) = ...
                options.session.tvident.sysKey(newValue-1:end,:);
        else
            newValue = length(options.session.tvident.sysString)+1;
        end
        options.session.tvident.sysString{newValue} = ['    ',noteString];
        options.session.tvident.sysValue = newValue;
        set(puVar,'string',options.session.tvident.sysString);
        set(puVar,'value',options.session.tvident.sysValue);
        set(puVar,'userData',options.session.tvident.sysValue);
        % adjust sysKey
        options.session.tvident.sysKey{newValue-1,1} = sysName;
        options.session.tvident.sysKey{newValue-1,2} = modName;
        
        set(userOpt,'userData',options);
        uiwait(msgbox(['The model and impulse response have been saved',...
            ' successfully by the name of ',modName,'. To view any ',...
            'model and impulse response, select it from the popup menu',...
            ' in this tab.'],'Model saved','modal'));
    end
end
end

function cbVisCallback(scr,~,userOpt,pHandle,pMod,...
    cb1,cb2,cb3,cb4,cb5,cb6)
% select graphics to be shown (IR, IRM, DG, DGLF, DGHF, D or TPeak)

rotate3d(pHandle,'off');

options = get(userOpt,'userData');

if strcmp(get(scr,'String'),'Time Varying Impulse Response')
    cbVisSel = [1,0,0,0,0,0,0];
elseif strcmp(get(scr,'String'),'Impulse Response Magnitude')
    cbVisSel = [0,1,0,0,0,0,0];
elseif strcmp(get(scr,'String'),'Low Frequency Dynamic Gain')
    cbVisSel = [0,0,1,0,0,0,0];
elseif strcmp(get(scr,'String'),'High Frequency Dynamic Gain')
    cbVisSel = [0,0,0,1,0,0,0];
elseif strcmp(get(scr,'String'),'Dynamic Gain')
    cbVisSel = [0,0,0,0,1,0,0];
elseif strcmp(get(scr,'String'),'Latency')
    cbVisSel = [0,0,0,0,0,1,0];
elseif strcmp(get(scr,'String'),'Time-to-Peak')
    cbVisSel = [0,0,0,0,0,0,1];
end

options.session.tvident.cbVisSelection = cbVisSel;
set(userOpt,'userData',options);

set(scr,'value',1);
set(cb1,'value',0);
set(cb2,'value',0);
set(cb3,'value',0);
set(cb4,'value',0);
set(cb5,'value',0);
set(cb6,'value',0);

plotType = get(scr,'String');
TVidentPlotImresp(pHandle.single,pMod,plotType);
end

function rbCallback(scr,~,userOpt,rb1,rb2,ext1,ext2,ext3,ext4,ext5,ext6,...
    ext7,ext8,ext9,ext10,ext11,ext12,ext13,ext14,ext15,ext16)
% adjust options from radiobuttons: resampling method, ectopic-beat related
% variables handling, border handling, border start and end points and RRI
% output

options = get(userOpt,'userData');
options.session.tvident.(get(scr,'tag')) = get(scr,'userData');

if strcmp(get(scr,'tag'),'model')
    if get(scr,'userData') == 0
        set(ext1,'Enable','on'); set(ext2,'Enable','on');
        if options.session.tvident.orMax == 0
            set(ext3,'Enable','on'); set(ext4,'Enable','on');
        end
        set(ext5,'Enable','off'); set(ext6,'Enable','off');
        set(ext7,'Enable','off'); set(ext8,'Enable','off');
        set(ext9,'Enable','off'); set(ext15,'Enable','off');
        options.session.tvident.param(1) = str2double(get(ext2,'string'));
        options.session.tvident.param(2) = str2double(get(ext4,'string'));
    else
        set(ext1,'Enable','off'); set(ext2,'Enable','off');
        set(ext3,'Enable','off'); set(ext4,'Enable','off');
        set(ext5,'Enable','on'); set(ext6,'Enable','on');
        set(ext7,'Enable','on'); set(ext8,'Enable','on');
        set(ext9,'Enable','on');
        if options.session.tvident.sysLen(1) ~= 0
            set(ext14,'Enable','on'); set(ext15,'enable','on');
        end
        options.session.tvident.param(1) = 0;
        options.session.tvident.param(2) = 0;
    end
    if get(scr,'userData') == 0 || get(scr,'userData') == 1
        set(ext10,'Enable','off'); set(ext11,'Enable','off');
        set(ext12,'Enable','off'); set(ext13,'Enable','off');
    else
        set(ext10,'Enable','on'); set(ext11,'Enable','on');
        if options.session.tvident.orMax == 0
            set(ext12,'Enable','on'); set(ext13,'Enable','on');
        end
    end
elseif strcmp(get(scr,'tag'),'orMax')
    if get(scr,'userData') == 0
        stat = 'on';
    else
        stat = 'off';
    end
    set(ext1,'Enable',stat);
    set(ext2,'Enable',stat);
    set(ext3,'Enable',stat);
    set(ext4,'Enable',stat);
    if options.session.tvident.sysLen(1) > 1
        set(ext5,'Enable',stat);
        set(ext6,'Enable',stat);
        set(ext7,'Enable',stat);
        set(ext8,'Enable',stat);
    end
    if options.session.tvident.sysLen(1) == 3
        set(ext9,'Enable',stat);
        set(ext10,'Enable',stat);
        set(ext11,'Enable',stat);
        set(ext12,'Enable',stat);
    end
    if options.session.tvident.model == 0
        set(ext13,'Enable',stat);
        set(ext14,'Enable',stat);
    elseif options.session.tvident.model == 2
        set(ext15,'Enable',stat);
        set(ext16,'Enable',stat);
    end
end
set(userOpt,'userData',options);

set(scr,'value',1);
set(rb1,'value',0);
if ~strcmp(get(scr,'tag'),'orMax')
    set(rb2,'value',0);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TODO: For now, only MDL is available. When methods AIC 
% and Best Fit become available, remove the two line below. 
set(ext3,'Enable','off');
set(ext4,'Enable','off');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end

function teCallback(scr,~,userOpt)
% adjust filter options

options = get(userOpt,'userData');

A=str2double(get(scr,'string'));
% set boundries according to filter tag
switch get(scr,'tag')
    case 'naMin'
        A = round(A); loLim = 0;
        if ~options.session.tvident.orMax
            hiLim = options.session.tvident.param(2);
        else
            hiLim = inf;
        end
    case 'naMax'
        A = round(A);
        hiLim = inf; loLim = options.session.tvident.param(1);
    case 'nb1Min'
        A = round(A); loLim = 1;
        if ~options.session.tvident.orMax
            hiLim = options.session.tvident.param(4);
        else
            hiLim = inf;
        end
    case 'nb1Max'
        A = round(A);
        hiLim = inf; loLim = options.session.tvident.param(3);
    case 'nb2Min'
        A = round(A); loLim = 1;
        if ~options.session.tvident.orMax
            hiLim = options.session.tvident.param(6);
        else
            hiLim = inf;
        end
    case 'nb2Max'
        A = round(A);
        hiLim = inf; loLim = options.session.tvident.param(5);
    case 'nk1Min'
        A = round(A); loLim = -inf;
        if ~options.session.tvident.orMax
            hiLim = options.session.tvident.param(8);
        else
            hiLim = inf;
        end
    case 'nk1Max'
        A = round(A);
        hiLim = inf; loLim = options.session.tvident.param(7);
    case 'nk2Min'
        A = round(A); loLim = -inf;
        if ~options.session.tvident.orMax
            hiLim = options.session.tvident.param(10);
        else
            hiLim = inf;
        end
    case 'nk2Max'
        A = round(A);
        hiLim = inf; loLim = options.session.tvident.param(9);
    case 'pole'
        loLim = 0.001; hiLim = 0.999;
    case 'sysMem'
        A = round(A);
        loLim = 1;
        if options.session.tvident.sysLen(1) ~= 0
            hiLim = options.session.tvident.sysLen(3);
        else
            hiLim = inf;
        end
    case 'genMin'
        A = round(A); loLim = 0;
        if ~options.session.tvident.orMax
            hiLim = options.session.tvident.gen(2);
        else
            hiLim = inf;
        end
    case 'genMax'
        A = round(A);
        hiLim = inf; loLim = options.session.tvident.gen(1);
end

if ~isnan(A)
    if A >= loLim && A <= hiLim
        value = A;
    elseif A < loLim
        value = loLim;
    else
        value = hiLim;
    end
    if ismember(get(scr,'tag'),{'naMin','naMax','nb1Min','nb1Max',...
            'nb2Min','nb2Max','nk1Min','nk1Max','nk2Min','nk2Max'})
        options.session.tvident.param(get(scr,'userData')) = value;
    elseif ismember(get(scr,'tag'),{'genMin','genMax'})
        options.session.tvident.gen(get(scr,'userData')) = value;
    else
        options.session.tvident.(get(scr,'tag')) = value;
    end
end

if ismember(get(scr,'tag'),{'naMin','naMax','nb1Min','nb1Max',...
        'nb2Min','nb2Max','nk1Min','nk1Max','nk2Min','nk2Max'})
    set(scr,'string',num2str(options.session.tvident.param(...
        get(scr,'userData'))));
elseif ismember(get(scr,'tag'),{'genMin','genMax'})
    set(scr,'string',options.session.tvident.gen(get(scr,'userData')));
else
    set(scr,'string',options.session.tvident.(get(scr,'tag')));
end
set(userOpt,'userData',options);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ESSA FUNÇÃO MOSTRA AS ESTRUTURAS DOS MODELOS ARX, LBF E MBF
function pbModelStructure(~,~,userOpt)
% opens window to show model structure

structureWindow = figure(2); clf(structureWindow);
set(structureWindow,'Position',[50 200 540 350],'Color',[.95 .95 .95],...
    'toolbar','none')

options = get(userOpt,'userData');
if options.session.tvident.model == 0
    set(structureWindow,'Name','CRSIDLab - ARX model structure')
    if options.session.tvident.sysLen(1) == 3 %ARX with 2 inputs
        handleIM=axes('Units','normalized','Position',...
            [0.004 0.006 0.99 0.99]);
        imshow('arx2in.png','parent',handleIM);
    elseif options.session.tvident.sysLen(1) == 2 %ARX with 1 input
        handleIM=axes('Units','normalized','Position',...
            [0.072 0.12 0.86 0.75]);
        imshow('arx1in.png','parent',handleIM);
    else
        set(structureWindow,'Name','CRSIDLab - AR model structure')
        handleIM=axes('Units','normalized','Position',...
            [0.169 0.12 0.66 0.75]);
        imshow('ar.png','parent',handleIM);
    end
elseif options.session.tvident.model == 1
    set(structureWindow,'Name','LBF model structure')
    handleIM=axes('Units','normalized','Position',[0.004 0.006 0.99 0.99]);
    if options.session.tvident.sysLen(1) == 3
        imshow('lbf2in.png','parent',handleIM);
    else
        imshow('lbf1in.png','parent',handleIM);
    end
else
    set(structureWindow,'Name','MBF model structure')
    handleIM=axes('Units','normalized','Position',[0.004 0.006 0.99 0.99]);
    if options.session.tvident.sysLen(1) == 3
        imshow('mbf2in.png','parent',handleIM);
    else
        imshow('mbf1in.png','parent',handleIM);
    end
end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ESSA FUNÇÃO MOSTRA AS FUNÇÕES DE BASE
function pbBasisFunction(~,~,userOpt,teSysMem,tePole,teGenMin,teGenMax,...
        teNb1Min,teNb1Max,teNb2Min,teNb2Max)
% open window to show basis functions

options = get(userOpt,'userData');
if (all(options.session.tvident.param(1:6)==0) && ...
        ~options.session.tvident.orMax) || ...
        (all(options.session.tvident.param([1 3 5])==0) && ...
        options.session.tvident.orMax)
    uiwait(errordlg(['No order indicated! Please choose at least one ',...
        'order higher than zero before proceeding.'],...
        'No order indicated','modal'));
else
    basisFunctionMenu(userOpt,teSysMem,tePole,teGenMin,teGenMax,...
        teNb1Min,teNb1Max,teNb2Min,teNb2Max)
end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ESSA FUNÇÃO GERA OS MODELOS ARX, LBF E MBF
function generateModel(~,~,userOpt,pSys,pMod,pFile,txInfo,pHandle,...
    rbIR,rbIRM,rbDG,rbDGL,rbDGH,rbD,rbTPeak)
% Generates model (AR/ARX/LBF/MBF) from data set
% original Matlab code: Luisa Santiago C. B. da Silva, Jul. 2015

errStat = 0;
options = get(userOpt,'userData');

% set 'Time Varying Impulse Response' option
set(rbIR,'value',1);
set(rbIRM,'value',0);
set(rbDG,'value',0);
set(rbDGL,'value',0);
set(rbDGH,'value',0);
set(rbD,'value',0);
set(rbTPeak,'value',0);

% verify if there is a similar model saved

sysName = options.session.tvident.sysKey{options.session.tvident.sysValue-1};
model = get(pMod,'userData');
patient = get(pFile,'userData');
prevMod = fieldnames(patient.tvsys.(sysName).models);
saved = 0;
if ~isempty(prevMod)
    for i = 1:length(prevMod)
        if isequal(patient.tvsys.(sysName).models.(prevMod{i}).Theta,...
                model.Theta) && isequal(...
                patient.tvsys.(sysName).models.(prevMod{i}).Type,...
                model.Type)
            saved = 1;
        end
    end
end

if options.session.tvident.modelGen && options.session.tvident.saved
    uiwait(errordlg(['Model already saved! A saved model is currently ',...
        'opened. To estimate a new model, please select a system on ',...
        'the popup menu.'],'Model opened','modal'));
    errStat = 1;
elseif ~errStat && options.session.tvident.sysLen(1) == 1 && ...
        all(options.session.tvident.param(1:2)==0 )
    uiwait(errordlg(['No order indicated! Please set the order to a ',...
        'value higher than zero before proceeding.'],...
        'No order indicated','modal'));
    errStat = 1;
elseif ~options.session.tvident.orMax && ... %max and min limits set by user
        (((options.session.tvident.param(10)<options.session.tvident.param(9)||...
        options.session.tvident.param(6)<options.session.tvident.param(5))&&...
        options.session.tvident.sysLen(1) == 3) || ...
        ((options.session.tvident.param(8)<options.session.tvident.param(7)||...
        options.session.tvident.param(4)<options.session.tvident.param(3))&&...
        options.session.tvident.sysLen(1) >= 2) || ...
        (options.session.tvident.param(2)<options.session.tvident.param(1) &&...
        options.session.tvident.model == 0) ||...
        (options.session.tvident.gen(2)<options.session.tvident.gen(1) &&...
        options.session.tvident.model == 2))
        
    uiwait(errordlg(['Invalid values! Maximum limits must be greater ',...
        'than or equal to the minimum limits.'],...
        'Invalid values','modal'));
    errStat = 1;
elseif options.session.tvident.modelGen && ~options.session.tvident.saved &&...
        ~saved
    [selButton, dlgShow] = uigetpref('CRSIDLabPref','identModelPref',...
        'Estimate model',sprintf(['Warning!','\nThe current model has ',...
        'not been saved.\nProceeding without saving will discard the ',...
        'current model.\nAre you sure you wish to proceed?']),...
        {'Yes','No'},'DefaultButton','No');
    if strcmp(selButton,'no') && dlgShow
        errStat = 1;
    end
end

if options.session.tvident.sysLen(1) > 0 && ~errStat
    options.session.tvident.modelGen = 1;
    sys = get(pSys,'userData');
    
    if options.session.tvident.sysLen(2) == 2
        ze = sys.data(:,:,:,1); zv = sys.data(:,:,:,2);
    else
        ze = sys.data; zv = ze;
    end
    
    if options.session.tvident.model == 0
        if options.session.tvident.sysLen(1) >= 2, idMethod = 'ARX';
        else idMethod = 'AR';
        end
    elseif options.session.tvident.model == 1, idMethod = 'LBF';
    else idMethod = 'MBF';
    end
    
    if options.session.tvident.criteria == 0, criteria = 'mdl';
    elseif options.session.tvident.criteria == 1, criteria = 'aic';
    else criteria = 0;
    end
    
    set(userOpt,'userData',options);
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MODIFICAÇÃO REALIZADA DIA 08/02/2022
    if options.session.tvident.model == 0
%         identArx(pMod,ze,zv,options.session.tvident.param,...
%             options.session.tvident.orMax,criteria,txInfo.imresp,userOpt);
        identArx(pMod,ze,zv,options.session.tvident.param,options.session.tvident.orMax,...
            criteria,idMethod,userOpt,rbIR,rbIRM,rbDGL,rbDGH,rbDG, rbD,rbTPeak);  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    else
        identObf(pMod,ze,zv,options.session.tvident.param,...
            options.session.tvident.orMax,options.session.tvident.pole,...
            options.session.tvident.sysMem,criteria,idMethod,...
            options.session.tvident.gen,userOpt,rbIR,rbIRM,rbDGL,...
            rbDGH,rbDG,rbD,rbTPeak);
    end
    model = get(pMod,'userData');
    model.OutputData = sys.data.y;
    set(pMod,'userData',model);
    options = get(userOpt,'userData');
    options.session.tvident.modelGen = 1;
    options.session.tvident.saved = 0;
       
    set(userOpt,'userData',options);
    modelInfoString(userOpt,pMod,txInfo.model);
    saveConfig(userOpt);
    plotFcn(pHandle,[],userOpt,pMod)
end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function identArx(pMod,ze,zv,param,orMax,pMethod,idMethod,userOpt,rbIR,rbIRM,rbDGL,rbDGH,rbDG, rbD,rbTPeak)

if orMax    % user chose orders and delays: no need to choose best model
    if size(ze.u,2) == 2
        nn = [param(1) param(3) param(5) param(7) param(9)];
    else
        nn = [param(1) param(3) param(7)];
    end
else         % user chose parameter set: choose best model
    wb = waitbar(0,'Please wait while the model is estimated','color',...
        [.94 .94 .94]); % waitbar
    set(findobj(wb,'Type','Patch'),'facecolor',[0 0.8 0]);
    set(findobj(wb,'Type','Patch'),'edgecolor',[0 0 0]);
    if size(ze.u,2) == 2
        if ishandle(wb), set(wb,'userData',[0.5 0]); end % half waitbar for each input 
        NN = struc(param(1):param(2),param(3):param(4),param(7):param(8));
        NN2 =struc(param(1):param(2),param(5):param(6),param(9):param(10));
        
        V = arxCost(ze(:,:,1),zv(:,:,1),NN,wb);
        nn1 = selstruc(V,pMethod);
        tempMod = arxModel([],ze(:,:,1),zv(:,:,1),nn1,0);
        if nn1(3)<0
            inv = [zv.u(:,1);zeros(abs(nn1(3)),1)];
            ine = [ze.u(:,1);zeros(abs(nn1(3)),1)];
        end
        outTempe = filter(tempMod.imResp.impulse{:},1,ine);
        outTempv = filter(tempMod.imResp.impulse{:},1,inv);
        if nn1(3)<0
            outTempe = outTempe(abs(nn1(3))+1:end);
            outTempv = outTempv(abs(nn1(3))+1:end);
        end
        outTempe =  ze.y-outTempe;
        outTempv =  zv.y-outTempv;
        
        if ishandle(wb), set(wb,'userData',[0.5 0.5]); end% half waitbar for each input 
        zeAux = iddata(outTempe,ze.u(:,2),ze.ts);
        zvAux = iddata(outTempv,zv.u(:,2),zv.ts);
        V = arxCost(zeAux,zvAux,NN2,wb);
        nn2 = selstruc(V,pMethod);
        
        nn = [floor((nn1(1)+nn2(1))/2) nn1(2) nn2(2) nn1(3) nn2(3)];
    else
        if size(ze.u,2) == 1
            NN=struc(param(1):param(2),param(3):param(4),param(7):param(8));
        else
            NN = struc(param(1):param(2),0,0);
        end
        if ishandle(wb), set(wb,'userData',[1 0]); end
        V = arxCost(ze,zv,NN,wb);
        nn = selstruc(V,pMethod);
    end
end

arxModel(pMod,ze,zv,nn,0,userOpt,rbIR,rbIRM,rbDGL,rbDGH,rbDG,rbD,rbTPeak);
if ishandle(wb), delete(wb); end
end

function V = arxCost(ze,zv,NN,wb)

%get output and inputs from iddata structure
outEst = ze.y;
outVal = zv.y;

%get info on orders and delays
na = NN(:,1);
naMax = max(na);
if size(ze.u,2)>=1
    in1Est = ze.u(:,1);
    in1Val = zv.u(:,1);
    nb1 = NN(:,2);
    nb1Max = max(nb1);
    if size(ze.u,2)==2
        in2Est = ze.u(:,2);
        in2Val = zv.u(:,2);
        nb2 = NN(:,3);
        nb2Max = max(nb2);
        nk1 = NN(:,4);
        nk1Max = max(nk1);
        nk1Min = min(nk1);
        nk2 = NN(:,5);
        nk2Max = max(nk2);
        nk2Min = min(nk2);
    else
        nk1 = NN(:,3);
        nk1Max = max(nk1);
        nk1Min = min(nk1);
        nb2 = zeros(size(NN,1),1);
        nb2Max = 0;
        nk2 = zeros(size(NN,1),1);
        nk2Max = 0;
        nk2Min = 0;
    end
else
    nb1 = zeros(size(NN,1),1);
    nb1Max = 0;
    nk1 = zeros(size(NN,1),1);
    nk1Max = 0;
    nk1Min = 0;
    nb2 = zeros(size(NN,1),1);
    nb2Max = 0;
    nk2 = zeros(size(NN,1),1);
    nk2Max = 0;
    nk2Min = 0;
end

%#columns of regression matrix (data samples according to model order)
tam = naMax+nb1Max+nb2Max+nk1Max-nk1Min+nk2Max-nk2Min;
%ref: first output point that can be estimated
%end_ref: last output point that can be estimated (neg delay)
if nk1Min>=0
    if nk2Min>=0
        ref = max([naMax+1 nb1Max+nk1Max+nk1Min-1 nb2Max+nk2Max+...
            nk2Min-1])+1;
        endRef = length(outEst);
        endRefV = length(outVal);
    else
        ref = max([naMax+1 nb1Max+nk1Max+nk1Min-1 nb2Max+...
            nk2Max-1])+1;
        endRef = length(outEst)+nk2Min;
        endRefV = length(outVal)+nk2Min;
    end
elseif nk2Min>=0
    ref = max([naMax+1 nb1Max+nk1Max-1 nb2Max+nk2Max+nk2Min-1])+1;
    endRef = length(outEst)+nk1Min;
    endRefV = length(outVal)+nk1Min;
else
    ref = max([naMax+1 nb1Max+nk1Max-1 nb2Max+nk2Max-1])+1;
    endRef = length(outEst)+min([nk1Min nk2Min]);
    endRefV = length(outVal)+min([nk1Min nk2Min]);
end
samples = endRef-(ref-1); %number of data points that can be estimated
samplesV = endRefV-(ref-1);
y = outEst(ref:endRef); %estimation output data
yv = outVal(ref:endRefV); %validation output data

%regression matrices allocation
U = zeros(samples,tam);
Uv = zeros(samplesV,tam);
maxSamp = max([samples samplesV]);

%build regression matrix
for i = 1:maxSamp
    %output samples starting one before reference up to order na
    if i<= samples, U(i,1:naMax) = -outEst(ref-1:-1:ref-naMax); end
    if i<= samplesV, Uv(i,1:naMax) = -outVal(ref-1:-1:ref-naMax); end
    if nb1Max ~= 0
        %first input samples starting at reference minus min delay up to order nb1 minus max delay
        if i <= samples
            U(i,naMax+1:naMax+nb1Max+nk1Max-nk1Min) = ...
                in1Est(ref-nk1Min:-1:ref-nk1Max-nb1Max+1);
        end
        if i <= samplesV
            Uv(i,naMax+1:naMax+nb1Max+nk1Max-nk1Min) = ...
                in1Val(ref-nk1Min:-1:ref-nk1Max-nb1Max+1);
        end
    end
    if nb2Max ~= 0
        %second input samples starting at reference minus min delay up to order nb2 minus max delay
        if i<= samples
            U(i,naMax+nb1Max+nk1Max-nk1Min+1:naMax+nb1Max+...
                nk1Max-nk1Min+nb2Max+nk2Max-nk2Min) = ...
                in2Est(ref-nk2Min:-1:ref-nk2Max-nb2Max+1);
        end
        if i<= samplesV
            Uv(i,naMax+nb1Max+nk1Max-nk1Min+1:naMax+nb1Max+...
                nk1Max-nk1Min+nb2Max+nk2Max-nk2Min) = ...
                in2Val(ref-nk2Min:-1:ref-nk2Max-nb2Max+1);
        end
    end
    ref=ref+1;
end
UU = U'*U;
Uy = U'*y;

%loss function matrix allocation
V = zeros(size(NN)+1)';

%calculate loss functions
fSolve = @idpack.mldividecov;
lim1 = naMax+1-nk1Min; lim2 = lim1-1;
lim3 = naMax+nb1Max+nk1Max-nk1Min-nk2Min+1; lim4 = lim3-1;
if ishandle(wb), barOpt = get(wb,'userData'); end
for k = 1:size(NN,1)
    %get section from matrices
    ind = [1:na(k) lim1+nk1(k):lim2+nb1(k)+nk1(k) lim3+nk2(k):lim4+...
        nb2(k)+nk2(k)];
    
    theta = fSolve(UU(ind,ind),Uy(ind)); %parameters' vector
    
    %loss function (normalized squared error)
    V(1,k) = (yv-Uv(:,ind)*theta)'*(yv-Uv(:,ind)*theta)/samplesV;
    if ishandle(wb), waitbar((k/size(NN,1))*barOpt(1)+barOpt(2),wb); end
end

V(2:end,1:end-1) = NN'; %adds orders associated to loss function to matrix V
V(1,size(NN,1)+1)=samples; %# points used for estimation
V(2,size(NN,1)+1)=yv'*yv/samplesV; %normalized squared validation data
end

function model = arxModel(pMod,ze,zv,nn,flagIm,userOpt,rbIR,rbIRM,rbDGL,rbDGH,rbDG,rbD,rbTPeak)
if ~isempty(pMod), model = get(pMod,'userData'); 
else model = dataPkg.sysModel; end

if ~flagIm
    %get output and inputs from iddata structure
    outEst = ze.y;
    outVal = zv.y;
    %get info on orders and delays
    na = nn(1);
    if size(ze.u,2)>=1
        in1Est = ze.u(:,1);
        in1Val = zv.u(:,1);
        nb1 = nn(2);
        if size(ze.u,2)==2
            in2Est = ze.u(:,2);
            in2Val = zv.u(:,2);
            nb2 = nn(3);
            nk1 = nn(4);
            nk2 = nn(5);
        else
            nk1 = nn(3);
            nb2 = 0;
            nk2 = 0;
        end
    else
        nb1 = 0;
        nk1 = 0;
        nb2 = 0;
        nk2 = 0;
    end
    
    %[thm,yhat,P,phi] = rarx([outEst in1Est],[na nb nk],'ff',lam,th0,P0,phi0);
    %[thm,yhat,P,phi] = rarx([outEst in1Est],[na nb nk],'ff');
    
    %Output Arguments:
    %%% thm: Estimated parameters of the model. 
    %%% yhat: Predicted value of the output.
    %%% P: Final values of the scaled covariance matrix of the parameters.
    %%% phi: phi contains the final values of the data vector.
    %[thm,yhat,P,phi] = rarx([outEst in1Est],[na nb nk],'ff',lam,'default','default','default');
    
    %L = length(yhat);
    %err = y(1:L)-yh(1:L);
    %NMSE = var(err)/var(y(1:L));
    
    % Sampling frequency from period
%     fs = 1/ze.ts;

    lgth = length(outEst);
    lambdas = [0.97:0.001:0.996];
    ERR = zeros(length(lambdas),lgth-1);
    k=1;
    
    %[ypred,err,c] = TVRecLeastSquares(outEst,vv);
    
        for lm = lambdas
            obj = recursiveARX([na nb1 nk1],'EstimationMethod','ForgettingFactor', 'ForgettingFactor', lm);
            [A,B,EstimatedOutput] = obj(outEst(1,j),in1Est(1,j));
%             [thm,EstimatedOutput,P,phi] = rarx([outEst in1Est],[na nb1 nk1],'ff',lm);
            
            ERR = outEst(1:lgth-1) - EstimatedOutput(1:lgth-1)';
            ERR_val(k) = sum(ERR(k,:).^2);
            k = k+1;
        end
    
    [val, min_k] = min(ERR_val);
    lm = lambdas(min_k);
    obj = recursiveARX([na nb1 nk1],'EstimationMethod','ForgettingFactor', 'ForgettingFactor', lm);
    [A,B,EstimatedOutput] = obj(outEst,in1Est);

%     [thm,EstimatedOutput,P,phi] = rarx([outEst in1Est],[na nb1 nk1],'ff',lm);

    EstimatedOutput = EstimatedOutput';
    L = length(EstimatedOutput);
    err = outEst-EstimatedOutput;
    NMSE = var(err)/var(outEst);
    
    [im,t] = impulse(obj);

    if ~isempty(pMod)
        % Fill model object
        model.OutputName = ze.OutputName;
        model.OutputUnit = ze.OutputUnit;
        model.InputName = ze.InputName;
        model.InputUnit = ze.InputUnit;
        model.Ts = ze.Ts;
        model.Type = idMethod;
        model.Theta = theta;
        model.SysMem = [];
        model.Pole = [];
        model.GenOrd = [];
        model.Order = [na nb1];
        model.Delay = nk1;
%       model.fit = [fite fitv];           %%%%%%%%%%%%%%%ADICIONADO%%%%%%%%%%%%%%
    end

if ~isempty(pMod)    
    
    % Fill model object
    model.imResp.impulse = cell(1);
    model.imResp.impulse{1} =  im(:,:,1);
    model.imResp.time = t;
    %model.imResp.delay = th;
    
    set(pMod,'userData',model);
    imRespIndicators(pMod,userOpt);
    
    % Enable impulse response indicators selection
    set(rbIR,'enable','on');
    set(rbIRM,'enable','on');
    set(rbDG,'enable','on');
    set(rbDGL,'enable','on');
    set(rbDGH,'enable','on');
    set(rbD,'enable','on');
    set(rbTPeak,'enable','on');
end
    
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% FUNÇÕES DOS MODELOS LAGUERRE E MEIXNER VARIANTES NO TEMPO
function identObf(pMod,ze,zv,param,orMax,pole,sysMem,pMethod,idMethod,...
    gen,userOpt,rbIR,rbIRM,rbDGL,rbDGH,rbDG,rbD,rbTPeak)

if orMax    % user chose orders and delays: no need to choose best model
    if size(ze.u,2)==2
        NN = [param(3) param(5) param(7) param(9)];
    else
        NN = [param(3) param(7)];
    end
    if strcmp(idMethod,'MBF')
        NN = [NN ones(1,size(ze.u,1))*min(gen)];
    end
else          % user chose parameters set: choose best model
    wb = waitbar(0,'Please wait while the model is estimated','color',...
        [.94 .94 .94]); % waitbar
    set(findobj(wb,'Type','Patch'),'facecolor',[0 0.8 0]);
    set(findobj(wb,'Type','Patch'),'edgecolor',[0 0 0]);
    if size(ze.u,2)==2
        if any(ismember(ze.InputName{2},{'ILV','Filtered ILV'})) %%~any(ismember(ze.InputName,{'RRI','HR'})) && ...
            if strcmp(idMethod,'MBF')
                NN = struc(0,param(5):param(6),param(3):param(4),...
                    param(9):param(10),param(7): param(8),min(gen):...
                    max(gen),min(gen):max(gen));
                NN1 = struc(0,param(5):param(6),param(9):param(10),...
                    min(gen):max(gen));
                NN2 = struc(0,param(3):param(4),param(7):param(8),...
                    min(gen):max(gen));
            else
                NN = struc(0,param(5):param(6),param(3):param(4),...
                    param(9):param(10),param(7):param(8));
                NN1 = struc(0,param(5):param(6),param(9):param(10));
                NN2 = struc(0,param(3):param(4),param(7):param(8));
            end
        else
            if strcmp(idMethod,'MBF')
                NN = struc(0,param(3):param(4),param(5):param(6),...
                    param(7):param(8),param(9):param(10),min(gen):...
                    max(gen),min(gen):max(gen));
                NN1 = struc(0,param(3):param(4),param(7):param(8),...
                    min(gen):max(gen));
                NN2 = struc(0,param(5):param(6),param(9):param(10),...
                    min(gen):max(gen));
            else
                NN = struc(0,param(3):param(4),param(5):param(6),...
                    param(7):param(8),param(9):param(10));
                NN1 = struc(0,param(3):param(4),param(7):param(8));
                NN2 = struc(0,param(5):param(6),param(9):param(10));
            end
        end
        
        % extract variables from structures
        outEst = ze.y;
        in1Est = ze.u(:,1);
        in2Est = ze.u(:,2);
        outVal = zv.y;
        in1Val = zv.u(:,1);
        in2Val = zv.u(:,2);
        ts = ze.Ts;
        
        if any(ismember(ze.InputName,{'ILV','Filtered ILV'})) %%~any(ismember(ze.InputName,{'RRI','HR'}))
            step = (19/20); off1 = (19/20); off2 = (39/40);
            if ishandle(wb), set(wb,'userData',[step 0]); end % include temp model
            if any(ismember(ze.InputName{2},{'ILV','Filtered ILV'}))
                aux1 = in1Est; aux2 = in1Val;
                in1Est = in2Est; in2Est = aux1;
                in1Val = in2Val; in2Val = aux2;
            end
            
            % uncorrelate ILV from second input
            zUncEst = iddata(in2Est,in1Est,ts);
            zUncVal = iddata(in2Val,in1Val,ts);
            NNunc = struc(round(3/(2*ts)):round(10/(2*ts)),...
                round(3/(2*ts)):round(10/(2*ts)),0);
            Vunc=arxstruc(zUncEst,zUncVal,NNunc);
            nnUnc=selstruc(Vunc,pMethod);
            mEst=arx(zUncEst,nnUnc);
            mVal=arx(zUncVal,nnUnc);
            in2EstCorr=idsim(in1Est,mEst);  % 2nd input corr to 1st input (est)
            in2EstUnc=in2Est-in2EstCorr;    % 2nd input unc to 1st input (est)
            in2ValCorr=idsim(in1Val,mVal);  % 2nd input corr to 1st input (val)
            in2ValUnc=in2Val-in2ValCorr;    % 2nd input unc to 1st input (val)

            % best model for uncorrelated input
            zTempEst = iddata(outEst,[in1Est in2EstUnc],ts);
            zTempVal = iddata(outVal,[in1Val in2ValUnc],ts);
            Vtemp = obfCost(zTempEst,zTempVal,NN,pole,sysMem,idMethod,wb);
            nnTemp = selstruc(Vtemp,pMethod);
            [simet,simvt]=obfModel([],zTempEst,zTempVal,nnTemp,pole,sysMem,gen,...
                idMethod,0);
            yTempEst = simet.y(:,2);     % output due to 2nd input uncorrelated from 1st input
            outEstIn1 = outEst-yTempEst;      % output correlated to 1st input
            yTempVal = simvt.y(:,2);     % output due to 2nd input uncorrelated from 1st input
            outValIn1 = outVal-yTempVal;      % output correlated to 1st input
            step = 1/40;
        else
            step = 1/2; off1 = 0; off2 = 1/2;
            outEstIn1 = outEst;
            outValIn1 = outVal;
        end
        
        if ishandle(wb), set(wb,'userData',[step off1]); end
        % best model for 1st input considering only the output that can be
        % correlated to it
        ze1 = iddata(outEstIn1,in1Est,ts);
        zv1 = iddata(outValIn1,in1Val,ts);
        V1 = obfCost(ze1,zv1,NN1,pole,sysMem,idMethod,wb);
        nn1 = selstruc(V1,pMethod);
        [sime1,simv1] = obfModel([],ze1,zv1,nn1,pole,sysMem,gen,idMethod,0);
        y1e = sime1.y;           % output due to 1st input (final)
        outEstUncIn1 = outEst-y1e;   % output uncorrelated to 1st input
        y1v = simv1.y;           % output due to 1st input (final)
        outValUncIn1 = outVal-y1v;   % output uncorrelated to 1st input
        
        if ishandle(wb), set(wb,'userData',[step off2]); end
        % best model for 2nd input considering only the output that can be
        % correlated to it
        ze2 = iddata(outEstUncIn1,in2Est,ts);
        zv2 = iddata(outValUncIn1,in2Val,ts);
        V2 = obfCost(ze2,zv2,NN2,pole,sysMem,idMethod,wb);
        nn2 = selstruc(V2,pMethod);
        
        % final parameters
        if any(ismember(ze.InputName{2},{'ILV','Filtered ILV'})) %%~any(ismember(ze.InputName,{'RRI','HR'})) && ...
            if strcmp(idMethod,'MBF')
                nn = [nn2(1) nn1(1) nn2(2) nn1(2) nn2(3) nn1(3)];
            else
                nn = [nn2(1) nn1(1) nn2(2) nn1(2)];
            end
        else
            if strcmp(idMethod,'MBF')
                nn = [nn1(1) nn2(1) nn1(2) nn2(2) nn1(3) nn2(3)];
            else
                nn = [nn1(1) nn2(1) nn1(2) nn2(2)];
            end
        end
        
    else
        if strcmp(idMethod,'MBF')
            NN = struc(0,param(3):param(4),param(7):param(8),min(gen):...
                max(gen));
        else
            NN = struc(0,param(3):param(4),param(7):param(8));
        end
        if ishandle(wb), set(wb,'userData',[1 0]); end
        V = obfCost(ze,zv,NN,pole,sysMem,idMethod,wb);
        nn = selstruc(V,pMethod);
    end
end

[simEstAux,simValAux] = obfModel(pMod,ze,zv,NN,pole,sysMem,gen,idMethod,...
    0,userOpt,rbIR,rbIRM,rbDGL,rbDGH,rbDG,rbD,rbTPeak);


model = get(pMod,'userData');
if size(ze.u,2)==2
    model.simOutEst = iddata(simEstAux.y(:,1)+simEstAux.y(:,2),[],...
        simEstAux.Ts);
    model.simOutVal = iddata(simValAux.y(:,1)+simValAux.y(:,2),[],...
        simValAux.Ts);
else
    model.simOutEst = simEstAux;
    model.simOutVal = simValAux;
end
set(pMod,'userData',model);
if orMax == 0, delete(wb); end
end

function [V,U,Uv,y,yv] = obfCost(ze,zv,NN,p,M,idMethod,wb)

%get output and inputs from iddata structure
outEst = ze.y;
outVal = zv.y;
in1EstOrd = ze.u(:,1);
in1ValOrd = zv.u(:,1);
nb1 = NN(:,2);
if size(ze.u,2)==2
    in2EstOrd = ze.u(:,2);
    in2ValOrd = zv.u(:,2);
    nb2 = NN(:,3);
    nk1 = NN(:,4);
    nk2 = NN(:,5);
    if strcmpi(idMethod,'mbf')
        gen1 = NN(:,6);
        gen2 = NN(:,7);
    else
        gen1 = zeros(size(NN,1),1);
        gen2 = zeros(size(NN,1),1);
    end
else
    nk1 = NN(:,3);
    in2EstOrd = zeros(size(in1EstOrd));
    in2ValOrd = zeros(size(in1ValOrd));
    nb2 = zeros(size(NN,1),1);
    nk2 = zeros(size(NN,1),1);
    if strcmpi(idMethod,'mbf')
        gen1 = NN(:,4);
    else
        gen1 = zeros(size(NN,1),1);
    end
    gen2 = zeros(size(NN,1),1);
end
nb1Max = max(nb1);
nk1Max = max(nk1);
nk1Min = min(nk1);
gen1Min = min(gen1);
gen1Max = max(gen1);
nb2Max = max(nb2);
nk2Max = max(nk2);
nk2Min = min(nk2);
gen2Min = min(gen2);
gen2Max = max(gen2);
nk1Var = nk1Min:nk1Max;
nk2Var = nk2Min:nk2Max;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   MEIXNERFILT - VERIFICAR
% filter data with meixner filter
in1Est = meixnerFilt(in1EstOrd,nb1Max,p,[gen1Min gen1Max],M);
in1Val = meixnerFilt(in1ValOrd,nb1Max,p,[gen1Min gen1Max],M);

if size(ze.u,2)==2
    in2Est = meixnerFilt(in2EstOrd,nb2Max,p,[gen2Min gen2Max],M);
    in2Val = meixnerFilt(in2ValOrd,nb2Max,p,[gen2Min gen2Max],M);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

tam = nb1Max+nb2Max; %#columns of regression matrix (data samples according to model order)
if nk1Max>=0 || nk2Max>=0
    ref = max([nk1Max nk2Max])+1;
else
    ref = 1;
end
if nk1Min<0 || nk2Min<0
    endRef = length(outEst)+min([nk1Min nk2Min]);
    endRefV = length(outVal)+min([nk1Min nk2Min]);
else
    endRef = length(outEst);
    endRefV = length(outVal);
end
samples = endRef-(ref-1);
samplesv = endRefV-(ref-1);
y = outEst(ref:endRef);
yv = outVal(ref:endRefV);

%regression matrices allocation
U = zeros(samples,tam,nk1Max-nk1Min+1,gen1Max-gen1Min+1,...
    nk2Max-nk2Min+1,gen2Max-gen2Min+1);
UU = zeros(tam,tam,nk1Max-nk1Min+1,gen1Max-gen1Min+1,...
    nk2Max-nk2Min+1,gen2Max-gen2Min+1);
Uy = zeros(tam,nk1Max-nk1Min+1,gen1Max-gen1Min+1,nk2Max-nk2Min+1,...
    gen2Max-gen2Min+1);
Uv = zeros(samplesv,tam,nk1Max-nk1Min+1,gen1Max-gen1Min+1,...
    nk2Max-nk2Min+1,gen2Max-gen2Min+1);

%build regression matrix
for d1 = 1:length(nk1Var)
    for g1 = 1:gen1Max-gen1Min+1
        for  d2 = 1:length(nk2Var)
            for g2 = 1:gen2Max-gen2Min+1
                U(:,1:nb1Max,d1,g1,d2,g2) = in1Est(...
                    ref-nk1Var(d1):endRef-nk1Var(d1),:,g1);
                Uv(:,1:nb1Max,d1,g1,d2,g2) = in1Val(...
                    ref-nk1Var(d1):endRefV-nk1Var(d1),:,g1);
                
                if size(ze.u,2)==2
                    U(:,nb1Max+1:nb1Max+nb2Max,d1,g1,d2,g2) = ...
                        in2Est(ref-nk2Var(d2):endRef-nk2Var(d2),:,g2);
                    Uv(:,nb1Max+1:nb1Max+nb2Max,d1,g1,d2,g2) = ...
                        in2Val(ref-nk2Var(d2):endRefV-nk2Var(d2),:,g2);
                end
                
                UU(:,:,d1,g1,d2,g2) = ...
                    U(:,:,d1,g1,d2,g2)'*U(:,:,d1,g1,d2,g2);
                Uy(:,d1,g1,d2,g2) = U(:,:,d1,g1,d2,g2)'*y;
            end
        end
    end
end

%allocate space for V matrix
V = zeros(size(NN')+1);
V(1:end-1,1:end-1) = NN';

fSolve = @idpack.mldividecov;
%calculate loss functions
if ishandle(wb), barOpt = get(wb,'userData'); end
for k = 1:size(NN,1)
    %get section from matrices
    ind = [1:nb1(k) nb1Max+1:nb1Max+nb2(k)];
    d1 = nk1(k)-nk1Min+1;
    g1 = gen1(k)-gen1Min+1;
    d2 = nk2(k)-nk2Min+1;
    g2 = gen2(k)-gen2Min+1;
    
    %theta = UU(ind,ind)\Uy(ind); %parameters' vector calculation
    theta = fSolve(UU(ind,ind,d1,g1,d2,g2),Uy(ind,d1,g1,d2,g2));
    
    V(1,k) = (yv-Uv(:,ind,d1,g1,d2,g2)*theta)'*...
        (yv-Uv(:,ind,d1,g1,d2,g2)*theta)/samplesv;
    if ishandle(wb), waitbar((k/size(NN,1))*barOpt(1)+barOpt(2),wb); end
end

V(1,end) = samples; %# points used for estimation
V(2,end) = yv'*yv/samplesv; %normalized squared validation data
end

function [simEst,simVal] = obfModel(pMod,ze,zv,nn,pole,sysMem,gen,idMethod,...
    flagIm,userOpt,rbIR,rbIRM,rbDGL,rbDGH,rbDG,rbD,rbTPeak)

if ~isempty(pMod), model = get(pMod,'userData');
else model = dataPkg.sysModel; end

if ~flagIm
    % Get output and inputs from iddata structure
    outEst = ze.y;
    outVal = zv.y;
    in1EstOrd = ze.u(:,1);
    in1ValOrd = zv.u(:,1);
    na = nn(1);
    % Min and max order of the model
    if size(nn) == [1,2]
        nbi = nn(1,1);
        nbf = nn(1,1);
    else
        nbi = nn(1,2);
        nbf = nn(end,2);
    end
    
    % Min and max delay of the model
    if size(nn) == [1,2]
        ndi = nn(1,2);
        ndf = nn(1,2);
    else
        ndi = nn(1,3);
        ndf = nn(end,3);
    end

    % Sampling frequency from period
    fs = 1/ze.ts;

    % System's memory
    p = sysMem;
    
    % Alpha coefficient
    alpha = pole;
    
%     [simEst,simVal] = impRespLaguerTV(pMod,idMethod,pole,sysMem,gen,userOpt,ze,zv,fs,outEst,outVal,in1EstOrd,in1ValOrd,p,alpha,nbi,nbf,ndi,ndf,...
%              rbIR,rbIRM,rbDGL,rbDGH,rbDG,rbD,rbTPeak);
        
     [t,th,h,nmse,y,ypred,md] = TVImpRespEstimation(fs,outEst,in1EstOrd,p,alpha,gen,nbi,nbf,ndi,ndf,idMethod);
   
   
    % Calculating convolution of impulse response with input validation data
    hSize = size(h);
    inValSize = size(in1ValOrd);
    xval = []; yval = [];
    
    for n = (md.ndelay + 1):1:inValSize(1)
        if (n - md.ndelay) <= hSize(1)
            xval = in1ValOrd(1:(n - md.ndelay),1);
            xval = flipud(xval);
            xval = padarray(xval, (hSize(1) - (n - md.ndelay)), 0, 'post');
        else
            xval = in1ValOrd(((n - md.ndelay) - (hSize(1) - 1)):(n - md.ndelay),1);
            xval = flipud(xval);
        end 
        yval = [yval sum(h(:,n) .* xval)];
    end
    
    % Normalizing output of validation data
    yval = yval./4;
    
    simEst = iddata(ypred',[],ze.ts);
    simVal = iddata(yval',[],zv.ts);

    % Fit to estimation data (NRMSE)
    outEstSize = size(outEst);
    yPredSize = size(ypred');

    if outEstSize(1) > yPredSize(1)
        outEst = outEst(1:yPredSize(1));
    else
        ypred = ypred(1:outEstSize(1));
    end
    
    fite = 100*(1-sqrt(var(outEst-ypred')/var(outEst)));

    % Fit to validation data (NRMSE)
    outValSize = size(outVal);
    yValSize = size(yval');

    if outValSize(1) > yValSize(1)
        
        outVal = outVal(1:yValSize(1));
    else
        yval = yval(1:outValSize(1));
    end
   
    %fitv = 100*(1-sqrt(var(outVal-yval')/var(outVal)));
    fitv = (1-sqrt(var(outVal-yval')/var(outVal)));
    
    % Removing first 30 seconds because RLS algorithm takes
    % approximatelly 20 seconds to stabilize - Javier Jo 2003
       h = h(:,30 * fs:end);
       t = t(30 * fs:end);
    
     if ~isempty(pMod)
        % Fill model object
        model.OutputName = ze.OutputName;
        model.OutputUnit = ze.OutputUnit;
        model.InputName = ze.InputName;
        model.InputUnit = ze.InputUnit;
        model.Ts = ze.Ts;
        model.Type = idMethod;
        model.Theta = md.c{1};
        model.SysMem = sysMem;
        model.Pole = pole;
        orderBf = size(md.bf{1});
        model.Order = orderBf(2);
        model.Delay = md.ndelay;
        if strcmpi(idMethod,'mbf')
            model.GenOrd = md.GenOrd;       %%%%%%%%%%%%%%%ADICIONADO%%%%%%%%%%%%%%
        end
%         model.fit = [fite fitv];           %%%%%%%%%%%%%%%ADICIONADO%%%%%%%%%%%%%%
    end

if ~isempty(pMod)    
    
    % Fill model object
    model.imResp.impulse = cell(1);
    model.imResp.impulse{1} = h;
    model.imResp.time = t;
    model.imResp.delay = th;
    
    set(pMod,'userData',model);
    imRespIndicators(pMod,userOpt);
    
    % Enable impulse response indicators selection
    set(rbIR,'enable','on');
    set(rbIRM,'enable','on');
    set(rbDG,'enable','on');
    set(rbDGL,'enable','on');
    set(rbDGH,'enable','on');
    set(rbD,'enable','on');
    set(rbTPeak,'enable','on');
end

end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  % MODIFICAÇÃO FEITA DIA 01/02/2022 - FUNÇÃO ADICIONADA
% function [simEst,simVal] = impRespLaguerTV(pMod,idMethod,pole,sysMem,gen,userOpt,ze,zv,fs,outEst,outVal,in1EstOrd,in1ValOrd,p,alpha,nbi,nbf,ndi,ndf,...
%         rbIR,rbIRM,rbDGL,rbDGH,rbDG,rbD,rbTPeak)
%  
%   % AQUI É FEITA A ESTIMAÇÃO DA RESPOSTA AO IMPULSO DO SISTEMA VARIANTE NO
%   % TEMPO (LAGUERRE + RLS)
%     % Estimating system's time varying impulse response
%     %if strcmpi(idMethod,'mbf')
%         [t,th,h,nmse,y,ypred,md] = TVImpRespEstimation(fs,outEst,in1EstOrd,p,alpha,gen,nbi,nbf,ndi,ndf,idMethod);
%    
%    
%     % Calculating convolution of impulse response with input validation data
%     hSize = size(h);
%     inValSize = size(in1ValOrd);
%     xval = []; yval = [];
%     
%     for n = (md.ndelay + 1):1:inValSize(1)
%         if (n - md.ndelay) <= hSize(1)
%             xval = in1ValOrd(1:(n - md.ndelay),1);
%             xval = flipud(xval);
%             xval = padarray(xval, (hSize(1) - (n - md.ndelay)), 0, 'post');
%         else
%             xval = in1ValOrd(((n - md.ndelay) - (hSize(1) - 1)):(n - md.ndelay),1);
%             xval = flipud(xval);
%         end 
%         yval = [yval sum(h(:,n) .* xval)];
%     end
%     
%     % Normalizing output of validation data
%     yval = yval./4;
%     
%     simEst = iddata(ypred',[],ze.ts);
%     simVal = iddata(yval',[],zv.ts);
% 
%     % Fit to estimation data (NRMSE)
%     outEstSize = size(outEst);
%     yPredSize = size(ypred');
% 
%     if outEstSize(1) > yPredSize(1)
%         outEst = outEst(1:yPredSize(1));
%     else
%         ypred = ypred(1:outEstSize(1));
%     end
%     
%     fite = 100*(1-sqrt(var(outEst-ypred')/var(outEst)));
% 
%     % Fit to validation data (NRMSE)
%     outValSize = size(outVal);
%     yValSize = size(yval');
% 
%     if outValSize(1) > yValSize(1)
%         outVal = outVal(1:yValSize(1));
%     else
%         yval = yval(1:outValSize(1));
%     end
%    
%     fitv = 100*(1-sqrt(var(outVal-yval')/var(outVal)));
%     
%      if ~isempty(pMod)
%         % Fill model object
%         model.OutputName = ze.OutputName;
%         model.OutputUnit = ze.OutputUnit;
%         model.InputName = ze.InputName;
%         model.InputUnit = ze.InputUnit;
%         model.Ts = ze.Ts;
%         model.Type = idMethod;
%         model.Theta = md.c{1};
%         model.SysMem = sysMem;
%         model.Pole = pole;
%         orderBf = size(md.bf{1});
%         model.Order = orderBf(2);
%         model.Delay = md.ndelay;
%         if strcmpi(idMethod,'mbf')
%             model.GenOrd = md.GenOrd;       %%%%%%%%%%%%%%%ADICIONADO%%%%%%%%%%%%%%
%         end
% %         model.fit = [fite fitv];
%     end
% 
% if ~isempty(pMod)    
%     
%     % Fill model object
%     model.imResp.impulse = cell(1);
%     model.imResp.impulse{1} = h;
%     model.imResp.time = t;
%     model.imResp.delay = th;
%     
%     set(pMod,'userData',model);
%     imRespIndicators(pMod,userOpt);
%     
%     % Enable impulse response indicators selection
%     set(rbIR,'enable','on');
%     set(rbIRM,'enable','on');
%     set(rbDG,'enable','on');
%     set(rbDGL,'enable','on');
%     set(rbDGH,'enable','on');
%     set(rbD,'enable','on');
%     set(rbTPeak,'enable','on');
% end
% 
% end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function imRespIndicators(pMod,userOpt)
% Calculate quantitative indicators from impulse response

model = get(pMod,'userData');

im = model.imResp.impulse;
p = model.SysMem;
fs = 1/model.Ts;

h = im{1};
[hrow,hcol] = size(h);
dim = 1;
L = hrow;

% Finding the next power of 2 based on the amount 
% of points of our signal
n = 2^nextpow2(L);

% FFT of impulse response
hfft = fft(h,n,dim);

% Getting the magnitude of the spectrum
P2 = abs(hfft'/n);
P1 = P2(:,1:n/2+1);
P1 = P1';

% Calculating the are of each frequency band
vlf = 0.04;
lf = 0.15;
hf = 0.4;
fmax = fs/2;
[aalf,aahf,aalfhf] = calcAreasFreqBand(P1,fmax,vlf,lf,hf);

% Impulse Response Magnitude
irm = [];
for l = 1:1:hcol
    irm = [irm (max(h(:,l)) - min(h(:,l)))];
end

% Total Dynamic Gain
dg = aalfhf;

% LF Dynamic Gain
dglf = aalf;

% HF Dynamic Gain
dghf = aahf;

% Response latency
d = zeros(hcol,1);
mem = 0:1:(p-1);
for l = 1:1:hcol
    d(l) = (mem * abs(h(:,l)))/(sum(abs(h(:,l))));  % (Blasi 2006)
end

% Time-to-peak
tpeak = [];
for l = 1:1:hcol
    if max(h(:,l)) >= min(h(:,l))
        [value,index] = max(h(:,l));
        tpeak(l) = (index(1) * 0.25);
    else
        [value,index] = min(h(:,l));
        tpeak(l) = (index(1) * 0.25);
    end
end
   
% Set information to model object
model.imResp.indicators.irm = irm;
model.imResp.indicators.dg.total = dg;
model.imResp.indicators.dg.lf = dglf;
model.imResp.indicators.dg.hf = dghf;
model.imResp.indicators.latency.time = d;
model.imResp.indicators.ttp.time = tpeak;

set(pMod,'userData',model);

end

function [dg,freq,absIR] = identDG(im,t,f1,f2,f3)
% % identDG Calculates dynamic gain
% %
% %  [dg,freq,absIR] = identDG(im,t,f1,f2) calculates single-sided spectrum
% %  'absIR' and frequency axis 'freq' from impulse response 'im' in time 
% %   axis 't' and uses it to calculate the dynamic gain 'dg' in three bands:
% %   'f1' to 'f3', correpondig to total DG, 'f1' to 'f2', corresponding to
% %   low frequency DG, and 'f2' to 'f3', corresponding to high frequency DG.
% %
% % original Matlab code: Luisa Santiago C. B. da Silva, Jul. 2015
% 
% % parameters
% ts = t(2)-t(1); fs = 1/ts; n = 1024;
% % fft
% freq = fs/2*linspace(0,1,n/2+1);
% absIR = abs(freqz(im,1,freq,fs));
% % dg
% freq2 = sort([freq, f1, f2, f3]);
% absIR2 = spline(freq,absIR,freq2);
% i = find(freq2 == f1,1);
% j = find(freq2 == f2,1);
% k = find(freq2 == f3,1);
% 
% dg(1) = (sum(absIR2(i:k))*fs/n)/(f3-f1); %total dynamic gain
% dg(2) = (sum(absIR2(i:j))*fs/n)/(f2-f1); %LF dynamic gain
% dg(3) = (sum(absIR2(j:k))*fs/n)/(f3-f2); %HF dynamic gain
end

function showDG(~,~,userOpt,pMod)
% % open window to show dynamic gain plots
% 
% options = get(userOpt,'userData');
% if options.session.tvident.modelGen
%     model = get(pMod,'userData');
%     freq = options.session.tvident.freq;
%     if length(model.InputName) == 2
%         [~,freq1,absIR1] = identDG(model.imResp.impulse{1},...
%             model.imResp.time,freq(1),freq(2),freq(3));
%         [~,freq2,absIR2] = identDG(model.imResp.impulse{2},...
%             model.imResp.time,freq(1),freq(2),freq(3));
%         plotDG(freq1,absIR1,model.InputName{1},freq(1),freq(2),freq(3),...
%             freq2,absIR2,model.InputName{2});
%     else
%         [~,freq1,absIR1] = identDG(model.imResp.impulse{1},...
%             model.imResp.time,freq(1),freq(2),freq(3));
%         if isempty(model.InputName)
%             plotDG(freq1,absIR1,model.OutputName{:},freq(1),freq(2),freq(3));
%         else
%             plotDG(freq1,absIR1,model.InputName{:},freq(1),freq(2),freq(3));
%         end
%     end
% end
end


function plotDG(freq1,absIR1,tipoIn1,f1,f2,f3,freq2,absIR2,tipoIn2)
% % plots dynamic gain
% 
% dgWindow = figure(2); clf(dgWindow);
% set(dgWindow,'toolbar','none','Name','Dynamic Gain plot','Position',...
%     [50,200,760,465],'Color',[.95 .95 .95])
% axes('Units','pixels','Position',[60 45 680 390]);
% 
% % generate label for first input according to its type
% switch tipoIn1
%     case 'RRI', y1label='|FFT hRRI|';
%     case 'SBP', y1label='|FFT hSBP|';
%     case 'DBP', y1label='|FFT hDBP|';
%     case 'HR', y1label='|FFT hHR|';
%     otherwise, y1label='|FFT hILV|';
% end
%     
% if nargin > 6
%     subplot(2,1,1), plot(freq1,absIR1);
%     axis([0 .5 0 max(absIR1)+.01]);
%     title('Dynamic Gain (DG)');
%     ylabel(y1label)
%     % lines that show band limits on first plot
%     line1=line([f1 f1],[0 max(absIR1)+.01]);
%     set(line1,'color',[1 0 0]);
%     line2=line([f2 f2],[0 max(absIR1)+.01]);
%     set(line2,'color',[1 0 0]);
%     line3=line([f3 f3],[0 max(absIR1)+.01]);
%     set(line3,'color',[1 0 0]);
%     
%     % generate labels for second input according to its type
%     switch tipoIn2
%         case 'RRI', y2label='|FFT hRRI|';
%         case 'SBP', y2label='|FFT hSBP|';
%         case 'DBP', y2label='|FFT hDBP|';
%         case 'HR', y2label='|FFT hHR|';
%         otherwise, y2label='|FFT hILV|';
%     end
%     
%     subplot(2,1,2), plot(freq2,absIR2);
%     axis([0 .5 0 max(absIR2)+.01]);
%     % lines that show band limits on second plot
%     line1=line([f1 f1],[0 max(absIR2)+.01]);
%     set(line1,'color',[1 0 0]);
%     line2=line([f2 f2],[0 max(absIR2)+.01]);
%     set(line2,'color',[1 0 0]);
%     line3=line([f3 f3],[0 max(absIR2)+.01]);
%     set(line3,'color',[1 0 0]);
%     ylabel(y2label)
%     xlabel('Frequency (Hz)');
% else
%     plot(freq1,absIR1)
%     axis([0 .5 0 max(absIR1)+.01]);
%     
%     % lines that show band limits on fist and only plot
%     line1=line([f1 f1],[0 max(absIR1)+.01]);
%     set(line1,'color',[1 0 0]);
%     line2=line([f2 f2],[0 max(absIR1)+.01]);
%     set(line2,'color',[1 0 0]);
%     line3=line([f3 f3],[0 max(absIR1)+.01]);
%     set(line3,'color',[1 0 0]);
%     
%     title('Dynamic Gain (DG)');
%     ylabel(y1label)
%     xlabel('Frequency (Hz)');
% end
end

function modelInfoString(userOpt,pMod,txInfo)
% build string to display quantitative indicators

model = get(pMod,'userData');
options = get(userOpt,'userData');

% generate labels and string indicators for empty tab
modType = ''; outName = '----'; outUn = '----'; in1Name = '----'; 
in1Un = '----'; in2Name = '----'; in2Un = '----'; ts = '----'; na = '--';
nb1 = '--'; nb1File = ''; nb2 = '--'; nb2File = ''; nk1 = '--'; nk2 = '--';
nk2File = ''; pole = '----'; sysMem = '----'; gen1 = '--'; gen2 = '--';
gen2File = ''; fite = '----'; fitv ='----'; 

% generate labels for output and first input
if options.session.tvident.modelGen
    modType = [model.Type,' '];
    outName = model.OutputName{:}; outUn = model.OutputUnit{:};
    if length(model.InputName) >= 1
        in1Name = model.InputName{1}; in1Un = model.InputUnit{1};
        if length(model.InputName) == 2
            in2Name = model.InputName{2}; in2Un = model.InputUnit{2};
        end
    else
        in1Name = model.OutputName{:}; in1Un = model.OutputUnit{:};
    end
    
    % prepare first input indicators for string
    ts = num2str(model.Ts); 
    na = num2str(model.Order(1));
    %fite = num2str(model.fit(1));       %%%%%%%%%%%%%%%ADICIONADO%%%%%%%%%%%%%%
    %fitv = num2str(model.fit(2));       %%%%%%%%%%%%%%%ADICIONADO%%%%%%%%%%%%%%
    if length(model.InputName) >= 1
       nb1 = num2str(model.Order(1));
       nb1File = nb1;
       nk1 = num2str(model.Delay(1));
       if length(model.InputName) == 2
           nb2 = num2str(model.Order(3));
           nk2 = num2str(model.Delay(2));
           nb2File = nb2; nk2File = nk2;
       end
    end
    if ismember(model.Type,{'MBF','LBF'})
        pole = num2str(model.Pole);
        sysMem = num2str(model.SysMem);
        if strcmp(model.Type,'MBF')
            gen1 = num2str(model.GenOrd(1));
            if length(model.InputName) == 2
                gen2 = num2str(model.GenOrd(2));
                gen2File = gen2;
            end
        end
    end
end

% information string to be displayed on screen
infoString = sprintf(['\n',modType,'Model information:\n\nSampling ',...
    'interval: ',ts,' seconds\nOutput data: ',outName,' (',outUn,')\n',...
    'Input 1 data: ',in1Name,' (',in1Un,')\nInput 2 data: ',in2Name,...
    ' (',in2Un,')\n\nParametrization [na nb1 nb2]:\n[',na,' ',nb1,' ',...
    nb2,']\n\nSignal delay [nk1 nk2]:\n[',nk1,' ',nk2,']\n\nPole: ',...
    pole,'\nSystem memory length: ',sysMem,'\nGeneralization order\n',...
    '[gen1 gen2]: [',gen1,' ',gen2,']\n\nFit to estimation data: ',fite,...
    ' %%\nFit to validation data: ',fitv,' %%\n']);
set(txInfo,'string',infoString);

% information string to be written to file
if options.session.tvident.modelGen
    info = sprintf([modType,'Model information:\n\nSampling interval:',...
        '\t',ts,'\t(s)\nOutput data:\t',outName,'\t(',outUn,')\nInput ',...
        '1 data:\t',in1Name,'\t(',in1Un,')\nInput 2 data:\t',in2Name,...
        '\t(',in2Un,')\n\nParametrization [na nb1 nb2]:\t',na,'\t',...
        nb1File,'\t',nb2File,'\n\nSignal delay [nk1 nk2]:\t',nk1,'\t',...
        nk2File,'\n\nPole:\t',pole,'\nSystem memory length:\t',sysMem,...
        '\nGeneralization order [gen1 gen2]:\t',gen1,'\t',gen2File,...
        '\n\nPercentage fit to estimation data:\t',fite,'\nPercentage ',...
        'fit to validation data:\t',fitv]);
    set(txInfo,'userData',info);
end
end

function imrespInfoString(userOpt,pMod,txInfo)
% % build string to display quantitative indicators
% 
% model = get(pMod,'userData');
% options = get(userOpt,'userData');
% freq = options.session.tvident.freq;
% 
% % generate labels and string indicators for empty tab
% outName = '----'; outUn = '----'; in1Name = 'Input 1'; in1Name2 = '----';
% in1Un = '----'; in1Un2 = '----'; in2Name = 'Input 2'; in2Name2 = '----'; 
% in2Un = '----'; irm1 = '----'; dgTot1 = '----'; dgLf1 = '----'; 
% dgHf1 = '----'; tDel1 = '----'; sampDel1 = '----'; tPeak1 = '----'; 
% sampPeak1 = '----'; irm2 = '----'; dgTot2 = '----'; dgLf2 = '----';
% dgHf2 = '----'; tDel2 = '----'; sampDel2 = '----'; tPeak2 = '----'; 
% sampPeak2 = '----';
% 
% % generate labels for output and first input
% if options.session.tvident.modelGen
%     outName = model.OutputName{:}; outUn = model.OutputUnit{:};
%     if length(model.InputName) >= 1
%         in1Name = model.InputName{1}; in1Name2 = model.InputName{1};
%         in1Un = model.InputUnit{1}; in1Un2 = model.InputUnit{1};
%         if length(model.InputName) == 2
%             in2Name = model.InputName{2}; in2Name2 = model.InputName{2};
%             in2Un = model.InputUnit{2};
%         end
%     else
%         in1Name = model.OutputName{:}; in1Un = model.OutputUnit{:};
%     end
%     
%     % prepare first input indicators for string
%     irm1 = num2str(model.imResp.indicators.irm(1)); 
%     dgTot1 = num2str(model.imResp.indicators.dg.total(1)); 
%     dgLf1 = num2str(model.imResp.indicators.dg.lf(1)); 
%     dgHf1 = num2str(model.imResp.indicators.dg.hf(1));
%     tDel1 =  num2str(model.imResp.indicators.latency.time(1)); 
%     sampDel1 = num2str(model.imResp.indicators.latency.samp(1));
%     tPeak1 = num2str(model.imResp.indicators.ttp.time(1)); 
%     sampPeak1 = num2str(model.imResp.indicators.ttp.samp(1));
%     if length(model.InputName) == 2
%         if ~isempty(model.imResp.impulse{1})
%             irm2 = num2str(model.imResp.indicators.irm(2));
%             dgTot2 = num2str(model.imResp.indicators.dg.total(2)); 
%             dgLf2 = num2str(model.imResp.indicators.dg.lf(2)); 
%             dgHf2 = num2str(model.imResp.indicators.dg.hf(2));
%             tDel2 = num2str(model.imResp.indicators.latency.time(2));
%             sampDel2 = num2str(model.imResp.indicators.latency.samp(2));
%             tPeak2 = num2str(model.imResp.indicators.ttp.time(2));
%             sampPeak2 = num2str(model.imResp.indicators.ttp.samp(2));
%         end
%     end
% end
% 
% % information string to be displayed on screen
% infoString = sprintf(['\nImpulse response information:\n\nImpulse ',...
%     'Response Magnitude (IRM):\n',in1Name,': ',irm1,' ',outUn,'/',in1Un,...
%     '\n',in2Name,': ',irm2,' ',outUn,'/',in2Un,'\n\nDynamic Gain (DG) ',...
%     '- ',num2str(freq(1)),' to ',num2str(freq(3)),' Hz:\n',in1Name,': ',...
%     dgTot1,' ',outUn,'/',in1Un,'\n',in2Name,': ',dgTot2,' ',outUn,'/',...
%     in2Un,'\n\nDG - LF (',num2str(freq(1)),' to ',num2str(freq(2)),...
%     ' Hz):\n',in1Name,': ',dgLf1,' ',outUn,'/',in1Un,'\n',in2Name,': ',...
%     dgLf2,' ',outUn,'/',in2Un,'\n\nDG - HF',' (',num2str(freq(2)),...
%     ' to ',num2str(freq(3)),' Hz):\n',in1Name,': ',dgHf1,' ',outUn,'/',...
%     in1Un,'\n',in2Name,': ',dgHf2,' ',outUn,'/',in2Un,'\n\nResponse ',...
%     'latency:\n',in1Name,': ',tDel1,' s (',sampDel1,' samples)\n',...
%     in2Name,': ',tDel2,' s (',sampDel2,' samples)\n\nTime-to-peak:\n',...
%     in1Name,': ',tPeak1,' s (',sampPeak1,' samples)\n',in2Name,': ',...
%     tPeak2,' s (',sampPeak2,' samples)\n']);
% set(txInfo,'string',infoString);
% 
% % information string to be written to file
% if options.session.tvident.modelGen
%     info = ['\tIRM\tTotal DG\tLF DG\tHF DG\tLatency\tTpeak\n',outName,...
%         '/',in1Name2,'\t',irm1,'\t',dgTot1,'\t',dgLf1,'\t',dgHf1,'\t',...
%         tDel1,'\t',tPeak1,'\n',outName,'/',in2Name2,'\t',irm2,'\t',...
%         dgTot2,'\t',dgLf2,'\t',dgHf2,'\t',tDel2,'\t',tPeak2,'\n\n',...
%         model.Type,' model impulse response information:\nOutput\t',...
%         outName,'\t',outUn,'\nInput 1\t',in1Name2,'\t',in1Un2,'\nInput',...
%         ' 2\t',in2Name2,'\t',in2Un,'\n\nLegends\nIRM\tImpulse response',...
%         ' magnitude\nDG\tDynamic gain\nLF\tLow frequency (',num2str(...
%         freq(1)),'-',num2str(freq(2)),' Hz)\nHF\tHigh frequency (',...
%         num2str(freq(2)),'-',num2str(freq(3)),' Hz)'];
%     
%     set(txInfo,'userData',info);
% end
end

function M = meixnerFilt(in,n,p,gen,N)
%meixner_filt Filters data using Meixner-like filter
%
%   M=meixner_filt(in,n,p,gen) applies the Meixner-like filter of pole 'p'
%   (0<=p<=1) to data 'in'. The data in must be uniformly sampled for the
%   filter to be applied. Returns matrix M with 'n' columns, containing the
%   data filtered by 'n' Meixner-like filters with orders ranging from 0 to
%   n-1 and generalization order given by 'gen'.
%
%   Inputs
%   in: data to be filtered.
%   n:  number of applied Meixner-like filters.
%   p:  Meixner-like filter pole (must be a value between 0 and 1).
%   gen:generalization order that determines how late the Meixner-like
%   functions start to fluctuate.
%   N:  filter impulse response length.
%
%   Outputs
%   M:  Matrix containing filtered data with 'n' columns (first column
%   contains data filtered by 0 order Meixner filter, last column contains
%   data filtered by (n-1)-th order Meixner filter).

%número de funções de laguerre necessário para gerar k funções de meixner
j = max(gen)+n+1;

%filtro de laguerre
lag = laguerreFilt(in,j,p,N)';

%matriz U
U = eye(j-1)*p;
U = [zeros(j-1,1) U];
U = [U; zeros(1,j)];
U = U+eye(j);
U_aux = U;

fSolve = @idpack.mldividecov;
M = zeros(length(in),n,(max(gen)-min(gen)+1));

if min(gen)~=0
    U = U^min(gen);
    L = chol(U*U','lower');
    A = fSolve(L,U);
    M(:,:,1) = (A(1:n,:)*lag)';
else
    U = U^0;
    M(:,:,1) = lag(1:n,:)';
end
for i = min(gen)+1:max(gen)
    U = U*U_aux;
    L = chol(U*U','lower');
    A = fSolve(L,U);
    M(:,:,i-min(gen)+1) = (A(1:n,:)*lag)';
end
end

function L = laguerreFilt(in,n,p,N)
%laguerre_filt Filters data using Laguerre filter
%
%   L=laguerre_filt(in,n,p) applies the Laguerre filter of pole 'p'
%   (0<=p<=1) to data 'in'. The data in must be uniformly sampled for the
%   filter to be applied. Returns matrix L with 'n' columns, containing the
%   data filtered by 'n' Laguerre filters with orders ranging from 0 to n-1.
%
%   Inputs
%   in: data to be filtered.
%   n:  number of applied Laguerre filters.
%   p:  Laguerre filter pole (must be a value between 0 and 1).
%   N:  filter impulse response length.
%
%   Outputs
%   L:  Matrix containing filtered data with 'n' columns (first column
%   contains data filtered by 0 order Laguerre filter, last column contains
%   data filtered by (n-1)-th order Laguerre filter).

L=zeros(n,length(in));
imp = zeros(1,N+1);
imp(1) = 1;

for j = 0 : n-1
    if j == 0 %order n=0
        B = [sqrt(1-p^2) 0];
        A = [1 -p];
    else
        B = conv(B,[-p 1]);
        A = conv(A,[1 -p]);
    end
    L_aux = filter(B,A,imp);
    L(j+1,:) = filter(L_aux,1,in);
end

L = L';

% This implementation is based on the paper "Use of Meixner Functions in
% Estimation of Volterra Kernels of Nonlinear Systems With Delay" by Musa
% H. Asyali and Mikko Juusola, published on IEE Transactions on Biomedical
% Engineering vol. 52, no. 2, February 2005.
end

function exportTxt(scr,~,userOpt,pMod,pFile,txInfo)
% export model information to text file

options = get(userOpt,'userData');
if options.session.tvident.modelGen
    model = get(pMod,'userData');
    patient = get(pFile,'userData');
    
    % suggested file name
    modName = [];
    sysKey = options.session.tvident.sysKey{...
        options.session.tvident.sysValue-1};
    prevMod = fieldnames(patient.tvsys.(sysKey).models);
    
    % if the model has been saved, find the corresponding tag
    if ~isempty(prevMod)
        for i = 1:length(prevMod)
            if isequal(patient.tvsys.(sysKey).models.(...
                    prevMod{i}).Theta,model.Theta) && ...
                    isequal(patient.tvsys.(sysKey).models.(...
                    prevMod{i}).Type,model.Type)
                modName = prevMod{i};
            end
        end
    end
    
    % if it hasn't been saved, get the new tag
    if isempty(modName)
        if ~isempty(prevMod), lastNo = str2double(prevMod{end}(6:end));
        else lastNo = 0;
        end
        modName = ['model',num2str(lastNo+1)];
    end
    
    [path,name,~] = fileparts(options.session.filename);
    
    if strcmp(get(scr,'tag'),'model')
        filenameTxt = fullfile(path,[name '_' sysKey '_' lower(...
            model.Type) '_',modName,'_info.txt']);
        [fileName,pathName,~] = uiputfile('*.txt',['Save ',model.Type,...
            ' model information to text file'],filenameTxt);
    else
        filenameTxt = fullfile(path,[name '_' sysKey '_' lower(...
            model.Type) '_' modName '_imresp_info.txt']);
        [fileName,pathName,~] = uiputfile('*.txt',['Save impulse ',...
            'response information to text file'],filenameTxt);
    end
    if (any(fileName~=0) || length(fileName)>1) && ...
            (any(pathName ~=0) || length(pathName)>1)
        filename = fullfile(pathName,fileName);
        [fid,message] = fopen(filename,'w');
        if fid == -1
            uiwait(errordlg(['Could not create file: ',message,...
                '. Verify if the file is opened in another program or ',...
                'try again with a different filename.'],...
                'TXT export error','modal'));
        else
            fprintf(fid,get(txInfo.(get(scr,'tag')),'userData'),'char');
            fclose(fid);
        end
    end
end
end

function tabChange(scr,~,pn,tb,pn2,pbInfo,aux1,userOpt,pSys,pMod,...
    pHandle,rbIR,rbIRM,rbDG,rbDGL,rbDGH,rbD,rbTPeak)

rotate3d(pHandle,'off');

if get(scr,'value') == 1
    set(pn,'visible','on');
    set(scr,'backgroundcolor',[1 1 1]);
    set(tb,'value',0,'backgroundcolor',[.94 .94 .94]);
    set(pn2,'visible','off');
    set(aux1,'visible','on');

    options = get(userOpt,'userData');
    if strcmp(get(scr,'tag'),'model')
        options.session.nav.tvimresp = 0;
        set(pbInfo,'enable','on');
    else
        options.session.nav.tvimresp = 1;
        set(pbInfo,'enable','off');
        options.session.tvident.cbVisSelection = [1,0,0,0,0,0,0];
        set(rbIR,'value',1);
        set(rbIRM,'value',0);
        set(rbDG,'value',0);
        set(rbDGL,'value',0);
        set(rbDGH,'value',0);
        set(rbD,'value',0);
        set(rbTPeak,'value',0);
    end
    set(userOpt,'userData',options);
    set(pbInfo,'tag',get(scr,'tag'));
    plotFcn(pHandle,pSys,userOpt,pMod);
else
    set(scr,'value',1);
end
end

function value = checkLim(userOpt,value,tag)

options = get(userOpt,'userData');
switch tag
    case 'naMin'
        value = round(value); loLim = 0;
        if ~options.session.tvident.orMax
            hiLim = options.session.tvident.param(2);
        else
            hiLim = inf;
        end
    case 'naMax'
        value = round(value);
        hiLim = inf; loLim = options.session.tvident.param(1);
    case 'nb1Min'
        value = round(value); loLim = 1;
        if ~options.session.tvident.orMax
            hiLim = options.session.tvident.param(4);
        else
            hiLim = inf;
        end
    case 'nb1Max'
        value = round(value);
        hiLim = inf; loLim = options.session.tvident.param(3);
    case 'nb2Min'
        value = round(value); loLim = 1;
        if ~options.session.tvident.orMax
            hiLim = options.session.tvident.param(6);
        else
            hiLim = inf;
        end
    case 'nb2Max'
        value = round(value);
        hiLim = inf; loLim = options.session.tvident.param(5);
    case 'nk1Min'
        value = round(value); loLim = -inf;
        if ~options.session.tvident.orMax
            hiLim = options.session.tvident.param(8);
        else
            hiLim = inf;
        end
    case 'nk1Max'
        value = round(value);
        hiLim = inf; loLim = options.session.tvident.param(7);
    case 'nk2Min'
        value = round(value); loLim = -inf;
        if ~options.session.tvident.orMax
            hiLim = options.session.tvident.param(10);
        else
            hiLim = inf;
        end
    case 'nk2Max'
        value = round(value);
        hiLim = inf; loLim = options.session.tvident.param(9);
    case 'pole'
        loLim = 0.001; hiLim = 0.999;
    case 'sysMem'
        value = round(value);
        loLim = 1;
        if options.session.tvident.sysLen(1) ~= 0
            hiLim = options.session.tvident.sysLen(3);
        else
            hiLim = inf;
        end
    case 'genMin'
        value = round(value); loLim = 0;
        if ~options.session.tvident.orMax
            hiLim = options.session.tvident.gen(2);
        else
            hiLim = inf;
        end
    case 'genMax'
        value = round(value);
        hiLim = inf; loLim = options.session.tvident.gen(1);
end

if value < loLim, value = loLim; end
if value > hiLim, value = hiLim; end
end

function saveConfig(userOpt)
% save session configurations for next session

options = get(userOpt,'userData');
options.tvident.model = options.session.tvident.model;
options.tvident.criteria = options.session.tvident.criteria;
options.tvident.orMax = options.session.tvident.orMax;
options.tvident.param = options.session.tvident.param;
options.tvident.gen = options.session.tvident.gen;
options.tvident.pole = options.session.tvident.pole;
options.tvident.sysMem = options.session.tvident.sysMem;
set(userOpt,'userData',options);
end