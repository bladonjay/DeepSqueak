function savesession_Callback(hObject, eventdata, handles)

handles.v_det = get(handles. popupmenuDetectionFiles,'Value');
try
    handles.SaveFile = handles.detectionfiles(handles.v_det).name;
    handles.SaveFile = handles.current_detection_file;
    Calls = handles.data.calls;
    callsMetaData=handles.data.callsMetaData;
catch
    fprintf('Didnt Save, no file to save \n');
    return
end



[FileName, PathName] = uiputfile(fullfile(handles.data.settings.detectionfolder, handles.SaveFile), 'Save Session (.mat)');
if FileName == 0
    return
end
h = waitbar(0.5, 'saving');


save(fullfile(PathName, FileName), 'Calls', 'callsMetaData', '-v7.3');

update_folders(hObject, eventdata, handles);
guidata(hObject, handles);
close(h);
