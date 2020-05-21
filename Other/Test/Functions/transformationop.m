function [kbpos,kbquat]=transformationop(kbPosold,kbquatold,Rot,Pos)




q=Rot;


qq=[1,0,0,0];


Rot_inv=[q(4),-q(1),-q(2),-q(3)];

Rotworld=qq.*Rot_inv;



q1=Rotworld;


Rotworld_inv=[q1(1),-q1(2),-q1(3),-q1(4)];



q1=kbquatold;


kbquatold_inv=[q1(1),-q1(2),-q1(3),-q1(4)];



final_rot= quat2rotm(Rotworld);

x = -Pos(1);
y = -Pos(2);
z = -Pos(3);

x_axis = final_rot(:,1);
y_axis = final_rot(:,2);
z_axis = final_rot(:,3);

transmatrix=[x_axis';y_axis';z_axis';[0 0 0]];

translation=[[1 0 0 -x];[0 1 0 -y];[0 0 1 -z];[0 0 0 1]];

transmatrix=[transmatrix,[0 0 0 1]'];



kbpos=transmatrix*translation*[kbPosold;1];

kbpos=kbpos(1:3);


kbquat=kbquatold.*Rotworld_inv;




end

