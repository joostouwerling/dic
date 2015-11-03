### ./src/correlation/graphics/selectpixel.m
Let the user select a pixel in (the target) image.

### ./src/correlation/graphics/plotDisplacements.m
Plots the calculated displacements on the reference image. Plots a red asterisk if it could not convergence or a blue asteriks when out of bounds for all grid points.

Input:

* config: the configuration struct
* output: the output array created in dic.m

Output:
It shows an image with vectors and asterisks.


### ./src/correlation/graphics/plotGridpoints.m
Plot the gridpoints and subsets on the reference image.

Input:

* config struct

Output:

The reference image with at every gridpoint a yellow asterisk with a white subsetborder around it.