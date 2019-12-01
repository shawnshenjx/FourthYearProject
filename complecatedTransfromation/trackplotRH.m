clear all
close all

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

%% Plot example fingertip trace
% Set up the figure
figure('Position',[100 100 800 800 ])
grid on
axis equal
ax = gca;
view(-150, 25)
axis([-0.5 0.5 -0.5 0.5 -0.5 0.5]*3000)
xlabel('x-axis')
ylabel('y-axis')
zlabel('z-axis')

% Construct initial handles
hold on
hmdFrameH = plotFrame([],[0 0 0],[1 0 0 0]); %why starts from zero

mPosH = plot3(0,0,0,'ko','MarkerFaceColor','r');
N = size(tData,1);

% Loop over samples
for i = 1:1:N
    data = tData(i);
    set(mPosH,'XData',data.mPos(1)*1000,'YData',data.mPos(2)*1000,'ZData',data.mPos(3)*1000); 
    
    hmdFrameH = plotFrame(hmdFrameH,data.hmdPos*1000,data.hmdRot);
    
    
    drawnow 
end
% 
% %% Plot frame
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
% uScale = 500;
% 
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
% %% Convert quaternion to euler angles
% function [ X, Y, Z ] = quaternionToEulerZYX( quaternion )
% 
% w = quaternion(1);
% x = quaternion(2);
% y = quaternion(3);
% z = quaternion(4);
% 
% ysqr = y * y;
% 	
% t0 = +2.0 * (w * x + y * z);
% t1 = +1.0 - 2.0 * (x * x + ysqr);
% X = atan2(t0, t1);
% 	
% t2 = +2.0 * (w * y - z * x);
% if (t2 > 1)
%     t2 = 1;
% elseif (t2 < -1)
%     t2 = -1;
% end
% Y = asin(t2);
% 	
% t3 = +2.0 * (w * z + x * y);
% t4 = +1.0 - 2.0 * (ysqr + z * z);
% Z = atan2(t3, t4);
% 
% X = X*180/pi;
% Y = Y*180/pi;
% Z = Z*180/pi;
% 
% 
% end
% 
% %% Construct homogeneous transform
% function T = constructHT( roll, pitch, yaw, x, y,  z)
% %CONSTRUCTHT Construct homogeneous transformation matrix
% %   T = CONSTRUCTHT( ROLL, PITCH, YAW, X, Y, Z) Construct the 4x4 homogeneous transformation matrix
% %   ROLL angle in radians about x axis
% %   PITCH angle in radians about y axis
% %   YAW angle in radians about z axis
% %   X offset in m in x direction
% %   Y offset in m in y direction
% %   Z offset in m in z direction
% %
% %   T is the 4x4 homogeneous transformation matrix
% %
% %   Order of operations is: 
% %       1. +ve Yaw about z axis, 
% %       2. +ve Pitch about y' axis, 
% %       3. +ve Roll about x'' axis, 
% %       4. Then translate in x, y, z
% %       This is the Tait-Bryan Sequence of z-y’-x? (intrinsic rotations) where the intrinsic rotations are known as: yaw, pitch and roll
% %       See https://en.wikipedia.org/wiki/Euler_angles#/media/File:Taitbrianzyx.svg
% 
% T = [   cos(yaw) * cos(pitch),  cos(yaw) * sin(pitch) * sin(roll) - sin(yaw) * cos(roll),   cos(yaw) * sin(pitch) * cos(roll) + sin(yaw) * sin(roll),   x;
%         sin(yaw) * cos(pitch),  sin(yaw) * sin(pitch) * sin(roll) + cos(yaw) * cos(roll),   sin(yaw) * sin(pitch) * cos(roll) - cos(yaw) * sin(roll),   y;
%         -sin(pitch),            cos(pitch)*sin(roll),                                       cos(pitch) * cos(roll),                                     z;
%         0,                      0                                                           0                                                           1];
% 
% end
% 
% 
% 
% 
