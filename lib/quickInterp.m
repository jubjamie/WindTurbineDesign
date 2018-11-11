function [x,y] = quickInterp(x,y,position,new_x)
%QUICKINTERP Interp an x value outside bounds of arrays

% Work out if use horzcat or vertcat
if(size(y,2)==1)
    arCat=@(a,b) vertcat(a,b);
else
    arCat=@(a,b) horzcat(a,b);
end

switch position
    case 'start'
        % Find gradient of first two points and use that backwards to new_x
        local_grad=(y(1)-y(2))/(x(2)-x(1));
        delta_x=x(1)-new_x;
        new_y=y(1)+(local_grad*delta_x);
        x=arCat(new_x,x);
        y=arCat(new_y,y);
    case 'end'
        % Find gradient at end and go forwards
        local_grad=(y(end)-y(end-1))/(x(end)-x(end-1));
        delta_x=new_x-x(end);
        new_y=y(end)+(local_grad*delta_x);
        x=arCat(x,new_x);
        y=arCat(y,new_y);
    otherwise
        disp('Position not valid');
end

