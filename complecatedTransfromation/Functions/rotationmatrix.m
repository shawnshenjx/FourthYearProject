
function [R]=rotationmatrix(uaxis,vaxis,waxis,translation)
uaxis=uaxis(1:3);
vaxis=vaxis(1:3);
waxis=waxis(1:3);

uaxis=uaxis/norm(uaxis);

vaxis=vaxis/norm(vaxis);


waxis=waxis/norm(waxis);


R=[(uaxis)';(vaxis)';(waxis)';[0 0 0]];
R=[R,translation];


end
