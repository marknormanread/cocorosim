
function [CrossFlag, Xint, Yint] = IntersectionOfLines(x1, y1, x2, y2, u1, v1, u2, v2)
% Function retrieved online, from http://www.mathworks.it/matlabcentral/newsreader/view_thread/22123, on Monday
% 01/01/11. I have made only minor changes. 
%
% Function will return the location where two lines cross, should they cross (which is indicated by the 
% crossflag). 
%
% X1 and Y1 represent the start of the first line. 
% X2 and Y2 represent the end of the first line
% U1 and V1 represent the start of the second line
% U2 and V2 represent the end of the second line.

dx = x2-x1;
dy = y2-y1;
du = u2-u1;
dv = v2-v1;

A = dv*dx-dy*du;

if A ~= 0
    t = -(v1*u2-u1*v2+x1*dv-y1*du)/A;
    s = (y1*x2-x1*y2+u1*dy-v1*dx)/A;

    if t >= 0 & t <= 1 & s >= 0 & s <= 1
        CrossFlag = 1;
        Xint = x1 + t*dx;
        Yint = y1 + t*dy;
        return
    end
end
CrossFlag = 0;
Xint = [];
Yint = [];
