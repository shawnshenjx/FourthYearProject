function [hAxes] = plotFrameEuler(hAxes, position,roll, pitch, yaw)

% Convert quaternion to rotation matrix

ht = constructHT(roll*pi/180,pitch*pi/180,yaw*pi/180,0,0,0);
rotM = ht(1:3,1:3);

x = position(1);
y = position(2);
z = position(3);

origin = [ 0 0 0 ]';

% Scale the axis lengths as required for visualisation
uScale = 500;

x_axis = uScale * [1 0 0]';
y_axis = uScale * [0 1 0]';
z_axis = uScale * [0 0 1]';

initial_rot = constructHT(0, 0, -pi/2, 0, 0, 0);
%final_rot = [0 -1 0; 0 0 1; 1 0 0] * initial_rot(1:3,1:3) * rotM;
final_rot = [0 -1 0; 0 0 1; -1 0 0] * initial_rot(1:3,1:3) * rotM;


x_axis = final_rot * x_axis;
y_axis = final_rot * y_axis;
z_axis = final_rot * z_axis;

move = constructHT(0, 0, 0, x, y, z);
x_axis = move * [ x_axis; 1];
y_axis = move * [ y_axis; 1];
z_axis = move * [ z_axis; 1];
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
