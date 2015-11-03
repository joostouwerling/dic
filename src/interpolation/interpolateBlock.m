%
% J.T. Ouwerling <j.t.ouwerling@student.rug.nl>, University of Groningen
% Date created: May 4, 2015
%
% Using bicubic interpolation, do an interpolation over the block
% block(2,2) -- block(2,3)
%    ||            ||
% block(3,2) -- block(3,3)
%
% This algorithm solves the system of linear equations A*alpha = beta,
% where A is a set of pre-determined parameters, alpha are the
% interpolation coefficients and beta the (derivatives) of f at the corner
% pixels of the interpolation block. For more details about the 
% interpolation technique, see the report attached to this code.
%
% Input parameters:
% block:    a 4x4 matrix where the interpolation will be done over the inner
%           block as described above.
%
% Output:
% coefficientsStruct:   a 16 size struct containing the coffiecients a_00,
%                       a_10, ... , a_23, a_33.
%
% function [coefficientsStruct] = interpolateBlock(block)
%

function [coefficientsStruct] = interpolateBlock(block)
    
    % Check the block size.
    if( size(block, 1) ~= 4 || size(block, 2) ~= 4)
        throw(MException('interpolation:invalidBlockSize', ...
            sprintf('Error in interpolateBlock. \nblock not 4x4 [size = (%d,%d)].', ...
                    size(block, 1), size(block, 2)) ...
        ))
    end

    % initialize the beta vector.
    beta = zeros(16,1);
    % f(x,y) values
    beta(1) = block(2,2); % f(0,0)
    beta(2) = block(2,3); % f(1,0)
    beta(3) = block(3,2); % f(0,1)
    beta(4) = block(3,3); % f(1,1)
    % df(x,y)/dx values
    beta(5) = derivativeToX(2,2, block); % f_x(0,0)
    beta(6) = derivativeToX(3,2, block); % f_x(1,0)
    beta(7) = derivativeToX(2,3, block); % f_x(0,1)
    beta(8) = derivativeToX(3,3, block); % f_x(1,1)
    % df(x,y)/dx values
    beta(9) = derivativeToY(2,2, block); % f_y(0,0)
    beta(10) = derivativeToY(3,2, block); % f_y(1,0)
    beta(11) = derivativeToY(2,3, block); % f_y(0,1)
    beta(12) = derivativeToY(3,3, block); % f_y(1,1)
    % df(x,y)/dx values
    beta(13) = derivativeToXY(2,2, block); % f_xy(0,0)
    beta(14) = derivativeToXY(3,2, block); % f_xy(1,0)
    beta(15) = derivativeToXY(2,3, block); % f_xy(0,1)
    beta(16) = derivativeToXY(3,3, block); % f_xy(1,1)
    
    beta;
    
    % Set inv(A) and solve for alpha.
    Ainv = [1   0   0   0   0   0   0   0   0   0   0   0   0   0   0   0;
            0   0   0   0   1   0   0   0   0   0   0   0   0   0   0   0;
            -3  3   0   0   -2  -1  0   0   0   0   0   0   0   0   0   0;
            2   -2  0   0   1   1   0   0   0   0   0   0   0   0   0   0;
            0   0   0   0   0   0   0   0   1   0   0   0   0   0   0   0;
            0   0   0   0   0   0   0   0   0   0   0   0   1   0   0   0;
            0   0   0   0   0   0   0   0   -3  3   0   0   -2  -1  0   0;
            0   0   0   0   0   0   0   0   2   -2  0   0   1   1   0   0;
            -3  0   3   0   0   0   0   0   -2  0   -1  0   0   0   0   0;
            0   0   0   0   -3  0   3   0   0   0   0   0   -2  0   -1  0;
            9   -9  -9  9   6   3   -6  -3  6   -6  3   -3  4   2   2   1;
            -6  6   6   -6  -3  -3  3   3   -4  4   -2  2   -2  -2  -1 -1;
            2   0   -2  0   0   0   0   0   1   0   1   0   0   0   0   0;
            0   0   0   0   2   0   -2  0   0   0   0   0   1   0   1   0;
            -6  6   6   -6  -4  -2  4   2   -3  3   -3  3   -2  -1  -2 -1;
            4   -4  -4  4   2   2   -2  -2  2   -2  2   -2  1   1   1   1];
        
    alpha = Ainv*beta;
    % Return the coefficients in a struct
    coefficientsStruct = struct( ...
        'a00', alpha(1), ...
        'a10', alpha(2), ...
        'a20', alpha(3), ...
        'a30', alpha(4), ...
        'a01', alpha(5), ...
        'a11', alpha(6), ...
        'a21', alpha(7), ...
        'a31', alpha(8), ...
        'a02', alpha(9), ...
        'a12', alpha(10), ...
        'a22', alpha(11), ...
        'a32', alpha(12), ...
        'a03', alpha(13), ...
        'a13', alpha(14), ...
        'a23', alpha(15), ...
        'a33', alpha(16) ...
    );
    
    
    