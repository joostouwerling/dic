%
% J.T. Ouwerling <j.t.ouwerling@student.rug.nl>, University of Groningen
% Date created: June 4, 2015
%
% Get the displacement row and column for a certain p vector.
% Input:
% - row: the row of the gridpoint
% - col: the column of the gridpoint
% - dRow: the distance between the row of the point and the row of the
% gridpoint
% - dCol: the distance between the col of the point and the column of the
% gridpoint
% - p: the p vector
%
% Output:
% row and column of the displacement 
%
% function [rowDisp, colDisp] = getDisplacementRowCol(row, col, dRow, dCol, p)
%

function [rowDisp, colDisp] = getDisplacementRowCol(row, col, dRow, dCol, p)
    rowDisp = row + p.v + p.v_x * dCol + p.v_y * dRow;
    colDisp = col + p.u + p.u_x * dCol + p.u_y * dRow;
end

