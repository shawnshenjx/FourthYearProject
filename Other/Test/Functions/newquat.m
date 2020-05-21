function [newquat]=newquat(oldquat,coordinatequat)


x_axis =[1 0 0]';
y_axis = [0 1 0]';
z_axis = [0 0 1]';



q=oldquat;

coordinatequat1=[q(1),q(2),-q(3),-q(4)];



r=quat2rotm(coordinatequat1);
 
 
x1 = r* x_axis;
y1 = r * y_axis;
z1 = r * z_axis;




q2=coordinatequat;

coordinatequat2=[q2(1),q2(2),-q2(3),-q2(4)];



r2=quat2rotm(coordinatequat2);


x2 = r2'* x1;
y2 = r2' * y1;
z2 = r2'* z1;



R=[x2,y2,z2];



newquat=rotm2quat(R);




end
