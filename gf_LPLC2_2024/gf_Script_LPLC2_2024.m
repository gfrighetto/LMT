%% gf_Script_LPLC2_2024
%  for testing the dorsoventral gradient in LPLC2 (combine with LoomScreen in FlyNeMo)
%  by using edges sweeping 7 leds (~15 deg) in 24 angular direction in 48
%  x-bins and 70 y-bins 

function gf_Script_LPLC2_2024

%% INITIAL PANELS STATUS

Panel_com('g_level_0')
%Panel_com('all_off')
pause(0.1)          % set a pause to give the panels controller computational time
%LED_OFF             % function for setting the Optogenetic LED on the NIDAQ output channels
daqreset            % resets Data Acquisition Toolbox and deletes all data acquisition objects.
clc                 % clean command window

%% SETUP FOLDER

% Establish root folder for today's experiments
todaypath = today_folder_setup;

% Change directory to the experiment folder
%cd(todaypath)

% % Also make a subfolder for each experiment
% folderpath = exp_folder_setup(expSelect,todaypath);

% try
%     cd(todaypath) % change directory
% catch
%     dirpath=uigetdir;
%     cd(dirpath)
% end


%% SETUP EXPERIMENTAL PARAMETERS

n = 1;

pSet(n).PreExpPause     =    10; % Pause before experiment starting
pSet(n).PostExpPause    =     5; % Pause after experiment ending
pSet(n).RandomTrials    =     1; % If 1 the trials order will be randomized, if 0 they won't be
pSet(n).TrialReps       =     2; % Number of trials repetitions
pSet(n).PatMeanLum      =    10; % Background intensity level
pSet(n).IdPat           =  1:25; % 24 patterns, 1:24 on SD card
pSet(n).PostTrialPause  =     3;
pSet(n).BaselinePause   =   0.5; % Do not change: hardcoded into position function
pSet(n).TrialPause      =     4; % Do not change: hardcoded into position function
pSet(n).CenterID        = evalin('base', 'CenterID');

% Pats features:
pSet(n).Angles          = [0 0:15:165 -15:-15:-180]; % angles for moving edges (+ means b2f; - means f2b)

% each pattern has 48 X pos related to vertical and horizontal postions and
% 70 extending steps

% X positions:
pSet(n).IdFuncX = 1; % 1 static position (the actual position is chosen based on FlyNeMo screen)

% Y positions:
pSet(n).IdFuncY = [3,4]; % one speed 20 deg/s in 70 steps (4 s in total, 0.62 s of extension)

parameterSet = pSet;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Verify parameters have not been changed by accident, by comparing with
% saved copy:
% clc;[errorFlag] = checkParameterSet(parameterSet);
% assert(~errorFlag,'Modify parameters and run again');
% Save a copy of the parameters used for this set of experiments
%file_name=[todaypath '\aq_EXP_PARAMETERS_' datestr(datevec(now),'yyyymmdd_HHMM')];
%save(file_name, 'parameterSet');

%% START DAQ LOGGING

% Initialize DAQ (will save a .daq file to current experiment folder)
%[ao ai dio]=fINIT_NiDAQ(dirpath,0:1,0:5); from input_Screen_2020
[ao, ai, dio]=fINIT_NiDAQ(todaypath,0:2,0:6);
try ao.Rate = 10000; catch  ai.SampleRate = 10000; end
try outputSingleScan(ao,[0 0 0]), catch, putsample(ao,[0 0 0]), end

% Start DAQ recording
try startBackground(ai), catch, start(ai), end

% Stall for time to prevent hastily double-tapped keys starting the experiments before slidebook is recording
loading=('|/-\|/-|');
loaded=('.');
for i = 1:8
loaded = strcat(loaded, '.');
clc; disp(strcat('DAQ starting',loaded, loading(i)));
pause(0.5)
end

% Now we can start recording in Slidebook:
clc; [~] = input('DAQ started. Start recording in Slidebook, then hit any key:  ');

tic

%% EXPERIMENT

IdExp = 1;
    % Enter individual experiments
    switch IdExp
        case 1 % UV square wave
            gf_ExpFuncs_LPLC2_2024(ao,pSet);        
    end
    
%% END

% If all is completed succesfully, shut down the DAQ
pause(5)
stop(ai);
stop(ao);
try outputSingleScan(ao,[0 0 0]), catch, putsample(ao,[0 0 0]), end

toc

% and LED panels
Panel_com('stop')
pause(0.1)
Panel_com('g_level_0')
%Panel_com('all_off')
pause(0.1)

disp('Experiments  complete. Stop Slidebook recording.')

% Play sound to notify that experiment is complete
load chirp
sound(y,Fs)

end

function [todaypath] = today_folder_setup

% This function creates a folder in \Desktop\gio_ExpOutput\ based on the
% current date and saved copies of the experiments inside a funcs folder

% INITIAL FOLDER SETUP

% Get today's date
%datevector = datevec(date); % datevec [converts the datetime or duration value t to a date vector�that is, a numeric vector whose six elements represent the year (yyyy), month (m), day (dd), hour (h), minute (min), and second (s) components of t]
% Format date as a string: yyyymmdd
%date_folderformat = num2str([datevector(1)*10000+datevector(2)*100+datevector(3)]);
% date_folderformat = date_folderformat(1:end) % without the leading 20xx in year string yyyy use date_folderformat(3:end)


% Get string for today's date with format yyyymmdd:
date_folderformat = datestr(datevec(now),'yyyymmdd'); % datestr [converts the datetime values in the input array t to text representing dates and times]
% If the variable 'giodirpath' doesn't exist yet
if ~exist('giodirpath','var') || ~strcmp(todaypath, ['C:\Users\3i\Desktop\gio_ExpOutput\LPLC2_2024\' date_folderformat])
    %..create it
    todaypath=['C:\Users\3i\Desktop\gio_ExpOutput\LPLC2_2024\' date_folderformat];
    cd(todaypath);
end

% If the folder of the same name / date doesn't exist yet
if ~exist(todaypath,'file')
    %..make the folder for today
    try
    mkdir(todaypath)
    catch
    todaypath=uigetdir;
    cd(todaypath)
    mkdir(todaypath)
    end
end

if ~exist([todaypath '\funcs'],'file')
    %..make the folder for a copy of the functions used
    mkdir([todaypath '\funcs'])
end

% Get the current time and do as before to format it: yyyymmddhhmm
%format shortg % set the output format so that floating-point values display with up to five digits.
%c=clock;
%date_fileformat = sprintf('%d%d%d%d', [c(1)*100+c(2)], c(3), c(4), c(5)) % to get a string. doubleStr = str2double(date_fileformat) % to get a double.
% or:
%date_fileformat = num2str([c(1)*100000000+c(2)*1000000+c(3)*10000 + c(4)*100 + c(5)]);
%date_fileformat = date_fileformat(3:end);

% Get the current time and do as before with format yyyymmddhhmm:
date_fileformat = datestr(datevec(now),'yyyymmdd_HHMM');

% Create unique file names from the current time
script_copy = [todaypath '\funcs\gf_Script_LPLC2_2024_' date_fileformat '.mat'];
assignin('base', 'script_copy', script_copy)
% And copy the two Matlab .m files that are currently in use, from current
% scripts folder
%copyfile('Y:\Giovanni\2P_ExpRun\gf_LPLC2_2024\gf_Script_LPLC2_2024.m', script_copy);
% % Change directory to today's folder
% cd(todaypath)

end

function [folderpath] = exp_folder_setup(expSelect,todaypath)

% EXPERIMENT FOLDER SETUP

% Make individual folder for this experiment, if it doesn't already exist
folderIdx = expSelect;
folderpath = [todaypath '\exp' num2str(folderIdx)];
if ~exist(folderpath,'file')
    %..make the folder
    mkdir(folderpath)
end

end

function [errorFlag] = checkParameterSet(newSet)
% Compare saved parameter set to new input values, to avoid mistakes
load('Y:\Giovanni\2P_ExpRun\gf_LPLC2_2024\parameterSet_LPLC2_2024.m') % parameters saved as pSet
[~,d1,d2] = comp_struct(newSet,pSet);
if ~isempty(d1) || ~isempty(d2) % differences found
    
    fields = intersect(fieldnames(d2),fieldnames(d1));
    
    for n = 1:size(fields,1)
        disp(['Change in pSet.' fields{n} ' found:'])
        disp(['     stored [' num2str([pSet.(fields{n})]) ']'])
        disp(['     change [' num2str([newSet.(fields{n})]) ']'])
    end
    
    if ~isempty(setdiff(fieldnames(d2),fieldnames(d1)))
        disp('Some fields not found:')
        disp(setdiff(fieldnames(d2),fieldnames(d1)))
    end
    
    continueFlag = 0;
    while ~continueFlag
        [tryStr] = input('To continue with changes, press ''1''. Press any other key to cancel.\n','s');
        if ~isnan(str2double(tryStr)) && str2double(tryStr) == 1
            errorFlag = 0;
            continueFlag = 1;
        elseif ~isnan(str2double(tryStr))
            disp('Try again') % number, but not correct one: possibly a mis-hit key
        else
            errorFlag = 1;
            continueFlag = 1;
        end
    end
else
    disp('Parameters checked: 100% match')
    errorFlag = 0;
end
end

%%

function gf_ExpFuncs_LPLC2_2024(ao,pSet)

%% TRIAL PARAMETERS AS FROM pSet (not for customization)

% Define trialParameters:
% [SequenceNumber, PatternNumber, X_func , Y_func, Angles, VoltageSeq CenterPosition]
trialParameters=[];
% Bar sweep
n=0;
for i = 1:length(pSet.IdPat)
    for ii= 1:length(pSet.IdFuncX); n=n+1;
        if i == 1 
        trialParameters(n,:) = [n pSet.IdPat(i) pSet.IdFuncX(ii) pSet.IdFuncY(2) pSet.Angles(i) pSet.CenterID(1)];
        else
        trialParameters(n,:) = [n pSet.IdPat(i) pSet.IdFuncX(ii) pSet.IdFuncY(1) pSet.Angles(i) pSet.CenterID(1)];
        end
    end
end

trialParameters(:,7) = linspace(1,10,25);

VoltRepetition = linspace(5,10,pSet.TrialReps);

%% RANDOMIZE TRIALS ORDER

if pSet.RandomTrials
    % Get random index
    trialOrder = randperm(size(trialParameters,1));
else
    trialOrder = 1:size(trialParameters,1);
end

ExpParams = trialParameters(trialOrder,:);
script_copy = evalin('base', 'script_copy');
save(script_copy, "ExpParams");

expt_duration = round(size(trialParameters,1)*pSet.TrialReps*(pSet.TrialPause + pSet.PostTrialPause + 0.5*pSet.BaselinePause)*1.01);
disp(['Estimated min experiment time:  ' num2str(expt_duration), 's  =  ' num2str(ceil(expt_duration/60)) 'min'])


%% INITIALIZE PANEL CONTROLLER STATUS

% Setup panels
Panel_com('g_level_0')
pause(0.1)
Panel_com('set_mode',[4,4]);
pause(0.1)
Panel_com('set_position',[pSet.CenterID(1),1]) % set starting position (xpos,ypos)
pause(0.1)
Panel_com('set_funcy_freq',100);
pause(0.1)
Panel_com('set_funcx_freq',100);
pause(0.1)


disp(['Experiment ' num2str(1) ' running..'])

% Pause before experiment:
pause(pSet.PreExpPause)

%% EXPERIMENT LOOP

for nIdx = 1:pSet.TrialReps
    
    % Display trial/set info
    disp(['Set ' num2str(nIdx) '/' num2str(pSet.TrialReps)])
    
    for trialIdx = 1:size(trialParameters,1)
        
        % Get trial parameters with randomized index
        patNum  = trialParameters(trialOrder(trialIdx),2);
        Xfunc   = trialParameters(trialOrder(trialIdx),3);
        Yfunc   = trialParameters(trialOrder(trialIdx),4);
        Angles  = trialParameters(trialOrder(trialIdx),5);
        VoltSeq = trialParameters(trialOrder(trialIdx),7);
        VoltRep = VoltRepetition(nIdx);
        
        % Print experiment info
        disp(['Trial ' num2str(trialIdx+(nIdx-1)*size(trialParameters,1)) ', pattern:' num2str(patNum) ', Angle:' num2str(Angles) 'deg'])
        
        mark_seqNum = VoltSeq;
        mark_repNum = VoltRep;
        
        Panel_com(['g_level_' num2str(pSet.PatMeanLum)])
        pause(pSet.BaselinePause)
        
        % Send new DAQ info to mark trial start
        try outputSingleScan(ao,[mark_seqNum, mark_repNum, 0]), catch, putsample(ao,[mark_seqNum, mark_repNum, 0]), end
        
        % Set pattern
        Panel_com('set_posfunc_id',[1 Xfunc]);
        pause(0.01)
        Panel_com('set_posfunc_id',[2 Yfunc]);
        pause(0.01)
        Panel_com('set_pattern_id',patNum);
        pause(0.01)
        Panel_com('start') % starts from mean lum bkgrnd
        pause(pSet.TrialPause)
        Panel_com('stop')  % after flash, finishes on mean lum bkgrnd
        pause(0.5*pSet.PostTrialPause)

        % Mark end of trial
        try outputSingleScan(ao,[0 0 0]), catch, putsample(ao,[0 0 0]), end        
        
        Panel_com(['g_level_' num2str(pSet.PatMeanLum)])
        pause(0.5*pSet.PostTrialPause)
        
    end
end

Panel_com(['g_level_' num2str(pSet.PatMeanLum)])
pause(0.1)

% Pause after experiment:
pause(pSet.PostExpPause)

end

