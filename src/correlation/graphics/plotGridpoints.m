%
% J.T. Ouwerling <j.t.ouwerling@student.rug.nl>, University of Groningen
% Date created: June 3, 2015
%
% Plot the griodpoints and susbets on the image.
%
% function plotGridpoints(config)
%

function plotGridpoints(config)
    im = imread(config.imReference.file);
    im = double(im(:,:));
    imshow(im, [0,255]);
    hold on;
    for i = 1:size(config.gridpoints.rows, 2)
        for j = 1:size(config.gridpoints.cols, 2)
            plot(config.gridpoints.cols(j),config.gridpoints.rows(i),'*y');
            hold on;
            xLow = config.gridpoints.cols(j) - (config.subsetSize.width - 1) / 2;
            yLow = config.gridpoints.rows(i) - (config.subsetSize.height - 1) / 2;
            rectangle('Position',[xLow yLow config.subsetSize.width - 1, config.subsetSize.height - 1],'EdgeColor','w');
            hold on;
        end
    end
end