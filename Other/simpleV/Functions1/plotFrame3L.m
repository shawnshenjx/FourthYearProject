function [hAxes] = plotFrame3L(hAxes, position, Cquaternion,Squaternion)

% Convert quaternion to rotation matrix

q=Cquaternion;
Cquaternion1=[q(1),-q(4),-q(3),-q(2)];

final_rot= quat2rotm(Cquaternion1);

q=Squaternion;
Squaternion1=[q(1),-q(4),-q(3),-q(2)];

final_rot2= quat2rotm(Squaternion1);


% [t1 ,t2, t3]=decompose_rotation(final_rot);
% final_rot=compose_rotation(-t1, -t2 ,-t3);
% [t1 ,t2, t3]=decompose_rotation(final_rot2);
% final_rot2=compose_rotation(-t1, -t2 ,-t3);

x = position(1);
y = position(2);
z = position(3);

origin = [ 0 0 0 ]';

% Scale the axis lengths as required for visualisation
uScale = 0.1;

x_axis = uScale * [1 0 0]';
y_axis = uScale * [0 1 0]';
z_axis = uScale * [0 0 1]';


x_axis1 = final_rot2'*final_rot * x_axis;
y_axis1 = final_rot2'*final_rot * y_axis;
z_axis1 = final_rot2'*final_rot* z_axis;

move =[[1 0 0 -x];[0 1 0 -y];[0 0 1 -z];[0 0 0 1]];
x_axis = move * [ x_axis1; 1];
y_axis = move * [ y_axis1; 1];
z_axis = move * [ z_axis1; 1];
origin = move * [ origin; 1];

if isempty(hAxes)
    hold on
    hAxisX = plot3([origin(1) x_axis(1)],[origin(2) x_axis(2)],[origin(3) x_axis(3)],'r-');
    hAxisY = plot3([origin(1) y_axis(1)],[origin(2) y_axis(2)],[origin(3) y_axis(3)],'g-');
    hAxisZ = plot3([origin(1) z_axis(1)],[origin(2) z_axis(2)],[origin(3) z_axis(3)],'b-');
    hAxes = [hAxisX;hAxisY;hAxisZ];
else 
    set(hAxes(1),'XData',[origin(1) x_axis(1)],'YData',[origin(2) x_axis(2)],'ZData',[origin(3) x_axis(3)]);
    set(hAxes(2),'XData',[origin(1) y_axis(1)],'YData',[origin(2) y_axis(2)],'ZData',[origin(3) y_axis(3)]);
    set(hAxes(3),'XData',[origin(1) z_axis(1)],'YData',[origin(2) z_axis(2)],'ZData',[origin(3) z_axis(3)]);
end

end
