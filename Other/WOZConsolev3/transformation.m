function [newpos] = transformation(oldpos,coordinatequat,coordinatepos)




position=coordinatepos;

q=coordinatequat;
coordinatequat1=[q(4),q(1),q(2),q(3)];

final_rot= quat2rotm(coordinatequat1);

x = position(1);
y = position(2);
z = position(3);

x_axis = final_rot(:,1);
y_axis = final_rot(:,2);
z_axis = final_rot(:,3);

transmatrix=[transpose(x_axis);transpose(y_axis);transpose(z_axis);[0 0 0]];

translation=[[1 0 0 -x];[0 1 0 -y];[0 0 1 -z];[0 0 0 1]];



transmatrix=[transmatrix,transpose([0 0 0 1])];


newpos=transmatrix*translation*[oldpos;1];

end
