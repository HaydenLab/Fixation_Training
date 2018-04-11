%CES 12/2/2011

function Training4SplitDot(initcell)

%Variables that can/should be changed according to training
blocksize = 1; %Block Size
rewardmin = 0; %Small reward duration
rewardmed = .06; %Medium reward duration
rewardlarge = .18; %Large reward duration
rewardhuge = .19; %Large reward duration
radius = 10; %Radius of fixation dot
fixmin = 1; %Fixation time min for reward
fixminbox = 0.1; %Fixation time min for reward

firstrecttime = 0; %Time with 1st rect on
btwnrecttime = 0; %Time between rects
scndrecttime = 0; %Time with 2nd rect on
feedbacktime = .5; %Feedback circle display length
iti = 1.5; %Intertrial interval
eye = 2;

global movedist; movedist = 250; %Rectangles' distance from center
global width; width = 30; %Width of rects
global height; height = 30; %Height of rects
fixbox = 5; % Thickness of rect fixation cue
windheight = 200; %Height of fixation window
windwidth = 200; %Width of fixation window
dispwind = 0; %Show fixation window

global hugecolor; hugecolor = [0 255 0]; %Huge reward color
global largecolor; largecolor = [0 0 255]; %Large reward color
global medcolor; medcolor = [100 100 100]; %Medium reward color
global smallcolor; smallcolor = [255 0 0]; %Small reward color
fixcuecolor = [255 255 255]; %Rect fixation cue color
backcolor = [50 50 50]; %Background color
maincolor = [255 255 0]; %Color of fixation dot
feedbackcolor = [0 255 0]; %Color of feedback circle

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
filename = [initial dateS '.' cell '1.SD.mat'];
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
        filename = [initial dateS '.' cell num2str(trynum) '.SD.mat'];
    else
        savename = [initial dateS '.' cell num2str(trynum) '.SD.mat'];
        trynum = 0;
    end
end
        
home
HideCursor; %This hides the Psychtoolbox startup Screen
oldEnableFlag = Screen('Preference', 'VisualDebugLevel', 0);% warning('off','MATLAB:dispatcher:InexactCaseMatch')
oldLevel = Screen('Preference', 'Verbosity', 0);%Hides PTB Warnings
global window; window = Screen('OpenWindow', 1, 0);

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

%Count trials for the whole day
cd ..;
daystrials = 0;
thesefiles = dir(foldername);
cd(foldername);
fileIndex = find(~[thesefiles.isdir]);
for i = 1:length(fileIndex)
    thisfile = thesefiles(fileIndex(i)).name;
    thisdata = importdata(thisfile);
    daystrials = daystrials + length(thisdata);
end
%*****

trial = 1;
trialinblk = 1;
trialinbin = 1;
home
if(continuing == 1)
    disp(['Trial #' num2str(trial) '/' num2str(trial + daystrials)]);
end
global targX; targX = 512;
global targY; targY = 384;
xmin = targX - (windwidth / 2);
xmax = targX + (windwidth / 2);
ymin = targY - (windheight / 2);
ymax = targY + (windheight / 2);
Lxmin = (targX-movedist) - (windwidth / 2);
Lxmax = (targX-movedist) + (windwidth / 2);
Rxmin = (targX+movedist) - (windwidth / 2);
Rxmax = (targX+movedist) + (windwidth / 2);
Wymin = targY - (windheight / 2);
Wymax = targY + (windheight / 2);
fixating = 0;
step = 1;
pause = 0;
timeofchoice = GetSecs - (feedbacktime + iti);
reactiontime = 0;
rewarded = 0;
gambleoutcome = 0;
trialinblk = 0;
savecommand = ['save ' savename ' data'];
correct = 0;
possible = 0;
pcent2graph(1) = 0;
elapsedtimestart = (GetSecs);
if(rand > 0.5)
    leftLarge = 1;
else
    leftLarge = 0;
end

while(continuing);
    % Setting Screen*****************
    if(step == 4)
        if(dispwind == 1)
            Screen('FillRect', window, [0 255 0], [(xmin) (ymin) (xmax) (ymax)]);
            Screen('FillRect', window, [0 0 0], [(xmin+5) (ymin+5) (xmax-5) (ymax-5)]);
        end
        Screen('FillOval', window, maincolor, [(targX-radius) (targY-radius) (targX+radius) (targY+radius)]);
    elseif(step == 5)
        if(dispwind == 1)
            Screen('FillRect', window, [0 255 0], [(xmin-movedist) (ymin) (xmax-movedist) (ymax)]);
            Screen('FillRect', window, [0 0 0], [((xmin+5)-movedist) (ymin+5) ((xmax-5)-movedist) (ymax-5)]);
            Screen('FillRect', window, [0 255 0], [(xmin+movedist) (ymin) (xmax+movedist) (ymax)]);
            Screen('FillRect', window, [0 0 0], [((xmin+5)+movedist) (ymin+5) ((xmax-5)+movedist) (ymax-5)]);
        end
        if(fixating == 1)
            Screen('FillOval', window, fixcuecolor, [((targX-movedist)-((width/2)+fixbox)) (targY-((height/2)+fixbox)) ((targX-movedist)+((width/2)+fixbox)) (targY+((height/2)+fixbox))]);
        elseif(fixating == 2)
            Screen('FillOval', window, fixcuecolor, [((targX+movedist)-((width/2)+fixbox)) (targY-((height/2)+fixbox)) ((targX+movedist)+((width/2)+fixbox)) (targY+((height/2)+fixbox))]);
        end
        if(leftLarge == 1)
            Screen('FillOval', window, largecolor, [((targX-movedist)-(width/2)) (targY-(height/2)) ((targX-movedist)+(width/2)) (targY+(height/2))]);
        else
            Screen('FillOval', window, smallcolor, [((targX-movedist)-(width/2)) (targY-(height/2)) ((targX-movedist)+(width/2)) (targY+(height/2))]);
        end
        if(leftLarge == 0)
            Screen('FillOval', window, largecolor, [((targX+movedist)-(width/2)) (targY-(height/2)) ((targX+movedist)+(width/2)) (targY+(height/2))]);
        else
            Screen('FillOval', window, smallcolor, [((targX+movedist)-(width/2)) (targY-(height/2)) ((targX+movedist)+(width/2)) (targY+(height/2))]);
        end
    elseif(step == 6)
        if(rewarded == 1)
            Screen('FillOval', window, fixcuecolor, [((targX-movedist)-((width/2)+fixbox)) (targY-((height/2)+fixbox)) ((targX-movedist)+((width/2)+fixbox)) (targY+((height/2)+fixbox))]);
            if(gambleoutcome == 0)
                Screen('FillOval', window, [0 0 0], [((targX-movedist)-(width/2)) (targY-(height/2)) ((targX-movedist)+(width/2)) (targY+(height/2))]);
            else
                Screen('FillOval', window, feedbackcolor, [((targX-movedist)-(width/2)) (targY-(height/2)) ((targX-movedist)+(width/2)) (targY+(height/2))]);
            end
        elseif(rewarded == 2)
            Screen('FillOval', window, fixcuecolor, [((targX+movedist)-((width/2)+fixbox)) (targY-((height/2)+fixbox)) ((targX+movedist)+((width/2)+fixbox)) (targY+((height/2)+fixbox))]);
            if(gambleoutcome == 0)
                Screen('FillOval', window, [0 0 0], [((targX+movedist)-(width/2)) (targY-(height/2)) ((targX+movedist)+(width/2)) (targY+(height/2))]);
            else
                Screen('FillOval', window, feedbackcolor, [((targX+movedist)-(width/2)) (targY-(height/2)) ((targX+movedist)+(width/2)) (targY+(height/2))]);
            end
        end
    end
    Screen(window,'flip');
    
    % Check eye position*****************
    e = Eyelink('newestfloatsample');
    if(step == 4)
        if(((xmin < e.gx(eye)) && (e.gx(eye) < xmax)) && ((ymin < e.gy(eye)) && (e.gy(eye) < ymax))) %Gaze is in box around center
            if(fixating == 0)
                fixtime = GetSecs;
                fixating = 1;
            elseif((fixating == 1) && (GetSecs > (fixmin + fixtime))) 
                step = 5;
                reactiontime = GetSecs;
                fixating = 0;
            end
        elseif(fixating == 1)
            fixating = 0;
        end
    elseif(step == 5)
        if(((Lxmin < e.gx(eye)) && (e.gx(eye) < Lxmax)) && ((Wymin < e.gy(eye)) && (e.gy(eye) < Wymax))) %Gaze is in box around LEFT
            if(fixating == 0)
                fixtime = GetSecs;
                fixating = 1;
            elseif((fixating == 1) && (GetSecs > (fixminbox + fixtime))) %
                if(leftLarge == 1)
                    gambleoutcome = 2;
                    reward(rewardlarge);
                else
                    reward(rewardmin);
                    gambleoutcome = 0;
                end
                rewarded = 1;
            end
        elseif(fixating == 1)
            fixating = 0;
        end
        if(((Rxmin < e.gx(eye)) && (e.gx(eye) < Rxmax)) && ((Wymin < e.gy(eye)) && (e.gy(eye) < Wymax))) %Gaze is in box around RIGHT
            if(fixating == 0)
                fixtime = GetSecs;
                fixating = 2;
            elseif((fixating == 2) && (GetSecs > (fixminbox + fixtime))) %
                if(leftLarge == 0)
                    gambleoutcome = 2;
                    reward(rewardlarge);
                else
                    reward(rewardmin);
                    gambleoutcome = 0;
                end
                rewarded = 2;
            end
        elseif(fixating == 2)
            fixating = 0;
        end
    end
    
    % Watch for keyboard interaction*****************
    comm=keyCapture();
    if(comm==-1) % ESC stops the calibration
        continuing=0;
    end
    if(comm==1) % Space rewards monkey
        reward(rewardlarge);
    end
    if(comm==2) % Control pauses
        if(pause == 0)
            pause = 1;
        else
            pause = 0;
        end
    end
    comm = 0;
    
    % Progress between steps*****************
    if(step == 6 && GetSecs > (timeofchoice + feedbacktime))
        step = 7;
        rewarded = 0;
        gambleoutcome = 0;
    elseif((step == 7 && GetSecs > (timeofchoice + feedbacktime + iti)) && (pause == 0))
        disp(' ');
        home
        disp(['Trial #' num2str(trial) '/' num2str(trial + daystrials)]);
        elapsedtimetotal = roundn(((getsecs-elapsedtimestart)/60),-1);
        disp(sprintf('Elapsed Time: %3.0f minutes', elapsedtimetotal));
        step = 1;
    elseif((step == 1 && GetSecs > (timeofchoice + feedbacktime + iti + firstrecttime)))
        step = 2;
    elseif((step == 2 && GetSecs > (timeofchoice + feedbacktime + iti + firstrecttime + btwnrecttime)))
        step = 3;
    elseif((step == 3 && GetSecs > (timeofchoice + feedbacktime + iti + firstrecttime + btwnrecttime + scndrecttime)))
        step = 4;
    end
    if(rewarded ~= 0 && step == 5)
        step = 6;
        timeofchoice = GetSecs;
        fixating = 0;
        
        %Safe data to file
        if(rewarded == 1)
            data(trial).choice = 1; %1=Left
        else
            data(trial).choice = 0; %2=Right
        end
        data(trial).gambleoutcome = gambleoutcome; %2=Win, 0=Lose
        data(trial).blocksize = blocksize; %Block Size
        data(trial).rewardmin = rewardmin; %Small reward duration
        data(trial).rewardmed = rewardmed;
        data(trial).rewardlarge = rewardlarge;
        data(trial).rewardhuge = rewardhuge;
        data(trial).reactiontime = (GetSecs - reactiontime);
        eval(savecommand);
        
        %Print % correct for each trial
        possible = possible + 1;
        if (((leftLarge == 1) && (data(trial).choice == 1)) || ((leftLarge == 0) && (data(trial).choice == 0))) 
            correct = correct + 1;
        end
        if(possible ~= 0)
            disp(sprintf('Correct: %3.2f%%', (100*correct/possible)));
        end
        if(trialinblk > blocksize)
            if(rand > 0.5)
                leftLarge = 1;
            else
                leftLarge = 0;
            end
            trialinblk = 1;
        end
        
        trial = trial + 1;
        trialinblk = trialinblk + 1;
        trialinbin = trialinbin + 1;
        pcent2graph(trial) = (100*correct/possible);
    end
end
if(length(pcent2graph) > 1)
    plot(pcent2graph);
end
Eyelink('stoprecording');
sca;
%keyboard
end

function f = createGamble(pcentBlue, side, isHuge)
global hugecolor;
global largecolor;
global smallcolor;
global targX;
global targY;
global window;
global movedist;
global height;
global width;
if(side == 1)
    Screen('FillRect', window, smallcolor, [((targX-movedist)-(width/2)) (targY-(height/2)) ((targX-movedist)+(width/2)) (targY+(height/2))]);
    if(isHuge == 1)
        Screen('FillRect', window, hugecolor, [((targX-movedist)-(width/2)) (targY-(height/2)) ((targX-movedist)+(width/2)) ((targY-(height/2)) + (pcentBlue * height))]);
    else
        Screen('FillRect', window, largecolor, [((targX-movedist)-(width/2)) (targY-(height/2)) ((targX-movedist)+(width/2)) ((targY-(height/2)) + (pcentBlue * height))]);
    end
else
    Screen('FillRect', window, smallcolor, [((targX+movedist)-(width/2)) (targY-(height/2)) ((targX+movedist)+(width/2)) (targY+(height/2))]);
    if(isHuge == 1)
		Screen('FillRect', window, hugecolor, [((targX+movedist)-(width/2)) (targY-(height/2)) ((targX+movedist)+(width/2)) ((targY-(height/2)) + (pcentBlue * height))]);
    else
        Screen('FillRect', window, largecolor, [((targX+movedist)-(width/2)) (targY-(height/2)) ((targX+movedist)+(width/2)) ((targY-(height/2)) + (pcentBlue * height))]);
    end
end
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
daq=DaqDeviceIndex;
disp(sprintf('Reward time: %4.2fs', rewardduration));
if(rewardduration ~= 0)
    DaqAOut(daq,0,.6);
    starttime=GetSecs;
    while (GetSecs-starttime)<(rewardduration);
    end;
    DaqAOut(daq,0,0);
    StopJuicer;
end
end