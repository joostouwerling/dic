%
% J.T. Ouwerling <j.t.ouwerling@student.rug.nl>, University of Groningen
% Date created: June 3, 2015
%
% get the indexes of the center gridpoint in the gridpoints arrays,
% created by calculateGridpoints().
%
% function [row, col] = getCenterGridpointIndices(gridpoints)
%

function [row, col] = getCenterGridpointIndices(gridpoints)
    row = floor(size(gridpoints.rows,2) / 2);
    col = floor(size(gridpoints.cols,2) / 2);
end