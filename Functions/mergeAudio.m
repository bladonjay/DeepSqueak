function audio = mergeAudio(fname, window)

pad = [];
if window(1) <= 1
    pad=zeros(abs(window(1)), 1);
    window(1) = 1;
end

audio = audioread(fname, window);
audio = [pad; mean(audio - mean(audio,1) ,2)]; % Take the mean of the audio channels
if isa(audio,'double')
    audio = int16(audio * 32767); % Convert to int16
end


end