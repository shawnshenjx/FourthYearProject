
clear all
close all

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
    
    
    data.hmdPos = cols(7:9);
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






figure('Position',[100 100 800 800 ])
grid on
axis equal
ax = gca;
view(-150, -100)
axis([-0.5 0.5 -0.5 0.5  -0.5 0.5 ]*10)
xlabel('x-axis')
ylabel('y-axis')
zlabel('z-axis')
% Construct initial handles
hold on
% hmdFrame = plotFrame([],[0 0 0],[1 0 0 0]); %why starts from zero

hmdFrameH = plotFrame3([],[0 0 0],[1 0 0 0],[1 0 0 0]);
hmdFrameH1 = plotFrame3([],[0 0 0],[1 0 0 0],[1 0 0 0]);
mPosH = plot3(0,0,0,'ko','MarkerFaceColor','r');
m1PosH = plot3(0,0,0,'ko','MarkerFaceColor','r');
m2PosH = plot3(0,0,0,'ko','MarkerFaceColor','r');


N2 = size(tData1,1);


N=min([N1 N2]);
for i = 1:1:N
    data = tData(2*i);
    data1 = tData1(i);
   
    
   
    mvector=transformation(data.mPos',data.hmdRot,data.hmdPos');
    set(mPosH,'XData',mvector(1),'YData',mvector(2),'ZData',mvector(3)); 
    
    
    m1vector=transformationL(data1.m1Pos',data1.hmdRot,data1.hmdPos');
    set(m1PosH,'XData',m1vector(1),'YData',m1vector(2),'ZData',m1vector(3)); 
    
    m2vector=transformationL(data1.m2Pos',data1.hmdRot,data1.hmdPos');
    set(m2PosH,'XData',m2vector(1),'YData',m2vector(2),'ZData',m2vector(3)); 
    
    
    
    

    hmdFrameHH= transformation(data.hmdPos',data.hmdRot,data.hmdPos');
    
    
    hmdFrameH = plotFrame3(hmdFrameH,hmdFrameHH,data.hmdRot,data.hmdRot);
    
    
    
    hmdFrameHH1= transformationL(data1.hmdPos',data1.hmdRot,data1.hmdPos');
    
    
    hmdFrameH1 = plotFrame3L(hmdFrameH1,hmdFrameHH1,data1.hmdRot,data1.hmdRot);
    
    
    drawnow
%     kbFrameHH= transformationE(data.kbPos',data.kbRot,data.kbPos');
%     
%     
%     hmdFrameH = plotFrame3(hmdFrameH,hmdFrameHH,data.hmdRot,data.hmdRot);
    
    
    
    
end

