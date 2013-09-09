
% Jessica Thompson
% June 20, 2013

% Generate random order of presentation for auditory imagery fMRI
% experiment
% 48 scales, 8 runs (4 listen, 4 random)

nscales = 24;


noteidxascend = 1:nscales;
noteidxdescend = 13:37;
idxascend = 1:2:(nscales*2);
idxdescend = 2:2:(nscales*2);

idxshuffle = randperm(nscales);
idxascend = idxascend(idxshuffle);
noteidxascend = noteidxascend(idxshuffle);
run1 = [idxascend(1:12)' noteidxascend(1:12)'];
run5 = [idxascend(13:24)' noteidxascend(13:24)'];

idxshuffle = randperm(nscales);
idxascend = idxascend(idxshuffle);
noteidxascend = noteidxascend(idxshuffle);
run2 = [idxascend(1:12)' noteidxascend(1:12)'];
run6 = [idxascend(13:24)' noteidxascend(13:24)'];

idxshuffle = randperm(nscales);
idxdescend = idxdescend(idxshuffle);
noteidxdescend=noteidxdescend(idxshuffle);
run3 = [idxdescend(1:12)' noteidxdescend(1:12)'];
run7 = [idxdescend(13:24)' noteidxdescend(13:24)'];

idxshuffle = randperm(nscales);
idxdescend = idxdescend(idxshuffle);
noteidxdescend = noteidxdescend(idxshuffle);
run4 = [idxdescend(1:12)' noteidxdescend(1:12)'];
run8 = [idxdescend(13:24)' noteidxdescend(13:24)'];

scaleorder = {run1,run2,run3,run4,run5,run6,run7,run8};

save('scaleorder24','scaleorder')
disp('Saved scaleorder24.mat')