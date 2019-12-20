function [eular] = quaternion2eular(coordinatequat)



q=coordinatequat;
coordinatequat1=[q(1),q(2),-q(3),-q(4)];

eular = quat2eul(coordinatequat1);



end