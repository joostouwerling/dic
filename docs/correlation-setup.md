### ./src/correlation/setup/requestConfiguration.m
This file shows the configuration screen and handles the input. It returns the input as a struct.

Input: none

Output:
A success indicator (1 for succes, 0 for failire) and a struct, with the following fields

* imReference.file: the file of the reference image
* imTarget.file: the file of the target image
* subsetSize: a substruct with width and height
* gridSpacing: a substruct with fields rows and cols
* convergenceCriterion: when |dp| is smaller than this, stop optimizing
* maxIterations: stop optimizing after this no. of iterations
* precision: the pixel precision

### ./src/correlation/setup/calculateGridpoints.m
This function calculates the gridpoints on which DIC is performed. 

Input: config struct, with the following required fields:

* config.imReference.file
* config.gridSpacing (rows & cols)
* config.subsetSize (width & height)

Output:
A struct with elements rows and cols, both a 1 x n array, which form together a 2d array of gridpoints i.e. output.rows = [1,4,7] and output.cols = [2,6,10].

### ./src/correlation/setup/getCenterGridpoints.m

get the center gridpoint from the config gridpoints struct, containing
an array in rows and an array in the cols fields.

function [row, col] = getCenterGridpoint(gridpoints)

### ./src/correlation/setup/getCenterGridpointIndices
Get the indexes of the center gridpoint in the gridpoints arrays,
created by calculateGridpoints().

function [row, col] = getCenterGridpointIndices(gridpoints)

### ./src/correlation/setup/requestInitialGuess.m
Request an initial guess by the user. It shows the center gridpoint on
the reference image and then lets the user select the same pixel in the
target image. The initial guess p vector is returned.

Input:

* config: the config struct
* centerRow: the row for the initial guess
* centerCol: the column for the initial guess

Output

* initialGuess: a p vector extracted from the user initial guess.

### ./src/correlation/setup/optimizeInitialGuess.m
This function optimizes the initial guess using coarse-fine search. It searches on a grid of 3x3 pixels in steps of 0.25 pixels for the best approximation of u and v. Their derivatives are not taken into account. This is because this method is really time consuming. It should be tested what the influence is of a better initial guess on the final results. There is a commented-out section which optimizes u_x and v_y which can be used as an example.

Input

* rowInit: the row of the gridpoint
* colInit: the column of the gridpoint
* config: the configuration struct
* initialGuess: the initial guess selected by the user.

Output:

* optimized: the optimized p vector
* cBest: the correlation coefficent for optimized.

### ./src/correlation/setup/getRowsCols.m
Calculate the discrete set of points on which the calculated is based, for a certain subset. For the complete subset, steps of config.precision are done and put in an array.

Input:

* rowInit: the row of the gridpoint
* colInit: the column of the gridpoint
* config: the config struct

Output:

* rows: a discrete set of rows
* cols: a discrete set of cols
