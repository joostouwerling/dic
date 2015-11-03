%
% J.T. Ouwerling <j.t.ouwerling@student.rug.nl>, University of Groningen
% Date created: June 10, 2015
%
% Plots the calculated displacements on the reference image. Plots a red asterisk 
% if it could not convergence or a blue asteriks when out of bounds for all grid points.
% 
% Input:
%
% * config: the configuration struct
% * output: the output array created in dic.m
% 
% Output:
% It shows an image with vectors and asterisks.
%
% function plotDisplacements(config, output)
%

function plotDisplacements(config, output)
    
    im = imread(config.imReference.file);
    im = double(im(:,:));
    imshow(im, [0,255]);
    hold on;
    
    for i = 1:size(output.result, 1)
        for j = 1:size(output.result, 2)
            if(output.result(i,j) == DicConstants.RESULT_OK)
                quiver(config.gridpoints.cols(j), config.gridpoints.rows(i), ...
                        output.p.u(i,j), output.p.v(i,j), 'y', 'LineWidth', 2);
                hold on;
            end
            if(output.result(i,j) == DicConstants.RESULT_NO_CONVERGENCE)
                plot(config.gridpoints.cols(j), config.gridpoints.rows(i), 'r*');
                hold on;
            end
            if(output.result(i,j) == DicConstants.RESULT_OUT_OF_BOUNDS)
                plot(config.gridpoints.cols(j), config.gridpoints.rows(i), 'b*');
                hold on;
            end
        end
    end

end