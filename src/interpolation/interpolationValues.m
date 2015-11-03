%
% E. Werkema <e.werkema@student.rug.nl>, University of Groningen
% Date created: September 4, 2015
%
% Calculate all gray values of interpolation points
%
% Input
%
% * rp: Row pixel number over which interpolation is done
% * cp: Column pixel number over which interpolation is done
% * xValues: Column (!) vector for all sub pixel x values (values between 0
% and 1). Must be a column vector so pointValues becomes a matrix.
% * yValues: Row (!) vector for all sub pixel y values (values between 0
% and 1). Must be a row vector so pointValues becomes a matrix.
% * intCoeff: Contains the interpolation coefficients
%
% Output:
%
% Returns all sub pixel gray values which are obtained from interpolation.
%
% function [pointValues] = interpolationValues(rp, cp, xValues, yValues, intCoeff)
%

function [pointValues] = interpolationValues(rp, cp, xValues, yValues, intCoeff)
    
    % Ones vectors keep correct size of matrix pointValues
    ox = ones(size(xValues));
    oy = ones(size(yValues));    
    
    pointValues =  intCoeff.a00(rp, cp)   + intCoeff.a01(rp, cp)*ox*yValues + intCoeff.a02(rp, cp)*ox*yValues.^2        + intCoeff.a03(rp, cp)*ox*yValues.^3 + ...      % i = 0
                intCoeff.a10(rp, cp)*xValues*oy    + intCoeff.a11(rp, cp)*xValues*yValues    + intCoeff.a12(rp, cp)*xValues*yValues.^2      + intCoeff.a13(rp, cp)*xValues*yValues.^3 + ...    % i = 1
                intCoeff.a20(rp, cp)*xValues.^2*oy  + intCoeff.a21(rp, cp)*xValues.^2*yValues  + intCoeff.a22(rp, cp)*xValues.^2*yValues.^2    + intCoeff.a23(rp, cp)*xValues.^2*yValues.^3 + ...  % i = 2
                intCoeff.a30(rp, cp)*xValues.^3*oy  + intCoeff.a31(rp, cp)*xValues.^3*yValues  + intCoeff.a32(rp, cp)*xValues.^3*yValues.^2    + intCoeff.a33(rp, cp)*xValues.^3*yValues.^3;       % i = 3
    
    pointValues = transpose(pointValues);    
end
    
    