function [newpos] = transformation(oldpos,coordinatequat,coordinatepos)


position=coordinatepos;



final_rot= quat2rotm(coordinatequat);

x = position(1);
y = position(2);
z = position(3);

origin = [ 0 0 0 ]';

% Scale the axis lengths as required for visualisation
uScale = 1;

x_axis = uScale * [1 0 0]';
y_axis = uScale * [0 1 0]';
z_axis = uScale * [0 0 1]';


% 
% initial_rot =  eul2rotm([0, 0, -pi/2]);
% final_rot = [0 -1 0; 0 0 1; 1 0 0] * initial_rot(1:3,1:3) * rotM;
% final_rot = [0 -1 0; 0 0 1; -1 0 0] * initial_rot(1:3,1:3) * rotM;


x_axis = final_rot * x_axis;
y_axis = final_rot * y_axis;
z_axis = final_rot * z_axis;

transmatrix=[x_axis';y_axis';z_axis';[0 0 0]];

translation=[[1 0 0 -x];[0 1 0 -y];[0 0 1 -z];[0 0 0 1]];



transmatrix=[transmatrix,[0 0 0 1]'];


newpos=transmatrix*translation*[oldpos;1];

end

