function [Calls,callsMetadata] = loadCallfile(filename)

try
    load(filename, 'Calls', 'callsMetadata');
catch
    load(filename, 'Calls');
end
% Backwards compatibility with struct format for detection files
if isstruct(Calls); Calls = struct2table(Calls, 'AsArray', true); end
if isempty(Calls); disp(['No calls in file: ' filename]); end
