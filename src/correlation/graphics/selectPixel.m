%
% J.T. Ouwerling <j.t.ouwerling@student.rug.nl>, University of Groningen
% Date created: June 3, 2015
%
% Let the user select a pixel in (the target) image.
%
% http://www.mathworks.com/matlabcentral/answers/31906-user-input-from-clicking-on-a-position-on-a-diagram-image
%
function [row, col] = selectPixel(imageFile)
    
    % Show the image
    im = imread(imageFile);
    imshow(im);
    axis([0 size(im,1) 0 size(im, 2)]);
    zoom on;
    
    % wait for enter press before going to point selection.
    waitfor(gcf,'CurrentCharacter',char(13))
    zoom reset
    zoom off
    [x,y] = ginput(1);
    
    % return
    row = round(y);
    col = round(x);
    close;
    
end