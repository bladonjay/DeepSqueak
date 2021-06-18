function [Calls,callsMetadata] = loadCallfile(filename)

load(filename, 'Calls', 'callsMetadata');

% Backwards compatibility with struct format for detection files
if isstruct(Calls); Calls = struct2table(Calls, 'AsArray', true); end
if isempty(Calls); disp(['No calls in file: ' filename]); end
