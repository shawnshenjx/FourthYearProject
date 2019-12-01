
clear all
close all

% addpath('/Users/junxiaoshen/Desktop/Fourth Year Project/Functions')


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

hmdFrameH =[];
mvector=[];



figure('Position',[100 100 800 800 ])
grid on
axis equal
ax = gca;
view(0, 0)
axis([-0.5 0.5 -1.0 1.0 -0.5 0.5]*10000)
xlabel('x-axis')
ylabel('y-axis')
zlabel('z-axis')

% Construct initial handles
hold on

mPosH = plot3(0,0,0,'ko','MarkerFaceColor','r');


% Loop over samples
for i = 1:1:N1
    data = tData(i);
    
    
    R=quat2rotm(data.hmdRot);
    R = rotm2tform(R);
    R(:,4)=[-data.hmdPos';1];
    R=R*1000;
    mPos=R*[data.mPos';1];
    set(mPosH,'XData',mPos(1),'YData',mPos(2),'ZData',mPos(3)); 
    
    hmdFrameH = plotFrame(hmdFrameH,R*[-data.hmdPos';1],data.hmdRot);

    
    drawnow 
end



function [hAxes] = plotFrame(hAxes, position, quaternion)

% Convert quaternion to rotation matrix
rul = quat2eul( quaternion );
% roll=rul(1);
% pitch=rul(2);
% yaw=rul(3);
rotM = eul2rotm(rul);

x = position(1);
y = position(2);
z = position(3);

origin = [ 0 0 0 ]';

% Scale the axis lengths as required for visualisation
uScale = 500;

x_axis = uScale * [1 0 0]';
y_axis = uScale * [0 1 0]';
z_axis = uScale * [0 0 1]';

initial_rot =  eul2rotm([0, 0, -pi/2]);
%final_rot = [0 -1 0; 0 0 1; 1 0 0] * initial_rot(1:3,1:3) * rotM;
final_rot = [0 -1 0; 0 0 1; -1 0 0] * initial_rot(1:3,1:3) * rotM;


x_axis = final_rot * x_axis;
y_axis = final_rot * y_axis;
z_axis = final_rot * z_axis;

move = constructHT(0, 0, 0, x, y, z);
x_axis = move * [ x_axis; 1];
y_axis = move * [ y_axis; 1];
z_axis = move * [ z_axis; 1];
origin = move * [ origin; 1];

if isempty(hAxes)
    hold on
    hAxisX = plot3([origin(1) x_axis(1)],[origin(2) x_axis(2)],[origin(3) x_axis(3)],'r-');
    hAxisY = plot3([origin(1) y_axis(1)],[origin(2) y_axis(2)],[origin(3) y_axis(3)],'g-');
    hAxisZ = plot3([origin(1) z_axis(1)],[origin(2) z_axis(2)],[origin(3) z_axis(3)],'b-');
    hAxes = [hAxisX;hAxisY;hAxisZ];
else 
    set(hAxes(1),'XData',[origin(1) x_axis(1)],'YData',[origin(2) x_axis(2)],'ZData',[origin(3) x_axis(3)]);
    set(hAxes(2),'XData',[origin(1) y_axis(1)],'YData',[origin(2) y_axis(2)],'ZData',[origin(3) y_axis(3)]);
    set(hAxes(3),'XData',[origin(1) z_axis(1)],'YData',[origin(2) z_axis(2)],'ZData',[origin(3) z_axis(3)]);
end

end





function T = constructHT( roll, pitch, yaw, x, y,  z)

T = [   cos(yaw) * cos(pitch),  cos(yaw) * sin(pitch) * sin(roll) - sin(yaw) * cos(roll),   cos(yaw) * sin(pitch) * cos(roll) + sin(yaw) * sin(roll),   x;
        sin(yaw) * cos(pitch),  sin(yaw) * sin(pitch) * sin(roll) + cos(yaw) * cos(roll),   sin(yaw) * sin(pitch) * cos(roll) - cos(yaw) * sin(roll),   y;
        -sin(pitch),            cos(pitch)*sin(roll),                                       cos(pitch) * cos(roll),                                     z;
        0,                      0                                                           0                                                           1];

end




% 
% 
% for i = 1:1:N1
%     data = tData(i);
%    
% %     [uaxis,vaxis,waxis,originpoint]= convertvectors(data.hmdPos*1000,data.hmdRot);
% 
% % 
% %     quat = [0.7071 0.7071 0 0];
% %     rotm = quat2rotm(quat);
% %     uaxis = rotm(1,:);
% %     vaxis = rotm(2,:);
% %     waxis = rotm(3,:);
% %     
%     originpoint=data.hmdPos*1000;
% %     offset=0;
% %     originpoint(1:3)=originpoint(1:3)-offset*vaxis(1:3);
% % 
% %     oripoint=[0 0 0 1]';
% %     Rmatrix=rotationmatrix(uaxis,vaxis,waxis,oripoint);
% 
%     R=quat2rotm(data.hmdRot);
%     
%    
%     [r,p,y]=decompose_rotation(R);
%     
%     [hAxes] = plotFrameEuler(hAxes, position,roll, pitch, yaw)
%     
%     
%     
%     newR=compose_rotation(r,p,y);
%     
%     tform = rotm2tform(newR)
%     
%     tform = rotm2tform(newR)
%     
%     
%     
%     rotm=R;
%     uaxis = rotm(1,:)';
%     vaxis = rotm(2,:)';
%     waxis = rotm(3,:)';
% 
% 
%     mvector1=[data.mPos(1)*1000,data.mPos(2)*1000,data.mPos(3)*1000]';
%     
%     
%     hmdFrameH= [hmdFrameH ,[R*[uaxis,vaxis,waxis],originpoint'-originpoint']];
%     mvector=[mvector, R*mvector1-originpoint'];
%     
% end
% 
% 
% 
% 
% 
% figure('Position',[100 100 800 800 ])
% grid on
% axis equal
% ax = gca;
% view(45,45)
% axis([-2 2 -2 2 -2 2]*2000)
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
% 
% function [y,p,r] = decompose_rotation(R) 
% 	y = atan2(R(3,2), R(3,3));
% 	p = atan2(-R(3,1), sqrt(R(3,2)*R(3,2) + R(3,3)*R(3,3)));
% 	r = atan2(R(2,1), R(1,1));
% end
% 
% 
% 
% 
% function R = compose_rotation(x, y, z)
% 	X = eye(3,3);
% 	Y = eye(3,3);
% 	Z = eye(3,3);
% 
%     X(2,2) = cos(x);
%     X(2,3) = -sin(x);
%     X(3,2) = sin(x);
%     X(3,3) = cos(x);
% 
%     Y(1,1) = cos(y);
%     Y(1,3) = sin(y);
%     Y(3,1) = -sin(y);
%     Y(3,3) = cos(y);
% 
%     Z(1,1) = cos(z);
%     Z(1,2) = -sin(z);
%     Z(2,1) = sin(z);
%     Z(2,2) = cos(z);
% 
% 	R = Z*Y*X;
% end
% 
% 
% 
% function [hAxes] = plotFrame(hAxes, position, quaternion)
% 
% % Convert quaternion to rotation matrix
% [ roll, pitch, yaw ] = quaternionToEulerZYX( quaternion );
% ht = constructHT(roll*pi/180,pitch*pi/180,yaw*pi/180,0,0,0);
% rotM = ht(1:3,1:3);
% 
% x = position(1);
% y = position(2);
% z = position(3);
% 
% origin = [ 0 0 0 ]';
% 
% % Scale the axis lengths as required for visualisation
% uScale = 50;
% x_axis = uScale * [1 0 0]';
% y_axis = uScale * [0 1 0]';
% z_axis = uScale * [0 0 1]';
% 
% initial_rot = constructHT(0, 0, -pi/2, 0, 0, 0);
% %final_rot = [0 -1 0; 0 0 1; 1 0 0] * initial_rot(1:3,1:3) * rotM;
% final_rot = [0 -1 0; 0 0 1; -1 0 0] * initial_rot(1:3,1:3) * rotM;
% 
% 
% x_axis = final_rot * x_axis;
% y_axis = final_rot * y_axis;
% z_axis = final_rot * z_axis;
% 
% move = constructHT(0, 0, 0, x, y, z);
% x_axis = move * [ x_axis; 1];
% y_axis = move * [ y_axis; 1];
% z_axis = move * [ z_axis; 1];
% origin = move * [ origin; 1];
% 
% if isempty(hAxes)
%     hold on
%     hAxisX = plot3([origin(1) x_axis(1)],[origin(2) x_axis(2)],[origin(3) x_axis(3)],'r-');
%     hAxisY = plot3([origin(1) y_axis(1)],[origin(2) y_axis(2)],[origin(3) y_axis(3)],'g-');
%     hAxisZ = plot3([origin(1) z_axis(1)],[origin(2) z_axis(2)],[origin(3) z_axis(3)],'b-');
%     hAxes = [hAxisX;hAxisY;hAxisZ];
% else 
%     set(hAxes(1),'XData',[origin(1) x_axis(1)],'YData',[origin(2) x_axis(2)],'ZData',[origin(3) x_axis(3)]);
%     set(hAxes(2),'XData',[origin(1) y_axis(1)],'YData',[origin(2) y_axis(2)],'ZData',[origin(3) y_axis(3)]);
%     set(hAxes(3),'XData',[origin(1) z_axis(1)],'YData',[origin(2) z_axis(2)],'ZData',[origin(3) z_axis(3)]);
% end
% 
% end
% 
% 
% 
% 
% % 
% % 
% % 
