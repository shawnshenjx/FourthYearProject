
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
% hmdPosmatrix=zeros(4,num);
% for i = 1:num
%     
% %   transmatrix = constructHT(roll,pitch,yaw,x,y,z);
%     hmdPos=tData.hmdPos;
%     hmdPosmatrix(i)=[hmdPos(i),1];
% %     =transmatrix*tData.hmdPos(i);
% end


N1 = size(tData,1);

hmdFrameH =[];
mvector=[];
% for i = 1:100:N
%     data = tData(i);
%    
%     hmdFrameH= [hmdFrameH ,convertvectors(data.hmdPos*1000,data.hmdRot)];
%     mvector=[mvector, [data.m1Pos(1)*1000,data.m1Pos(2)*1000,data.m1Pos(3)*1000,1]'];
%     
%     
% end
% 


for i = 1:1:N1
    data = tData(i);
   
%     [uaxis,vaxis,waxis,originpoint]= convertvectors(data.hmdPos*1000,data.hmdRot);

% 
%     quat = [0.7071 0.7071 0 0];
%     rotm = quat2rotm(quat);
%     uaxis = rotm(1,:);
%     vaxis = rotm(2,:);
%     waxis = rotm(3,:);
%     
    originpoint=data.hmdPos*1000;
%     offset=0;
%     originpoint(1:3)=originpoint(1:3)-offset*vaxis(1:3);
% 
%     oripoint=[0 0 0 1]';
%     Rmatrix=rotationmatrix(uaxis,vaxis,waxis,oripoint);

    R=quat2rotm(data.hmdRot);
    
    rotm=R;
    uaxis = rotm(1,:)';
    vaxis = rotm(2,:)';
    waxis = rotm(3,:)';


    mvector1=[data.mPos(1)*1000,data.mPos(2)*1000,data.mPos(3)*1000]';
    scale=0;vaxis;
 
    originpointT=originpoint - scale*vaxis;
    hmdFrameH= [hmdFrameH ,[R*[uaxis,vaxis,waxis],originpoint'-originpointT']];
    mvector=[mvector, R*mvector1-originpointT'];
    
end











filename = 'trace2.csv';
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






% hmdPosmatrix=zeros(4,num);
% for i = 1:num
%     
% %   transmatrix = constructHT(roll,pitch,yaw,x,y,z);
%     hmdPos=tData.hmdPos;
%     hmdPosmatrix(i)=[hmdPos(i),1];
% %     =transmatrix*tData.hmdPos(i);
% end

N2 = size(tData,1);%choose smaller value of n

kbFrameH =[];
m1vector=[];
m2vector=[];
% for i = 1:100:N
%     data = tData(i);
%    
%     hmdFrameH= [hmdFrameH ,convertvectors(data.hmdPos*1000,data.hmdRot)];
%     mvector=[mvector, [data.m1Pos(1)*1000,data.m1Pos(2)*1000,data.m1Pos(3)*1000,1]'];
%     
%     
% end
% 

for i = 1:1:N2
    data = tData(i);
%    
%     [uaxis,vaxis,waxis,originpoint]= convertvectors(data.hmdPos*1000,data.hmdRot);
%     Rmatrix=rotationmatrix(uaxis,vaxis,waxis,originpoint);
    
    originpointhmd=data.hmdPos*1000;
    originpointkb=data.kbPos*1000;
    rotm=eul2rotm(data.kbRot);
    
    R=quat2rotm(data.hmdRot);
    uaxis = rotm(1,:)';
    vaxis = rotm(2,:)';
    waxis = rotm(3,:)';

    kbFrameH= [kbFrameH ,[R*[uaxis,vaxis,waxis],originpointkb'-originpointhmd']];
    
    
    m1vector1=[data.m1Pos(1)*1000,data.m1Pos(2)*1000,data.m1Pos(3)*1000]';
    m1vector=[m1vector, R*m1vector1];
    
    
    m2vector1=[data.m2Pos(1)*1000,data.m2Pos(2)*1000,data.m2Pos(3)*1000]';
    m2vector=[m2vector, R*m2vector1-originpointhmd'];
    
end









figure('Position',[100 100 800 800 ])
grid on
axis equal
ax = gca;
view(3)
axis([-0.5 0.5 -0.5 0.5 -0.5 0.5]*6000)
xlabel('x-axis')
ylabel('y-axis')
zlabel('z-axis')


camup([0 1 0])


% Construct initial handles
hold on
% hmdFrame = plotFrame([],[0 0 0],[1 0 0 0]); %why starts from zero
% i=1;

% kbFrame = plotFrame2([], kbFrameH(:,i),kbFrameH(:,i+1),kbFrameH(:,i+2),kbFrameH(:,i+3));

m1PosH = plot3(0,0,0,'ko','MarkerFaceColor','r');
m2PosH = plot3(0,0,0,'ko','MarkerFaceColor','b');


% hmdFrame = plotFrame2([], hmdFrameH(:,i),hmdFrameH(:,i+1),hmdFrameH(:,i+2),hmdFrameH(:,i+3));
mPosH = plot3(0,0,0,'ko','MarkerFaceColor','g');




N=min([N1 N2]);

% Loop over sample
% 
for i = 1:4:(N*4)
    ia=(i+3)/4;
    set(m1PosH,'XData',m1vector(1,ia*2),'YData',m1vector(2,ia*2),'ZData',m1vector(3,ia*2)); 
    set(m2PosH,'XData',m2vector(1,ia*2),'YData',m2vector(2,ia*2),'ZData',m2vector(3,ia*2)); 
    
    
    set(mPosH,'XData',mvector(1,ia),'YData',mvector(2,ia),'ZData',mvector(3,ia)); 

    ii=i*2;
    kbFrame = plotFrame2([], kbFrameH(:,ii),kbFrameH(:,ii+1),kbFrameH(:,ii+2),kbFrameH(:,ii+3));
    
    %hmdFrame = plotFrame2([], hmdFrameH(:,i),hmdFrameH(:,i+1),hmdFrameH(:,i+2),hmdFrameH(:,i+3));
    
    drawnow 
end








% 
% 
% 
% figure('Position',[100 100 800 800 ])
% grid on
% axis equal
% ax = gca;
% view(45,45)
% axis([-0.5 0.5 -0.5 0.5 -0.5 0.5]*6000)
% xlabel('x-axis')
% ylabel('y-axis')
% zlabel('z-axis')
% 
% % Construct initial handles
% hold on
% % hmdFrame = plotFrame([],[0 0 0],[1 0 0 0]); %why starts from zero
% i=1;
% hmdFrame = plotFrame2([], hmdFrameH(:,i),hmdFrameH(:,i+1),hmdFrameH(:,i+2),hmdFrameH(:,i+3));
% mPosH = plot3(0,0,0,'ko','MarkerFaceColor','r');
% 
% N = size(tData,1);
% 
% % Loop over sample
% % 
% for i = 1:16:(N*4)
%     ia=(i+3)/4;
%     
%     set(mPosH,'XData',mvector(1,ia),'YData',mvector(2,ia),'ZData',mvector(3,ia)); 
% 
%     
%     hmdFrame = plotFrame2(hmdFrame, hmdFrameH(:,i),hmdFrameH(:,i+1),hmdFrameH(:,i+2),hmdFrameH(:,i+3));
%     drawnow 
% end
% 
% 
% 
