% --------------------------------------------------------------------
function Import_From_Ultravox_Callback(hObject, eventdata, handles)

[ultravoxName,ultravoxPath] = uigetfile([handles.data.squeakfolder '/*.txt'],'Select Ultravox Log');
[audioname, audiopath] = uigetfile({
    '*.wav;*.ogg;*.flac;*.UVD;*.au;*.aiff;*.aif;*.aifc;*.mp3;*.m4a;*.mp4' 'Audio File'
    '*.wav' 'WAVE'
    '*.flac' 'FLAC'
    '*.ogg' 'OGG'
    '*.UVD' 'Ultravox File'
    '*.aiff;*.aif', 'AIFF'
    '*.aifc', 'AIFC'
    '*.mp3', 'MP3 (it''s probably a bad idea to record in MP3'
    '*.m4a;*.mp4' 'MPEG-4 AAC'
    }, 'Select Audio File',handles.data.settings.audiofolder);
AudioFile = fullfile(audiopath,audioname);


% Convert from unicode to ascii
fin = fopen(fullfile(ultravoxPath,ultravoxName),'r');
chars = fscanf(fin,'%c');
chars(1:2) = [];
chars(chars == 0) = [];
chars = strrep(chars,',','.');
fin2 = fopen(fullfile(ultravoxPath,'temp.txt'),'w');
fwrite(fin2, chars, 'uchar');
fclose('all');

% Read file as a table
ultravox = readtable(fullfile(ultravoxPath,'temp.txt'),'Delimiter',';','ReadVariableNames',1,'HeaderLines',0);

% The Ultravox table only contains the frequency at max amplitude, so we
% need to specify the bandwidth.
CallBandwidth = inputdlg('Enter call bandwidth (kHz), because Ultravox doesn''t include it in the output file ','Import from Ultravox', [1 50],{'30'});
if isempty(CallBandwidth); return; end
CallBandwidth = str2double(CallBandwidth);

audioInfo = audioinfo(AudioFile);
if audioInfo.NumChannels > 1
    warning('Audio file contains more than one channel. Use channel 1...')
end

rate = audioInfo.SampleRate;
Calls = struct('Rate',struct,'Box',struct,'RelBox',struct,'Score',struct,'Audio',struct,'Accept',struct,'Type',struct,'Power',struct);
hc = waitbar(0,'Importing Calls from Ultravox Log');

for i=1:length(ultravox.Call)
    waitbar(i/length(ultravox.Call),hc);
    
    Calls(i).Rate = rate;
    
    Calls(i).Box = [
        ultravox.StartTime_s_(i),...
        (ultravox.FreqAtMaxAmp_Hz_(i)/1000) - CallBandwidth / 2,...
        ultravox.StopTime_s_(i) - ultravox.StartTime_s_(i),...
        CallBandwidth];
    
    Calls(i).RelBox=[
        (ultravox.Duration_ms_(i) / 1000),...
        (ultravox.FreqAtMaxAmp_Hz_(i)/1000) - CallBandwidth / 2,...
        (ultravox.Duration_ms_(i) / 1000),...
        CallBandwidth];
    
    Calls(i).Score = 1;
    
    WindL = ultravox.StartTime_s_(i) - (ultravox.Duration_ms_(i) / 1000);
    WindL = round(WindL .* rate);

    WindR = ultravox.StopTime_s_(i) + (ultravox.Duration_ms_(i) / 1000);
    WindR = round(WindR .* rate);
    WindR = min(WindR,audioInfo.TotalSamples);
    
    
    if WindL >= audioInfo.TotalSamples
        disp('Call starts after the file ends')
        continue
    end
    if WindR > audioInfo.TotalSamples
        disp('Call ends after the file ends')
        continue
    end
    
    audio = mergeAudio(AudioFile, [WindL WindR]);
    
    Calls(i).Audio= audio;
    Calls(i).Accept = 1;
    Calls(i).Type = categorical(ultravox.PatternLabel(i));
    Calls(i).Power = 0;
end
close(hc);
Calls = struct2table(Calls);

[FileName, PathName] = uiputfile(fullfile(handles.data.settings.detectionfolder, '*.mat'), 'Save Call File');
filename = fullfile(PathName,FileName);

Calls = merge_boxes(Calls.Box, Calls.Score, Calls.Type, Calls.Power, audioInfo, 1, 0, 0);

h = waitbar(.9,'Saving Output Structures');
detectiontime = datestr(datetime('now'),'mmm-DD-YYYY HH_MM PM');
save(filename,'Calls','AudioFile','detectiontime','-v7.3');

close(h);

update_folders(hObject, eventdata, handles);
