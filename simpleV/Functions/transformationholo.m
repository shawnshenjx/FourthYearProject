function [kbpos,kbquat]=transformationholo(kbPosold,kbquatold,Rot,Pos)




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


final_rot= quat2rotm(Rot);

x = Pos(1);
y = Pos(2);
z = Pos(3);

x_axis = final_rot(:,1);
y_axis = final_rot(:,2);
z_axis = final_rot(:,3);

transmatrix=[x_axis';y_axis';z_axis';[0 0 0]];

translation=[[1 0 0 -x];[0 1 0 -y];[0 0 1 -z];[0 0 0 1]];

transmatrix=[transmatrix,[0 0 0 1]'];



kbpos=transmatrix*translation*[kbPosold;1];


kbpos=kbpos(1:3);


kbquat=kbquatold_inv.*Rot;






end


