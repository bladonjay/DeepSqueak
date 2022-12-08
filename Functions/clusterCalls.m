ClusterCalls

%% first i want to pull some random call images, 
% ijust to see what they looklike


% callfiles are in...
load('USVdataFULL2021-10-20.mat');
calldir='G:\USV data\Detections';
callfiles=getAllFiles(calldir,'.mat');
wavdir='G:\USV data\Raw\wav';
wavfiles=getAllFiles(wavdir,'.wav');

for i=1:height(USVSession)
    callname=USVSession.FileName(i);
    USVSession.callFile=callfiles(contains(callfiles,callname));
    
    if isempty(USVSession.audiodata(i))
        wavfile=wavfiles(contains(wavfiles,callname));
        USVSession.audiodata=audioinfo(wavfile{1});
        
        
        
        

        
        
%% DeepSqueaks clustering algorithms

% K-means
%{  
For Kmeans, they basically reduce the data into a M calls by 3 matrix,
where the columns are slope, freq and duration... shitty...

%}

% autoencoder using the images
%{
the pitfall with this is that certain calls of a type, say long monotonic
calls with a pitch jump somewhere do not look similar.  they only have
similar properties (one main frequency, with a 'jump' to another

so we need to use a set of characteristics to describe these calls.

first, we need to identify the sounds that are loud.  This can be done
with the blobs.

Once we have the blobs we can characterize them.

1. overall average numbers:
a. principal frequency- the peak of the histogram
b. maybe the whole spectrogram of times containing the call splines
    or just the histogram of the splines on the y axis
c. number of peaks in the histogram using some algorithm
d. information content in histogram (sparsity)
e. linear fit- slope, offset, and corrected sum of squares (mean squared
dev)
f. entropy in x axis
g. entropy in y axis
h. peak frequency
i. min frequency
j. max-min freq
    - average frequency (mean of all the y values in spline)
    - average freq normalized to between min and max (a version of skew)
    - StDev of frequency
    - Sinuosity (overall average)
    - Overall Power (mean of ridge)
    -

2. blob specific numbers:
a. number of blobs
b. max sinuosity of all blobs
c. min sinuosity of all blobs
d. max diff in freq between any two blobs
e. the % of all blobs the max blob occupies
f. max slope of any blob
g. mean slope across blobs
h. min slope of any blob