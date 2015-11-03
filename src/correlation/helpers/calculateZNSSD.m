%
% J.T. Ouwerling <j.t.ouwerling@student.rug.nl>, University of Groningen
% Date created: June 10, 2015
%
% This function calculates the ZNSSD correlation coefficient. 
%
% Input:
%
% * rowInit: The row of the gridpoint
% * colInit: the column of the gridpoint
% * config: the config array as created by requestConfiguration() and modified in dic.m
% * p: the p displacement factir
% * [optional] fValues: values of the reference subset, to prevent recomputing it.
%
% Output:
% * A 4 digit precision correlation coefficient.
%
% function [znssd] = calculateZNSSD(rowInit, colInit, config, p, [optional] fValues)
%

function [znssd] = calculateZNSSD(rowInit, colInit, config, p, fValues)

    % Calculate the boundaries for the subset
    [rows,cols] = getRowsCols(rowInit, colInit, config);
    
    if(nargin < 5)
        fValues = zeros(size(rows, 2), size(cols,2));
    end
    gValues = zeros(size(rows, 2), size(cols,2));
    
    cfRef = config.imReference.interpolation;
    cfTar = config.imTarget.interpolation;
    
    % calculate the mean value for the reference and target image
    for row = 1:size(rows,2)
        for col = 1:size(cols,2)
            % reference image
            if(nargin < 5)
                r = floor(rows(row));
                c = floor(cols(col));
                x = cols(col) - c;
                y = rows(row) - r;
                fValues(row,col) =  cfRef.a00(r,c)      + cfRef.a01(r,c)*y      + cfRef.a02(r,c)*y^2        + cfRef.a03(r,c)*y^3 + ...      % i = 0
                                    cfRef.a10(r,c)*x    + cfRef.a11(r,c)*x*y    + cfRef.a12(r,c)*x*y^2      + cfRef.a13(r,c)*x*y^3 + ...    % i = 1
                                    cfRef.a20(r,c)*x^2  + cfRef.a21(r,c)*x^2*y  + cfRef.a22(r,c)*x^2*y^2    + cfRef.a23(r,c)*x^2*y^3 + ...  % i = 2
                                    cfRef.a30(r,c)*x^3  + cfRef.a31(r,c)*x^3*y  + cfRef.a32(r,c)*x^3*y^2    + cfRef.a33(r,c)*x^3*y^3;       % i = 3
            end
            %fMean = fMean + fValues(row, col);
            % target image
            %[rowVal, colVal] = getDisplacementRowCol(rows(1, row), cols(1, col), (rows(1, row) - rowInit), (cols(1, col) - colInit), p);
            rowVal = rows(row) + p.v + p.v_x * (cols(col) - colInit) + p.v_y * (rows(row) - rowInit);
            colVal = cols(col) + p.u + p.u_x * (cols(col) - colInit) + p.u_y * (rows(row) - rowInit);
            r = floor(rowVal);
            c = floor(colVal);
            x = colVal - c;
            y = rowVal - r;   
            %gValues(row, col) = getValueAtRowCol(rowVal, colVal, config.imTarget.interpolation);
            gValues(row,col) =  cfTar.a00(r,c)      + cfTar.a01(r,c)*y      + cfTar.a02(r,c)*y^2        + cfTar.a03(r,c)*y^3 + ...      % i = 0
                                cfTar.a10(r,c)*x    + cfTar.a11(r,c)*x*y    + cfTar.a12(r,c)*x*y^2      + cfTar.a13(r,c)*x*y^3 + ...    % i = 1
                                cfTar.a20(r,c)*x^2  + cfTar.a21(r,c)*x^2*y  + cfTar.a22(r,c)*x^2*y^2    + cfTar.a23(r,c)*x^2*y^3 + ...  % i = 2
                                cfTar.a30(r,c)*x^3  + cfTar.a31(r,c)*x^3*y  + cfTar.a32(r,c)*x^3*y^2    + cfTar.a33(r,c)*x^3*y^3;       % i = 3
            
            %gMean = gMean + gValues(row, col);
        end
    end
    %numPoints = ((rowEnd - rowStart) / config.precision) + 1;
    %numPoints = numPoints * (((colEnd - colStart) / config.precision) + 1);
    % Final calculation step, dividing by n
    fMean = mean(mean(fValues));
    gMean = mean(mean(gValues));
    
    % calculate delta f/g -> sqrt [ sum ( f(i,j) - fmean )^2 ]
    deltaf = 0;
    deltag = 0;
    for row = 1:size(rows, 2)
        for col = 1:size(cols, 2)
            % reference image
            deltaf = deltaf + (fValues(row, col) - fMean)^2;
            % target image
            deltag = deltag + (gValues(row, col) - gMean)^2;
        end
    end
    deltaf = sqrt(deltaf);
    deltag = sqrt(deltag);
    
    % calculate ZN SSD
    znssd = 0;
    for row = 1:size(rows, 2)
        for col = 1:size(cols, 2)
            znssd = znssd + ( ((fValues(row, col) - fMean) / deltaf) - ((gValues(row, col) - gMean) / deltag) )^2;
        end
    end
end