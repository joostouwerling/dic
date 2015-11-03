%
% J.T. Ouwerling <j.t.ouwerling@student.rug.nl>, University of Groningen
% Date created: May 4, 2015
%
% Test the function derivateToX. The following tests are done:
% - Check on a block of size (1,1).
% - Check if the boundary checks are correct.
% - Check if the returned value is correct.
%

fails=0;

% Testing unallowed block size
disp('--- Testing block size of (1,1) ---');
block = 1;
try
    derivativeToX(1,1,block);
catch ME
    if( strcmp(ME.identifier, 'interpolation:outOfRange'))
        disp('OK: Detected block size of 1 error.');
    else
        disp('FAIL: Unidentifierd error when detecting block size of 1');
        disp(ME.message);
        fails = fails+1;
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% testing unallowed values for x

disp('--- Testing block size of (3,3) but x = 1 || 3 ---');
block = [0,0,0;1,1,1;2,2,2];
try
    derivativeToX(1,1,block);
catch ME
    if( strcmp(ME.identifier, 'interpolation:outOfRange'))
        disp('OK: Detected x=1 error.');
    else
        disp('FAIL: Unidentifierd error when detecting x = 1');
        disp(ME.message);
        fails = fails+1;
    end
end
try
    derivativeToX(3,1,block);
catch ME
    if( strcmp(ME.identifier, 'interpolation:outOfRange'))
        disp('OK: Detected x = size(block,2) error.');
    else
        disp('FAIL: Unidentifierd error when detecting x = size(block,2)');
        disp(ME.message);
        fails = fails+1;
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Testing unallowed values for y

disp('--- Testing block size of (3,3) but y = 0 || 4 ---');
block = [0,0,0;1,1,1;2,2,2];
try
    derivativeToX(2,0,block);
catch ME
    if( strcmp(ME.identifier, 'interpolation:outOfRange'))
        disp('OK: Detected y=0 error.');
    else
        disp('FAIL: Unidentifierd error when detecting y = 0');
        disp(ME.message);
        fails = fails+1;
    end
end
try
    derivativeToX(2,4,block);
catch ME
    if( strcmp(ME.identifier, 'interpolation:outOfRange'))
        disp('OK: Detected y = size(block,1)+1 error.');
    else
        disp('FAIL: Unidentifierd error when detecting y = size(block,1)+1');
        disp(ME.message);
        fails = fails+1;
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Test derivative values

disp('--- Testing derivative values for block = zeros(3), block = [0,3,9] and block = [1 2 3, 4 5 6, 7 8 9] at (2,2)');

block = zeros(3);
derivative = derivativeToX(2,2,block);
if (derivative == 0)
    disp('OK: derivative for zeros block.');
else
    disp(sprintf('FAIL: derivative for zeros block was %d', derivative));
    fails = fails+1;
end

block = [0,3,9];
derivative = derivativeToX(2,1,block);
if (derivative == 4.5)
    disp('OK: derivative for 2nd block.');
else
    disp(sprintf('FAIL: derivative for 2nd block was %d', derivative));
    fails = fails+1;
end

block = [1,2,3;4,5,6;7,8,9];
derivative = derivativeToX(2,2,block);
if (derivative == 1)
    disp('OK: derivative for 3nd block.');
else
    disp(sprintf('FAIL: derivative for 3nd block was %d', derivative));
    fails = fails+1;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp('----------------------');  
if(fails == 0)
    disp('ALL TESTS PASSED!');
else
    disp(sprintf('FAIL: %d tests failed!', fails));
end

       
