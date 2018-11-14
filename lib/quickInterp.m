function [x,y] = quickInterp(x,y,position,new_x)
%QUICKINTERP Interp an x value outside bounds of arrays
%   Returns the array with an extra term at the front or back linearly
%   interpolated from the closest two points.

% Work out if use horzcat or vertcat depending on shape of arrays
% Define a consistently named anonymous function to handle the variation.
if(size(y,2)==1)
    arCat=@(a,b) vertcat(a,b);
else
    arCat=@(a,b) horzcat(a,b);
end

% Choose where the new value should go. Start or End
switch position
    case 'start'
        % Find gradient of first two points and use that backwards to new_x
        local_grad=(y(1)-y(2))/(x(2)-x(1));
        delta_x=x(1)-new_x;
        new_y=y(1)+(local_grad*delta_x);
        % Place at front of original array
        x=arCat(new_x,x);
        y=arCat(new_y,y);
    case 'end'
        % Find gradient at end and go forwards
        local_grad=(y(end)-y(end-1))/(x(end)-x(end-1));
        delta_x=new_x-x(end);
        new_y=y(end)+(local_grad*delta_x);
        % Place at end of original array.
        x=arCat(x,new_x);
        y=arCat(y,new_y);
    otherwise
        error('Position not valid'); % Error if no position givven.
end

