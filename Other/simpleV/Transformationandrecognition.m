clear all

addpath('Functions')


addpath('Data')
% Open tracking log



filename = 'dummy_trace.csv';
fid = fopen(filename);

% Data to populate from file
tData = [];

% Read first line of file, discard header
tline = fgetl(fid);
tline = fgetl(fid);
tline = fgetl(fid);
tline = fgetl(fid);
tline = fgetl(fid);
tline = fgetl(fid);
tline = fgetl(fid);
tline = fgetl(fid);

while ischar(tline)
    % Split data row into columns
    cols = str2double(strsplit(tline,','));
    
    % Assemble new data structure for sample
    data = struct;
    
    offset=[0 0.05 0];
    
    data.hmdPos = cols(7:9)-offset;
    data.hmdRot = cols(3:6);
    
    data.mPos = cols(10:12);
    data.t = cols(2);
    
    % Append sample
    tData = [tData; data];
    
    % Get next line
    tline = fgetl(fid);
end

N1 = size(tData,1);








filename = 'trace1.csv';




fid = fopen(filename);

% Data to populate from file
tData1 = [];

% Read first line of file, discard header
tline = fgetl(fid);
col = str2double(strsplit(tline,','));
data1 = struct;
data1.kbPos=col(2:4);
data1.kbRot=col(6:8);
tline = fgetl(fid);
tline = fgetl(fid);

cols1 = str2double(strsplit(tline,','));
initialtime=cols1(14);
while ischar(tline)
    % Split data row into columns
    cols = str2double(strsplit(tline,','));
    
    % Assemble new data structure for sample
    
    
    
    
    
    data1.hmdPos = cols(11:13);
    data1.hmdRot = cols(7:10);
    
    data1.m1Pos = cols(1:3);
    data1.m2Pos = cols(4:6);
    data1.t = cols(14);
    
    % Append sample
    tData1 = [tData1; data1];
    
    % Get next line
    tline = fgetl(fid);
end









% type holokeyboard.txt;


fileID = fopen('holokeyboard.txt','r');

C = textscan(fileID,'%s %f %f %f %f','Delimiter',';');

A=size(C{1});
keySet=strings(1,A(1));
% keycod=zeros(1,A(1));
% xcenter=zeros(1,A(1));
% ycenter=zeros(1,A(1));
% width=zeros(1,A(1));
% height=zeros(1,A(1));
valueSet=cell(1,A(1));
for i = 2:1:A(1)
    keySet(i)=C{1}{i};
        

    xcenter=C{2}(i);
    ycenter=C{3}(i);
    width=C{4}(i);
    height=C{5}(i);
    
    valueSet{i}{1} = [xcenter,ycenter,width,height];
end



M = containers.Map(keySet,valueSet);




for i = 1:1:N
    
    
  data = tData(i);
  data1 = tData1(2*i);
   
    
   
  mvector=transformation(data.mPos',data.hmdRot,data.hmdPos');
  
  
  KBpos=transformation(mvector,data1.hmdRot,data1.hmdPos');
  
  
  mvector1=transformation(mvector,data1.kbRot,KBpos);
  
  
  if norm(mvector1-M('w'))<L
      disp{'w'}
  if norm(mvector1-M('o'))<L
      disp{'o'}

end
