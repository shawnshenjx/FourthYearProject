

function [x_axis,y_axis,z_axis,origin] = convertvectorsEuler(position, euler )
% Convert quaternion to rotation matrix
roll=euler(1);
pitch =euler(2);
yaw =euler(3);
ht = constructHTL(roll*pi/180,pitch*pi/180,yaw*pi/180,0,0,0);
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
y_axis = final_rot * y_axis;
z_axis = final_rot * z_axis;

move = constructHT(0, 0, 0, x, y, z);
x_axis = move * [ x_axis; 1];
x_axis = [x_axis(1:3)/norm(x_axis(1:3));1];


y_axis = move * [ y_axis; 1];
y_axis = [y_axis(1:3)/norm(y_axis(1:3));1];


z_axis = move * [ z_axis; 1];
z_axis = [z_axis(1:3)/norm(z_axis(1:3));1];

origin = move * [ origin; 1];





% 
% vectors=[x_axis,y_axis,z_axis,origin];


end



