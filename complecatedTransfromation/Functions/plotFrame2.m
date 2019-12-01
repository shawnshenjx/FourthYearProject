
function [hAxes] = plotFrame2(hAxes, x_axis , y_axis, z_axis,origin)
s=500;
x_axis=x_axis*s;
y_axis=y_axis*s;
z_axis=z_axis*s;


if isempty(hAxes)
    hold on
    hAxisX = plot3([origin(1) origin(1)+x_axis(1)],[origin(2) origin(2)+x_axis(2)],[origin(3) origin(3)+x_axis(3)],'r-');
    hAxisY = plot3([origin(1) origin(1)+y_axis(1)],[origin(2) origin(2)+y_axis(2)],[origin(3) origin(3)+y_axis(3)],'g-');
    hAxisZ = plot3([origin(1) origin(1)+z_axis(1)],[origin(2) origin(2)+z_axis(2)],[origin(3) origin(3)+z_axis(3)],'b-');
    hAxes = [hAxisX;hAxisY;hAxisZ];
else 
    set(hAxes(1),'XData',[origin(1) origin(1)+x_axis(1)],'YData',[origin(2) origin(2)+x_axis(2)],'ZData',[origin(3) origin(3)+x_axis(3)]);
    set(hAxes(2),'XData',[origin(1) origin(1)+y_axis(1)],'YData',[origin(2) origin(2)+y_axis(2)],'ZData',[origin(3) origin(3)+y_axis(3)]);
    set(hAxes(3),'XData',[origin(1) origin(1)+z_axis(1)],'YData',[origin(2) origin(2)+z_axis(2)],'ZData',[origin(3) origin(3)+z_axis(3)]);
end

end
