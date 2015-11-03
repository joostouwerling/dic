%
% J.T. Ouwerling <j.t.ouwerling@student.rug.nl>, University of Groningen
% Date created: May 4, 2015
%
% Approximates the derivative at block(row,col) in the x (i.e. column)
% direction, using the finite differences method. See, for more details, 
% the report attached to this code.
%
% Input parameters:
% col:      the x (column) position in block
% row:      the y (row) position in block
% block:    a matrix with at least 1 column left and right of the input
%           param col, and row should be between 1 and size(block, 1).
% 
% function [derivative] = derivativeToX(col, row, block)
%

function [derivative] = derivativeToX(col, row, block)
    % Check if col is within the range. Need one element to the left and
    % right.
    if(col <= 1 || col >= size(block, 2))
        throw(MException('interpolation:outOfRange', ...
            sprintf('Error in deriveToX. \ncol out of range [col = %d, size = (%d,%d)].', ...
                col, size(block, 1), size(block, 2)) ...
        ));
    end
    % Check if row is within the range. The only constraint is that it is
    % within the matrix.
    if(row < 1 || row > size(block, 1))
        throw(MException('interpolation:outOfRange', ...
            sprintf('Error in deriveToX. \nrow out of range [row = %d, size = (%d,%d)].', ...
                row, size(block, 1), size(block, 2)) ...
        ));
    end
    % calculate the derivative.
    derivative = (block(row, col + 1) - block(row, col - 1))/2;