### ./src/interpolation/derivativeToX.m
Approximates the derivative at block(row,col) in the x (i.e. column)
direction, using the finite differences method. See, for more details, 
the report attached to this code.

Input parameters:

* col:      the x (column) position in block
* row:      the y (row) position in block
* block:    a matrix with at least 1 column left and right of the input param col, and row should be between 1 and size(block, 1).

Output

* the derivative value approximation

### ./src/interpolation/derivativeToY.m
Approximates the derivative at block(row,col) in the y (i.e. row)
direction, using the finite differences method. See, for more details, 
the report attached to this code.

Input parameters:

* col:      the x (column) position in block
* row:      the y (row) position in block
* block:    a matrix with at least 1 column left and right of the input param col, and row should be between 1 and size(block, 2).

Output

* the derivative value approximation

### ./src/interpolation/derivativeToYX.m
Approximates the derivative at block(row,col) in the xy
direction, using the finite differences method. See, for more details, 
the report attached to this code.

Input parameters:

* col:      the x (column) position in block
* row:      the y (row) position in block
* block:    a matrix with at least 1 column left and right of the input param col, and 1 row above and below the input param row.

Output

* the derivative value approximation

### ./src/interpolation/interpolateBlock.m
Using bicubic interpolation, do an interpolation over the block

``block(2,2) -- block(2,3)
   ||            ||
block(3,2) -- block(3,3)``

This algorithm solves the system of linear equations A*alpha = beta,
where A is a set of pre-determined parameters, alpha are the
interpolation coefficients and beta the (derivatives) of f at the corner
pixels of the interpolation block. For more details about the 
interpolation technique, see the report attached to this code.

Input parameters:

block: a 4x4 matrix where the interpolation will be done over the inner block as described above.

Output:

coefficientsStruct:
a 16 size struct containing the coffiecients a_00, a_10, ... , a_23, a_33.

### ./src/interpolation/interpolate.m
Interpolate a complete image. It drops the boundary pixel rows and 
columns so we do not have to approximate values.

Input

* image: the image filename

Output:

Interpolation coefficients in a struct with the fields a00 .. a33, 
all having a matrix with coefficients. This is an efficient way
(memory wise) to send information back.