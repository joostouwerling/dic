% 
% J.T. Ouwerling <j.t.ouwerling@student.rug.nl>, University of Groningen
% Date created: June 10, 2015
% 
% Calculate and return the hessian as defined in the theory for IC-GN
% 
% Input
% 
% * rowInit: the row of the gridpoint
% * colInit: the col of the gridpoint
% * rows: a discrete set of row values. Calculated based on subsetsize and precision.
% * cols: "..." of column values "..."
% * fData: reference image values and the mean and delta value.
% 
% Output:
% 
% * a 6x6 hessian matrix
% 
% function [hessian] = getHessian(rowInit, colInit, rows, cols, fData)
% 

function [hessian] = getHessian(rowInit, colInit, rows, cols, fData)
    
    hessian = zeros(6,6);

    f_x = fData.dx;
    f_y = fData.dy;
    
    for row = 1:size(rows,2)
        for col = 1:size(cols, 2)
            deltaX = cols(col) - colInit;
            deltaY = rows(row) - rowInit;
            dfdwdp = [  f_x(row, col) f_x(row, col)*deltaX f_x(row, col)*deltaY ...
                        f_y(row, col) f_y(row, col)*deltaX f_y(row, col)*deltaY];
            hessian = hessian + transpose(dfdwdp) * dfdwdp;
        end
    end

end