function [x,y,z] = trans2(mPts,pHmd,qHmd,kbP,kbQ,hlPs,hlQs)

scale=1000;
Rot=hlQs;
kbquatold=kbQ;
kbPosold=kbP*scale;
Pos=hlPs*scale;

q=Rot;
Rot=[q(1),q(2),-q(3),-q(4)];
Rot_inv=[q(1),-q(2),q(3),q(4)];




q=kbquatold;
kbquatold_inv=[q(1),-q(2),q(3),q(4)];



oldpos= kbPosold;
a=-oldpos(1);
b=oldpos(2);
c=oldpos(3);

kbPosold=[a;b;c];



oldpos= Pos;


a=-oldpos(1);
b=oldpos(2);
c=oldpos(3);

Pos=[a;b;c];


final_rot= quat2rotm1(Rot);

x = Pos(1);
y = Pos(2);
z = Pos(3);

x_axis = final_rot(:,1);
y_axis = final_rot(:,2);
z_axis = final_rot(:,3);


transmatrix=[transpose(x_axis);transpose(y_axis);transpose(z_axis);[0 0 0]];

translation=[[1 0 0 -x];[0 1 0 -y];[0 0 1 -z];[0 0 0 1]];



transmatrix=[transmatrix,transpose([0 0 0 1])];



kbpos=transmatrix*translation*[kbPosold;1];


kbpos=kbpos(1:3);


kbquat=kbquatold_inv.*Rot;


kbquatold=kbquat;
kbPosold=kbpos;




Rot=qHmd;
Pos=pHmd*scale;


q=Rot;


qq=[1,0,0,0];


Rot_inv=[q(4),-q(1),-q(2),-q(3)];

Rotworld=qq.*Rot_inv;



q1=Rotworld;


Rotworld_inv=[q1(1),-q1(2),-q1(3),-q1(4)];



q1=kbquatold;


kbquatold_inv=[q1(1),-q1(2),-q1(3),-q1(4)];



final_rot= quat2rotm1(Rotworld);

x = -Pos(1)+0.05;
y = -Pos(2)+0.2;
z = -Pos(3)-0.05;

x_axis = final_rot(:,1);
y_axis = final_rot(:,2);
z_axis = final_rot(:,3);

transmatrix=[transpose(x_axis);transpose(y_axis);transpose(z_axis);[0 0 0]];

translation=[[1 0 0 -x];[0 1 0 -y];[0 0 1 -z];[0 0 0 1]];



transmatrix=[transmatrix,transpose([0 0 0 1])];



kbpos=transmatrix*translation*[kbPosold;1];

kbpos=kbpos(1:3);


kbquat=kbquatold.*Rotworld_inv;




coordinatepos=kbpos;
coordinatequat=kbquat;


position=coordinatepos;


final_rot= quat2rotm1(coordinatequat);

x = position(1);
y = position(2);
z = position(3);

x_axis = final_rot(:,1);
y_axis = final_rot(:,2);
z_axis = final_rot(:,3);


transmatrix=[transpose(x_axis);transpose(y_axis);transpose(z_axis);[0 0 0]];

translation=[[1 0 0 -x];[0 1 0 -y];[0 0 1 -z];[0 0 0 1]];



transmatrix=[transmatrix,transpose([0 0 0 1])];



newpos=transmatrix*translation*[transpose(mPts*scale);1];

x=newpos(1);

y=newpos(2);

z=newpos(3);
