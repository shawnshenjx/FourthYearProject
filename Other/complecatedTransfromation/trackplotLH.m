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

tline = fgetl(fid);



while ischar(tline)
    % Split data row into columns
    cols = str2double(strsplit(tline,','));
    
    % Assemble new data structure for sample
    data = struct;
    
    
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

%% Plot example fingertip trace
% Set up the figure
figure('Position',[100 100 800 800 ])
grid on
axis equal
ax = gca;
view(150, 25)
axis([-0.5 0.5 -0.5 0.5 -0.5 0.5]*3000)
xlabel('x-axis')
ylabel('y-axis')
zlabel('z-axis')

% Construct initial handles
hold on
hmdFrameH = plotFrameL([],[0 0 0],[1 0 0 0]); %why starts from zero
m1PosH = plot3(0,0,0,'ko','MarkerFaceColor','b');
m2PosH = plot3(0,0,0,'ko','MarkerFaceColor','r');
N = size(tData,1);

% Loop over samples
for i = 1:1:N
    data = tData(i);
    set(m1PosH,'XData',data.m1Pos(1)*1000,'YData',data.m1Pos(2)*1000,'ZData',data.m1Pos(3)*1000); 
    set(m2PosH,'XData',data.m2Pos(1)*1000,'YData',data.m2Pos(2)*1000,'ZData',data.m2Pos(3)*1000);
    hmdFrameH = plotFrameL(hmdFrameH,data.hmdPos*1000,data.hmdRot);
    
    
    drawnow 
end


