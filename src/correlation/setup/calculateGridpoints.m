%
% J.T. Ouwerling <j.t.ouwerling@student.rug.nl>, University of Groningen
% Date created: June 3, 2015
%
% This function calculates the gridpoints on which DIC is performed. 
%
% Input: config struct, with the following required fields:
% - config.imReference.file
% - config.gridSpacing (rows & cols)
% - config.subsetSize (width & height)
%
% Output:
% A struct with elements rows and cols, both a 1 x n array,
% which form together a 2d array of gridpoints
% i.e. output.rows = [1,4,7] and output.cols = [2,6,10].
%
% function [gridpoints] = calculateGridpoints(config)
%

function [gridpoints] = calculateGridpoints(config)
    
    gridSpacing = config.gridSpacing;
    subsetSize = config.subsetSize;

    im = imread(config.imReference.file);
    [rows, cols] = size(im);
    
    % interpolation border
    rowsAvailable = rows - 2;
    colsAvailable = cols - 2;
    
    % subset size margin
    rowsAvailable = rowsAvailable - (subsetSize.height - 1);
    colsAvailable = colsAvailable - (subsetSize.width - 1);
    
    % the number of grid points in both directions
    numVertical = ceil(rowsAvailable / gridSpacing.rows);
    numHorizontal = ceil(colsAvailable / gridSpacing.cols);
    
    % calculate the area that the grid points use.
    height = (numVertical - 1) * gridSpacing.rows;
    width = (numHorizontal - 1) * gridSpacing.cols;
    
    % Calculate the necessary spacing at the top and left to
    % center the grid points.
    spacingTop = ceil((rows - height) / 2);
    spacingLeft = ceil((cols - width) / 2);
    
    % return the gridpoints struct
    gridpoints = struct( ...
        'rows', spacingTop:gridSpacing.rows:(spacingTop + gridSpacing.rows * (numVertical-1) + 1), ...
        'cols', spacingLeft:gridSpacing.cols:(spacingLeft + gridSpacing.cols * (numHorizontal-1) + 1) ...
    );

end