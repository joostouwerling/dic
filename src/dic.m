%
% J.T. Ouwerling <j.t.ouwerling@student.rug.nl>, University of Groningen
% Date created: June 10, 2015
%
% This file is the imperative program which is connects the dic 
% parts together. It has several sections, which are clearly indicated 
% in the code.
% 
% 1. Instruction messages and configuration input
% 2. Gridpoint definitions and user-based initial guess
% 3. Interpolation of both images
% 4. Optimize the initial guess using coarse fine search.
% 5. Prepare the output data structure.
% 6. Setup the priority queue and its dependencies.
% 7. The reliability-guided displacement tracking strategy. (see the report for more info on this)
%
% There are also two helper functions. approximateInitialGuess 
% approximates the initial guess of a new gridpoint by applying a correction 
% factor based on distance from its "parent" gridpoint. storeResult
% stores the results of IC-GN optimization in the output array.
%
% Input: dic()
% 
% Output:
% A 4x1 struct with the following fields, all 2d arrays:
% - result: one of DicConstants.RESULT_(OK | NO_CONVERGENCE | OUT_OF_BOUNDS)
% - coefficient: the correlation coefficient at that grid point
% - iterations: the number of needed iterations before convergence.
% - p: a 6x1 struct with the following fields: u, v, u_x, u_y, v_x, v_y
%
% The somewhat weird structure of the p field is because of memory 
% considerations. Matlab uses a lot of header data for every different 
% struct field, so adding separate p's would take a lot of memory 
% (width*height*headerData) instead of (6*headerData).
%

function [output] = dic()
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % SECTION 1
    % Show some introduction messages and request the configuration
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    close all;

    title = 'Digital Image Correlation (DIC)';
    messageHeader = ['Welcome at this DIC program created by J.T. ' ...
                     'Ouwerling under the supervision of dr. E.T. ' ...
                     'Faber, at the University of Groningen, in May 2015.'];
    messageContent = ['First, the input configuration has to be given ' ...
                      'by you. Thereafter, you also have to provide ' ...
                      'an initial guess to help the algorithm get ' ...
                      'started. Afterwards, the programm will do all ' ...
                      'the hard work.'];
    h = msgbox({messageHeader ' ' messageContent}, title);
    uiwait(h);
    
    % Request the configuration parameters from the user
    [config, success] = requestConfiguration();
    if(success == 0)
        error('The configuration did not go well. Abort mission');
        return;
    end
    
    % Request the initial guess from the user 
    messageHeader = [ 'You will now select the initial guesses to set up the ' ...
                'algorithm. The procedure is as follows: the system ' ...
                'shows the reference image with a yellow asterisk '... 
                'at one of the gridpoints. The target image is also shown. ' ...
                'Zoom in on the same point in the target image and press enter. ' ...
                'You will now be able to select the same specific pixel.' ...
                'Try to make this initial guess as accurate as possible'];  
    h = msgbox(messageHeader, title);
    uiwait(h);
    

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % SECTION 2
    % Define the grid points and request the initial guess.
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    config.('gridpoints') = calculateGridpoints(config);
    % plotGridpoints(config);
    % figure;
    [centerRow, centerCol] = getCenterGridpoint(config.gridpoints);
    initialGuess = requestInitialGuess(config, centerRow, centerCol);
    close all;
    
    messageHeader = [ 'Thanks! I will now do the rest. See you at the end'];
    h = msgbox(messageHeader, title);
    uiwait(h);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % SECTION 3
    % Interpolate both images and make the results accesible.
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    disp('Interpolating the reference image...');
    config.imReference.('interpolation') = interpolate(config.imReference.file);
    disp('Interpolating the target image...');
    config.imTarget.('interpolation') = interpolate(config.imTarget.file);
    
    % config.imReference.values = pointValues(config.imReference, config);
    % config.imTarget.values = pointValues(config.imTarget, config);
    
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % SECTION 4
    % Optimize the initial guess using coarse fine search
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    disp('Optimize the initial guess with a coarse-fine search.');
    [initialGuess, c] = optimizeInitialGuess(centerRow, centerCol, config, initialGuess);
    
    initialC = c;
    fprintf('Initial guess found at: p = [u, v, u_x, u_y, v_x, v_y] = [%.4f %.4f %.4f %.4f %.4f %.4f]\n', ...
                initialGuess.u, initialGuess.v, initialGuess.u_x, ...
                initialGuess.u_y, initialGuess.v_x, initialGuess.v_y);
    fprintf('The correlation coefficient was %.4f\n', c);
    
    tic;

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % SECTION 5
    % Prepare the output data structure.
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    width = size(config.gridpoints.cols, 2);
    height = size(config.gridpoints.rows, 2);
    output = struct( ...
        'result', NaN(height, width), ...
        'coefficient', NaN(height, width), ...
        'iterations', NaN(height, width), ...
        'convHist', NaN(height*width, config.maxIterations), ...
        'config', config, ...
        'time', struct( ...
            'priority', NaN, ...
            'initial', NaN, ...
            'icgn', NaN(height, width), ...
            'cc', NaN(height, width), ...
            'total', NaN ...
        ), ...
        'p', struct( ...
            'u', NaN(height, width), ...
            'v', NaN(height, width), ...
            'u_x', NaN(height, width), ...
            'u_y', NaN(height, width), ...
            'v_x', NaN(height, width), ...
            'v_y', NaN(height, width) ...
        ) ...
    );
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % SECTION 6
    % Setup the priority queue and its dependencies
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    start_priority = toc;
    gridpointStatus = zeros(height, width);
    gridpointStatus(:,:) = DicConstants.STATUS_READY;
    
    if(exist('mkgroup.dic.DicResult', 'class') ~= 8)
        javaaddpath('./sem-dic/src/correlation/priorityqueue/');
    end
    queue = java.util.PriorityQueue(height*width, mkgroup.dic.DicResultComparator);
    output.time.priority = toc - start_priority;

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % SECTION 7
    % The reliability-guided displacement tracking strategy. First,
    % use IC-GN to optimize the initial guess displacement. Store
    % it in a priority queue, sorted by correlation coefficient. 
    % Then, while the pqueue is not empty, pop the top element off
    % and analyze all four neighbors, if they are not yet done. Then
    % put these results in the output array and enqueue them.
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    disp('Optimizing the initial guess at the center gridpoint with IC-GN.');
    start_initial = toc;
    [result, p, c, iterations, convHist, time_icgn, time_cc] = optimizeICGN(initialGuess, centerRow, centerCol, config);
    output.time.initial = toc - start_initial;
    
    if (result==2 || result==1)
        p = initialGuess;
        c = initialC;
        disp('Unable to optimize the initial guess with IC-GN, continuing with the coarse-fine search result.');
    else
        fprintf('Initial guess found at: p = [u, v, u_x, u_y, v_x, v_y] = [%.4f %.4f %.4f %.4f %.4f %.4f]\n', ...
                    p.u, p.v, p.u_x, p.u_y, p.v_x, p.v_y);
        fprintf('The correlation coefficient was %.4f\n', c);    
    end
    
    [row, col] = getCenterGridpointIndices(config.gridpoints);
    storeResult(row, col, result, p, c, iterations, convHist, time_icgn, time_cc);
    queue.offer(mkgroup.dic.DicResult(c, row, col));
    gridpointStatus(row,col) = DicConstants.STATUS_IN_QUEUE;

    while(queue.isEmpty == 0)
        result = queue.poll();
        row = result.row;
        col = result.col;
        gridpointStatus(row, col) = DicConstants.STATUS_DONE;
        fprintf('Popped %d %d from the queue\n', row, col);
        % top neighbor;
        analyzeGridpoint(row,col,-1,0);
        % bottom neighbor
        analyzeGridpoint(row,col,1,0);
        % left neighbor
        analyzeGridpoint(row,col,0,-1);
        % right neighbor
        analyzeGridpoint(row,col,0,1);
        fprintf('Current queue size: %d\n', queue.size);
    end
    
    plotDisplacements(config, output);
    
    output.time.total = toc;
    
    %
    % Helper function - analyze gridpoint if not already analyzed
    % by IC-GN and store result in output
    %
    
    function analyzeGridpoint(row, col, drow, dcol)
        if(row+drow >= 1 && col+dcol >= 1 && row+drow <= size(gridpointStatus,1) && col+dcol <= size(gridpointStatus, 2) && gridpointStatus(row+drow, col+dcol) == DicConstants.STATUS_READY)
            pGuess = approximateInitialGuess(row, col, drow, dcol);
            [result, p, c, iterations, convHist, time_icgn, time_cc] = optimizeICGN(pGuess, config.gridpoints.rows(row+drow), config.gridpoints.rows(col+dcol), config);
            fprintf('Analyzed %d %d with c = %.4f\n', row+drow, col+dcol, c);
            storeResult(row+drow, col+dcol, result, p, c, iterations, convHist, time_icgn, time_cc);
            queue.offer(mkgroup.dic.DicResult(c, row+drow, col+dcol));
            gridpointStatus(row+drow,col+dcol) = DicConstants.STATUS_IN_QUEUE;
        end
    end

    %
    % Helper function - approximate the initial guess based on 
    % a change in columns / rows, based on the old p vector.
    %
    function pnew = approximateInitialGuess(row, col, drow, dcol)
        p = createPvector( ...
            output.p.u(row,col), ...
            output.p.v(row,col), ...
            output.p.u_x(row,col), ...
            output.p.u_y(row,col), ...
            output.p.v_x(row,col), ...
            output.p.v_y(row,col) ...
        );
        pnew = createPvector( ...
            p.u + p.u_x*dcol + p.u_y*drow, ...
            p.v + p.v_x*dcol + p.v_y*drow, ...
            p.u_x, ...
            p.u_y, ...
            p.v_x, ...
            p.v_y ...
        );
    end
    
    %
    % Helper function - store the result of an optimization
    % in the output array.
    %
    function storeResult(row, col, result, p, c, iterations, convHist, time_icgn, time_cc)
        output.result(row,col) = result;
        output.coefficient(row, col) = c;
        output.iterations(row, col) = iterations;
        output.convHist((row-1)*width+col,:) = convHist;
        output.time.icgn(row,col) = time_icgn;
        output.time.cc(row,col) = time_cc;
        output.p.u(row, col) = p.u;
        output.p.v(row, col) = p.v;
        output.p.u_x(row, col) = p.u_x;
        output.p.u_y(row, col) = p.u_y;
        output.p.v_x(row, col) = p.v_x;
        output.p.v_y(row, col) = p.v_y;
    end
    
end