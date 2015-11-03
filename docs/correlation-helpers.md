### ./src/correlation/helpers/DicConstants.m
A Matlab class with some numerical constants, which can be used for storing state and results. The following constants are available:

For results of IC-GN:

* RESULT_OK
* RESULT_NO_CONERGENCE
* RESULT_OUT_OF_BOUNDS

For status of gridpoints in the priority queue

* STATUS_READY
* STATUS_IN_QUEUE
* STATUS_DONE

### ./src/correlation/helpers/createPvector.m
This function creates the infamous p vector

Input:

* u
* v
* u_x
* u_y
* v_x
* v_y

Output:

* A p struct with all inputs as fields.

### ./src/correlation/helpers/getDisplacementRowCol.m
**deprecated - time overhead too large**

Get the displacement row and column for a certain p vector.
Input:

* row: the row of the gridpoint
* col: the column of the gridpoint
* dRow: the distance between the row of the point and the row of the
gridpoint
* dCol: the distance between the col of the point and the column of the
gridpoint
* p: the p vector

Output:

 * row and column of the displacement 

### ./src/correlation/helpers/getReferenceValues.m
Calculate information about the reference subset and return it as a struct, to prevent recalculation.

Input:

* rows: the discrete set of row values for the subset
* cols: the discrete set of column values for the subset
* config: the configuration struct

Output:
A struct fData with the fields: values, mean and delta, dy and dx.

* values: the values at all points [0,255]
* mean: the mean of all values
* delta: the delta of all values
* dy: df/dy at all points
* dx: df/dx at all points

### ./src/correlation/helpers/getValueAtRowCol.m
** deprecated - takes too much computing overhead **

Get the greyscale value at row and col, using the coefficient list of a complete image.

function [value] = getValueAtRowCol(row, col, coeff)

### ./src/correlation/helpers/calculateZNSSD.m
This function calculates the ZNSSD correlation coefficient. 

Input:

* rowInit: The row of the gridpoint
* colInit: the column of the gridpoint
* config: the config array as created by requestConfiguration() and modified in dic.m
* p: the p displacement factir
* [optional] fValues: values of the reference subset, to prevent recomputing it.

Output:
* A 4 digit precision correlation coefficient.