% --- Executes on button press in multinetdect.
% uses automerge callback
function multinetdect_Callback(hObject, eventdata, handles, SingleDetect)
if isempty(handles.audiofiles)
    errordlg('No Audio Selected')
    return
end
if isempty(handles.networkfiles)
    errordlg('No Network Selected')
    return
end
if exist(handles.data.settings.detectionfolder,'dir')==0
    errordlg('Please Select Output Folder')
    uiwait
    load_detectionFolder_Callback(hObject, eventdata, handles)
    handles = guidata(hObject);  % Get newest version of handles
end

%% Do this if button Multi-Detect is clicked
if ~SingleDetect
    audioselections = listdlg('PromptString','Select Audio Files:','ListSize',[500 300],'ListString',handles.audiofilesnames);
    if isempty(audioselections)
        return
    end
    networkselections = listdlg('PromptString','Select Networks:','ListSize',[500 300],'ListString',handles.networkfilesnames);
    if isempty(audioselections)
        return
    end
    
  
    %% Do this if button Single-Detect is clicked
elseif SingleDetect
    audioselections = get(handles.AudioFilespopup,'Value');
    networkselections = get(handles.neuralnetworkspopup,'Value');
end

Settings = [];
for k=1:length(networkselections)
    prompt = {'Total Analysis Length (Seconds; 0 = Full Duration)','Analysis Chunk Length (Seconds; GPU Dependent)','Overlap (Seconds)','Frequency Cut Off High (kHZ)','Frequency Cut Off Low (kHZ)','Score Threshold (0-1)','Append Date to FileName (1 = yes)'};
    dlg_title = ['Settings for ' handles.networkfiles(networkselections(k)).name];
    num_lines=[1 100]; options.Resize='off'; options.WindowStyle='modal'; options.Interpreter='tex';
    def = handles.data.settings.detectionSettings;
    current_settings = str2double(inputdlg(prompt,dlg_title,num_lines,def,options));
    
    if isempty(current_settings) % Stop if user presses cancel
        return
    end
    
    Settings = [Settings, current_settings];
    handles.data.settings.detectionSettings = sprintfc('%g',Settings(:,1))';
end

if isempty(Settings)
    return
end

% Save the new settings
handles.data.saveSettings();



update_folders(hObject, eventdata, handles);
handles = guidata(hObject);  % Get newest version of handles


%% For Each File
for j = 1:length(audioselections)
    % initialize all the data
    CurrentAudioFile = audioselections(j);
    Calls = [];
    AudioFile=[];
    callsMetadata=[];
    % For Each Network
    for k=1:length(networkselections)
        h = waitbar(0,'Loading neural network...');
        
        AudioFile = fullfile(handles.audiofiles(CurrentAudioFile).folder,handles.audiofiles(CurrentAudioFile).name);
       
        networkname = handles.networkfiles(networkselections(k)).name;
        networkpath = fullfile(handles.networkfiles(networkselections(k)).folder,networkname);
        NeuralNetwork=load(networkpath);%get currently selected option from menu
        close(h);
        % append, and grab the filedata
        Callsi= SqueakDetect(AudioFile,NeuralNetwork,handles.audiofiles(CurrentAudioFile).name,Settings(:,k),j,length(audioselections),networkname,handles.optimization_slider.Value);
        
        Calls= [Calls; Callsi];
    end
    clear Callsi
    
    % generate metadata
    [~,audioname] = fileparts(AudioFile);
    detectiontime=datestr(datetime('now'),'mmm-DD-YYYY HH_MM PM');
    callsMetadata=audioinfo(AudioFile);
    
    % dont need to add call data if you have correct filename
    %{
    fullaudio = audioread(AudioFile);
    fullaudio = fullaudio - mean(fullaudio,1);
    switch 'mean'
        case 'first'
            fullaudio = fullaudio(:,1);
        case 'mean'
            fullaudio = mean(fullaudio,2);
        case 'max'
            [~,index] = max(abs(fullaudio'));
            fullaudio = fullaudio(sub2ind(size(fullaudio),1:size(fullaudio,1),index));
    end
    callsMetadata.audioData=fullaudio;
    %}
    
    
    h = waitbar(1,'Saving...');
    
    
    %% Save the file
    
    % Append date to filename
    if Settings(7)
        fname = fullfile(handles.data.settings.detectionfolder,[audioname ' ' detectiontime '.mat']);
    else
        fname = fullfile(handles.data.settings.detectionfolder,[audioname '.mat']);
    end
    
    % Display the number of calls
    fprintf(1,'%d Calls found in: %s \n',height(Calls),audioname)
    
    % if there are calls, save out
    if ~isempty(Calls)
        Calls = Automerge_Callback(Calls, [], AudioFile);
        save(fname,'Calls','Settings','AudioFile','callsMetadata','detectiontime','networkselections','-v7.3','-mat');
    end
    
    delete(h)
end
update_folders(hObject, eventdata, handles);
guidata(hObject, handles);
