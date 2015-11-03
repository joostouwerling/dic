%
% J.T. Ouwerling <j.t.ouwerling@student.rug.nl>, University of Groningen
% Date created: June 10, 2015
%
% This function executes the IC-GN optimization. First, the reference image 
% values are calculated as well as the hessian. Then the loop keeps calculating 
% delta p until converged or the number of maximum iterations is reached. 
% There is also a check of out of bounds.
% 
% There are several subfunction used. These are:
% 
% * willOverflow: check if the current p will get out of bounds.
% * criterionSatisfied: check if the convergence criterion is satisfied
% * getUpdatedPvector: uses the inversion of the warp function to get the updated p vector
% * constructWarpFromP: name says it all. Creates warp matrix from p vector.
% * extractPfromWarp: extract the p vector from a warp matrix
% 
% Input:
% 
% * initialp: the initial p vector guess
% * row: the gridpoint row
% * col: the gridpoint col
% * config: the config struct
% 
% Output:
% 
% * result: One of DicConstants.RESULT_(OK | OUT_OF_BOUNDS | NO_CONVERGENCE)
% * p: the optimal p vector in 4 digits accuracy. All elements Inf if the result is not RESULT_OK.
% * c: the correlation coefficient in 4 digits accuracy. Is Inf if result is not RESULT_OK
% * iterations: the number of iterations done until stopping conditions were met.
% 
% function [result, p, c, iterations] = optimizeICGN(initialp, row, col, config)
% 

function [result, p, c, iterations, convHist, time_icgn, time_cc] = optimizeICGN(initialp, row, col, config)

    rowNumber = find(config.gridpoints.rows==row);
    colNumber = find(config.gridpoints.cols==col);

    %
    % Calculate the values of the reference image and the hessian
    %
    wb = waitbar(0, sprintf('Setting up IC-GN for gridpoint (%d, %d)', rowNumber, colNumber));
    [rows, cols] = getRowsCols(row, col, config);
    fData = getReferenceValues(rows, cols, config);
    hessian = getHessian(row, col, rows, cols, fData);
    
    % dp = [u u_x u_y v v_x v_y]
    iterations = 0;
    overflown = 0;
    pisnan = 0;
    dp = createPvector(Inf,0,0,0,0,0);
    p = initialp;
    convHist = zeros(config.maxIterations, 1);
    time_cc = NaN;
    time_icgn = NaN;
    set( get(findobj(wb,'type','axes'),'title'), 'string', sprintf('Calculating p for gridpoint (%d, %d)', rowNumber, colNumber));
    waitbar(1/3, wb);
    start_icgn = toc;
    while(iterations < config.maxIterations && criterionSatisfied(dp) == false)
        % Check if we do not overflow
        if(willOverflow(p))
            overflown = 1;
            break;
        end
        % Check if dislocations are Not a Number (NaN)
        if(isnan(p.v) || isnan(p.u))
            pisnan = 1;
            break;
        end
        dp = getDeltaP(row, col, rows, cols, config, p, fData, hessian);
        p = getUpdatedPvector(p, dp);
        convHist(iterations+1) = currentConvergence(dp);
        percentage = 1/3+min(2/3,1/(log10(convHist(iterations+1)/config.convergenceCriterion)+1));
        waitbar(percentage, wb);
        iterations = iterations + 1;
    end
    time_icgn = toc - start_icgn;
   close(wb);
    
    % return the correct status & values
    c = Inf;
    pInf = createPvector(Inf, Inf, Inf, Inf, Inf, Inf);
    if(overflown)
       p = pInf;
       result = DicConstants.RESULT_OUT_OF_BOUNDS;
       return;
    end
    if (pisnan)
       p = pInf;
       result = DicConstants.RESULT_NOT_A_NUMBER;
       return;
    end
    satisfied = criterionSatisfied(dp);
    if(satisfied == false)
        result = DicConstants.RESULT_NO_CONVERGENCE;
        p = pInf;
        return;
    end
    result = DicConstants.RESULT_OK;
    start_cc = toc;
    c = calculateZNSSD(row, col, config, p);
    time_cc = toc - start_cc;
    %
    % Check if the current p will overflow
    %
    function will = willOverflow(p)
       will = false;
       rowStart = row - (config.subsetSize.height - 1)/2;
        rowEnd = row + (config.subsetSize.height - 1)/2;
        colStart = col - (config.subsetSize.width - 1)/2;
        colEnd = col + (config.subsetSize.width - 1)/2;

        rows2 = rowStart:config.precision:rowEnd;
        cols2 = colStart:config.precision:colEnd;
       I_r = ones(size(rows2'));
       I_c = ones(size(cols2));
       maxRow = max(max(rows2'*I_c + p.v + p.v_x * I_r * (cols2 - col) + p.v_y * (rows2' - row)*I_c));
       maxCol = max(max(I_r*cols2 + p.u + p.u_x * I_r * (cols2 - col) + p.u_y * (rows2' - row)*I_c));
       if(floor(maxRow) > size(config.imTarget.interpolation.a00, 1) || floor(maxCol) > size(config.imTarget.interpolation.a00, 2))
           will = true;
           return;
       end
       minRow = min(min(rows2'*I_c + p.v + p.v_x * I_r * (cols2 - col) + p.v_y * (rows2' - row)*I_c));
       minCol = min(min(I_r*cols2 + p.u + p.u_x * I_r * (cols2 - col) + p.u_y * (rows2' - row)*I_c));
       if(minRow < 1 || minCol < 1)
           will = true;
           return;
       end
    end
    
    
    %
    % This function sets satisfied to true if delta p has converged,
    % otherwise satisfied is false.
    %
    function satisfied = criterionSatisfied(dp)
       satisfied = false; 
       incr = dp.u^2 + dp.v^2;
       incr = incr + (((config.subsetSize.width - 1) / 2) * dp.u_x)^2;
       incr = incr + (((config.subsetSize.width - 1) / 2) * dp.v_x)^2;
       incr = incr + (((config.subsetSize.height - 1) / 2) * dp.u_y)^2;
       incr = incr + (((config.subsetSize.height - 1) / 2) * dp.v_y)^2;
       incr = sqrt(incr);
       if(incr < config.convergenceCriterion)
           satisfied = true;
       end
    end

    %
    % Current convergence function.
    %
    function convergence = currentConvergence(dp)
       convergence = dp.u^2 + dp.v^2;
       convergence = convergence + (((config.subsetSize.width - 1) / 2) * dp.u_x)^2;
       convergence = convergence + (((config.subsetSize.width - 1) / 2) * dp.v_x)^2;
       convergence = convergence + (((config.subsetSize.height - 1) / 2) * dp.u_y)^2;
       convergence = convergence + (((config.subsetSize.height - 1) / 2) * dp.v_y)^2;
       convergence = sqrt(convergence);
    end
   
    %
    % This function merges the newly found delta p with the current known
    % p vector according to Wnew = Wold * inv(Wdp);
    %
    function newPvector = getUpdatedPvector(p, dp)
        warpOld = constructWarpFromP(p);
        warpDp = constructWarpFromP(dp);
        warp = warpOld/warpDp;
        newPvector = extractPfromWarp(warp);
    end
    
    %
    % Construct a warp function from the p vector.
    %
    function warp = constructWarpFromP(p)
        warp =  [   1 + p.u_x,  p.u_y,      p.u;
                    p.v_x,      1 + p.v_y   p.v;
                    0           0           1   ];
    end

    %
    % Extract the p vector from a warp
    %
    function p = extractPfromWarp(warp)
        p = createPvector( ...
            warp(1,3), ...      % u
            warp(2,3), ...      % v
            warp(1,1) - 1, ...  % u_x
            warp(1,2), ...      % u_y
            warp(2,1), ...      % v_x
            warp(2,2) - 1 ...   % v_y
        );
    end
    
end
