%CES, MAM, TB 11/23/2011


function TrainingTwoRect(initcell)

%Variables that can/should be changed according to training
blocksize = 1; %Block Size
rewardmin = 0; %Small reward duration
rewardmax = .12; %Large reward duration
radius = 10; %Radius of fixation dot
fixmin = 1; %Fixation time min for reward
fixminbox = 0.2; %Fixation time min for reward

movedist = 250; %Rectangles' distance from center
itimin = 2; %Intertrial range min
itimax = 2; %Intertrial range max
initrecttime = 1; %Time with rects on before fixation dot appears
fblength = .5; %Feedback circle display length
width = 80; %Width of rects
height = 300; %Height of rects
fixbox = 5; % Thickness of rect fixation cue
windheight = 200; %Height of fixation window
windwidth = 200; %Width of fixation window
dispwind = 0; %Show fixation window
disprisky = 0; % Set to 1 to display % risky choices

largecolor = [0 0 255]; %Large reward color
medcolor = [100 100 100]; %Medium reward color
smallcolor = [255 0 0]; %Small reward color
fixcuecolor = [255 255 255]; %Rect fixation cue color
backcolor = [50 50 50]; %Background color
maincolor = [255 255 0]; %Color of fixation dot
feedbackcolor = [128 255 128]; %Color of feedback circle
eye = 1;

%initcell is monkey initial and cell letter, e.g. 'GA' for George, cell A
%if there is no cell just input the initial, e.g. 'G'
cd /Data/Training;
dateS = datestr(now, 'yymmdd');
initial = initcell(1);
if(numel(initcell) == 1)
    cell = '';
else
    cell = initcell(2);
end
filename = [initial dateS '.' cell '1.TR.mat'];
foldername = [initial dateS];
warning off all;
try
    mkdir(foldername)
end
warning on all;
cd(foldername)
trynum = 1;
while(trynum ~= 0)
    if(exist(filename)~=0)
        trynum = trynum +1;
        filename = [initial dateS '.' cell num2str(trynum) '.TR.mat'];
    else
        savename = [initial dateS '.' cell num2str(trynum) '.TR.mat'];
        trynum = 0;
    end
end
        
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

Screen('FillRect', window, backcolor);
Screen(window,'flip');
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
trialinblk = 1;
home
if(continuing == 1)
    disp(['Trial #' num2str(trial)]);
end
targX = 512;
targY = 384;
xmin = targX - (windwidth / 2);
xmax = targX + (windwidth / 2);
ymin = targY - (windheight / 2);
ymax = targY + (windheight / 2);
Lxmin = (targX-movedist) - (width / 2);
Lxmax = (targX-movedist) + (width / 2);
Rxmin = (targX+movedist) - (width / 2);
Rxmax = (targX+movedist) + (width / 2);
Wymin = targY - (height / 2);
Wymax = targY + (height / 2);
feedback = 0;
between = 0;
fixating = 0;
step = 1;
pause = 0;
fbtime = GetSecs - initrecttime;
gptime = 0;
rewarded = 0;
gambleoutcome = 0;
trialinblk = 0;
whichrects = randperm(4);
savecommand = ['save ' savename ' data'];
correct = 0;
possible = 0;
grey = 0;
gamble = 0;
pcent2graph(1) = 0;
while(continuing);
    y=0;
    if(between == 0 && feedback==0)
        if(step == 3)
            if(fixating == 1)
                screen('FillRect', window, fixcuecolor, [((targX-movedist)-((width/2)+fixbox)) (targY-((height/2)+fixbox)) ((targX-movedist)+((width/2)+fixbox)) (targY+((height/2)+fixbox))]);
            elseif(fixating == 2)
                screen('FillRect', window, fixcuecolor, [((targX+movedist)-((width/2)+fixbox)) (targY-((height/2)+fixbox)) ((targX+movedist)+((width/2)+fixbox)) (targY+((height/2)+fixbox))]);
            end
        end
        if(step == 2)
            if(dispwind == 1)
                screen('FillRect', window, [0 255 0], [(xmin) (ymin) (xmax) (ymax)]);
                screen('FillRect', window, [0 0 0], [(xmin+5) (ymin+5) (xmax-5) (ymax-5)]);
            end
            screen('FillOval', window, maincolor, [(targX-radius) (targY-radius) (targX+radius) (targY+radius)]);
        else
            if(whichrects(1) == 1) %Left rectangles
                screen('FillRect', window, largecolor, [((targX-movedist)-(width/2)) (targY-(height/2)) ((targX-movedist)+(width/2)) (targY+(height/2))]);
            elseif(whichrects(1) == 2)
                screen('FillRect', window, smallcolor, [((targX-movedist)-(width/2)) (targY-(height/2)) ((targX-movedist)+(width/2)) (targY+(height/2))]);
            elseif(whichrects(1) == 3)
                screen('FillRect', window, medcolor, [((targX-movedist)-(width/2)) (targY-(height/2)) ((targX-movedist)+(width/2)) (targY+(height/2))]);
            elseif(whichrects(1) == 4)
                screen('FillRect', window, largecolor, [((targX-movedist)-(width/2)) (targY-(height/2)) ((targX-movedist)+(width/2)) (targY)]);
                screen('FillRect', window, smallcolor, [((targX-movedist)-(width/2)) (targY) ((targX-movedist)+(width/2)) (targY+(height/2))]);
            end
            if(whichrects(2) == 1) %Right rectangles
                screen('FillRect', window, largecolor, [((targX+movedist)-(width/2)) (targY-(height/2)) ((targX+movedist)+(width/2)) (targY+(height/2))]);
            elseif(whichrects(2) == 2)
                screen('FillRect', window, smallcolor, [((targX+movedist)-(width/2)) (targY-(height/2)) ((targX+movedist)+(width/2)) (targY+(height/2))]);
            elseif(whichrects(2) == 3)
                screen('FillRect', window, medcolor, [((targX+movedist)-(width/2)) (targY-(height/2)) ((targX+movedist)+(width/2)) (targY+(height/2))]);
            elseif(whichrects(2) == 4)
                screen('FillRect', window, largecolor, [((targX+movedist)-(width/2)) (targY-(height/2)) ((targX+movedist)+(width/2)) (targY)]);
                screen('FillRect', window, smallcolor, [((targX+movedist)-(width/2)) (targY) ((targX+movedist)+(width/2)) (targY+(height/2))]);
            end
        end
        Screen(window,'flip');
    end
    comm=keyCapture();
    if(comm==-1) % ESC stops the calibration
        continuing=0;
    end
    if(comm==1) % Space rewards monkey
        reward(rewardmax);
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
    if(between == 0 && feedback == 0)
        if(step == 2)
            if(((xmin < e.gx(eye)) && (e.gx(eye) < xmax)) && ((ymin < e.gy(eye)) && (e.gy(eye) < ymax))) %If gaze is in box around center
                if(fixating == 0)
                    fixtime = GetSecs;
                    fixating = 1;
                elseif((fixating == 1) && (GetSecs > (fixmin + fixtime))) %
                    step = 3;
                    gptime = GetSecs;
                    fixating = 0;
                end
            elseif(fixating == 1)
                fixating = 0;
            end
        elseif(step == 3)
            if(((Lxmin < e.gx(eye)) && (e.gx(eye) < Lxmax)) && ((Wymin < e.gy(eye)) && (e.gy(eye) < Wymax))) %If gaze is in box around LEFT
                if(fixating == 0)
                    fixtime = GetSecs;
                    fixating = 1;
                elseif((fixating == 1) && (GetSecs > (fixminbox + fixtime))) %
                    if(whichrects(1) == 1)
                        reward(rewardmax);
                    elseif(whichrects(1) == 2)
                        reward(rewardmin);
                    elseif(whichrects(1) == 3)
                        reward((rewardmax+rewardmin)/2);
                    elseif(whichrects(1) == 4)
                        if(rand > 0.5)
                            reward(rewardmax);
                            gambleoutcome = 2;
                        else
                            reward(rewardmin);
                            gambleoutcome = 1;
                        end
                    end
                    screen('FillRect', window, fixcuecolor, [((targX-movedist)-((width/2)+fixbox)) (targY-((height/2)+fixbox)) ((targX-movedist)+((width/2)+fixbox)) (targY+((height/2)+fixbox))]);
                    if((gambleoutcome == 2) || (whichrects(1) == 1))
                        screen('FillRect', window, largecolor, [((targX-movedist)-(width/2)) (targY-(height/2)) ((targX-movedist)+(width/2)) (targY+(height/2))]);
                        screen('FillOval', window, feedbackcolor, [((targX-movedist)-25) (targY-25) ((targX-movedist)+25) (targY+25)]);
                    elseif((gambleoutcome == 1) || (whichrects(1) == 2))
                        screen('FillRect', window, smallcolor, [((targX-movedist)-(width/2)) (targY-(height/2)) ((targX-movedist)+(width/2)) (targY+(height/2))]);
                    elseif(whichrects(1) == 3)
                        screen('FillRect', window, medcolor, [((targX-movedist)-(width/2)) (targY-(height/2)) ((targX-movedist)+(width/2)) (targY+(height/2))]);
                        screen('FillOval', window, feedbackcolor, [((targX-movedist)-25) (targY-25) ((targX-movedist)+25) (targY+25)]);
                    end
                    rewarded = 1;
                end
            elseif(fixating == 1)
                fixating = 0;
            end
            if(((Rxmin < e.gx(eye)) && (e.gx(eye) < Rxmax)) && ((Wymin < e.gy(eye)) && (e.gy(eye) < Wymax))) %If gaze is in box around RIGHT
                if(fixating == 0)
                    fixtime = GetSecs;
                    fixating = 2;
                elseif((fixating == 2) && (GetSecs > (fixminbox + fixtime))) %
                    if(whichrects(2) == 1)
                        reward(rewardmax);
                    elseif(whichrects(2) == 2)
                        reward(rewardmin);
                    elseif(whichrects(2) == 3)
                        reward((rewardmax+rewardmin)/2);
                    elseif(whichrects(2) == 4)
                        if(rand > 0.5)
                            reward(rewardmax);
                            gambleoutcome = 2;
                        else
                            reward(rewardmin);
                            gambleoutcome = 1;
                        end
                    end
                    screen('FillRect', window, fixcuecolor, [((targX+movedist)-((width/2)+fixbox)) (targY-((height/2)+fixbox)) ((targX+movedist)+((width/2)+fixbox)) (targY+((height/2)+fixbox))]);
                    if((gambleoutcome == 2) || (whichrects(2) == 1))
                        screen('FillRect', window, largecolor, [((targX+movedist)-(width/2)) (targY-(height/2)) ((targX+movedist)+(width/2)) (targY+(height/2))]);
                        screen('FillOval', window, feedbackcolor, [((targX+movedist)-25) (targY-25) ((targX+movedist)+25) (targY+25)]);
                    elseif((gambleoutcome == 1) || (whichrects(2) == 2))
                        screen('FillRect', window, smallcolor, [((targX+movedist)-(width/2)) (targY-(height/2)) ((targX+movedist)+(width/2)) (targY+(height/2))]);
                    elseif(whichrects(2) == 3)
                        screen('FillRect', window, medcolor, [((targX+movedist)-(width/2)) (targY-(height/2)) ((targX+movedist)+(width/2)) (targY+(height/2))]);
                        screen('FillOval', window, feedbackcolor, [((targX+movedist)-25) (targY-25) ((targX+movedist)+25) (targY+25)]);
                    end
                    rewarded = 2;
                end
            elseif(fixating == 2)
                fixating = 0;
            end
        end
    end
    comm = 0;
    if(feedback==1 && GetSecs > (fbtime + fblength))
        feedback = 0;
        between = 1;
        Screen(window,'flip');
    elseif((between==1 && GetSecs > (fbtime + fblength + iti)) && (pause == 0))
        between = 0;
    elseif((between==0 && GetSecs > (fbtime + fblength + iti + initrecttime)) && (pause == 0) && (step == 1))
        step = 2;
    end
    if(rewarded ~= 0) %If he just completed a trial, save data
        Screen(window,'flip');
        fbtime = GetSecs;
        feedback = 1;
        if(rewarded == 1)
            data(trial).choice = 1; %1=Left
        else
            data(trial).choice = 0; %2=Right
        end
        data(trial).left = whichrects(1); %1=B, 2=R, 3=G, 4=B/R
        data(trial).right = whichrects(2);
        data(trial).gambleoutcome = gambleoutcome; %2=B, 1=R
        data(trial).blocksize = blocksize; %Block Size
        data(trial).rewardmin = rewardmin; %Small reward duration
        data(trial).rewardmax = rewardmax;
        data(trial).reactiontime = (GetSecs - gptime);
        eval(savecommand);
        %Print % correct for each trial
        if ((data(trial).left == 1) || (data(trial).right == 1)) %if either side is blue, monkey should have picked that sideS
            possible = possible + 1; %This is a chance for the monkey to get something right
            if ((data(trial).left == 1 && data(trial).choice == 1) || (data(trial).right == 1 && data(trial).choice == 0))
                correct = correct + 1; %The monkey chose blue - correct!
            end
        elseif (data(trial).left == 2 || data(trial).right == 2) %If either is red, monkey shouldn't pick it
            possible = possible + 1;
            if ((data(trial).left == 2 && data(trial).choice == 0) || (data(trial).right == 2 && data(trial).choice == 1))
                correct = correct + 1;
            end
        elseif ((data(trial).left == 3 && data(trial).choice == 0) || (data(trial).right == 3 && data(trial).choice == 1)) %monkey chose grey over gamble
            grey = grey + 1;
        else
            gamble = gamble + 1;
        end
        if(possible ~= 0)
            disp(sprintf('Correct: %3.1f%%', (100*correct/possible)));
        else
            disp('(All gambles vs. grey)');
        end
        if((gamble+grey)~=0 && disprisky == 1)
            disp(sprintf('Risky choices: %3.1f%%', (100*grey/(gamble+grey))));
        end
        pcent2graph(trial) = (100*correct/possible);
        trial = trial + 1;
        trialinblk = trialinblk +1;
        if(trialinblk > blocksize)
            whichrects = randperm(4);
            trialinblk = 1;
        elseif(rand > 0.5)
            holdvar = whichrects(1);
            whichrects(1) = whichrects(2);
            whichrects(2) = holdvar;
        end
        disp(' ');
        disp(['Trial #' num2str(trial)]);
        step = 1;
        fixating = 0;
        rewarded = 0;
        gambleoutcome = 0;
    end
end
if(length(pcent2graph) > 1)
    plot(pcent2graph);
end
Eyelink('stoprecording');
sca;
%keyboard
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
disp(sprintf('Reward time: %4.2fs', rewardduration));
if(rewardduration ~= 0)
    DaqAOut(daq,0,.6);
    starttime=getsecs;
    while (getsecs-starttime)<(rewardduration);
    end;
    DaqAOut(daq,0,0);
    StopJuicer;
end
end