function Calls = Automerge_Callback(Calls1,Calls2,AudioFile,audioMetadata,mergeopt)
%% Merges two detection files into one

Calls=[Calls1; Calls2];

% Audio info (you can also just pull this from the call data, callMetadata)
try
    audio_info=audioMetadata;
catch
    audio_info = audioinfo(AudioFile);
end
%% Merge overlapping boxes

%% delete bad calls?
if ~exist('mergeopt','var')
    answer = questdlg('Merge or delete Rejected Calls?', ...
        'Delete Call Menu', ...
        'Merge In','Leave Out','Just Delete Them','Leave Out');
    if strcmpi(answer,'Yes please')
        Calls{:,'Accept'}=true;
    elseif strcmpi(answer,'Just Delete Them')
        Calls=Calls(Calls.Accept==1,:);
    end
elseif mergeopt==1
    Calls{:,'Accept'}=true;
elseif mergeopt==2
    Calls=Calls(Calls.Accept==1,:);
end

    
Calls = merge_boxes(Calls.Box, Calls.Score, Calls.Type, Calls.Power, audio_info, 1, 0, 0);
calls2=merge_boxes2(Calls,audio_info,1,0,0,0);
end
