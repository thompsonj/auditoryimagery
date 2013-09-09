function gen_labels

% This script will generate two label files for the auditory imagery
% experiment. Each TR (dynamic scan) of the fMRI protocol can be labeled
% according to the absolute pitch or the relative scale degree of the
% presented or imagined note. In both cases, rest scans (no sound, no 
% imagination) are labeled 0 and the presentation of reference tones are
% labelled -1. Both a MATLAB .mat data file and a space-delimited text 
% file are saved. The first column contains the condition label for each TR.
% The second column indicates the run for each TR, such that the text file can
% be used as a label file in pymvpa.

% ABSOLUTE PITCH
% The lowest heard tone (C3) is given the label 1 and subsequent pitches
% are assigned consecutive integers up to the highest pitch, B5 
% (label='36'). 
% files saved: 
%     'AuditoryImagery_AbsolutePitch.labels'
%     'AuditoryImagery_AbsolutePitch.mat'
%     


% RELATIVE SCALE DEGREE
% files saved: 
%     'AuditoryImagery_ScaleDegree.labels'
%     'AuditoryImagery_ScaleDegree.mat'


order = load('scaleorder24.mat');
labels = zeros(1480,2);
n=[0 2 4 5 7 9 11 12];
prun = 0;
%---RUN LOOP---%
str = sprintf('Press 0 for absolute pitch labels, 1 for scale degree labels:');
labeltype = input(str);
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
            [status]=presentstim(run);
            if status == 1
                prun = run;
            end
        else
            disp('Finished 8th run, stopping')
            break
        end
    end
    if labeltype
        fname = 'ScaleDegree';
    else
        fname = 'AbsolutePitch';
    end
    dlmwrite(['AuditoryImagery_',fname,'.labels'],labels,' ')
    save(['AuditoryImagery_',fname], 'labels')
    return
%---END RUN LOOP---%

%-------------------------------------------------------------------------%
function [status] = presentstim(run)
    notefnames = order.scaleorder{run}(:,2);
    scalefnames = order.scaleorder{run}(:,1);
    ntrials = 12;
    start = ((run-1)*185)+1;
    idx = start;
    labels(start:run*185, 2) = run;
    
    % Begin run
    % 4 seconds (two TRs) of silence and instructions before stimulus starts
    labels(idx:idx+1, 1) = 0;
    idx = idx+2;
  for itrials=1:ntrials
        %Play reference tone for 2 seconds
        labels(idx, 1) = -1;
        idx = idx +1;
        % 6 seconds of Silence
        labels(idx:idx+2, 1) = 0;
        idx = idx +3;
        % 8 notes of scale
        if labeltype
            % SCALE DEGREE
            if ismember(run,[1,2,5,6])
                labels(idx:idx+3, 1) = 0;
                idx = idx +4;
                labels(idx:idx+3, 1) = 1;
                idx = idx +4;
            else
                labels(idx:idx+3, 1) = 1;
                idx = idx +4;
                labels(idx:idx+3, 1) = 0;
                idx = idx +4;
            end
        else
            % ABSOLUTE PITCH
            if mod(scalefnames(itrials),2)
                % Ascending
                labels(idx:idx+7,1) = n+notefnames(itrials);
            else
                % Descending
                labels(idx:idx+7,1) = (notefnames(itrials) -12) + (fliplr(n));
            end   
        end
        if ~mod(run, 2)
            % Imagiation run
            labels(idx:idx+7,1) =labels(idx:idx+7,1)+36;
        end
        idx = idx+8;
        % 6 seconds of silence
        labels(idx:idx+2, 1) = 0;
        idx = idx +3;
    end
    % Extra 3 TRs at end of run, silent
    labels(idx:idx+2, 1) =0;
    idx = idx +3;
    idx

    status = 1;
    return
end
%-------------------------------------------------------------------------%

end
