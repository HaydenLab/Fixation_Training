%MAM, TB, CES 10/27/2011

%Calibration program for monkey using eyelink
%we need to somehow make sure that the fixation points are within the
%resolution of the eyelink (1024X768??). Monitor resolution is set to %1024x768.
%if we want to go out beyond resolution, then we need to tell the eyelink.

function TrainingBigJump()
clear all

%Variables that can/should be changed according to training
        
home
HideCursor; %This hides the Psychtoolbox startup screen
oldEnableFlag = Screen('Preference', 'VisualDebugLevel', 0);% warning('off','MATLAB:dispatcher:InexactCaseMatch')
oldLevel = Screen('Preference', 'Verbosity', 0);%Hides PTB Warnings
window = Screen('OpenWindow', 1, 0);

if ~Eyelink('IsConnected')
    Eyelink('initialize');%connects to eyelink computer
end
Eyelink('startrecording');%turns on the recording of eye position
Eyelink('Command', 'calibration_type = HV5');
Eyelink('Command', 'randomize_calibration_order = NO');
Eyelink('Command', 'force_manual_accept = YES');
Eyelink('StartSetup');
% Wait until Eyelink actually enters Setup mode:
trackerResp = true;
while trackerResp && Eyelink('CurrentMode')~=2 % Mode 2 is setup mode
    % Let the user abort with ESCAPE
    [keyIsDown,secs,keyCode] = KbCheck;
    if keyIsDown && keyCode(KbName('ESCAPE'))
        disp('Aborted while waiting for Eyelink!');
        trackerResp = false;
    end
end
% Send the keypress 'o' to put Eyelink in output mode
Eyelink('SendKeyButton',double('o'),0,10);
Eyelink('SendKeyButton',double('o'),0,10);

fixationmin = 1; %Fixation time min for reward
movedist = 20; %Distance dot moves
rewardmin = .1; %Reward duration range min
rewardmax = .16; %Reward duration range max
itimin = 1; %Intertrial range min
itimax = 2; %Intertrial range max
fblength = .5; %Feedback circle display length
flicker = 0; %Dot is flickering
fixboxon = 1; %Box around dot when fixating
largecolor = [0 0 255];
smallcolor = [255 0 0];
hertz = 10; %Hertz of flicker
radius = 10; %Radius of dots
maincolor = [255 255 0]; %Main color of dot
offcolor = [0 255 0]; %Off color of dot for flicker
feedbackcolor = [128 255 128]; %Color of feedback circle
targX = 512; %X cord. of first dot
targY = 384; %Y cord. of first dot
height = 250; %Height of window for reward
width = 250; %Width of window for reward
dispwind = 0; %Show fixation window
eye = 1;

iti = ((itimax-itimin) * rand) + itimin;
continuing = 1;
go = 0;
disp('Right Arrow to start');
gokey=KbName('RightArrow');
nokey=KbName('ESCAPE');
while((go == 0) && (continuing == 1))
    [keyIsDown,secs,keyCode] = KbCheck;
    if keyCode(gokey)
        go = 1;
    elseif keyCode(nokey)
        continuing = 0;
    end
end
while keyIsDown
    [keyIsDown,secs,keyCode] = KbCheck;
end

trial = 1;
if(continuing == 1)
    disp(['Fixation Dot #' num2str(trial)]);
end
time = GetSecs;
fixmin = fixationmin / 2;
flick = 1;
feedback = 0;
between = 0;
fixating = 0;
moved = 0;
pause = 0;
fbtime = 0;
LorS = rand;
while(continuing);
    xmin = targX - (width / 2);
    xmax = targX + (width / 2);
    ymin = targY - (height / 2);
    ymax = targY + (height / 2);
    y=0;
    if(between == 0)
        if(dispwind == 1 && feedback == 0)
            screen('FillRect', window, [0 255 0], [(xmin) (ymin) (xmax) (ymax)]);
            screen('FillRect', window, [0 0 0], [(xmin+5) (ymin+5) (xmax-5) (ymax-5)]);
        end
        if(flicker ~= 1 && feedback==0)
            if(fixating == 1 && fixboxon ~= 0)
                if(LorS > .5)
                    screen('FillOval', window, largecolor, [(targX-radius) (targY-radius) (targX+radius) (targY+radius)]);
                    rewardduration = rewardmax;
                else
                    screen('FillOval', window, smallcolor, [(targX-radius) (targY-radius) (targX+radius) (targY+radius)]);
                    rewardduration = rewardmin;
                end
            else
                screen('FillOval', window, maincolor, [(targX-radius) (targY-radius) (targX+radius) (targY+radius)]);
            end
            Screen(window,'flip');
        elseif(flick == 1 && feedback==0)
            if(GetSecs > (time + (1/hertz)))
                flick = 0;
                if(fixating == 1 && fixboxon ~= 0)
                    if(LorS > .5)
                        screen('FillOval', window, largecolor, [(targX-radius) (targY-radius) (targX+radius) (targY+radius)]);
                        rewardduration = rewardmax;
                    else
                        screen('FillOval', window, smallcolor, [(targX-radius) (targY-radius) (targX+radius) (targY+radius)]);
                        rewardduration = rewardmin;
                    end
                else
                    screen('FillOval', window, maincolor, [(targX-radius) (targY-radius) (targX+radius) (targY+radius)]);
                end
                Screen(window,'flip');
                time = GetSecs;
            else
                if(fixating == 1 && fixboxon ~= 0)
                    if(LorS > .5)
                        screen('FillOval', window, largecolor, [(targX-radius) (targY-radius) (targX+radius) (targY+radius)]);
                        rewardduration = rewardmax;
                    else
                        screen('FillOval', window, smallcolor, [(targX-radius) (targY-radius) (targX+radius) (targY+radius)]);
                        rewardduration = rewardmin;
                    end
                else
                    screen('FillOval', window, offcolor, [(targX-radius) (targY-radius) (targX+radius) (targY+radius)]);
                end
                Screen(window,'flip');
            end
        elseif(flick == 0 && feedback==0)
            if(GetSecs > (time + (1/hertz)))    
                flick = 1;
                if(fixating == 1 && fixboxon ~= 0)
                    if(LorS > .5)
                        screen('FillOval', window, largecolor, [(targX-radius) (targY-radius) (targX+radius) (targY+radius)]);
                        rewardduration = rewardmax;
                    else
                        screen('FillOval', window, smallcolor, [(targX-radius) (targY-radius) (targX+radius) (targY+radius)]);
                        rewardduration = rewardmin;
                    end
                else
                    screen('FillOval', window, offcolor, [(targX-radius) (targY-radius) (targX+radius) (targY+radius)]);
                end
                Screen(window,'flip');
                time = GetSecs;
            else
                if(fixating == 1 && fixboxon ~= 0)
                    if(LorS > .5)
                        screen('FillOval', window, largecolor, [(targX-radius) (targY-radius) (targX+radius) (targY+radius)]);
                        rewardduration = rewardmax;
                    else
                        screen('FillOval', window, smallcolor, [(targX-radius) (targY-radius) (targX+radius) (targY+radius)]);
                        rewardduration = rewardmin;
                    end
                else
                    screen('FillOval', window, maincolor, [(targX-radius) (targY-radius) (targX+radius) (targY+radius)]);
                end
                Screen(window,'flip');
            end
        end
    end
    comm=keyCapture();
    if(comm==-1) % ESC stops the calibration
        continuing=0;
    end
    if(comm==1) % Space rewards monkey
        reward(rewardduration);
    end
    if(comm==2) % Control pauses
        if(pause == 0)
            pause = 1;
            between = 1;
            Screen(window,'flip');
        else
            pause = 0;
        end
    end
    e = Eyelink('newestfloatsample');
    if(((xmin < e.gx(eye)) && (e.gx(eye) < xmax)) && ((ymin < e.gy(eye)) && (e.gy(eye) < ymax))) %If gaze is in box around center, reward and feedback circle
        if(between == 0 && feedback == 0)
            if (fixating == 0)
                if(moved == 0)
                    LorS = rand;
                end
                fixtime = GetSecs;
                fixating = 1;
            elseif((fixating == 1) && (GetSecs > (fixmin + fixtime))) %
                if(moved)
                    reward(rewardduration);
                    screen('FillOval', window, feedbackcolor, [(targX-25) (targY-25) (targX+25) (targY+25)]);
                    Screen(window,'flip');
                    fbtime = GetSecs;
                    feedback = 1;
                    trial = trial + 1;
                    disp(['Fixation Dot #' num2str(trial)]);
                    targX = 512; 
                    targY = 384;
                    moved = 0;
                    fixating = 0;
                else
                    if(rand > .5)
                        targX = targX + movedist;
                    else
                        targX = targX - movedist;
                    end
                    moved = 1;
                    if(movedist ~= 0)
                        fixating = 0;
                    end
                end
            end
        end
    elseif(fixating == 1)
        fixating = 0;
    end
    comm = 0;
    if(feedback==1 && GetSecs > (fbtime + fblength))
        feedback = 0;
        between = 1;
        Screen(window,'flip');
    elseif((between==1 && GetSecs > (fbtime + fblength + iti)) && (pause == 0))
        between = 0;
    end
    if(flicker == 1 && feedback==0)
        Screen(window,'flip');
    end
end
eyelink('stoprecording');
sca;
end

function a = keyCapture()
stopkey=KbName('ESCAPE');
pause=KbName('RightControl');
reward=KbName('space');
[keyIsDown,secs,keyCode] = KbCheck;
if keyCode(stopkey)
    a = -1;
elseif keyCode(reward)
    a = 1;
elseif keyCode(pause)
    a = 2;
else
    a = 0;
end
while keyIsDown
    [keyIsDown,secs,keyCode] = KbCheck;
end
end

function reward(rewardduration)

% 10/3/11  MAM
daq=DaqDeviceIndex;
DaqAOut(daq,0,.6);
starttime=getsecs;
disp([rewardduration]);
while (getsecs-starttime)<(rewardduration);
end;
DaqAOut(daq,0,0);
StopJuicer;
end