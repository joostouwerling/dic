%
% J.T. Ouwerling <j.t.ouwerling@student.rug.nl>, University of Groningen
% Date created: June 10, 2015
%
% This function optimizes the initial guess using coarse-fine search. 
% It searches on a grid of 3x3 pixels in steps of 0.25 pixels for the best 
% approximation of u and v. Their derivatives are not taken into account. 
% This is because this method is really time consuming. It should be 
% tested what the influence is of a better initial guess on the final 
% results. There is a commented-out section which optimizes u_x and v_y 
% which can be used as an example.
% 
% Input
% 
% * rowInit: the row of the gridpoint
% * colInit: the column of the gridpoint
% * config: the configuration struct
% * initialGuess: the initial guess selected by the user.
% 
% Output:
% 
% * optimized: the optimized p vector
% * cBest: the correlation coefficent for optimized.
% 
% function [ optimized, cBest ] = optimizeInitialGuess( rowInit, colInit, config, initialGuess )
% 

function [ optimized, cBest ] = optimizeInitialGuess( rowInit, colInit, config, initialGuess )

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
    
    % calculate f values
    fValues = zeros(size(rows,2)/config.precision, size(cols,2)/config.precision);
    cfRef = config.imReference.interpolation;
    
    for row = 1:size(rows,2)
        row_index = round((row-1+y)/config.precision)+1;
        r = rows(row); % pixel row number
        for col = 1:size(cols,2)
            c = cols(col); % pixel column number
            col_index = round((col-1+x)/config.precision)+1;
            fValues(row_index, col_index) = interpolationValues(r,c,x,y,cfRef);
        end
    end
    
    % search in a 3x3 area for the best pixel approximation on a .25 pixel
    % interval.
    wb = waitbar(0, 'Search on a 3x3 (u,v) area for the best match with 0.25 pixel variations in u and v');
    row = rowInit;
    col = colInit;
    cBest = Inf;
    pBest = initialGuess;
    p = initialGuess;
    beginU = (initialGuess.u - 1);
    endU = (initialGuess.u + 1);
    for u = beginU:0.25:endU
        for v = (initialGuess.v - 1):0.25:(initialGuess.v + 1)
            p.u = u;
            p.v = v;
            c = calculateZNSSD(row, col, config, p, fValues);
            if(c < cBest)
                cBest = c;
                pBest = p;
            end
        end
        percentage = (u - beginU) / (endU - beginU);
        waitbar(percentage, wb);
    end
    close(wb);
    optimized = pBest;
    
%     p = pBest;
%     for u = (pBest.u - 0.25):0.05:(pBest.u + 0.25)
%         for v = (pBest.v - 0.25):0.05:(pBest.v + 1)
%             p.u = u;
%             p.v = v;
%             c = calculateZNSSD(row, col, config, p, fValues);
%             if(c < cBest)
%                 cBest = c;
%                 pBest = p;
%             end
%         end
%         u
%     end
%     
%     toc;
%     
%     pBest
%     cBest
%     
%     tic
%     
%     p = pBest;
%     for u_x = (pBest.u_x - 0.15):0.05:(pBest.u_x + 0.15)
%         for v_y = (pBest.v_y - 0.15):0.05:(pBest.v_y + 0.15)
%             p.u_x = u_x;
%             p.v_y = v_y;
%             c = calculateZNSSD(row, col, config, p, fValues);
%             if(c < cBest)
%                 cBest = c;
%                 pBest = p;
%             end
%         end
%         u_x
%     end
%     
%     toc
%     
%     pBest
%     cBest
end

