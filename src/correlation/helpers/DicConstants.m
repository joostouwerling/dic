%
% J.T. Ouwerling <j.t.ouwerling@student.rug.nl>, University of Groningen
% Date created: June 10, 2015
%
% A class with several numerical constants, used for storing state. 
% All constant names speak for themselves.
%

classdef DicConstants
    properties(Constant = true)
    	% For the result array.
        RESULT_OK = 0;
        RESULT_NO_CONVERGENCE = 1;
        RESULT_OUT_OF_BOUNDS = 2;
        RESULT_NOT_A_NUMBER = 3;
        % For keeping track which gridpoints are (not) done.
        STATUS_READY = 0;
        STATUS_IN_QUEUE = 1;
        STATUS_DONE = 2;
    end
end