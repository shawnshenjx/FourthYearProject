
%% Construct homogeneous transform
function T = constructHTL( roll, pitch, yaw, x, y,  z)
%CONSTRUCTHT Construct homogeneous transformation matrix
%   T = CONSTRUCTHT( ROLL, PITCH, YAW, X, Y, Z) Construct the 4x4 homogeneous transformation matrix
%   ROLL angle in radians about x axis
%   PITCH angle in radians about y axis
%   YAW angle in radians about z axis
%   X offset in m in x direction
%   Y offset in m in y direction
%   Z offset in m in z direction
%
%   T is the 4x4 homogeneous transformation matrix
%
%   Order of operations is: 
%       1. +ve Yaw about z axis, 
%       2. +ve Pitch about y' axis, 
%       3. +ve Roll about x'' axis, 
%       4. Then translate in x, y, z
%       This is the Tait-Bryan Sequence of z-y’-x? (intrinsic rotations) where the intrinsic rotations are known as: yaw, pitch and roll
%       See https://en.wikipedia.org/wiki/Euler_angles#/media/File:Taitbrianzyx.svg
yaw = -yaw;
pitch = -pitch;
rool = -roll;
T = [   cos(yaw) * cos(pitch),  cos(yaw) * sin(pitch) * sin(roll) - sin(yaw) * cos(roll),   cos(yaw) * sin(pitch) * cos(roll) + sin(yaw) * sin(roll),   x;
        sin(yaw) * cos(pitch),  sin(yaw) * sin(pitch) * sin(roll) + cos(yaw) * cos(roll),   sin(yaw) * sin(pitch) * cos(roll) - cos(yaw) * sin(roll),   y;
        -sin(pitch),            cos(pitch)*sin(roll),                                       cos(pitch) * cos(roll),                                     z;
        0,                      0                                                           0                                                           1];

end

