% gen_stim.m
%
% Generate sinetone scales in each major key from G3 to F#4
function gen_stim()
    scales = {'C3', 'Csharp3', 'D3', 'Eflat3', 'E3', 'F3', 'Fsharp3','G3', 'Aflat3', 'A3', 'Bflat3', 'B3','C4', 'Csharp4', 'D4', 'Eflat4', 'E4', 'F4', 'Fsharp4', 'G4', 'Aflat4', 'A4','Bflat4', 'B4','C5'};
    notes = [scales 'Csharp5', 'D5', 'Eflat5', 'E5', 'F5', 'Fsharp5','G5', 'Aflat5', 'A5', 'Bflat5', 'B5','C6'];
    numscales=length(scales);
    fs=44100; % audio sampling rate
    a440 = 440;
    %freqs = ([(2)^(1/12)].^[0:numscales-1]) * lowfreq; % starting freq of each scale
    allf = a440*2*((2).^(([0:(numscales+12)-1]*-1)/12));
    allf = fliplr(allf);
    nSeconds=2;
    allfreqs=zeros(1,8*12);
    %scales = {'G3', 'Aflat3', 'A3', 'Bflat3', 'B3', 'C4', 'Csharp4', 'D4', 'Eflat4', 'E4', 'F4', 'Fsharp4'};
    for i=1:numscales % for each of the 12 major scales
        [noteA, noteD, scaleA, scaleD, freqsad] = genMajorScale(i,allf,nSeconds,fs);
        allfreqs(1+(i-1)*8:8*i) = freqsad;
        wavwrite(scaleA, fs,16, ['stimuli/majorscales/' scales{i} '_ascend'])
        wavwrite(scaleD, fs,16, ['stimuli/majorscales/' scales{i} '_descend'])
        wavwrite(noteA, fs,16, ['stimuli/notes/' notes{i}])
        wavwrite(noteD, fs,16, ['stimuli/notes/' notes{i+12}])
    end
    % plot histogram of pitches
%     exp = repmat(allfreqs,1,4);
%     length(exp)
%     hist(exp, unique(allfreqs))
end

% 
function [noteA, noteD, scaleA,scaleD,freqs] = genMajorScale(i,allf,nSeconds,fs)
    up = 441; %10th of a second rise and fall to avoid clipping
    down = 441;
    env = [linspace(0, 1, up) ones(1,(nSeconds*fs)-up-down) linspace(1, 0, down)];
    n=[0 2 4 5 7 9 11 12]; % semitones to add to freq to make major scale
    freqs = allf(i+n);
    phons=90; % ff
    A = getLoudness(phons,freqs); % intensity value for each note of scale
    A(A>=1) = .9999;
    A
    %freqsad = [freqs freqs(end-1:-1:1)]; % Ascending and descending
    scaleA = zeros(1,nSeconds*fs);
    scaleD = zeros(1,nSeconds*fs);
    onoff = 1:nSeconds*fs:(nSeconds*fs*8)+1; % indices of boundaries between notes
    for f=1:length(freqs)
        if f==1
            noteA = A(f)*env.*sin(linspace(0, nSeconds*freqs(f)*2*pi, round(nSeconds*fs)));
            noteD= A(f)*env.*sin(linspace(0, nSeconds*freqs(end-f+1)*2*pi, round(nSeconds*fs)));
        end
        
        scaleA(onoff(f):onoff(f+1)-1) = A(f)*env.*sin(linspace(0, nSeconds*freqs(f)*2*pi, round(nSeconds*fs)));
        scaleD(onoff(end-f):onoff(end-f+1)-1) = A(f)*env.*sin(linspace(0, nSeconds*freqs(f)*2*pi, round(nSeconds*fs)));
    end
end

function A = getLoudness(phons,freqs)
    [spl, allfreqs] = iso226(phons);
    [low low] = min(abs(allfreqs-freqs(1)));
    [high high] = min(abs(allfreqs-(freqs(end))));
    % Interpolate to get intensity values for each frequency in the scale.
    splinterp = interp1(allfreqs(low:high), spl(low:high), freqs, 'spline');
    % convert to sound pressure
    p0=0.00002;
    A = (p0*10.^(splinterp/20));
    A = [A A(end-1:-1:1)];
end