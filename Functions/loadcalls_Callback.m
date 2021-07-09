% --- Executes on button press in LOAD CALLS.

function loadcalls_Callback(hObject, eventdata, handles,call_file_number)


update_folders(hObject, eventdata, handles);
handles = guidata(hObject);
if nargin == 3 % if "Load Calls" button pressed
    handles.current_file_id = get(handles.popupmenuDetectionFiles,'Value');
    handles.current_detection_file = handles.detectionfiles(handles.current_file_id).name;
end

h = waitbar(0,sprintf('Loading Call file %s \n Please wait...', handles.current_detection_file));


% load the audiofile data, maybe also load the audio data too...

handles.data.calls = [];

%handles.data.callsAudio=[];
%[handles.data.calls, handles.data.callsAudio] = loadCallfile(fullfile(handles.detectionfiles(handles.current_file_id).folder,  handles.current_detection_file));


handles.data.currentcall=1;

% now here I think I need to also merge the calls...
[handles.data.calls, handles.data.callsMetadata] = loadCallfile(fullfile(handles.detectionfiles(handles.current_file_id).folder,  handles.current_detection_file));

% does metadata have a valid filename?
try
    assert(isfile(handles.data.callsMetadata.Filename));
catch
    % find the file on your own
    try
        callfile=fullfile(handles.detectionfiles(handles.current_file_id).folder,  handles.current_detection_file);
        % find all the files in that folder that are .wav files
        candidates=getAllFiles(handles.detectionfiles(handles.current_file_id).folder,'.wav');
        % find the original wav file that contains 100% of the filename
        for i=1:length(candidates)
            matchct(i)=startsWith(callfile,candidates{i}(1:end-4));
        end
        handles.data.callsMetadata=audioinfo(candidates{matchct});
    catch
        % if no more options, ask
    [mf,md]=uigetfile('.wav',sprintf('Load wav file matching %s',handles.detectionfiles(handles.current_file_id).name));
    handles.data.callsMetadata=audioinfo(fullfile(md,mf));
    end
end
% now remerge all the calls to see if any are overlapping
handles.data.calls = Automerge_Callback(handles.data.calls, [], [], handles.data.callsMetadata);


cla(handles.axes7);
cla(handles.axes5);
cla(handles.axes1);
cla(handles.axes4);
cla(handles.axes3);
%% Create plots for update_fig to update

% Waveform
handles.Waveform = line(handles.axes3,1,1,'Color',[.1 .75 .75]);
handles.SNR = surface(handles.axes3,[],[],[],[],...
    'facecol','r',...
    'edgecol','interp',...
    'linew',2);
set(handles.axes3,'YTickLabel',[]);
set(handles.axes3,'XTickLabel',[]);
set(handles.axes3,'XTick',[]);
set(handles.axes3,'YTick',[]);
set(handles.axes3,'Color',[.1 .1 .1],'YColor',[1 1 1],'XColor',[1 1 1],'Box','off','Ylim',[-1 0],'Clim',[0 1]);

% Contour
handles.ContourScatter = scatter(1:5,1:5,'LineWidth',1.5,'Parent',handles.axes7,'XDataSource','x','YDataSource','y');
set(handles.axes7,'Color',[.1 .1 .1],'YColor',[1 1 1],'XColor',[1 1 1],'Box','off');
set(handles.axes7,'YTickLabel',[]);
set(handles.axes7,'XTickLabel',[]);
set(handles.axes7,'XTick',[]);
set(handles.axes7,'YTick',[]);
handles.ContourLine = line(handles.axes7,[1,5],[1,5],'LineStyle','--','Color','y');

% Spectrogram
handles.spect = imagesc([],[],handles.background,'Parent', handles.axes1);
cb=colorbar(handles.axes1);
cb.Label.String = 'Amplitude';
cb.Color = [1 1 1];
cb.FontSize = 12;
ylabel(handles.axes1,'Frequency (kHz)','Color','w');
xlabel(handles.axes1,'Time (s)','Color','w');
set(handles.axes1,'Color',[.1 .1 .1]);
handles.box=rectangle('Position',[1 1 1 1],'Curvature',0.2,'EdgeColor','g',...
    'LineWidth',3,'Parent', handles.axes1);

% Filtered image
handles.filtered_image_plot = imagesc([],'Parent', handles.axes4);
set(handles.axes4,'Color',[.1 .1 .1],'YColor',[1 1 1],'XColor',[1 1 1],'Box','off');
set(handles.axes4,'YTickLabel',[]);
set(handles.axes4,'XTickLabel',[]);
set(handles.axes4,'XTick',[]);
set(handles.axes4,'YTick',[]);


% Plot Call Position
CallTime = handles.data.calls.Box(:,1);

line([0 max(CallTime)],[0 0],'LineWidth',1,'Color','w','Parent', handles.axes5);
line([0 max(CallTime)],[1 1],'LineWidth',1,'Color','w','Parent', handles.axes5);
set(handles.axes5,'XLim',[0 max(CallTime)]);
set(handles.axes5,'YLim',[0 1]);

set(handles.axes5,'Color',[.1 .1 .1],'YColor',[.1 .1 .1],'XColor',[.1 .1 .1],'Box','off','Clim',[0 1]);
set(handles.axes5,'YTickLabel',[]);
set(handles.axes5,'XTickLabel',[]);
set(handles.axes5,'XTick',unique(sort(CallTime)));
set(handles.axes5,'YTick',[]);
handles.axes5.XAxis.Color = 'w';
handles.axes5.XAxis.TickLength = [0.035 1];

% Call position
handles.CurrentCallLinePosition = line([CallTime(1) CallTime(1)],[0 1],'LineWidth',3,'Color','g','Parent', handles.axes5);
handles.CurrentCallLineLext= text((CallTime(1)),1.2,[num2str(1,'%.1f') ' s'],'Color','W', 'HorizontalAlignment', 'center','Parent',handles.axes5);

colormap(handles.axes1,handles.data.cmap);
colormap(handles.axes4,handles.data.cmap);

close(h);
update_fig(hObject, eventdata, handles);
guidata(hObject, handles);
