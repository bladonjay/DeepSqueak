function stats = CalculateStats(I,windowsize,noverlap,nfft,SampleRate,Box,EntropyThreshold,AmplitudeThreshold,verbose)
if nargin <= 8
    verbose = 0;
end




%% Ridge Detection
% Calculate entropy at each time point
stats.Entropy = geomean(I,1) ./ mean(I,1);
stats.Entropy = smooth(stats.Entropy,3)';
% Find maximum amplitude and corresponding at each time point
[amplitude,ridgeFreq] = max((I));
amplitude = smooth(amplitude,3)';


% one method of getting the EntropyThreshold
% now get top and bottom quartiles

myopt=3; % 3 is the standard method
if myopt==1
    quartiles=prctile(stats.Entropy,[30 90]); % get top quartile and bottom quartile
    % now get the mean of each of those
    qmean=nanmean(stats.Entropy(stats.Entropy<quartiles(1)));
    qmean(2)=nanmean(stats.Entropy(stats.Entropy>quartiles(2)));
    % now split the differencde
    EntropyThreshold=1-nanmean(qmean);
    
elseif myopt==2
    % another method
    mydata=sort(stats.Entropy);
    [crit]=elbow_method(mydata,1:length(mydata),[],true);
    EntropyThreshold=1-mydata(crit);
    
end

zcrit=nanmean(I(:))+2*nanstd(I(:));
okz=sum(I>zcrit)>0;
%EntropyThreshold=max(stats.Entropy(okz));
% Get index of the time points where entropy and aplitude are greater than their thesholds
% iteratively lower threshholds until at least 6 points are selected
iter = 0;




greaterthannoise = false(1, size(I, 2));
while sum(greaterthannoise)<5
    % either amplitude thresh or entropy threshold
    greaterthannoise = greaterthannoise | 1-stats.Entropy > EntropyThreshold   / 1.1 ^ iter;
    greaterthannoise = greaterthannoise & amplitude       > AmplitudeThreshold / 1.1 ^ iter;
    if iter > 10
%         disp('Could not detect contour')
        greaterthannoise = true(1, size(I, 2));
        break;
    end
   
    if iter > 1
        disp('lowering threshold')
    end
    iter = iter + 1;
end

% index of time points
stats.ridgeTime = find(greaterthannoise);
stats.ridgeFreq = ridgeFreq(greaterthannoise);
% Smoothed frequency of the call contour
try
    stats.ridgeFreq_smooth = smooth(stats.ridgeTime,stats.ridgeFreq,7,'sgolay');
catch
    disp('Cannot apply smoothing. The line is probably too short');
    stats.ridgeFreq_smooth=stats.ridgeFreq';
end



if verbose==1
    figure;
    sp=subplot(3,2,1);
    imagesc(I);
    sp(2)=subplot(3,2,3);
    plot(stats.Entropy);
    hold on; plot(find([1-stats.Entropy]>EntropyThreshold),...
        [1-stats.Entropy([1-stats.Entropy]>EntropyThreshold)],'r.');
    % how would we find the amplitude for that?
    sp(3)=subplot(3,2,2);
    imagesc(I>prctile(I(:),99));
    sp(4)=subplot(3,2,5);
    imagesc(I>zcrit);
    sp(5)=plot(stats.ridgeTime,stats.ridgeFreq_smooth);
    
    linkaxes(sp,'x'); set(sp(4),'YLim',get(sp(1),'YLim'),'YDir','reverse');
    close(gcf);
    
end
%% Calculate the scaling factors of the spectrogram 2k because of nyquist?
spectrange = SampleRate / 2000; % get frequency range of spectrogram in KHz
FreqScale = spectrange / (1 + floor(nfft / 2)); % kHz per pixel
TimeScale = (windowsize - noverlap) / SampleRate; % seconds per pixel


%% Frequency gradient of spectrogram
[~, stats.FilteredImage] = imgradientxy(I);


%% Signal to Noise Ratio
stats.SignalToNoise = mean(1 - stats.Entropy(stats.ridgeTime));

%% Time Stats
stats.BeginTime = Box(1) + min(stats.ridgeTime)*TimeScale;
stats.EndTime = Box(1) + max(stats.ridgeTime)*TimeScale;
stats.DeltaTime = stats.EndTime - stats.BeginTime;

%% Frequency Stats
% Median frequency of the call contour
stats.PrincipalFreq= FreqScale * median(stats.ridgeFreq_smooth) + Box(2);

% Low frequency of the call contour
stats.LowFreq = FreqScale * min(stats.ridgeFreq_smooth) + Box(2);

% High frequency of the call contour
stats.HighFreq = FreqScale * max(stats.ridgeFreq_smooth) + Box(2);

% Delta frequency of the call contour
stats.DeltaFreq = stats.HighFreq - stats.LowFreq;

% Frequency standard deviation of the call contour
stats.stdev = std(FreqScale*stats.ridgeFreq_smooth);

% Slope of the call contour
try
    X = [ones(length(stats.ridgeTime),1), TimeScale*stats.ridgeTime.'];
    ls = X \ (FreqScale*stats.ridgeFreq_smooth);
    stats.Slope = ls(2);
catch
    stats.Slope = 0;
end

%% Max Power ( PSD )
% Magnitude
ridgePower = amplitude(stats.ridgeTime);
% Magnitude sqaured divided by sum of squares of hamming window
ridgePower = ridgePower.^2 / sum(hamming(windowsize).^2);
ridgePower = 2*ridgePower / SampleRate;
% Convert power to db
ridgePower = 10 * log10(ridgePower);

% Mean power of the call contour
stats.MaxPower = mean(ridgePower);
% Power of the call contour
stats.Power = ridgePower;

%% Sinuosity - path length / duration
try
    D = pdist([stats.ridgeTime' stats.ridgeFreq_smooth],'Euclidean');
    Z = squareform(D);
    leng=Z(1,end);
    c=0;
    for ll=2:length(Z)
        c=c+1;
        totleng(c)=Z(ll-1,ll);
    end
    stats.Sinuosity=sum(totleng)/leng;
catch
    stats.Sinuosity = 1;
end

end


