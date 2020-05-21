function [newquat1]=newquat2(oldquat)




q=oldquat;
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


newquat1=[qwNew,qxNew,qyNew,qzNew];



end
