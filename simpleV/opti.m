
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

figure('Position',[100 100 800 800 ])
grid on
axis equal
ax = gca;
view(25, 25)
axis([-0.5 0.5 -0.5 0.5  -0.5 0.5 ]*1)
xlabel('x-axis')
ylabel('y-axis')
zlabel('z-axis')

% Construct initial handles
hold on
hmdFrameH = plotFrame3([],[0 0 0],[1 0 0 0],[1 0 0 0]);

mPosH = plot3(0,0,0,'ko','MarkerFaceColor','r');




for i = 1:1:N1
    data = tData(i);
    
    
    
   
    mvector=transformation(data.mPos',data.hmdRot,data.hmdPos');
    set(mPosH,'XData',mvector(1),'YData',mvector(2),'ZData',mvector(3)); 
    
    
    hmdFrameHH= transformation(data.hmdPos',data.hmdRot,data.hmdPos');
    
    
    hmdFrameH = plotFrame3(hmdFrameH,hmdFrameHH,data.hmdRot,data.hmdRot);
    
    drawnow

end