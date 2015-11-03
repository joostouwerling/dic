%
% J.T. Ouwerling <j.t.ouwerling@student.rug.nl>, University of Groningen
% Date created: June 10, 2015
%
% This function calculates the delta p step in the IC GN optimization of the 
% p vector. The theory behind it can be found in the report. 
% 
% Input: 
%
% * rowInit: the row of the gridpoint
% * colInit: the column of the gridpoint
% * rows: a discrete set of row values. Calculated based on subsetsize and precision.
% * cols: "..." of column values "..."
% * config: the config structure.
% * p: the current best p vector
% * fData: a struct with reference image values, mean and delta
% * hessian: the pre-computed hessian
% 
% Output:
% 
% * dp: the delta p vector which need to be inverted and applied to p.
% 
% function [dp] = getDeltaP(rowInit, colInit, rows, cols, config, p, fData, hessian)
% 

function [dp] = getDeltaP(rowInit, colInit, rows, cols, config, p, fData, hessian)
    cfTar = config.imTarget.interpolation;
    cfRef = config.imReference.interpolation;
    maxR = size(cfTar.a00,1);
    maxC = size(cfTar.a00,2);
    
    gValues = zeros(size(rows,2),size(cols,2));
    
    % Calculate the 
    for row = 1:size(rows,2)
        for col = 1:size(cols,2)
            rowVal = rows(row) + p.v + p.v_x * (cols(col) - colInit) + p.v_y * (rows(row) - rowInit);
            colVal = cols(col) + p.u + p.u_x * (cols(col) - colInit) + p.u_y * (rows(row) - rowInit);
            r = floor(rowVal);
            c = floor(colVal);
            x = colVal - c;
            y = rowVal - r;   
            gValues(row,col) =  cfTar.a00(r,c)      + cfTar.a01(r,c)*y      + cfTar.a02(r,c)*y^2        + cfTar.a03(r,c)*y^3 + ...      % i = 0
                            cfTar.a10(r,c)*x    + cfTar.a11(r,c)*x*y    + cfTar.a12(r,c)*x*y^2      + cfTar.a13(r,c)*x*y^3 + ...    % i = 1
                            cfTar.a20(r,c)*x^2  + cfTar.a21(r,c)*x^2*y  + cfTar.a22(r,c)*x^2*y^2    + cfTar.a23(r,c)*x^2*y^3 + ...  % i = 2
                            cfTar.a30(r,c)*x^3  + cfTar.a31(r,c)*x^3*y  + cfTar.a32(r,c)*x^3*y^2    + cfTar.a33(r,c)*x^3*y^3;       % i = 3
            
            
            %gValues(row, col) = getValueAtRowCol(rowVal, colVal, config.imTarget.interpolation);
        end
    end
    gMean = mean2(gValues);
    
    % calculate delta f/g -> sqrt [ sum ( f(i,j) - fmean )^2 ]
    deltag = 0;
    for row = 1:size(rows, 2)
        for col = 1:size(cols, 2)
            % target image
            deltag = deltag + (gValues(row, col) - gMean)^2;
        end
    end
    deltag = sqrt(deltag);
    
    % Calculate the second part of the delta p equation
    part2 = zeros(6,1);
    f_x = fData.dx;
    f_y = fData.dy;
    for row = 1:size(rows,2)
        for col = 1:size(cols, 2)
           
            deltaX = cols(col) - colInit;
            deltaY = rows(row) - rowInit;
            
            dfdwdp = [  f_x(row, col); f_x(row, col)*deltaX; f_x(row, col)*deltaY; ...
                        f_y(row, col); f_y(row, col)*deltaX; f_y(row, col)*deltaY];
            %factor = fData.values(row, col) - fData.mean - fData.delta/deltag*(gValues(row,col) - gMean);
            part2 = part2 + dfdwdp*(fData.values(row, col) - fData.mean - fData.delta/deltag*(gValues(row,col) - gMean));
        end
    end
    
    dpRaw = -inv(hessian) * part2;
    dp = createPvector(dpRaw(1), dpRaw(4), dpRaw(2), dpRaw(3), dpRaw(5), dpRaw(6));
end