function Calls = Automerge_Callback(Calls1,Calls2,AudioFile,audioMetadata)
%% Merges two detection files into one

Calls=[Calls1; Calls2];

% Audio info (you can also just pull this from the call data, callMetadata)
try
    audio_info=audioMetadata;
catch
    audio_info = audioinfo(AudioFile);
end
%% Merge overlapping boxes
Calls = merge_boxes(Calls.Box, Calls.Score, Calls.Type, Calls.Power, audio_info, 1, 0, 0);
