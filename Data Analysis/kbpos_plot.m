


addpath('Functions')


addpath('evenlog')

filename = 'event-log_is_she_done_yet_191220_032711.csv';
fid = fopen(filename);

% Data to populate from file
tData = [];

% Read first line of file, discard header
tline = fgetl(fid);

tline = fgetl(fid);

while ischar(tline)
    % Split data row into columns
    cols = str2double(strsplit(tline,','));
    
    % Assemble new data structure for sample
    data = struct;
    

    data.hmdPos = cols(1:3);
    data.hmdRot = cols(4:7);
    data.kbPos = cols(8:10);
    data.kbRot = cols(11:14);
	
	
	data.rbPos = cols(15:17);
    data.rbRot = cols(18:21);
	
	
    data.t = cols(2);
    
    % Append sample
    tData = [tData; data];
    
    % Get next line
    tline = fgetl(fid);
end

N = size(tData,1);



for i = 1:1:N
    data = tData(i);

    [kbpos,kbquat]=transformationholo(data.kbPos',data.kbRot,data.hmdRot,data.hmdPos');

    %[kbposnew,kbquatnew]=transformationop(kbpos,kbquat,data.hmdRot,data.hmdPos);
    offset=[-0.02 -0.05 -0.04];
    [kbposnew,kbquatnew]=transformationop(kbpos,kbquat,data.hmdRot,data.hmdPos+offset);
    kbposnew

end


