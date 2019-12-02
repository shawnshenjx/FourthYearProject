
clear all
close all

addpath('Functions')


addpath('NEWDATA')
% Open tracking log
filename = 'kb_shape_slowOP.csv';
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
    

    offset=[0 0.05 0.03];
    data.hmdPos = (cols(7:9)-offset)*1000;
    data.hmdRot = cols(3:6);
    
    data.mPos = cols(10:12)*1000;
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
rotate3d on
view(25, 25)
axis([-0.5 0.5 -0.5 0.5  -0.5 0.5 ]*50000)
xlabel('x-axis')
ylabel('y-axis')
zlabel('z-axis')

% Construct initial handles
hold on
hmdFrameH = plotFrame3([],[0 0 0],[1 0 0 0],[1 0 0 0]);

mPosH = plot3(0,0,0,'ko','MarkerFaceColor','r');

mtrace1=zeros(1);
mtrace2=zeros(1);
mtrace3=zeros(1);


for i = 1:1:N1
    data = tData(i);
    
    
    
   
    mvector=transformation(data.mPos',data.hmdRot,data.hmdPos');
    set(mPosH,'XData',mvector(1),'YData',mvector(2),'ZData',mvector(3)); 
    
    
    mtrace1=[mtrace1,mvector(1)];
    mtrace2=[mtrace2,mvector(2)];
    mtrace3=[mtrace3,mvector(3)];
    plot3(mtrace1(1,2:end),mtrace2(1,2:end),mtrace3(1,2:end))
    
    hmdFrameHH= transformation(data.hmdPos',data.hmdRot,data.hmdPos');
    
    
    hmdFrameH = plotFrame3(hmdFrameH,hmdFrameHH,data.hmdRot,data.hmdRot);
    
    drawnow

end