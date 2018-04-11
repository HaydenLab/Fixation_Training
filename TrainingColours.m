% Updated 20180411 Cindy Jiaxin Tu
% Check the screenid, eye and DataDir
%TB Dec 15, 2011
%For training monkeys with different colours (reward sizes), rectangular
%targets

function TrainingColours(initcell)
if nargin<1
    initcell = 'temp';
end
global eye
global oldEnableFlag;
global oldLevel;
global window;
global pause;
global k

try
    eye = 1
    screenid = 1;
    DataDir = 'E:/Data/Training'
    reward =  @(rewardduration)reward_digital_Juicer1(rewardduration); % call juicer function
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%VARIABLES%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %General variables
    blocksize   = 1;
    radius      = 10;
    fixationTime= 0.5;
    choiceTime  = 0.2;
    winsize     = 150; % size of the fixation window
    ITI         = .1;  %Inter Trial Interval
    trialBreakTime = 2; %Time the monkey has to complete a trial once its begun
    %asynchTime  = 0; %Time each option is shown before fixation,
    %asynchronously, not currently in use
    
    %Task variables, trial types
    infoDelay   = 0; %Delay between the choice and the information cue
    infoOn      = 0.5; %Time that the information cue is on for
    rewardDelay = 0; %Delay between the information cue and the reward
    cueTime     = .5; %Minimum amount of time the info cues are on for
    
    pRed        = 0;
    pOrange     = .25  + pRed;
    pYellow     = 0 + pOrange;
    pGrey       = .25 + pYellow;
    pBlue       = 0 + pGrey;
    pGreen      = .25 + pBlue;
    pPurple     = 0 + pGreen;
    pCyan       = 1; %Currently set to 1, cyan's probability is 1-(probability of all other colours)
    
    
    backcolour       = [50,   50,  50];
    
    %Display variables
    resolution = Screen(screenid,'Resolution');
    x0 = resolution.width/2; 
    y0 = resolution.height/2;
    targDist = 300; % pixels distance from center % CHANGE ME%
    center = [x0,y0];
    left = [x0-targDist,y0];
    right = [x0+targDist,y0];
    
    red.colour      = [255,   0,   0];
    orange.colour   = [255, 125,  50];
    yellow.colour   = [255, 255,   0];
    grey.colour     = [100, 100, 100];
    blue.colour     = [  0,   0, 255];
    green.colour    = [  0, 255,   0];
    purple.colour   = [255,   0, 255];
    cyan.colour     = [  0, 255, 255];
    
    
    treeMult = 1;
    red.rewSize     = 0 * treeMult;
    orange.rewSize  = .06 * treeMult;
    yellow.rewSize  = .08 * treeMult;
    grey.rewSize    = .10 * treeMult;
    blue.rewSize    = .12 * treeMult;
    green.rewSize   = .14 * treeMult;
    purple.rewSize  = .16 * treeMult;
    cyan.rewSize    = .18 * treeMult;
    
    red.type = 1;
    orange.type = 1;
    yellow.type = 1;
    grey.type = 1;
    blue.type = 1;
    green.type = 1;
    purple.type = 1;
    cyan.type = 1;
    
    colour.fix       = [250, 250,   0];
    colour.choiceFix = [255, 255, 255];
    colour.feedback  = [128, 255, 128];
    
    size.fixD         = 20;
    size.feedbackD    = 30;
    size.cue.height   = 300;
    size.cue.width    = 80;
    size.window       = winsize;
    size.fixBox.size  = 5;     %This is the size of the border when monkey is fixating on a choice
    size.fixBox.width = size.cue.width + size.fixBox.size;
    size.fixBox.height= size.cue.height + size.fixBox.size;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%INITIALIZATION STUFF%%%%%%%%%%%%%%%%%%%%%%%%%%
    cd(DataDir)
    %Make the data folder for this date, make a file name
    dateS = datestr(now, 'yymmdd');
    initial = initcell(1);
    if numel(initcell) == 1
        cell = '';
    else
        cell = initcell(2);
    end
    filename = [initial dateS '.' cell '1.TC.mat'];
    foldername = [initial dateS];
    mkdir(foldername)
    cd(foldername)
    trynum = 1;
    while(trynum ~= 0)
        if exist(filename,'file')
            trynum = trynum +1;
            filename = [initial dateS '.' cell num2str(trynum) '.TC.mat'];
        else
            savename = [initial dateS '.' cell num2str(trynum) '.TC.mat'];
            trynum = 0;
        end
    end
    
    warning('off', 'MATLAB:warn_r14_stucture_assignment');
    %Display initialization stuff
    oldEnableFlag = Screen('Preference', 'VisualDebugLevel', 0);% warning('off','MATLAB:dispatcher:InexactCaseMatch')
    oldLevel = Screen('Preference', 'Verbosity', 0);%Hides PTB Warnings
    window = Screen('OpenWindow', screenid, 0);
    Screen('FillRect', window, backcolour);
    Screen(window,'flip');
    
    %Eyelink setup
    if ~Eyelink('IsConnected')
        Eyelink('initialize');%connects to eyelink computer
    end
    Eyelink('startrecording');%turns on the recording of eye position
    Eyelink('StartSetup');
    % Wait until Eyelink actually enters Setup mode:
    trackerResp = true;
    while trackerResp && Eyelink('CurrentMode')~=2 % Mode 2 is setup mode
        % Let the user abort with ESCAPE
        [keyIsDown,~,keyCode] = KbCheck;
        if keyIsDown && keyCode(KbName('ESCAPE'))
            disp('Aborted while waiting for Eyelink!');
            trackerResp = false;
        end
    end
    % Send the keypress 'o' to put Eyelink in output mode
    Eyelink('SendKeyButton',double('o'),0,10);
    Eyelink('SendKeyButton',double('o'),0,10); %A second time to start recording
    %Miscellaneous variable initialization
    k.pressed = 0;
    k.escape = 0;
    k.juice = 0;
    k.pause = 0;
    pause = 0;
    continuing  = 1;
    trialnum    = 0;
    possible = 0;
    correct     = 0;
    fix.type    = 0;
    fix.location= center;
    fix.rewSize = 0;
    block = 0;
    startTime = GetSecs;  
     %% Draw a window in Eyelink %CT
    Eyelink('command','clear_screen %d', 0); % removes previous drawing
    Eyelink('command', 'draw_cross %d %d 15', x0, y0); % put a cross in the middle
    Eyelink('command','draw_box %d %d %d %d 15',x0-(winsize),y0-(winsize),x0+(winsize),y0+(winsize));
    leftrect = round(rect(left,size.fixBox)); % supplied coordinates have to be integers
    rightrect = round(rect(right,size.fixBox));
    LargeSize.width = winsize*2;LargeSize.height = winsize*2;
    leftrectLarge = round(rect(left,LargeSize));
    rightrectLarge = round(rect(right,LargeSize));
    Eyelink('command', 'draw_box %d %d %d %d 15', leftrect(1),leftrect(2),leftrect(3),leftrect(4));
    Eyelink('command','draw_box %d %d %d %d 15', rightrect(1),rightrect(2),rightrect(3),rightrect(4));
    Eyelink('command', 'draw_box %d %d %d %d 15', leftrectLarge(1),leftrectLarge(2),leftrectLarge(3),leftrectLarge(4));
    Eyelink('command','draw_box %d %d %d %d 15', rightrectLarge(1),rightrectLarge(2),rightrectLarge(3),rightrectLarge(4));
    
    
    %%%%%%%%%%%%%%%%%%%%%%%BEGINNING OF REAL CODE%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    while (continuing && ~k.escape);
        k = keyCheck;
        trialnum = trialnum+1;
        disp(['Trial: ' num2str(trialnum)]);
        choice = 0;     %Keeps track of whether/what choice was made
        %This decides what sort of trial it will be, and sets the options
        %accordingly
        if(block == 0)
            block = blocksize;
            while(1) %This is a hack workaround, Matlab doesn't have do-while.
                randC1 = rand;   %Random variable for choosing colour for opt1
                randC2 = rand;
                if(randC1 < pRed)
                    opt1 = red;
                elseif(randC1 < pOrange)
                    opt1 = orange;
                elseif(randC1 < pYellow)
                    opt1 = yellow;
                elseif(randC1 < pGrey)
                    opt1 = grey;
                elseif(randC1 < pBlue)
                    opt1 = blue;
                elseif(randC1 < pGreen)
                    opt1 = green;
                elseif(randC1 < pPurple)
                    opt1 = purple;
                elseif(randC1 < pCyan)
                    opt1 = cyan;
                end
                if(randC2 < pRed)
                    opt2 = red;
                elseif(randC2 < pOrange)
                    opt2 = orange;
                elseif(randC2 < pYellow)
                    opt2 = yellow;
                elseif(randC2 < pGrey)
                    opt2 = grey;
                elseif(randC2 < pBlue)
                    opt2 = blue;
                elseif(randC2 < pGreen)
                    opt2 = green;
                elseif(randC2 < pPurple)
                    opt2 = purple;
                elseif(randC2 < pCyan)
                    opt2 = cyan;
                end
                if(~isequal(opt1.colour, opt2.colour))
                    break;
                end
            end
        end
        block = block-1;
        if (rand > .5)
            opt1.location = left; 
            opt2.location = right; %Coin flip to decide the sides
        else opt1.location = right; 
            opt2.location = left;
        end
        rTime = GetSecs;
        if pause
            Screen(window,'flip');
            k = pauseComm;
        end
      
        while (~k.escape && ~fixate(fixationTime, colour, size, fix)); 
            k = keyCheck; 
        end %Fixation dot
        while (~k.escape && choice == 0) 
            choice = fixate(choiceTime, colour, size, opt1,opt2, trialBreakTime);
            k = keyCheck;
        end %Monkey chooses here
        
        rTime = GetSecs - rTime;
        sTime = GetSecs;
        if(choice == -1) %This will force a repeat of the same trial
            trialnum = trialnum - 1;
            block = block + 1;
        else
            while(~k.escape && GetSecs - sTime < infoDelay) 
                k = keyCheck;
            end
            if(~k.escape)
                if(choice == 1)
                    chosen = opt1;
                else
                    chosen = opt2;
                end
                
                gReward = chosen.rewSize;
                chosen.cue = 1;
                
                cTime = GetSecs;
                makeStim(chosen, colour, size, 1, 1);
                Screen(window, 'flip');
                sTime = GetSecs;
                while(~k.escape && GetSecs - sTime < infoOn) k = keyCheck;end
                Screen(window, 'flip');
                sTime = GetSecs;
                while(~k.escape && GetSecs - sTime < rewardDelay - infoOn) k = keyCheck;end
                reward(gReward);
                while(~k.escape && GetSecs - cTime < cueTime) k = keyCheck;end
                if(isfield(opt2,'type'))
                    possible = possible + 1;
                    if(chosen.rewSize == max(opt1.rewSize,opt2.rewSize))
                        correct = correct + 1;
                    end
                end
                Screen(window, 'flip');
                iTime = GetSecs;
                while(~k.escape && GetSecs - iTime < ITI) end
                disp(sprintf('Correct: %3.1f%%', (100*correct/possible)));
                disp(sprintf('Elapsed time: %d:%02.0f', (floor((GetSecs - startTime)/60)), mod((GetSecs-startTime),60)));
                data(trialnum).opt1 = opt1;
                data(trialnum).opt2 = opt2;
                data(trialnum).chosen = chosen;
                data(trialnum).reward = gReward;
                data(trialnum).rTime = rTime;
                save(savename,'data');
            end
        end
    end
catch err
end
Eyelink('stoprecording');
Eyelink('command','clear_screen %d', 0); % removes previous drawing from eyelink screen
sca;
cd(fileparts(mfilename('fullpath'))); % go back to the current file folder directory
if exist('err','var'); % if there is an error caught
    rethrow(err); % broadcast the error message
end
end

function a = rect(location, size)
a = [(location(1)-(size.width/2)) (location(2)-(size.height/2)) (location(1)+(size.width/2)) (location(2)+(size.height/2))];
end

%Draws the cue shapes. Types, fixation=0, coloured square = 1
function makeStim(stim, colour, size, fixflag, feedback)
if ~exist('feedback','var')
    feedback = 0;
end

global window;
if(stim.type == 0)
    Screen('FillOval', window, colour.fix, [(stim.location-(size.fixD/2)) (stim.location+(size.fixD/2))]);
else
    if fixflag
        Screen('FillRect', window, colour.choiceFix, rect(stim.location,size.fixBox)); end
    if(stim.type == 1)
        Screen('FillRect', window, stim.colour, rect(stim.location,size.cue));
        if(feedback == 1) 
            Screen('FillOval', window, colour.feedback, [(stim.location-(size.feedbackD/2)) (stim.location+(size.feedbackD/2))]);
        end
    end
end
end

function a = fixate(fixtime, colour, size, opt1, opt2, trialBreakTime)
global pause;
global window;
global k;
global eye;
a = 0;
% eye = 2;
trialTime = GetSecs;
if ~exist('opt2','var')
    opt2 = 0;
end
continuing = 1;
winsize = size.window;
while (continuing && ~k.escape)
    k = keyCheck;
    if (opt1.type == 0 && pause)
        Screen(window,'flip');
        k = pauseComm;
    end
    makeStim(opt1, colour, size, 0, 0);
    if(isfield(opt2,'type')) 
        makeStim(opt2, colour, size, 0, 0); 
    end
    Screen(window,'flip');
    e=Eyelink('newestfloatsample');
    if ((e.gx(eye) >= opt1.location(1)-winsize) && (e.gx(eye) <= opt1.location(1)+winsize) && (e.gy(eye)>=opt1.location(2)-winsize) && (e.gy(eye) <= opt1.location(2)+winsize));
        makeStim(opt1, colour, size, 1, 0);
        if(isfield(opt2,'type')) makeStim(opt2, colour, size, 0, 0); end
        Screen(window,'flip');
        sTime = GetSecs;
        time = 0;
        while (time < fixtime &&((e.gx(eye) >= opt1.location(1)-winsize) && (e.gx(eye) <= opt1.location(1)+winsize) && (e.gy(eye)>=opt1.location(2)-winsize) && (e.gy(eye) <= opt1.location(2)+winsize)));
            e=Eyelink('newestfloatsample');
            time = GetSecs - sTime;
        end
        if (time > fixtime) continuing = 0; a = 1; end
    end
    if (isfield(opt2,'type') && (e.gx(eye) >= opt2.location(1)-winsize) && (e.gx(eye) <= opt2.location(1)+winsize) && (e.gy(eye)>=opt2.location(2)-winsize) && (e.gy(eye) <= opt2.location(2)+winsize));
        makeStim(opt1, colour, size, 0, 0);
        if(isfield(opt2,'type')) makeStim(opt2, colour, size, 1, 0);end
        Screen(window,'flip');
        sTime = GetSecs;
        time = 0;
        while (time < fixtime &&((e.gx(eye) >= opt2.location(1)-winsize) && (e.gx(eye) <= opt2.location(1)+winsize) && (e.gy(eye)>=opt2.location(2)-winsize) && (e.gy(eye) <= opt2.location(2)+winsize)));
            e=Eyelink('newestfloatsample');
            time = GetSecs - sTime;
        end
        if (time > fixtime) 
            continuing = 0; 
            a = 2; 
        end
    end
    if (isfield(opt2,'type') && GetSecs-trialTime > trialBreakTime && continuing)
        continuing = 0; a = -1;
    end
end
end

function key = keyCheck
global pause;
KbName('UnifyKeyNames'); 
stopkey=KbName('ESCAPE');
juicekey=KbName('space');
pausekey=KbName('RightControl');
key.pressed = 0;
key.escape = 0;
key.juice = 0;
key.pause = 0;
[~,~,keyCode] = KbCheck;
if keyCode(stopkey)
    key.escape = 1;
    key.pressed = 1;
end
if keyCode(juicekey)
    key.juice = 1;
    key.pressed = 1;
    reward(0.14);
end
if keyCode(pausekey)
    key.pause = 1;
    key.pressed = 1;
    if(pause == 0)
        pause = 1;
    end
end
end

function k = pauseComm
global pause;
disp('Paused');
k = keyCheck;
while (pause == 1) && ~k.escape
    k = keyCheck;
    while k.pressed
        k = keyCheck;
    end
    while ~k.pressed
        k = keyCheck;
    end
    if k.pause || k.escape
        pause = -1;
        while k.pressed && k.pause
            k = keyCheck;
        end
    end
end
pause = 0;
end
