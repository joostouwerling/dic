%
% J.T. Ouwerling <j.t.ouwerling@student.rug.nl>, University of Groningen
% Date created: June 10, 2015
%
% Interpolate a complete image. It drops the boundary pixel rows and 
% columns so we do not have to approximate values.
%
% Input
%
% * image: the image filename
%
% Output:
%
% Interpolation coefficients in a struct with the fields a00 .. a33, 
% all having a matrix with coefficients. This is an efficient way
% (memory wise) to send information  back.
%
% function [interpolationCoefficients] = interpolate(image)
%

function [interpolationCoefficients] = interpolate(image)
    
    % read the image
    image = imread(image);
    image = double(image(:,:));

    % Check the block size.
    if( size(image, 1) < 4 || size(image, 2) < 4)
        throw(MException('interpolation:invalidImageSize', ...
            sprintf('Error in interpolate. \nimage must be at least 4x4 [size = (%d,%d)].', ...
                    size(image, 1), size(image, 2)) ...
        ));
    end

    % Initialze the struct matrix.
    [height, width] = size(image);
    height = height - 3;
    width = width - 3;
    interpolationCoefficients = struct( ...
        'a00', zeros(height, width), ...
        'a01', zeros(height, width), ...
        'a02', zeros(height, width), ...
        'a03', zeros(height, width), ...
        'a10', zeros(height, width), ...
        'a11', zeros(height, width), ...
        'a12', zeros(height, width), ...
        'a13', zeros(height, width), ...
        'a20', zeros(height, width), ...
        'a21', zeros(height, width), ...
        'a22', zeros(height, width), ...
        'a23', zeros(height, width), ...
        'a30', zeros(height, width), ...
        'a31', zeros(height, width), ...
        'a32', zeros(height, width), ...
        'a33', zeros(height, width) ...
    );
    
    wb = waitbar(0, 'Interpolating...');

    for row = 2:height+1
        for col = 2:width+1
            block = image((row-1):(row+2), (col-1):(col+2));
            % i = 0
            coeff = interpolateBlock(block);
            interpolationCoefficients.a00(row-1,col-1) = coeff.a00;
            interpolationCoefficients.a01(row-1,col-1) = coeff.a01;
            interpolationCoefficients.a02(row-1,col-1) = coeff.a02;
            interpolationCoefficients.a03(row-1,col-1) = coeff.a03;
            % i = 1
            interpolationCoefficients.a10(row-1,col-1) = coeff.a10;
            interpolationCoefficients.a11(row-1,col-1) = coeff.a11;
            interpolationCoefficients.a12(row-1,col-1) = coeff.a12;
            interpolationCoefficients.a13(row-1,col-1) = coeff.a13;
            % i = 2
            interpolationCoefficients.a20(row-1,col-1) = coeff.a20;
            interpolationCoefficients.a21(row-1,col-1) = coeff.a21;
            interpolationCoefficients.a22(row-1,col-1) = coeff.a22;
            interpolationCoefficients.a23(row-1,col-1) = coeff.a23;
            % i = 3
            interpolationCoefficients.a30(row-1,col-1) = coeff.a30;
            interpolationCoefficients.a31(row-1,col-1) = coeff.a31;
            interpolationCoefficients.a32(row-1,col-1) = coeff.a32;
            interpolationCoefficients.a33(row-1,col-1) = coeff.a33;
        end
        if(mod(row, floor(height / 10)) == 0)
            percentage = (row - 2) / (height-1);
            waitbar(percentage, wb);
        end
    end
    close(wb);
    
end
    
    