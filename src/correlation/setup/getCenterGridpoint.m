%
% J.T. Ouwerling <j.t.ouwerling@student.rug.nl>, University of Groningen
% Date created: June 3, 2015
%
% get the center gridpoint from the config gridpoints struct, containing
% an array in rows and an array in the cols fields.
%
% function [row, col] = getCenterGridpoint(gridpoints)
%

function [row, col] = getCenterGridpoint(gridpoints)
    row = gridpoints.rows(floor(size(gridpoints.rows,2) / 2));
    col = gridpoints.cols(floor(size(gridpoints.cols,2) / 2));
end