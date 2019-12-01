
clear all
close all

addpath('Functions')


addpath('Data')
% Open tracking log

filename = 'trace1.csv';
fid = fopen(filename);

% Data to populate from file
tData = [];

% Read first line of file, discard header
tline = fgetl(fid);
col = str2double(strsplit(tline,','));
data = struct;
data.kbPos=col(2:4);
data.kbRot=col(6:8);
tline = fgetl(fid);
tline = fgetl(fid);

cols1 = str2double(strsplit(tline,','));
initialtime=cols1(14);
while ischar(tline)
    % Split data row into columns
    cols = str2double(strsplit(tline,','));
    
    % Assemble new data structure for sample
    
    
    
    data.hmdPos = cols(11:13);
    data.hmdRot = cols(7:10);
    
    data.m1Pos = cols(1:3);
    data.m2Pos = cols(4:6);
    data.t = cols(14);
    
    % Append sample
    tData = [tData; data];
    
    % Get next line
    tline = fgetl(fid);
end






figure('Position',[100 100 800 800 ])
grid on
axis equal
ax = gca;
view(25, 25)
axis([-0.5 0.5 -0.5 0.5  -0.5 0.5 ]*10)
xlabel('x-axis')
ylabel('y-axis')
zlabel('z-axis')
% Construct initial handles
hold on
% hmdFrame = plotFrame([],[0 0 0],[1 0 0 0]); %why starts from zero

hmdFrameH = plotFrame3([],[0 0 0],[1 0 0 0],[1 0 0 0]);


m1PosH = plot3(0,0,0,'ko','MarkerFaceColor','r');
m2PosH = plot3(0,0,0,'ko','MarkerFaceColor','r');


N2 = size(tData,1);



for i = 1:1:N2
    data = tData(i);
    
   
    m1vector=transformation(data.m1Pos',data.hmdRot,data.hmdPos');
    set(m1PosH,'XData',m1vector(1),'YData',m1vector(2),'ZData',m1vector(3)); 
    
    m2vector=transformation(data.m2Pos',data.hmdRot,data.hmdPos');
    set(m2PosH,'XData',m2vector(1),'YData',m2vector(2),'ZData',m2vector(3)); 
    
    
    
    

    hmdFrameHH= transformation(data.hmdPos',data.hmdRot,data.hmdPos');
    
    
    hmdFrameH = plotFrame3(hmdFrameH,hmdFrameHH,data.hmdRot,data.hmdRot);
    
    
    
%     kbFrameHH= transformationE(data.kbPos',data.kbRot,data.kbPos');
%     
%     
%     hmdFrameH = plotFrame3(hmdFrameH,hmdFrameHH,data.hmdRot,data.hmdRot);
    
    
    
    
end





