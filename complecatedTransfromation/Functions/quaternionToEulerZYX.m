%% Convert quaternion to euler angles
function [ X, Y, Z ] = quaternionToEulerZYX( quaternion )

w = quaternion(1);
x = quaternion(2);
y = quaternion(3);
z = quaternion(4);

ysqr = y * y;
	
t0 = +2.0 * (w * x + y * z);
t1 = +1.0 - 2.0 * (x * x + ysqr);
X = atan2(t0, t1);
	
t2 = +2.0 * (w * y - z * x);
if (t2 > 1)
    t2 = 1;
elseif (t2 < -1)
    t2 = -1;
end
Y = asin(t2);
	
t3 = +2.0 * (w * z + x * y);
t4 = +1.0 - 2.0 * (ysqr + z * z);
Z = atan2(t3, t4);

X = X*180/pi;
Y = Y*180/pi;
Z = Z*180/pi;


end
