function T = ht4x4( position, q)

if (nargin < 2)
   q = quaternion(1, 0, 0, 0);
end

rot3x3 = rotmat(q,'point');

T = rot3x3;
T = [T transpose(position)];
T = [T; 0 0 0 1];

end