%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DeepSqueak 2.7.0                                                        %
% Copyright (c) 2021 Kevin Coffey , Russell Marx, & Robert Ciszek         %
%                                                                         %
% Licensed under the BSD 3-Clause Licence:                                %
% https://opensource.org/licenses/BSD-3-Clause                            %
%                                                                         %
% Unless required by applicable law or agreed to in writing, software     %
% distributed under the License is distributed on an "AS IS" BASIS,       %
% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = DeepSqueak(varargin)

set(groot,'defaultFigureVisible','on');
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @DeepSqueak_OpeningFcn, ...
    'gui_OutputFcn',  @DeepSqueak_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end
if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end

% --- Executes just before DeepSqueak is made visible.
function DeepSqueak_OpeningFcn(hObject, eventdata, handles, varargin)
% Very Important Logo (Mouse from hjw)
disp '                                                                                                                                 .---.'
disp '                                                                                                                                /  .  \  '
disp '                                                                                                       ) _     _               |\_/|   |'
disp '                                                                                                      ( (^)-~-(^)              |   |   |'
disp '    ._______________________________________________________________________________________________,-.\_( 0 0 )__,-.__________|___|__,|'
disp '   /  .-.                                                                                           ''M''   \   /   ''M''                  |'
disp '  |  /   \                                                                                                 >o<                         |'
disp '  | |\_.  |                                                                                                                            |  '
disp '  |\|  | /|        ,---,                                    .--.--.                                                         ,-.        |  '
disp '  | `---'' |      .''  .'' `\                      ,-.----.   /  /    ''.   ,----.                                          ,--/ /|        |'
disp '  |       |    ,---.''     \                     \    /  \ |  :  /`. /  /   /  \-.         ,--,                        ,--. :/ |        |'
disp '  |       |    |   |  .`\  |                    |   :    |;  |  |--`  |   :    :|       ,''_ /|                        :  : '' /         |'
disp '  |       |    :   : |  ''  |   ,---.     ,---.  |   | .\ :|  :  ;_    |   | .\  .  .--. |  | :    ,---.     ,--.--.   |  ''  /          |'
disp '  |       |    |   '' ''  ;  :  /     \   /     \ .   : |: | \  \    `. .   ; |:  |,''_ /| :  . |   /     \   /       \  ''  |  :          |'
disp '  |       |    ''   | ;  .  | /    /  | /    /  ||   |  \ :  `----.   \''   .  \  ||  '' | |  . .  /    /  | .--.  .-. | |  |   \         | '
disp '  |       |    |   | :  |  ''.    '' / |.    '' / ||   : .  |  __ \  \  | \   `.   ||  | '' |  | | .    '' / |  \__\/: . . ''  : |. \        |'
disp '  |       |    ''   : | /  ; ''   ;   /|''   ;   /|:     |`-'' /  /`--''  /  `--''""| |:  | : ;  ; | ''   ;   /|  ," .--.; | |  | '' \ \       |'
disp '  |       |    |   | ''` ,/  ''   |  / |''   |  / |:   : :   ''--''.     /     |   | |''  :  `--''   \''   |  / | /  /  ,.  | ''  : |--''        |'
disp '  |       |    ;   :  .''    |   :    ||   :    ||   | :     `--''---''      |   | ::  ,      .-./|   :    |;  :   .''   \;  |,''           |'
disp '  |       |    |   ,.''       \   \  /  \   \  / `---''.|                   `---''.| `--`----''     \   \  / |  ,     .-./''--''             |'
disp '  |       |    ''---''          `----''    `----''    `---`                     `---`                `----''   `--`---''                     |'
disp '  |       |                                                                                                                            |'
disp '  \       |____________________________________________________________________________________________________________________________/'
disp '   \     /'
disp '    `---'''
disp '  '
disp '  '
disp '  '

% Set Handles
hFig = hObject;
handles.hFig=hFig;

% % Fullscreen
% warning ('off','all');
% pause(0.00001);
% frame_h = get(handle(gcf),'JavaFrame');
% set(frame_h,'Maximized',1);

% Create a class to hold the data
squeakfolder = fileparts(mfilename('fullpath'));

% Add to MATLAB path and check for toolboxes
if ~isdeployed
    % Add DeepSqueak to the path
    addpath(squeakfolder);
    addpath(genpath(fullfile(squeakfolder, 'Functions')));
    savepath
    
    %% Display error message if running on matlab before 2017b or toolboxes not found
    if verLessThan('matlab','9.3')
        errordlg(['Warning, DeepSqueak requires MATLAB 2017b or later. It looks like you are use MATLAB ' version('-release')],'upgrade your matlab')
    end
    
    try
        verLessThan('nnet','1');
    catch
        warning('Deep Learning Toolbox not found')
    end
    
    try
        verLessThan('curvefit','1');
    catch
        warning('Curve Fitting Toolbox not found')
    end
    
    try
        verLessThan('vision','1');
    catch
        warning('Computer Vision System Toolbox not found')
    end
    
    try
        verLessThan('images','1');
    catch
        warning('Image Processing Toolbox not found')
    end
    
    try
        verLessThan('parallel','1');
    catch
        warning('Parallel Computing Toolbox not found')
    end
end

handles.data = squeakData(squeakfolder);

set ( hFig, 'Color', [.1 .1 .1] );
handles.output = hObject;
cd(handles.data.squeakfolder);

% Display version
try
    fid = fopen(fullfile(handles.data.squeakfolder,'CHANGELOG.md'));
    txt = fscanf(fid,'%c');
    txt = strsplit(txt);
    changes = find(contains(txt,'##'),1); % Get the values after the bold heading
    handles.DSVersion = txt{changes+1};
    disp(['DeepSqueak version ' handles.DSVersion]);
    fclose(fid);
catch
    handles.DSVersion = '?';
end
% Check if a new version is avaliable by comparing changelog to whats online
try
    WebChangelogTxt= webread('https://raw.githubusercontent.com/DrCoffey/DeepSqueak/master/CHANGELOG.md');
    WebChangelog = strsplit(WebChangelogTxt);
    changes = find(contains(WebChangelog,'##')); % Get the values after the bold heading
    WebVersion = WebChangelog{changes+1};
    if ~strcmp(WebVersion,handles.DSVersion)
        disp ' '
        disp 'A new version of DeepSqueak is avaliable.'
        disp('<a href="https://github.com/DrCoffey/DeepSqueak">Download link</a>')
        changes = strfind(WebChangelogTxt,'##');
        disp(WebChangelogTxt(changes(1)+3:changes(2)-1))
    end
end

% set(handles.spectogramWindow,'Visible', 'off');
% set(handles.epochSpect,'Visible', 'off');
% set(handles.topRightButton, 'Visible', 'off');
% set(handles.topLeftButton, 'Visible', 'off');

if ~(exist(fullfile(handles.data.squeakfolder,'Background.png'), 'file')==2)
    disp('Background image not found')
    background = zeros(280);
    fonts = listTrueTypeFonts;
    background = insertText(background,[10 8],'DeepSqueak','Font',char(datasample(fonts,1)),'FontSize',30);
    background = insertText(background,[10 80],'DeepSqueak','Font',char(datasample(fonts,1)),'FontSize',30);
    background = insertText(background,[10 150],'DeepSqueak','Font',char(datasample(fonts,1)),'FontSize',30);
    background = insertText(background,[10 220],'DeepSqueak','Font',char(datasample(fonts,1)),'FontSize',30);
    handles.background = background;
else
    handles.background=imread('Background.png');
end
if ~(exist(fullfile(handles.data.squeakfolder,'DeepSqueak.fig'), 'file')==2)
    errordlg('"DeepSqueak.fig" not found');
end


% Cool Background Image
imshow(handles.background, 'Parent', handles.axes1);
set(handles.axes1,'Color',[0.1 0.1 0.1],'YColor',[1 1 1],'XColor',[1 1 1]);
set(handles.axes1,'XTick',[]);
set(handles.axes1,'YTick',[]);
update_folders(hObject, eventdata, handles);
handles = guidata(hObject);  % Get newest version of handles

% Set the sliders to the saved values
set(handles.TonalitySlider, 'Value', handles.data.settings.EntropyThreshold);

dropdown_items = cellstr(get(handles.epochWindowSizePopup,'String'));
dropdown_items = regexprep(dropdown_items, '[^0-9.]', ' ');
dropdown_items = str2double(dropdown_items);
set(handles.epochWindowSizePopup, 'Value', find(dropdown_items == handles.data.settings.windowSize))

dropdown_items = cellstr(get(handles.focusWindowSizePopup,'String'));
dropdown_items = regexprep(dropdown_items, '[^0-9.]', ' ');
dropdown_items = str2double(dropdown_items);
set(handles.epochWindowSizePopup, 'Value', find(dropdown_items == handles.data.settings.focus_window_size))
    
guidata(hObject, handles);

set(handles.axes7,'Color',[0.1 0.1 0.1],'YColor',[1 1 1],'XColor',[1 1 1],'Box','off','Clim',[0,1]);
set(handles.axes7,'XTickLabel',[]);
set(handles.axes7,'XTick',[]);
set(handles.axes7,'YTick',[]);

set(handles.axes3,'Color',[0.1 0.1 0.1],'YColor',[1 1 1],'XColor',[1 1 1],'Box','off','Clim',[0,1]);
set(handles.axes3,'XTickLabel',[]);
set(handles.axes3,'XTick',[]);
set(handles.axes3,'YTick',[]);

C = spatialPattern([1000,10000],-2);
imagesc(C(1:900,1:10000),'Parent', handles.spectogramWindow);
colormap(handles.spectogramWindow,inferno);
set(handles.spectogramWindow,'Color',[0.1 0.1 0.1],'YColor',[1 1 1],'XColor',[1 1 1]);
set(handles.spectogramWindow,'XTickLabel',[]);
set(handles.spectogramWindow,'XTick',[]);
set(handles.spectogramWindow,'YTick',[]);

% imagesc(C(900:1000,1:10000),'Parent', handles.detectionAxes);
% colormap(handles.detectionAxes,inferno);
set(handles.detectionAxes,'Color',[64/255 10/255 103/255],'YColor',[1 1 1],'XColor',[1 1 1]);
set(handles.detectionAxes,'XTickLabel',[]);
set(handles.detectionAxes,'XTick',[]);
set(handles.detectionAxes,'YTick',[]);
set(handles.spectogramWindow,'Parent',handles.hFig);

function varargout = DeepSqueak_OutputFcn(hObject, eventdata, handles)
shg;
varargout{1} = handles.output;

% --- Executes on button press in PlayCall.
function PlayCall_Callback(hObject, eventdata, handles)
% Play the sound within the boxs
audio =  handles.data.calls.Audio{handles.data.currentcall};
if ~isfloat(audio)
    audio = double(audio) / (double(intmax(class(audio)))+1);
elseif ~isa(audio,'double')
    audio = double(audio);
end

playbackRate = handles.data.calls.Rate(handles.data.currentcall) * handles.data.settings.playback_rate; % set playback rate

% Bandpass Filter
% audio = bandpass(audio,[handles.data.calls.RelBox(handles.data.currentcall, 2), handles.data.calls.RelBox(handles.data.currentcall, 2) + handles.data.calls.RelBox(handles.data.currentcall, 4)] * 1000,handles.data.calls.Rate(handles.data.currentcall));
paddedsound = [zeros(3125,1); audio; zeros(3125,1)];

soundsc(paddedsound,playbackRate);

%Set the default sizes for epoch and focus windows
handles.data.settings.focus_window_size = 0.5;
handles.data.settings.windowSize = 2;
handles.data.settings.spectogram_ticks = 11;

guidata(hObject, handles);

% --- Executes on button press in NextCall.
function NextCall_Callback(hObject, eventdata, handles)
if handles.data.currentcall(1) < height(handles.data.calls) % If not the last call
    handles.data.currentcall=handles.data.currentcall+1;
    handles.data.current_call_valid = true;
    handles.data.current_call_tag = num2str(handles.data.calls{handles.data.currentcall,'Tag'});
    handles.data.focusCenter = handles.data.calls.Box(handles.data.currentcall,1) + handles.data.calls.Box(handles.data.currentcall,3)/2;
    update_fig(hObject, eventdata, handles);
end
% guidata(hObject, handles);

% --- Executes on button press in PreviousCall.
function PreviousCall_Callback(hObject, eventdata, handles)
if handles.data.currentcall(1) >1 % If not the first call
    handles.data.currentcall=handles.data.currentcall-1;
    handles.data.current_call_valid = true;
    handles.data.current_call_tag = num2str(handles.data.calls{handles.data.currentcall,'Tag'});
    handles.data.focusCenter = handles.data.calls.Box(handles.data.currentcall,1) + handles.data.calls.Box(handles.data.currentcall,3)/2;
    update_fig(hObject, eventdata, handles);
end

% --- Executes on selection change in Networks Folder Pop up.
function neuralnetworkspopup_Callback(hObject, eventdata, handles)
guidata(hObject, handles);

% --- Executes during Networks Folder Pop up.
function neuralnetworkspopup_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in Audio Folder Pop up.
function AudioFilespopup_Callback(hObject, eventdata, handles)
guidata(hObject, handles);

% --- Executes during Audio Folder Pop up.
function AudioFilespopup_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in Detection Folder Pop up.
function popupmenuDetectionFiles_Callback(hObject, eventdata, handles)
guidata(hObject, handles);

% --- Executes during Detection Folder Pop up.
function popupmenuDetectionFiles_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in AcceptCall.
function AcceptCall_Callback(hObject, eventdata, handles)
handles.data.calls.Accept(handles.data.currentcall) = 1;
handles.update_position_axes = 1;
NextCall_Callback(hObject, eventdata, handles)

% --- Executes on button press in RejectCall.
function RejectCall_Callback(hObject, eventdata, handles)
handles.data.calls.Accept(handles.data.currentcall) = 0;
handles.update_position_axes = 1;
NextCall_Callback(hObject, eventdata, handles)

% --- Executes during MAIN AXES CREATION
function axes1_CreateFcn(hObject, eventdata, handles)

function slide_focus(focus_offset, hObject, eventdata, handles)
% Move the focus window one unit over
new_position = handles.data.focusCenter + focus_offset;
new_position = min(new_position, handles.data.audiodata.Duration - handles.data.settings.focus_window_size ./ 2);
new_position = max(new_position, handles.data.settings.focus_window_size ./ 2);
handles.data.focusCenter = new_position;

if new_position >= handles.data.windowposition + handles.data.settings.windowSize
    forwardButton_Callback(hObject, eventdata, handles);
elseif new_position < handles.data.windowposition
    backwardButton_Callback(hObject, eventdata, handles);
else
    calls_within_window = find(...
        handles.data.calls.Box(:,1) > new_position &...
        sum(handles.data.calls.Box(:,[1,3]),2) < handles.data.settings.focus_window_size);
    
    if ~isempty(calls_within_window)
        handles.data.currentcall = calls_within_window(1);
        
        handles.data.current_call_valid = true;
        handles.data.current_call_tag = num2str(handles.data.calls{handles.data.currentcall,'Tag'});
    end
    
    guidata(hObject,handles);
    update_fig(hObject, eventdata, handles);
end

function score_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function score_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function status_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function status_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on key press with focus on figure1 or any of its controls.
function figure1_WindowKeyPressFcn(hObject, eventdata, handles)
switch eventdata.Character
    case 'p'
        PlayCall_Callback(hObject, eventdata, handles)
    case {'e', 29} % char(29) is right arrow key
        NextCall_Callback(hObject, eventdata, handles)
    case {'q', 28} % char(28) is left arrow key
        PreviousCall_Callback(hObject, eventdata, handles)
    case 'a'
        AcceptCall_Callback(hObject, eventdata, handles)
    case 'r'
        RejectCall_Callback(hObject, eventdata, handles)
    case 'd'
        rectangle_Callback(hObject, eventdata, handles)
    case 30 % char(30) is up arrow key
        slide_focus(+ handles.data.settings.focus_window_size, hObject, eventdata, handles)
    case 31 % char(31) is down arrow key
        slide_focus(- handles.data.settings.focus_window_size, hObject, eventdata, handles)
    case 'space'
        forwardButton_Callback(hObject, eventdata, handles);
    case handles.data.labelShortcuts
        %% Update the call labels
        % Index of the shortcut
        idx = contains(handles.data.labelShortcuts, eventdata.Character);
        handles.data.calls.Type(handles.data.currentcall) = categorical(handles.data.settings.labels(idx));
        update_fig(hObject, eventdata, handles);
end
% drawnow

function figure1_KeyPressFcn(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function popupmenuColorMap_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function freq_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in rectangle.
function rectangle_Callback(hObject, eventdata, handles)
current_box = drawrectangle( 'Parent',handles.axes1,...
                            'FaceAlpha',0,...
                            'LineWidth',1 );
  
audio = handles.data.AudioSamples(current_box.Position(1), current_box.Position(1) + current_box.Position(3));
audio = audio - mean(audio,1);
new_tag = max(handles.data.calls.Tag) + 1;
% new_box = {handles.data.audiodata.SampleRate, current_box.Position, [0,0,0,0], 0, audio,0,0,1,new_tag };
new_box = table();
new_box.Rate = handles.data.audiodata.SampleRate;
new_box.Box = current_box.Position;
new_box.RelBox = calculateRelativeBox(current_box.Position, handles.axes1);
new_box.Score = 1;
new_box.Audio = {int16(audio*32767)};
new_box.Type = categorical({'USV'});
new_box.Power = 0;
new_box.Accept = 1;
new_box.Tag = new_tag;
handles.data.calls = [handles.data.calls;new_box];
set(current_box,'Tag',num2str(new_tag)); 
set(current_box,'Color',[0 1 0]);

%Now delete the roi and render the figure. The roi will be rendered along
%with the existing boxes.
handles.data.current_call_valid = true;
SortCalls(hObject, eventdata, handles, 'time', 0, -1);
guidata(hObject,handles);
delete(current_box)
update_fig(hObject, eventdata, handles)

guidata(hObject,handles);

% --------------------------------------------------------------------
function select_audio_Callback(hObject, eventdata, handles)
% Find audio in folder
path=uigetdir(handles.data.settings.audiofolder,'Select Audio File Folder');
if isnumeric(path);return;end
handles.data.settings.audiofolder = path;
handles.data.saveSettings();
update_folders(hObject, eventdata, handles);

% --------------------------------------------------------------------
function load_networks_Callback(hObject, eventdata, handles)
% Find networks
path=uigetdir(handles.data.settings.networkfolder,'Select Network Folder');
if isnumeric(path);return;end
handles.data.settings.networkfolder = path;
handles.data.saveSettings();
update_folders(hObject, eventdata, handles);

function load_detectionFolder_Callback(hObject, eventdata, handles)
% Find audio in folder
path=uigetdir(handles.data.settings.detectionfolder,'Select Detection File Folder');
if isnumeric(path);return;end
handles.data.settings.detectionfolder = path;
handles.data.saveSettings();
update_folders(hObject, eventdata, handles);

% --------------------------------------------------------------------
function folders_Callback(hObject, eventdata, handles)

% --------------------------------------------------------------------
function export_raven_Callback(hObject, eventdata, handles)
% Export current file as a txt file for viewing in Raven
% http://www.birds.cornell.edu/brp/raven/RavenOverview.html
raventable = [{'Selection'} {'View'} {'Channel'} {'Begin Time (s)'} {'End Time (s)'} {'Low Freq (Hz)'} {'High Freq (Hz)'} {'Delta Time (s)'} {'Delta Freq (Hz)'} {'Avg Power Density (dB FS)'} {'Annotation'}];
View = 'Spectrogram 1';
Channel = 1;
for i = 1:height(handles.data.calls)
    if handles.data.calls.Accept(i)
        Selection = i;
        BeginTime = handles.data.calls.Box(i, 1);
        EndTime = sum(handles.data.calls.Box(i ,[1, 3]));
        LowFreq = handles.data.calls.Box(i, 2) * 1000;
        HighFreq = sum(handles.data.calls.Box(i, [2, 4])) * 1000;
        DeltaTime = EndTime - BeginTime;
        DeltaFreq = HighFreq - LowFreq;
        AvgPwr = 1;
        Annotation = handles.data.calls.Accept(i);
        raventable = [raventable; {Selection} {View} {Channel} {BeginTime} {EndTime} {LowFreq} {HighFreq} {DeltaTime} {DeltaFreq} {AvgPwr} {Annotation}];
    end
end
a  = cell2table(raventable);
handles.current_file_id = get(handles.popupmenuDetectionFiles,'Value');
current_detection_file = handles.detectionfiles(handles.current_file_id).name;
ravenname=[strtok(current_detection_file,'.') '_Raven.txt'];
[FileName,PathName] = uiputfile(ravenname,'Save Raven Truth Table (.txt)');
writetable(a,[PathName FileName],'delimiter','\t','WriteVariableNames',false);
guidata(hObject, handles);

% --------------------------------------------------------------------
function export_Callback(hObject, eventdata, handles)

function training_Callback(hObject, eventdata, handles)

% --------------------------------------------------------------------
function customlabels_Callback(hObject, eventdata, handles)
% Define call categories
prompt = {
    'Label 1  --- Key 1'
    'Label 2  --- Key 2'
    'Label 3  --- Key 3'
    'Label 4  --- Key 4'
    'Label 5  --- Key 5'
    'Label 6  --- Key 6'
    'Label 7  --- Key 7'
    'Label 8  --- Key 8'
    'Label 9  --- Key 9'
    'Label 10  --- Key 0'
    'Label 11  --- Key -'
    'Label 12  --- Key ='
    'Label 13  --- Key !'
    'Label 14  --- Key "'
    'Label 15  --- Key #'   
    'Label 16  --- Key ¤'   
    'Label 17  --- Key &'
    'Label 18  --- Key /'    
    };

prompt = {
    'Label 1  --- Key 1'
    'Label 2  --- Key 2'
    'Label 3  --- Key 3'
    'Label 4  --- Key 4'
    'Label 5  --- Key 5'
    'Label 6  --- Key 6'
    'Label 7  --- Key 7'
    'Label 8  --- Key 8'
    'Label 9  --- Key 9'
    'Label 10  --- Key 0'
    'Label 11  --- Key ='
    'Label 12  --- Key +'
    'Label 13  --- Key !'
    'Label 14  --- Key "'
    'Label 15  --- Key #'   
    'Label 16  --- Key ¤'   
    'Label 17  --- Key &'
    'Label 18  --- Key /'    
    'Label 19  --- Key ('
    'Label 20  --- Key )'
    'Label 21  --- Key ='
    'Label 22  --- Key @'
    'Label 23  --- Key £'
    'Label 24  --- Key $'
    'Label 25  --- Key {'
    'Label 26  --- Key ['
    'Label 27  --- Key ]'
    'Label 28  --- Key }'
    'Label 29  --- Key §'
    'Label 30  --- Key *'     
    };

dlg_title = 'Set Custom Label Names';
num_lines=[1,60]; options.Resize='off'; options.WindowStyle='modal'; options.Interpreter='tex';
old_labels = handles.data.settings.labels;
new_labels = inputdlgcol(prompt,dlg_title,num_lines,old_labels,options,3);
if ~isempty(new_labels)
    handles.data.settings.labels = new_labels;
    handles.data.saveSettings();
    update_folders(hObject, eventdata, handles);
end
guidata(hObject, handles);

% --------------------------------------------------------------------
function Change_Playback_Rate_Callback(hObject, eventdata, handles)
prompt = {'Playback Rate: (default = 0.0.5)'};
dlg_title = 'Change Playback Rate';
num_lines=1; options.Resize='off'; options.WindowStyle='modal'; options.Interpreter='tex';
defaultans = {num2str(handles.data.settings.playback_rate)};
rate = inputdlg(prompt,dlg_title,num_lines,defaultans);
if isempty(rate); return; end

[newrate,~,errmsg] = sscanf(rate{1},'%f',1);
disp(errmsg);
if ~isempty(newrate)
    handles.data.settings.playback_rate = newrate;
    handles.data.saveSettings();
    update_folders(hObject, eventdata, handles);
end
guidata(hObject, handles);

% --------------------------------------------------------------------
function Change_Display_Range_Callback(hObject, eventdata, handles)
% Change the x and y axis in the spectrogram viewer
prompt = {'Low Frequency (kHz):', 'High Frequency (kHz):', 'Fixed Display Range (s) (Set to 0 to autoscale)'};
dlg_title = 'New Display Range:';
num_lines=[1 80]; options.Resize='off'; options.WindowStyle='modal'; options.Interpreter='tex';
defaultans = {num2str(handles.data.settings.LowFreq),num2str(handles.data.settings.HighFreq),num2str(handles.data.settings.DisplayTimePadding)};
dispRange = inputdlg(prompt,dlg_title,num_lines,defaultans);
if isempty(dispRange); return; end

[LowFreq,~,errmsg] = sscanf(dispRange{1},'%f',1);
disp(errmsg);
[HighFreq,~,errmsg] = sscanf(dispRange{2},'%f',1);
disp(errmsg);
[DisplayTimePadding,~,errmsg] = sscanf(dispRange{3},'%f',1);
disp(errmsg);
if ~isempty(LowFreq) && ~isempty(HighFreq) && ~isempty(DisplayTimePadding)
    if HighFreq > LowFreq
        handles.data.settings.LowFreq = LowFreq;
        handles.data.settings.HighFreq = HighFreq;
        %handles.data.settings.DisplayTimePadding = DisplayTimePadding;
        handles.data.saveSettings();
        update_folders(hObject, eventdata, handles);
        update_fig(hObject, eventdata, handles);
        
    else
        errordlg('High cutoff must be greater than low cutoff.')
    end
end
guidata(hObject, handles);

% --------------------------------------------------------------------
function Help_Callback(hObject, eventdata, handles)

% --------------------------------------------------------------------
function Untitled_3_Callback(hObject, eventdata, handles)

% --------------------------------------------------------------------
function CallClassification_Callback(hObject, eventdata, handles)

% --------------------------------------------------------------------
function ChangeContourThreshold_Callback(hObject, eventdata, handles)
% Change the contour threshold
prompt = {'Tonality Threshold: (default = 0.25)', 'Amplitude Threshold: (default = 0.075)'};
dlg_title = 'New Contour Threshold:';
num_lines=[1 50]; options.Resize='off'; options.WindowStyle='modal'; options.Interpreter='tex';
defaultans = {num2str(handles.data.settings.EntropyThreshold),num2str(handles.data.settings.AmplitudeThreshold)};
threshold = inputdlg(prompt,dlg_title,num_lines,defaultans);
if isempty(threshold); return; end

[Tonality,~,errmsg] = sscanf(threshold{1},'%f',1);
disp(errmsg);
[Amplitude,~,errmsg] = sscanf(threshold{2},'%f',1);
disp(errmsg);

if ~isempty(Tonality) && ~isempty(Amplitude)
    handles.data.settings.EntropyThreshold = Tonality;
    handles.data.settings.AmplitudeThreshold = Amplitude;
    handles.data.saveSettings();
    update_folders(hObject, eventdata, handles);
    try
        update_fig(hObject, eventdata, handles);
    catch
        disp('Could not update figure. Is a call loaded?')
    end
end
guidata(hObject, handles);

% --------------------------------------------------------------------
function ViewManual_Callback(hObject, eventdata, handles)
web('https://github.com/DrCoffey/DeepSqueak/wiki','-browser');

% --------------------------------------------------------------------
function AboutDeepSqueak_Callback(hObject, eventdata, handles)
title = 'About DeepSqueak';

d = dialog('Position',[300 350 500  600],'Name',title,'WindowStyle','Normal','Visible', 'off','Color', [0,0,0]);
movegui(d,'center');
ha = axes(d,'Units','Normalized','Position',[0,0,1,1]);

A = zeros(128);
A = insertText(A,[64,20],'Coffey & Marx, 2019','TextColor','white','BoxColor','Black','AnchorPoint','Center','FontSize',11);
A = insertText(A,[64,64],'DeepSqueak','TextColor','white','BoxColor','Black','AnchorPoint','Center');
A = insertText(A,[64,80],['Version ' handles.DSVersion],'TextColor','white','BoxColor','Black','AnchorPoint','Center','FontSize',11);

A = A(:,:,1);

P = [64, 64];
D = 3;
T = [1,0,-1,0;0,1,0,-1];	% 4 directions
k = 0;

handle_image = imshow(A,[0,1],'parent',ha);

btn = uicontrol('Parent',d,...
    'Units','Normalized',...
    'Position',[.42 .01 .16 .06],...
    'String','Okay',...
    'Callback','delete(gcf)');
set(d,'Visible','on')

while isvalid(handle_image)
    k = k+1;
    a = A(P(1),P(2));
    A(P(1),P(2)) = ~a;
    if ( a )
        D = mod(D+1,4);
    else
        D = mod(D-1,4);
    end
    P = P+T(:,D+1);
    handle_image.CData = A;
    pause(.01)
end

% --- Executes on slider movement.
function TonalitySlider_Callback(hObject, eventdata, handles)
handles.data.settings.EntropyThreshold=(get(hObject,'Value'));
handles.data.saveSettings();
update_fig(hObject, eventdata, handles);

% --- Executes during object creation, after setting all properties.
function TonalitySlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TonalitySlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

function Manifesto_Callback(hObject, eventdata, handles)
% Open the file

% If a text file
if exist(fullfile(handles.data.squeakfolder,'Manifestos',[hObject.Text '.txt']),'file') == 2
    fname = fullfile(handles.data.squeakfolder,'Manifestos',[hObject.Text '.txt']);
    fid = fopen(fname);
    chr = fscanf(fid,'%c');
    % Remove extra line end chars
    chr = strrep(chr,char(10),'');
    fprintf(1,'\n\n\n\n\n\n\n\n\n');
    fprintf(1,'%c',chr);
    fprintf(1,'\n\n');
    
    fclose(fid);
    
    % Display
    S.fh = figure('units','pixels',...
        'position',[40 40 760 640],...
        'menubar','none',...
        'resize','on',...
        'numbertitle','off',...
        'name',hObject.Text);
    S.tx = uicontrol('style','edit',...
        'units','pix',...
        'position',[10 10 750 630],...
        'backgroundcolor','w',...
        'HorizontalAlign','left',...
        'min',0,'max',10,...
        'String',chr,...
        'FontName','Courier',...
        'FontSize',11,...
        'BackgroundColor',[0,0,.1],...
        'ForegroundColor',[.6,1,1],...
        'enable','inactive');
    % If a pdf
elseif  exist(fullfile(handles.data.squeakfolder,'Manifestos',[hObject.Text '.pdf']),'file') == 2
    fname = fullfile(handles.data.squeakfolder,'Manifestos',[hObject.Text '.pdf']);
    open(fname)
elseif  strcmp(hObject.Text,'Read the Paper')
    fname = fullfile(handles.data.squeakfolder,'DeepSqueak.pdf');
    open(fname)
end

% --------------------------------------------------------------------
function submit_a_bug_Callback(hObject, eventdata, handles)
% hObject    handle to submit_a_bug (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
web('https://github.com/UEFepilepsyAIVI/DeepSqueak/issues','-browser');

% --- Executes on slider movement.
function optimization_slider_Callback(hObject, eventdata, handles)
hObject.Value = round(hObject.Value);

% --- Executes on button press in backwardButton.
function backwardButton_Callback(hObject, eventdata, handles)
% handles.data.windowposition = max(0, handles.data.windowposition - handles.data.settings.windowSize);
handles.data.focusCenter = max(0, handles.data.windowposition - handles.data.settings.focus_window_size ./ 2);
% get_closest_call_to_focus(hObject, eventdata, handles);

jumps = floor(handles.data.focusCenter / handles.data.settings.windowSize);
handles.data.windowposition = jumps*handles.data.settings.windowSize;

calls_within_window = find(handles.data.calls.Box(:,1) < handles.data.windowposition + handles.data.settings.windowSize, 1, 'last');
if ~isempty(calls_within_window)
    handles.data.currentcall = calls_within_window;
    handles.data.current_call_valid = true;
    handles.data.current_call_tag = num2str(handles.data.calls{handles.data.currentcall,'Tag'});
end

update_fig(hObject, eventdata, handles);


% --- Executes on button press in forwardButton.
function forwardButton_Callback(hObject, eventdata, handles)
% handles.data.windowposition = min(handles.data.audiodata.Duration - handles.data.settings.windowSize, handles.data.windowposition + handles.data.settings.windowSize);
handles.data.focusCenter = handles.data.windowposition + handles.data.settings.windowSize + handles.data.settings.focus_window_size ./ 2;
handles.data.focusCenter = min(handles.data.focusCenter, handles.data.audiodata.Duration - handles.data.settings.focus_window_size ./ 2);

jumps = floor(handles.data.focusCenter / handles.data.settings.windowSize);
handles.data.windowposition = jumps*handles.data.settings.windowSize;

% handles.data.focusCenter = max(0, handles.data.windowposition - handles.data.settings.focus_window_size ./ 2);
% get_closest_call_to_focus(hObject, eventdata, handles);

calls_within_window = find(handles.data.calls.Box(:,1) > handles.data.windowposition, 1);
if ~isempty(calls_within_window)
    handles.data.currentcall = calls_within_window;
    handles.data.current_call_valid = true;
    handles.data.current_call_tag = num2str(handles.data.calls{handles.data.currentcall,'Tag'});
end

update_fig(hObject, eventdata, handles);
% guidata(hObject, handles);

function get_closest_call_to_focus(hObject, eventdata, handles)
calls_within_window = find(...
    handles.data.calls.Box(:,1) > handles.data.windowposition &...
    sum(handles.data.calls.Box(:,[1,3]),2) < handles.data.windowposition + handles.data.settings.windowSize);
if ~isempty(calls_within_window)
    callMidpoints = handles.data.calls.Box(calls_within_window,1) + handles.data.calls.Box(calls_within_window,3)/2;
    [~, closestCall] = min(abs(callMidpoints - handles.data.focusCenter));
    handles.data.currentcall = calls_within_window(closestCall);
    handles.data.current_call_valid = true;
    handles.data.current_call_tag = num2str(handles.data.calls{handles.data.currentcall,'Tag'});
end
update_fig(hObject, eventdata, handles);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function epochWindowSizePopup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to epochWindowSizePopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
padding = cellstr(get(hObject,'String')); 
seconds = regexp(padding{get(hObject,'Value')},'([\d*.])*','match');
seconds = str2num(seconds{1});
handles.data.settings.windowSize = seconds;
guidata(hObject, handles);

% --- Executes on mouse press over axes background.
function spectogramWindow_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to spectogramWindow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes on selection change in spectogramScalePopup.
function spectogramScalePopup_Callback(hObject, eventdata, handles)
% hObject    handle to spectogramScalePopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns spectogramScalePopup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from spectogramScalePopup
update_fig(hObject, [], handles);

% --- Executes during object creation, after setting all properties.
function spectogramScalePopup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to spectogramScalePopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function SpectogramMax_Callback(hObject, eventdata, handles)
% hObject    handle to SpectogramMax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    set(hObject, 'String', num2str(get_spectogram_max(hObject, handles))); 
    guidata(hObject,handles);
    update_fig(hObject, [], handles);

% --- Executes during object creation, after setting all properties.
function SpectogramMax_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SpectogramMax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function focusWindowSizePopup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to focusWindowSizePopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

padding = cellstr(get(hObject,'String')); 
seconds = regexp(padding{get(hObject,'Value')},'([\d*.])*','match');
seconds = str2double(seconds{1});
handles.data.settings.focus_window_size = seconds;
guidata(hObject, handles);

% --- Executes on button press in topLeftButton.
function topLeftButton_Callback(hObject, eventdata, handles)
% hObject    handle to topLeftButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    slide_focus(handles.data.settings.focus_window_size*(-1), hObject, eventdata, handles)

% --- Executes on button press in topRightButton.
function topRightButton_Callback(hObject, eventdata, handles)
% hObject    handle to topRightButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    slide_focus(handles.data.settings.focus_window_size*(1), hObject, eventdata, handles)

% --- Executes on button press in loadAudioFile.
function loadAudioFile_Callback(hObject, eventdata, handles)
h = waitbar(0,'Loading Audio Please wait...');
update_folders(hObject, eventdata, handles);
handles = guidata(hObject);
if nargin == 3 % if "Load Calls" button pressed
    handles.current_file_id = get(handles.AudioFilespopup,'Value');
    handles.current_audio_file = handles.audiofiles(handles.current_file_id).name;
end

% try
audio_info = audioinfo(fullfile(handles.data.settings.audiofolder,handles.current_audio_file));

Calls = table('Size',[1, 8], 'VariableTypes',...
    {'double',...
    'double',...
    'double',...
    'double',...
    'cell',...
    'categorical',...
    'double',...
    'logical'},...
    'VariableNames',...
    {'Rate',...
    'Box',...
    'RelBox',...
    'Score',...
    'Audio',...
    'Type',...
    'Power',...
    'Accept'});

Calls.Rate=audio_info.SampleRate;
Calls.Box=[0 0 1 1];
Calls.RelBox=[0 0 1 1];
Calls.Score=0;
Calls.Type=categorical({'NA'});
Calls.Power=1;
Calls.Accept=0;

handles.data.calls = Calls;
tag_column_exists = strcmp('Tag',handles.data.calls.Properties.VariableNames);
if  ~tag_column_exists
    handles.data.calls.Tag =  [1:size(handles.data.calls,1)]';
end

handles.data.audiodata = audio_info;

guidata(hObject, handles);
initialize_display(hObject, eventdata, handles);
handles = guidata(hObject);

close(h);
update_fig(hObject, eventdata, handles);

% catch
%    disp('WARNING: No Audio Folder Selected'); 
% end


% --- Executes during object creation, after setting all properties.
function detectionAxes_CreateFcn(hObject, eventdata, handles)
% hObject    handle to detectionAxes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

function popupmenuColorMap_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuColorMap (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

function freqUpper_Callback(hObject, eventdata, handles)
% hObject    handle to freqUpper (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%     set(hObject, 'String', num2str(get_spectogram_max(hObject, handles)));
%     guidata(hObject,handles);
%     update_fig(hObject, [], handles);
HighFreq=str2double(get(hObject,'String'));
try
    handles.data.settings.HighFreq = HighFreq;
    update_fig(hObject, eventdata, handles);
catch
    errordlg('High cutoff must be greater than low cutoff.')
end
% Hints: get(hObject,'String') returns contents of freqUpper as text
%        str2double(get(hObject,'String')) returns contents of freqUpper as a double

% --- Executes during object creation, after setting all properties.
function freqUpper_CreateFcn(hObject, eventdata, handles)
% hObject    handle to freqUpper (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function freqLower_Callback(hObject, eventdata, handles)
% hObject    handle to freqLower (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
LowFreq = str2double(get(hObject,'String'));
if handles.data.settings.HighFreq > LowFreq
    handles.data.settings.LowFreq = LowFreq;
    update_fig(hObject, eventdata, handles);
else
    errordlg('High cutoff must be greater than low cutoff.')
end
% Hints: get(hObject,'String') returns contents of freqLower as text
%        str2double(get(hObject,'String')) returns contents of freqLower as a double

% --- Executes during object creation, after setting all properties.
function freqLower_CreateFcn(hObject, eventdata, handles)
% hObject    handle to freqLower (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over loadcalls.
function loadcalls_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to loadcalls (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes on button press in callBackward.
function callBackward_Callback(hObject, eventdata, handles)
if handles.data.currentcall>1 % If not the first call
    handles.data.currentcall=handles.data.currentcall-1;
    handles.data.focusCenter = handles.data.windowposition + handles.data.settings.windowSize - handles.data.settings.focus_window_size ./ 2;
    update_fig(hObject, eventdata, handles);
end

% --- Executes on button press in callForward.
function callForward_Callback(hObject, eventdata, handles)
if handles.data.currentcall < height(handles.data.calls) % If not the last call
    handles.data.currentcall=handles.data.currentcall+1;
    update_focus_display(hObject, handles);
    update_fig(hObject, eventdata, handles);
end
% hObject    handle to callForward (see GCBO)

% --------------------------------------------------------------------
function contributorToolsMenu_Callback(hObject, eventdata, handles)
% hObject    handle to contributorToolsMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Untitled_2_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
