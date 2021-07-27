function Calls = Automerge_Callback(Calls1,Calls2,AudioFile,audioMetadata,mergeopt)
%% Merges two detection files into one

Calls=[Calls1; Calls2];

%first try the audiofile input
if isstring(AudioFile) || ischar(AudioFile)
    audioOK= isfile(AudioFile);
    if audioOK
        audio_info=audioinfo(AudioFile);
    end
else
    audioOK=0;
end
if ~audioOK
    if nargin>3
        % if that doesnt work, now try the struct
        if  isstruct(audioMetadata)
            try
                AudioFile=audioMetadata.Filename;
                audioOK= isfile(AudioFile);
                audio_info=audioMetadata;
            catch
                audioOK=0;
            end
        else
            audio_info=audioMetadata;
        end
        % if neither worked, pull your file
        if ~audioOK
            [AudioFile,AudioDir]=uigetfile('*.wav','Load Audio File');
            audio_info = audioinfo(fullfile(AudioDir,AudioFile));
        end
    else
        [mf,md]=uigetfile('.wav',sprintf('Load wav file matching %s'));
        audio_info=audioinfo(fullfile(md,mf));
    end
end


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

%% Merge overlapping boxes
    
Calls = merge_boxes(Calls.Box, Calls.Score, Calls.Type, Calls.Power, audio_info, 1, 0, 0);
%calls2=merge_boxes2(Calls,audio_info,1,0,0,0);
end
