%
% J.T. Ouwerling <j.t.ouwerling@student.rug.nl>, University of Groningen
% Date created: June 10, 2015
%
% Calculate information about the reference subset and return it as a struct, to prevent recalculation.
% 
% Input:
% 
% * rows: the discrete set of row values for the subset
% * cols: the discrete set of column values for the subset
% * config: the configuration struct
% 
% Output:
% A struct fData with the fields: values, mean and delta, dy and dx.
% 
% * values: the values at all points [0,255]
% * mean: the mean of all values
% * delta: the delta of all values
% * dy: df/dy at all points
% * dx: df/dx at all points
%
% function [fData] = getReferenceValues(rows, cols, config)
%

function [fData] = getReferenceValues(rows, cols, config)
    fValues = zeros(size(rows, 2), size(cols,2));
    f_x = zeros(size(rows, 2), size(cols,2));
    f_y = zeros(size(rows, 2), size(cols,2));
    cfRef = config.imReference.interpolation;
    
    % calculate the f values, and f_x and f_y
    for row = 1:size(rows,2)
        for col = 1:size(cols,2)
            r = floor(rows(row));
            c = floor(cols(col));
            x = cols(col) - c;
            y = rows(row) - r;
            % real value
            fValues(row,col) =  cfRef.a00(r,c)      + cfRef.a01(r,c)*y      + cfRef.a02(r,c)*y^2        + cfRef.a03(r,c)*y^3 + ...      % i = 0
                                cfRef.a10(r,c)*x    + cfRef.a11(r,c)*x*y    + cfRef.a12(r,c)*x*y^2      + cfRef.a13(r,c)*x*y^3 + ...    % i = 1
                                cfRef.a20(r,c)*x^2  + cfRef.a21(r,c)*x^2*y  + cfRef.a22(r,c)*x^2*y^2    + cfRef.a23(r,c)*x^2*y^3 + ...  % i = 2
                                cfRef.a30(r,c)*x^3  + cfRef.a31(r,c)*x^3*y  + cfRef.a32(r,c)*x^3*y^2    + cfRef.a33(r,c)*x^3*y^3;       % i = 3
            % derivative to x
            f_x(row, col) =     0                     + 0                         + 0                             + 0 + ...                         % i = 0
                                cfRef.a10(r,c)        + cfRef.a11(r,c)*y          + cfRef.a12(r,c)*y^2            + cfRef.a13(r,c)*y^3 + ...      % i = 1
                                2*cfRef.a20(r,c)*x    + 2*cfRef.a21(r,c)*x*y      + 2*cfRef.a22(r,c)*x*y^2        + 2*cfRef.a23(r,c)*x*y^3 + ...  % i = 2
                                3*cfRef.a30(r,c)*x^2  + 3*cfRef.a31(r,c)*x^2*y    + 3*cfRef.a32(r,c)*x^2*y^2      + 3*cfRef.a33(r,c)*x^2*y^3;     % i = 3
            
            % derivative to y  
            f_y(row, col) = 0 + cfRef.a01(r,c)        + 2*cfRef.a02(r,c)*y        + 3*cfRef.a03(r,c)*y^2 + ...      % i = 0
                            0 + cfRef.a11(r,c)*x      + 2*cfRef.a12(r,c)*x*y      + 3*cfRef.a13(r,c)*x*y^2 + ...    % i = 1
                            0 + cfRef.a21(r,c)*x^2    + 2*cfRef.a22(r,c)*x^2*y    + 3*cfRef.a23(r,c)*x^2*y^2 + ...  % i = 2
                            0 + cfRef.a31(r,c)*x^3    + 2*cfRef.a32(r,c)*x^3*y    + 3*cfRef.a33(r,c)*x^3*y^2;       % i = 3
            
                            
        end
    end
    
    % calculate the mean
    fMean = mean2(fValues);
    
    % calculate delta f
    deltaf = 0;
    for row = 1:size(rows, 2)
        for col = 1:size(cols, 2)
            deltaf = deltaf + (fValues(row, col) - fMean)^2;
        end
    end
    deltaf = sqrt(deltaf);
    
    
    % Return the struct with the reference image data
    fData = struct( ...
        'values', fValues, ...
        'mean', fMean, ...
        'delta', deltaf, ...
        'dy', f_y, ...
        'dx', f_x ...
    );
    
end