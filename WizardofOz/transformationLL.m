function [newpos] = transformationLL(oldpos,coordinatequat,coordinate1quat,coordinatepos)




position=coordinatepos;



q=coordinatequat;
coordinatequat1=[q(1),q(2),-q(3),-q(4)];

q=coordinate1quat;

q2=[q(1),-q(2),q(3),q(4)];


coordinatequat2=coordinatequat1.*q2;


final_rot= quat2rotm(coordinatequat2);




final_rot= quat2rotm(coordinatequat2);




x = position(1);
y = position(2);
z = position(3);

x_axis = final_rot(:,1);
y_axis = final_rot(:,2);
z_axis = final_rot(:,3);

transmatrix=[transpose(x_axis);transpose(y_axis);transpose(z_axis);[0 0 0]];

translation=[[1 0 0 -x];[0 1 0 -y];[0 0 1 -z];[0 0 0 1]];



transmatrix=[transmatrix,transpose([0 0 0 1])];

a=oldpos(1);
b=oldpos(2);
c=oldpos(3);

oldpos=[a;b;c];

newpos=transmatrix*translation*[oldpos;1];

a=-newdpos(1);
b=newpos(2);
c=newpos(3);


oldpos=[a;b;c];


end

