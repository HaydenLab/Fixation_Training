%MAM, TB, CES 10/27/2011

%Calibration program for monkey using eyelink


  % The right and left arrow do not work in this program as we need them to
  % do 12/6/2011
  
function OneCalibration3()
clear all
global s;

KbName('UnifyKeyNames');

%Variables that can/should be changed according to training
        
home
% HideCursor; 
%% Psychtoolbox & Screen Setup
		screens             = Screen( 'Screens' ); % Initialize the Screen
		visual_opt.screen   = max( screens ); % median(screens);  % select what screen to use (not needed when using Eyelink)
%This hides the Psychtoolbox startup Screen

oldEnableFlag = Screen('Preference', 'VisualDebugLevel', 0);% warning('off','MATLAB:dispatcher:InexactCaseMatch')
oldLevel = Screen('Preference', 'Verbosity', 0);%Hides PTB Warnings
window = Screen('OpenWindow', 1, 0);
Screen('FillRect', window, [50 50 50]);
Screen(window,'flip');


if ~Eyelink('IsConnected')
    Eyelink('initialize');%connects to eyelink computer
end
Eyelink('startrecording');%turns on the recording of eye position
Eyelink('command','screen_pixel_coords = %ld %ld %ld %ld', 0, 0, 1920, 1080);
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
   
%Initialize juicer NI USB 6501
s = daq.createSession('ni');
addDigitalChannel(s,'Dev3','Port2/line0:1','OutputOnly'); 


fixmin = .1; %Fixation time min for reward
rewardmin = .12; %Reward duration range min
rewardmax = .12; %Reward duration range max
itimin = 2; %Intertrial range min
itimax = 2; %Intertrial range max
fblength = .5; %Feedback circle display length
flicker = 1;%Dot is flickering  DOES THIS EVEN WORK??
fixboxon = 1; %Box around dot when fixating
largecolor = [255 0 0];
smallcolor = [255 0 0];
hertz = 3; %Hertz of flicker  
radius = 25;        %Radius of dots
maincolor = [255 0 0]; %Main color of dot
offcolor = [255 0 0]; %Off color of dot for flicker
feedbackcolor = [128 255 128]; %Color of feedback circle
targX = 960; %X cord. of first dot
targY = 540; %Y cord. of first dot
height = 550; %Height of window for reward
width = 550; %Width of window for reward
elapsedtimestart = (GetSecs);
eye = 1;  %1= left 2=right

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
flick = 1;
feedback = 0;
between = 0;
fixating = 0;
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
        if(flicker ~= 1 && feedback==0)
            if(fixating == 1 && fixboxon ~= 0)
                if(LorS > .5)
                    Screen('FillOval', window, largecolor, [(targX-radius) (targY-radius) (targX+radius) (targY+radius)]);
                    rewardduration = rewardmax;
                else
                    Screen('FillOval', window, smallcolor, [(targX-radius) (targY-radius) (targX+radius) (targY+radius)]);
                    rewardduration = rewardmin;
                end
            else
                Screen('FillOval', window, maincolor, [(targX-radius) (targY-radius) (targX+radius) (targY+radius)]);
            end
            Screen(window,'flip');
        elseif(flick == 1 && feedback==0)
            if(GetSecs > (time + (1/hertz)))
                flick = 0;
                if(fixating == 1 && fixboxon ~= 0)
                    if(LorS > .5)
                        Screen('FillOval', window, largecolor, [(targX-radius) (targY-radius) (targX+radius) (targY+radius)]);
                        rewardduration = rewardmax;
                    else
                        Screen('FillOval', window, smallcolor, [(targX-radius) (targY-radius) (targX+radius) (targY+radius)]);
                        rewardduration = rewardmin;
                    end
                else
                    Screen('FillOval', window, maincolor, [(targX-radius) (targY-radius) (targX+radius) (targY+radius)]);
                end
                Screen(window,'flip');
                time = GetSecs;
            else
                if(fixating == 1 && fixboxon ~= 0)
                    if(LorS > .5)
                        Screen('FillOval', window, largecolor, [(targX-radius) (targY-radius) (targX+radius) (targY+radius)]);
                        rewardduration = rewardmax;
                    else
                        Screen('FillOval', window, smallcolor, [(targX-radius) (targY-radius) (targX+radius) (targY+radius)]);
                        rewardduration = rewardmin;
                    end
                else
                    Screen('FillOval', window, offcolor, [(targX-radius) (targY-radius) (targX+radius) (targY+radius)]);
                end
                Screen(window,'flip');
            end
        elseif(flick == 0 && feedback==0)
            if(GetSecs > (time + (1/hertz)))    
                flick = 1;
                if(fixating == 1 && fixboxon ~= 0)
                    if(LorS > .5)
                        Screen('FillOval', window, largecolor, [(targX-radius) (targY-radius) (targX+radius) (targY+radius)]);
                        rewardduration = rewardmax;
                    else
                        Screen('FillOval', window, smallcolor, [(targX-radius) (targY-radius) (targX+radius) (targY+radius)]);
                        rewardduration = rewardmin;
                    end
                else
                    Screen('FillOval', window, offcolor, [(targX-radius) (targY-radius) (targX+radius) (targY+radius)]);
                end
                Screen(window,'flip');
                time = GetSecs;
            else
                if(fixating == 1 && fixboxon ~= 0)
                    if(LorS > .5)
                        Screen('FillOval', window, largecolor, [(targX-radius) (targY-radius) (targX+radius) (targY+radius)]);
                        rewardduration = rewardmax;
                    else
                        Screen('FillOval', window, smallcolor, [(targX-radius) (targY-radius) (targX+radius) (targY+radius)]);
                        rewardduration = rewardmin;
                    end
                else
                    Screen('FillOval', window, maincolor, [(targX-radius) (targY-radius) (targX+radius) (targY+radius)]);
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
        reward_digital_Juicer1(rewardmax) ;
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
                LorS = rand;
                fixtime = GetSecs;
                fixating = 1;
            elseif((fixating == 1) && (GetSecs > (fixmin + fixtime))) %**** Replace with check for pupil
                reward_digital_Juicer1(rewardduration);
                Screen('FillOval', window, feedbackcolor, [(targX-20) (targY-20) (targX+20) (targY+20)]);
                Screen(window,'flip');
                fbtime = GetSecs;
                feedback = 1;
                trial = trial + 1;
                home;
                disp(['Fixation Dot #' num2str(trial)]);
                %targX = (rand() * 624) + 200;
                %targY = (rand() * 468) + 150;
                fixating = 0;
                elapsedtimetotal = roundn(((GetSecs-elapsedtimestart)/60),-1);
                disp(['Elapsed Time:' num2str(elapsedtimetotal) ' minutes']);
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
Eyelink('stoprecording');
sca;
end

function a = keyCapture()
stopkey=KbName('ESCAPE');
pause=KbName('RightControl');
reward_digital_Juicer1=KbName('space');
[keyIsDown,secs,keyCode] = KbCheck;
if keyCode(stopkey)
    a = -1;
elseif keyCode(reward_digital_Juicer1)
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

function manualReward
global vars; global s;
[keyIsDown,~,keyCode] = KbCheck;

if keyCode(KbName('UpArrow'))
    disp('Maual Reward with Duration in Sec:')
    disp(vars.maualRwd)
    reward_digital_Juicer1(vars.maualRwd);
    WaitSecs(0.2);
end
end

function reward_digital_Juicer1(rewardDuration)%MAM 20170206
%Changed by MAM 20160707 to use with Sesison-based Interface 
%This function is to be used with the NI USB 6501 card.
%Pin 17/P0.0 (Juicer 1) and 25/GND(ground)
%Pin 18/P0.1 (Juicer 2) and 26/GND(ground)
warning('off','all');
% rewardDuration = 1;
%%%Move this into the running code so it initializes when you start the
%%%program.  The addline command will also turn on strobing capability.
%%%
s = daq.createSession('ni');
addDigitalChannel(s,'Dev3','Port2/line0:1','OutputOnly'); 

% outputSingleScan(s,[1 0 0 0])= juicer1 
% outputSingleScan(s,[0 1 0 0])= juicer2
% outputSingleScan(s,[0 0 1 0])= juicer3
% outputSingleScan(s,[0 0 0 1])= juicer4
outputSingleScan(s,[1 0 0 0]);
tic;
while toc < rewardDuration;
end
outputSingleScan(s,[0 0 0 0]);

pause(0.001);


end