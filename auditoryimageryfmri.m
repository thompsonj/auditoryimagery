function auditoryimageryfmri

%---PARAMETERS---%
    debug=0
    %counters
        prun = 0;
    % Setup display:
        KbName('UnifyKeyNames');
        escapeKey = KbName('ESCAPE');
        TriggerKey = KbName('space');
        one = 30;KbName('1');
        two = 31;KbName('2');
        three = 32;KbName('3');
        four = 33;KbName('4');
    %response heys
        cKey = {'y','n'};
        key_y = KbName(cKey{1});
        key_n = KbName(cKey{2});
    %order
        order = load('scaleorder24.mat');
    %audio info
        nrchannels = 2;
        startsignal = 1200;
        freq=44100;  
        reqlatencyclass = 2;
        buffersize = 0;     % Pointless to set this. Auto-selected to be optimal.

    %stim info
        notes = {'C3', 'Csharp3', 'D3', 'Eflat3', 'E3', 'F3', 'Fsharp3',...
            'G3', 'Aflat3', 'A3', 'Bflat3', 'B3','C4', 'Csharp4', 'D4',...
            'Eflat4', 'E4', 'F4', 'Fsharp4', 'G4', 'Aflat4', 'A4','Bflat4', ...
            'B4','C5','Csharp5', 'D5', 'Eflat5', 'E5', 'F5', 'Fsharp5',...
            'G5', 'Aflat5', 'A5', 'Bflat5', 'B5','C6'};
        scales = {'C3_ascend', 'C3_descend','Csharp3_ascend', 'Csharp3_descend','D3_ascend','D3_descend',...
            'Eflat3_ascend','Eflat3_descend', 'E3_ascend','E3_descend',...
            'F3_ascend','F3_descend', 'Fsharp3_ascend','Fsharp3_descend'...
            'G3_ascend','G3_descend', 'Aflat3_ascend','Aflat3_descend', ...
            'A3_ascend','A3_descend', 'Bflat3_ascend','Bflat3_descend', ...
            'B3_ascend','B3_descend','C4_ascend','C4_descend',...
            'Csharp4_ascend', 'Csharp4_descend','D4_ascend','D4_descend',...
            'Eflat4_ascend','Eflat4_descend', 'E4_ascend','E4_descend',...
            'F4_ascend','F4_descend', 'Fsharp4_ascend','Fsharp4_descend'...
            'G4_ascend','G4_descend', 'Aflat4_ascend','Aflat4_descend', ...
            'A4_ascend','A4_descend', 'Bflat4_ascend','Bflat4_descend', ...
            'B4_ascend','B4_descend','C5_ascend','C5_descend'};
        stimbase = ['stimuli' filesep];
        scaledir = [stimbase 'majorscales' ];
        notedir = [stimbase 'notes' ];
        Gray = 128;                

        fixplay = [0, 127, 00];
        fixtask = [127, 0, 0];
        cirbool = Circle(10);

        perfectUpToMaxDiameter = 25;
        %colors
        black = [0,0,0];
        red = [127, 0, 0];
        blue = [0,0,127];
        white = [127,127,127];
        
        Screen('Preference', 'SkipSyncTests', 0); % 0 means perform sync tests for maximum accuracy
%---END PRAMETERS---%

%---RUN LOOP---%
runtimes = zeros(1,8);
str = sprintf('Specify the accession code (e.g. 16jul13ad):');
code = input(str,'s');
    while true
        if prun < 8
            str = sprintf('Specify the run number[1-8] or press enter to start run %d or 0 to quit:',prun+1);
            urun = input(str);
            if isempty(urun)
                run = prun + 1;
            elseif urun > 0 && urun <= 8
                run = urun;
            else
                disp('iQuit');
                return
            end
            [status, runtime]=presentstim(run);
            runtimes(run) = runtime;
%             if mod(run,2)
%                 status = imagine(run);
%             else
%                 status = listen(run);
%             end
            if status == 1
                prun = run;
            end
        else
            disp('Finished 8th run, stopping')
            break
        end
    end
    save([code '_runtimes.mat'],'runtimes')
    return
%---END RUN LOOP---%

%-------------------------------------------------------------------------%
function [status,runtime] = presentstim(run)
    % Load notes in order or presentation
    notefnames = notes(order.scaleorder{run}(:,2));
    scalefnames = scales(order.scaleorder{run}(:,1));
    [audionotes, notes_len, deviceid] = loadaudio(notefnames,notedir);
    [audioscales, scales_len, deviceid] = loadaudio(scalefnames,scaledir);
    ntrials = length(notes_len);
    vivid = zeros(1,ntrials);
    %OPEN WINDOW
    screenid = max(Screen('Screens'));
    if debug
        [win, wRect] = Screen('OpenWindow', screenid, Gray, [0 0 100 100]);
%         [win, wRect] = Screen('OpenWindow', screenid, Gray, [0 0 640 480]);
%         [win, wRect] = Screen('OpenWindow', screenid, Gray, [0 0 1024 768]);
    else
        [win, wRect] = Screen('OpenWindow', screenid, Gray);
    end
    %get black
    Black = BlackIndex(win);

    %get center point
    [X,Y] = RectCenter(wRect);

    %fixation cross
    FixCross = [X-1,Y-7,X+1,Y+7;X-7,Y-1,X+7,Y+1];
    % metronome circle
    %MetroCircle = [X-8, Y-8, X+8, Y+8];

    %instructions
    if mod(run,2)
        instr = 'LISTEN to';
    else
        instr = 'IMAGINE';
    end
    if sum(ismember([1, 2, 5, 6],run))>0
        instr = [instr ' ASCENDING major scales'];
    else
        instr = [instr ' DESCENDING major scales'];
    end
        
    runstart='Waiting for the session to start...';
    Screen('FillRect',win,Gray,wRect);
    Screen('textsize',win, 29);
    DrawFormattedText(win, runstart, 'center', 'center', Black);
    Screen('Flip',win);
    % Open audio device for low-latency output:
    pahandle = PsychPortAudio('Open', deviceid, [], reqlatencyclass, freq, 2, buffersize);
    
    % Wait for signal from scanner
    if ~debug
        HideCursor;
        [P4, openerror] = IOPort('OpenSerialPort', '/dev/cu.USA19H3d1P1.1','BaudRate=115200');
        IOPort('Flush',P4);
        pulse = IOPort('read',P4,1,1);
        while isempty(pulse)|| ~(pulse==53)
            pulse = IOPort('read',P4,1,1);
        end
        IOPort('Flush',P4);
    else
        [keyIsDown, secs, KeyCode] = KbCheck;
        keyIsDown = 0;
        while ~(keyIsDown & (KeyCode(TriggerKey) | KeyCode(escapeKey)))
            [keyIsDown, secs, KeyCode] = KbCheck;
        end
        if KeyCode(escapeKey)
            Screen('CloseAll');
        end
    end
    
    % Begin run
    % 4 seconds before stimulus starts
    starttime = GetSecs;
    DrawFormattedText(win, sprintf('Run %d',run), 'center', 'center', Black);
    Screen('Flip',win);
    WaitSecs(1.0);
    % Display instructions once at the beginning of the run
    DrawFormattedText(win, instr, 'center', 'center', Black);
    Screen('Flip',win);
    WaitSecs(2.0);
    Screen('FillRect', win, black, FixCross');
    Screen('Flip',win);
    WaitSecs(1.0);
  for itrials=1:ntrials
        %Play reference tone
        PsychPortAudio('FillBuffer', pahandle, audionotes(itrials));
        Screen('FillRect', win, fixplay, FixCross'); % green while ref tone plays
        Screen('Flip',win);
        PsychPortAudio('Start', pahandle, 1, 0, 1);
        WaitSecs(2);
        Screen('FillRect', win, black, FixCross'); % back to black
        Screen('Flip',win);
        % 6 seconds of Silence
        WaitSecs(4.9);
        Screen('FillRect', win, red, FixCross'); % red to indicate start
        Screen('Flip',win);
        WaitSecs(1);
        if mod(run, 2)
            % play scale
            PsychPortAudio('FillBuffer', pahandle, audioscales(itrials));
            PsychPortAudio('Start', pahandle, 1, 0, 1);
        end
        for i=1:8
            if mod(i,2)
                Screen('FillRect',win,black,wRect);
                Screen('FillRect', win, Gray, FixCross'); 
                Screen('Flip',win);
%                 Screen('FillOval', win, red,MetroCircle,perfectUpToMaxDiameter);
%                 Screen('Flip',win);
            else
                Screen('FillRect',win,Gray,wRect);
                Screen('FillRect', win, black, FixCross'); 
                Screen('Flip',win);
%                 Screen('FillOval', win, blue,MetroCircle,perfectUpToMaxDiameter);
%                 Screen('Flip',win);
            end
            WaitSecs(2);% 2 seconds per note
        end
        Screen('FillRect',win,Gray,wRect);
        Screen('Flip',win);
        if ~debug
            vivid(itrials) = GetVividness(win, run, Y, P4);% 4 seconds
        else
            vivid(itrials) = GetVividness(win, run, Y);
        end
        Screen('FillRect', win, black, FixCross'); % back to black
        Screen('Flip', win);
        WaitSecs(1.99);
        
  end
    endtime=GetSecs;
    disp('time for one run:');
    runtime = endtime-starttime
    DrawFormattedText(win, 'Run Finished', 'center', 'center', Black);
    Screen('Flip',win);
    endtime=GetSecs;
    if ~debug
        IOPort('Close',P4);
    end
    % Done, close driver and display:
    Priority(0);
    PsychPortAudio('Close');
    Screen('CloseAll');
    

    % Save vividness/attention ratings
    save([code '_run' int2str(run), '_vividness'], 'vivid')
    status = 1;
    return
end
%-------------------------------------------------------------------------%
function vividness = GetVividness(win,run,Y,P4)
    tasklength = 4.0;
    taskstart=GetSecs;
    pressed=0;
    if mod(run,2)
        question = 'Please rate your attentiveness on this trial. \n\n\n 1     2     3     4 \n\n\n Not Attentive                  Very Attentive';  
    else
        question = 'Please rate the vividness of your imagination on this trial.\n\n\n 1     2     3     4\n\n\n Not Vivid              Very Vivid';
    end
    DrawFormattedText(win, question, 'center', Y-70, black);
    Screen('Flip',win);
    if ~debug
        vividness = 0;
        while GetSecs-taskstart < tasklength
            pulse = IOPort('read',P4,0,1);
            if pressed==0 && (~isempty(pulse))
                if pulse>=49 && pulse<=52 2
                    pressed=1;
                    response = pulse-48;
                    vividness = response;
                    %probe_resp(iblock,1)=response;
                    IOPort('Flush',P4);
                end
            end
            
        end
    else
        [keyIsDown, secs, KeyCode] = KbCheck;
     
        keyIsDown = 0;
        while GetSecs-taskstart < tasklength && ~(keyIsDown && (KeyCode(one) || KeyCode(two) || KeyCode(three) || KeyCode(four)))
            [keyIsDown, secs, KeyCode] = KbCheck;
            if keyIsDown
                find(KeyCode)
                KbName(KeyCode)
            end
        end
        if KeyCode(one)
            vividness = 1;
        elseif KeyCode(two)
            vividness=2;
        elseif KeyCode(three)
            vividness=3;
        elseif KeyCode(four)
            vividness=4;
        else
            vividness=0;
        end
        vividness
        WaitSecs(tasklength-(GetSecs-taskstart));
    end
    
    
end
%-------------------------------------------------------------------------%
function [clips, clips_len, deviceid] = loadaudio(fnames,dir)
% Read all sound files and create & fill one dynamic audiobuffer for
% each read soundfile:

    % Initialize driver, request low-latency preinit:
    InitializePsychSound(1);
    if ~IsLinux
        PsychPortAudio('Verbosity', 4);
    end
    numtracks = length(fnames);
    clips = zeros(numtracks,1);
    clips_len = zeros(numtracks,1);
    for f=1:numtracks
        try
            
            disp(cat(2, 'Loading ', dir, filesep, char(fnames(f)), '.wav'))
            [audiodata, infreq] = wavread(cat(2,dir, filesep, char(fnames(f)), '.wav'));
            if infreq ~= freq
                fprintf('Incorrect sampling rate of %d', infreq)
            end
        catch 
            fprintf('Failed to read and add file %s. Skipped.\n', char(fnames(f)));
            psychlasterror
            psychlasterror('reset');
        end
        clips(f) = PsychPortAudio('CreateBuffer', [], transpose(repmat(audiodata,1,2)));
        clips_len(f) = size(audiodata,1)/freq;
     end
    
    % Default to auto-selected default output device if none specified:
%     if nargin < 2
%         deviceid = [];
%     end

%     if isempty(deviceid)
        deviceid = -1;
%     end

    if deviceid == -1
        fprintf('Will use auto-selected default output device. This is the system default output\n');
        fprintf('device in "normal" (=reliable but high latency) mode. In low-latency mode its the\n');
        fprintf('device with the lowest inherent latency on your system (as determined by some internal\n');
        fprintf('heuristic). If you are not satisfied with the results you may query the available devices\n');
        fprintf('yourself via a call to devs = PsychPortAudio(''GetDevices''); and provide the device index\n');
        fprintf('of a suitable device\n\n');
    else
        fprintf('Selected the following output device (deviceid=%i) according to your spec:\n', deviceid);
        devs = PsychPortAudio('GetDevices');
        for idx = 1:length(devs)
            if devs(idx).DeviceIndex == deviceid
                break;
            end
        end
        disp(devs(idx));
    end
    % Force GetSecs and WaitSecs into memory to avoid latency later on:
    GetSecs;
    WaitSecs(0.1);
end
%-------------------------------------------------------------------------%

end
