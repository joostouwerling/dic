%
% J.T. Ouwerling <j.t.ouwerling@student.rug.nl>, University of Groningen
% Date created: June 3, 2015
%
% Request an initial guess by the user. It shows the center gridpoint on
% the reference image and then lets the user select the same pixel in the
% target image. The initial guess p vector is returned.
%
% function [initialGuess] = requestInitialGuess(config, centerRow, centerCol)
%

function [initialGuess] = requestInitialGuess(config, centerRow, centerCol)
    
    % Show the reference image with the grid point highlighted
    im = imread(config.imReference.file);
    im = double(im(:,:));
    imshow(im, [0,255]);
    hold on;
    plot(centerCol,centerRow,'*y');
    figure;
    
    % Select the same pixel in the target image
    [selectedRow, selectedCol] = selectPixel(config.imTarget.file);
    close;
    
    % Create the initial guess vector.
    initialGuess = createPvector( ...
        selectedCol - centerCol, ...
        selectedRow - centerRow, ...
        0, 0, 0, 0 ... %derivatives
    );

end