function [newpos] = transformationLL(oldpos,coordinatequat,coordinatepos)




position=coordinatepos;



q=coordinatequat;
coordinatequat1=[q(1),q(2),-q(3),-q(4)];


qq=coordinatequat1;

angle = -30 * pi / 180;


qw=qq(1);
qx=qq(2);
qy=qq(3);
qz=qq(4);

qRx = 0;
qRy = sin(angle / 2);
qRz = 0;
qRw = cos(angle / 2);

qxNew = qw*qRx + qx*qRw + qy*qRz - qz*qRy;
qyNew = qw*qRy - qx*qRz + qy*qRw + qz*qRx;
qzNew = qw*qRz + qx*qRy - qy*qRx + qz*qRw;
qwNew = qw*qRw - qx*qRx - qy*qRy - qz*qRz;


coordinatequat2=[qwNew,qxNew,qyNew,qzNew];
final_rot= quat2rotm(coordinatequat2);

% final_rot= quat2rotm(coordinatequat1);
% [t1 ,t2, t3]=decompose_rotation(final_rot);
% final_rot=compose_rotation(-t1, -t2 ,-t3);







x = position(1);
y = position(2);
z = position(3);

x_axis = final_rot(:,1);
y_axis = final_rot(:,2);
z_axis = final_rot(:,3);

transmatrix=[x_axis';y_axis';z_axis';[0 0 0]];

translation=[[1 0 0 -x];[0 1 0 -y];[0 0 1 -z];[0 0 0 1]];



transmatrix=[transmatrix,[0 0 0 1]'];

a=oldpos(1);
b=oldpos(2);
c=oldpos(3);

oldpos=[a;b;c];

newpos=transmatrix*translation*[oldpos;1];

end

