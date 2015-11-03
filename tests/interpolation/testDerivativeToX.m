%{
Test the function derivateToX. The following tests are done:
- Check if the boundary checks are correct.
- Check if the returned value is correct.
%}

block = 1;
try
    derivativeToX(1,1,block)
catch ME
    disp(ME.identifier);
end