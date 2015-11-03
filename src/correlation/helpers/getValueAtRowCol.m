%
% J.T. Ouwerling <j.t.ouwerling@student.rug.nl>, University of Groningen
% Date created: June 4, 2015
%
% Get the greyscale value at row and col, using the coefficient list of a complete image.
%
% function [value] = getValueAtRowCol(row, col, coeff)
%

function [value] = getValueAtRowCol(row, col, coeff)
    r = floor(row);
    c = floor(col);
    x = col - c;
    y = row - r;
            % j = 0             % j = 1                 % j = 2                     % j = 3             
    value = coeff.a00(r,c)      + coeff.a01(r,c)*y      + coeff.a02(r,c)*y^2        + coeff.a03(r,c)*y^3 + ...      % i = 0
            coeff.a10(r,c)*x    + coeff.a11(r,c)*x*y    + coeff.a12(r,c)*x*y^2      + coeff.a13(r,c)*x*y^3 + ...    % i = 1
            coeff.a20(r,c)*x^2  + coeff.a21(r,c)*x^2*y  + coeff.a22(r,c)*x^2*y^2    + coeff.a23(r,c)*x^2*y^3 + ...  % i = 2
            coeff.a30(r,c)*x^3  + coeff.a31(r,c)*x^3*y  + coeff.a32(r,c)*x^3*y^2    + coeff.a33(r,c)*x^3*y^3;       % i = 3
end