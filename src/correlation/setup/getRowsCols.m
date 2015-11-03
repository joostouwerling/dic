%
% J.T. Ouwerling <j.t.ouwerling@student.rug.nl>, University of Groningen
% Date created: June 10, 2015
%
% Calculate the discrete set of points on which the calculated is based, 
% for a certain subset. For the complete subset, steps of config.precision 
% are done and put in an array.
% 
% Input:
% 
% * rowInit: the row of the gridpoint
% * colInit: the column of the gridpoint
% * config: the config struct
% 
% Output:
% 
% * rows: a discrete set of rows
% * cols: a discrete set of cols
% 
% function [rows, cols] = getRowsCols(rowInit, colInit, config)
%

function [rows, cols] = getRowsCols(rowInit, colInit, config)
    rowStart = rowInit - (config.subsetSize.height - 1)/2;
    rowEnd = rowInit + (config.subsetSize.height - 1)/2;
    colStart = colInit - (config.subsetSize.width - 1)/2;
    colEnd = colInit + (config.subsetSize.width - 1)/2;
    rows = rowStart:config.precision:min(rowEnd,config.gridpoints.rows(end));
    cols = colStart:config.precision:min(colEnd,config.gridpoints.cols(end));
end