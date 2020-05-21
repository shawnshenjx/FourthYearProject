function [keys] = parseLayout(layoutFile)
%PARSELAYOUT Summary of this function goes here
%   Detailed explanation goes here

if nargin < 1
    layoutFile = 'data/holokeyboard.txt';
end

keys = [];

layoutText = fileread(layoutFile);

lines = strsplit(layoutText,'\n');

for i = 1:size(lines,2)
    line = char(lines{i});
    
    if (isempty(line) || line(1) == '#')
        continue;
    else
        cols = strsplit(line,';');
        
        if (size(cols,2) == 5)
            keyLabel = char(cols(1));        
            keyPos = [str2double(cols(2)) str2double(cols(3))];
            keySize = [str2double(cols(4)) str2double(cols(5))];

            key = struct;
            key.label = keyLabel;
            key.pos = keyPos;
            key.size = keySize;

            keys = [keys; key];
        end
    end
end

end

