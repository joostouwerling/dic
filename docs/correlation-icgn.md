### ./src/correlation/icgn/getDeltaP.m
This function calculates the delta p step in the IC GN optimization of the p vector. The theory behind it can be found in the report. 

Input: 

* rowInit: the row of the gridpoint
* colInit: the column of the gridpoint
* rows: a discrete set of row values. Calculated based on subsetsize and precision.
* cols: "..." of column values "..."
* config: the config structure.
* p: the current best p vector
* fData: a struct with reference image values, mean and delta
* hessian: the pre-computed hessian

Output:

* dp: the delta p vector which need to be inverted and applied to p.

### ./src/correlation/icgn/getHessian.m
Calculate and return the hessian as defined in the theory for IC-GN

Input

* rowInit: the row of the gridpoint
* colInit: the col of the gridpoint
* rows: a discrete set of row values. Calculated based on subsetsize and precision.
* cols: "..." of column values "..."
* fData: reference image values and the mean and delta value.

Output:

* a 6x6 hessian matrix

### ./src/correlation/icgn/optimizeICGN.m
This function executes the IC-GN optimization. First, the reference image values are calculated as well as the hessian. Then the loop keeps calculating delta p until converged or the number of maximum iterations is reached. There is also a check of out of bounds.

There are several subfunction used. These are:

* willOverflow: check if the current p will get out of bounds.
* criterionSatisfied: check if the convergence criterion is satisfied
* getUpdatedPvector: uses the inversion of the warp function to get the updated p vector
* constructWarpFromP: name says it all. Creates warp matrix from p vector.
* extractPfromWarp: extract the p vector from a warp matrix

Input:

* initialp: the initial p vector guess
* row: the gridpoint row
* col: the gridpoint col
* config: the config struct

Output:

* result: One of DicConstants.RESULT_(OK | OUT_OF_BOUNDS | NO_CONVERGENCE)
* p: the optimal p vector in 4 digits accuracy. All elements Inf if the result is not RESULT_OK.
* c: the correlation coefficient in 4 digits accuracy. Is Inf if result is not RESULT_OK
* iterations: the number of iterations done until stopping conditions were met.
