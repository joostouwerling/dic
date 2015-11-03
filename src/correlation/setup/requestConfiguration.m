%
% J.T. Ouwerling <j.t.ouwerling@student.rug.nl>, University of Groningen
% Date created: June 3, 2015
%
% This file shows the configuration screen and handles the input. It returns the input as a struct.
% 
% Input: none
% 
% Output:
% A success indicator (1 for succes, 0 for failire) and a struct, with the following fields
% 
% * imReference.file: the file of the reference image
% * imTarget.file: the file of the target image
% * subsetSize: a substruct with width and height
% * gridSpacing: a substruct with fields rows and cols
% * convergenceCriterion: when |dp| is smaller than this, stop optimizing
% * maxIterations: stop optimizing after this no. of iterations
% * precision: the pixel precision
% 
% function [config, success] = requestConfiguration()
%

function [config, success] = requestConfiguration()
    success = 0;
    config = [];
    % Request input from a prompt.
    defFile = 'samples\tilting1_2.tif';
    defFile2 = 'samples\tilting1_1.tif';
    def = {defFile, defFile2, '21', '21', '11', '11', '0.01', '50', '0.1'};
    prompt = {...
        'Enter the location of the reference image:', ...
        'Enter the location of the target image:', ...
        'Enter the subset size (width)', ...
        'Enter the subset size (height)', ...
        'Enter the grid spacing (horizontal)', ...
        'Enter the grid spacing (vertical)', ...
        'Enter the convergence criterion', ...
        'Enter the maximum number of iterations', ...
        'Enter the pixel search precision'
    };
    title = 'DIC input configuration';
    inputAnswer = inputdlg(prompt, title, [1 100], def);
    
    % This catches the cancel button
    if(size(inputAnswer) == 0)
        return;
    end
    
    % check if the images exist.
    imReference = char(inputAnswer(1));
    imTarget = char(inputAnswer(2));
    if(exist(imReference, 'file') ~= 2)
        errordlg('Reference image does not exists or is not a file.');
        return;
    end
    if(exist(imTarget, 'file') ~= 2)
        errordlg('Target image does not exists or is not a file.');
        return;
    end
    
    % Create a subset size vector and check if the values are valid.
    subsetSize = struct('height', str2double(inputAnswer(4)), ...
                        'width', str2double(inputAnswer(3)));
    if( isnan(subsetSize.width) || isnan(subsetSize.height) )
        errordlg('The input subset sizes are not valid integers.');
        return;
    end
    
    % Fetch the grid spacing
    gridSpacing = struct('rows', str2double(inputAnswer(6)), ... 
                         'cols', str2double(inputAnswer(5)));
    if( isnan(gridSpacing.rows) || isnan(gridSpacing.cols) )
        errordlg('The input subset sizes are not valid integers.');
        return;
    end
    
    % Convergence criterion
    convergenceCriterion = str2double(inputAnswer(7));
    if( isnan(convergenceCriterion) ) 
        errordlg('The convergence criterion is not a valid double.');
        return;
    end
    
    % Convergence criterion
    maxIterations = str2double(inputAnswer(8));
    if( isnan(maxIterations) ) 
        errordlg('The number of max iterations is not a valid integer.');
        return;
    end
    
    % Pixel precision
    precision = str2double(inputAnswer(9));
    if( isnan(precision) )
        errordlg('The precision is not a valid double.');
        return;
    end    
    
    imRefStruct = struct('file', imReference);
    imTargetStruct = struct('file', imTarget);
    
    % Set up the config struct and return with success!
    config = struct('imReference', imRefStruct, ...
                    'imTarget', imTargetStruct, ...
                    'subsetSize', subsetSize, ...
                    'gridSpacing', gridSpacing, ...
                    'convergenceCriterion', convergenceCriterion, ...
                    'maxIterations', maxIterations, ...
                    'precision', precision);
    success = 1;
    
end