

function [x_axis,y_axis,z_axis,origin] = convertvectors(position, quaternion)
% Convert quaternion to rotation matrix
[ roll, pitch, yaw ] = quaternionToEulerZYX( quaternion );
ht = constructHT(roll*pi/180,pitch*pi/180,yaw*pi/180,0,0,0);
rotM = ht(1:3,1:3);

x = position(1);
y = position(2);
z = position(3);

origin = [ 0 0 0 ]';


% Scale the axis lengths as required for visualisation
uScale = 1;

x_axis = uScale * [1 0 0]';
y_axis = uScale * [0 1 0]';
z_axis = uScale * [0 0 1]';

initial_rot = constructHT(0, 0, -pi/2, 0, 0, 0);
%final_rot = [0 -1 0; 0 0 1; 1 0 0] * initial_rot(1:3,1:3) * rotM;
final_rot = [0 -1 0; 0 0 1; -1 0 0] * initial_rot(1:3,1:3) * rotM;


x_axis = final_rot * x_axis;
x_axis=[x_axis;1];
y_axis = final_rot * y_axis;
y_axis=[y_axis;1];
z_axis = final_rot * z_axis;
z_axis=[z_axis;1];

move = constructHT(0, 0, 0, x, y, z);


origin = move * [ origin; 1];




end



