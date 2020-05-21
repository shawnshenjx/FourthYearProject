
clear all

figure(2)
addpath('/Users/junxiaoshen/Desktop/Fourth Year Project/Functions')


addpath('/Users/junxiaoshen/Desktop/Fourth Year Project/Data')
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
    
    
    hmdFrameH= [hmdFrameH ,[R*[uaxis,vaxis,waxis],originpoint'-originpoint']];
    mvector=[mvector, R*mvector1-originpoint'];
    
end





figure('Position',[100 100 800 800 ])
grid on
axis equal
ax = gca;
view(45,45)
axis([-2 2 -2 2 -2 2]*2000)
xlabel('x-axis')
ylabel('y-axis')
zlabel('z-axis')

% Construct initial handles
hold on
% hmdFrame = plotFrame([],[0 0 0],[1 0 0 0]); %why starts from zero
i=1;
hmdFrame = plotFrame2([], hmdFrameH(:,i),hmdFrameH(:,i+1),hmdFrameH(:,i+2),hmdFrameH(:,i+3));
mPosH = plot3(0,0,0,'ko','MarkerFaceColor','r');

N = size(tData,1);

% Loop over sample
% 
for i = 1:16:(N*4)
    ia=(i+3)/4;
    
    set(mPosH,'XData',mvector(1,ia),'YData',mvector(2,ia),'ZData',mvector(3,ia)); 

    
    hmdFrame = plotFrame2(hmdFrame, hmdFrameH(:,i),hmdFrameH(:,i+1),hmdFrameH(:,i+2),hmdFrameH(:,i+3));
    drawnow 
end




function [y,p,r] = decompose_rotation(R)
	y = atan2(R(3,2), R(3,3));
	p = atan2(-R(3,1), sqrt(R(3,2)*R(3,2) + R(3,3)*R(3,3)));
	r = atan2(R(2,1), R(1,1));
end




function R = compose_rotation(x, y, z)
	X = eye(3,3);
	Y = eye(3,3);
	Z = eye(3,3);

    X(2,2) = cos(x);
    X(2,3) = -sin(x);
    X(3,2) = sin(x);
    X(3,3) = cos(x);

    Y(1,1) = cos(y);
    Y(1,3) = sin(y);
    Y(3,1) = -sin(y);
    Y(3,3) = cos(y);

    Z(1,1) = cos(z);
    Z(1,2) = -sin(z);
    Z(2,1) = sin(z);
    Z(2,2) = cos(z);

	R = Z*Y*X;
end


% 
% 
% 
