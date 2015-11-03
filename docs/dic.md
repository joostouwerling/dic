### ./src/dic.m
This file is the imperative program which is connects the dic parts together. It has several sections, which are clearly indicated in the code.

1. Instruction messages and configuration input
2. Gridpoint definitions and user-based initial guess
3. Interpolation of both images
4. Optimize the initial guess using coarse fine search.
5. Prepare the output data structure.
6. Setup the priority queue and its dependencies.
7. The reliability-guided displacement tracking strategy. (see the report for more info on this)

There are also two helper functions. **approximateInitialGuess** approximates the initial guess of a new gridpoint by applying a correction factor based on distance from its "parent" gridpoint. **storeResult** stores the results of IC-GN optimization in the output array.

Input: dic()

Output:
A 4x1 struct with the following fields, all 2d arrays:

* result: one of DicConstants.RESULT_(OK | NO_CONVERGENCE | OUT_OF_BOUNDS)
* coefficient: the correlation coefficient at that grid point
* iterations: the number of needed iterations before convergence.
* p: a 6x1 struct with the following fields: u, v, u_x, u_y, v_x, v_y

The somewhat weird structure of the p field is because of memory considerations. Matlab uses a lot of header data for every different struct field, so adding separate p's would take a lot of memory (width*height*headerData) instead of (6*headerData).

**Important note**: the p vector returned is in terms of rows and cols, not in x and y. A conversion needs to be applied to make it correct. The units are pixels.