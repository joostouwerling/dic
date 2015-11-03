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
    rowStart = rowInit - (config.subsetSize.height - 1)/2;
    rowEnd = rowInit + (config.subsetSize.height - 1)/2;
    colStart = colInit - (config.subsetSize.width - 1)/2;
    colEnd = colInit + (config.subsetSize.width - 1)/2;
    
    % rows and cols in pixels
    rows = rowStart:rowEnd-1;
    cols = colStart:colEnd-1;
    % X and Y values in subpixels
    x = (0:config.precision:1)';
    y = 0:config.precision:1;
    % Image interpolation data
    cfRef = config.imReference.interpolation;
    cfTar = config.imTarget.interpolation;
    
    % calculate sub pixel gray values for f and g from interpolation
    if(nargin < 5)
        fValues = zeros(size(rows,2)/config.precision, size(cols,2)/config.precision);
    end
    gValues = zeros(size(rows,2)/config.precision, size(cols,2)/config.precision);
    
    for row = 1:size(rows,2)
        row_index = round((row-1+y)/config.precision)+1;
        r = rows(row); % pixel row number
        for col = 1:size(cols,2)
            c = cols(col); % pixel column number
            col_index = round((col-1+x)/config.precision)+1;
            suby = y+r; % exact subpixel row location
            subx = x+c; % exact subpixel column location
            % reference image
            if(nargin < 5)
                fValues(row_index,col_index) = interpolationValues(r,c,x,y,cfRef);
            end
            % target image
            rowVal = suby + p.v + p.v_x * (subx' - colInit) + p.v_y * (suby - rowInit);
            colVal = subx + p.u + p.u_x * (subx - colInit) + p.u_y * (suby' - rowInit);
            tarR = min(floor(rowVal));
            tarC = min(floor(colVal));
            tarX = colVal - tarC;
            tarY = rowVal - tarR;
            gValues(row_index,col_index) = interpolationValues(tarR,tarC,tarX,tarY,cfTar);
        end
    end
    

    % Calculate the mean of F and G
    fMean = mean(mean(fValues));
    gMean = mean(mean(gValues));
    % calculate delta f/g -> sqrt [ sum ( f(i,j) - fmean )^2 ]
    deltaf = 0;
    deltag = 0;
    for row = 1:size(rows, 2)
        row_index = round((row-1+y)/config.precision)+1;
        for col = 1:size(cols, 2)
            col_index = round((col-1+x)/config.precision)+1;
            % reference image
            deltaf = deltaf + sum(sum((fValues(row_index, col_index) - fMean).^2));
            % target image
            deltag = deltag + sum(sum((gValues(row_index, col_index) - gMean).^2));
        end
    end
    deltaf = sqrt(deltaf);
    deltag = sqrt(deltag);
    
    % calculate ZN SSD
    znssd = 0;
    for row = 1:size(rows, 2)
        row_index = round((row-1+y)/config.precision)+1;
        for col = 1:size(cols, 2)
            col_index = round((col-1+x)/config.precision)+1;
            znssd = znssd + sum(sum((((fValues(row_index, col_index) - fMean) / deltaf) - ((gValues(row_index, col_index) - gMean) / deltag) ).^2));
        end
    end
end