function [newpos] = transformationL(oldpos,coordinatequat,coordinatepos)




position=coordinatepos;


q=coordinatequat;
coordinatequat1=[q(1),-q(4),-q(3),-q(2)];




final_rot= quat2rotm(coordinatequat1);
% [t1, t2, t3]=decompose_rotation(final_rot);
% final_rot=compose_rotation(t1,t2 ,t3);

z = -position(1);
y = position(2);
x = position(3);

x_axis = final_rot(:,1);
y_axis = final_rot(:,2);
z_axis = final_rot(:,3);

transmatrix=[x_axis';y_axis';z_axis';[0 0 0]];

translation=[[1 0 0 -x];[0 1 0 -y];[0 0 1 -z];[0 0 0 1]];



transmatrix=[transmatrix,[0 0 0 1]'];

c=-oldpos(1);
b=oldpos(2);
a=oldpos(3);

oldpos=[a;b;c];

newpos=transmatrix*translation*[oldpos;1];

% newpos=[-newpos(1) ,newpos(2), newpos(3)];

end

