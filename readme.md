# Digital Image Correlation

This Matlab **R2010a**, as developed on a Windows 8.1 64 bit system, source code is implemented by J.T. Ouwerling (<j.t.ouwerling@student.rug.nl>) and it is highly recommended for readers to read his report, Digital Image Correlation for 3D surface topography in Scanning Electron Microscopy, attached in this repository. The code and report are co-authored by dr. ir. E.T. Faber (<ennefaber@gmail.com>) and J. Th. M. De Hosson (<J.T.M.de.Hosson@rug.nl>). &copyright; University of Groningen, 2015

## Code structure
There are four folders which contain Matlab (and a bit Java) source code, as well as other things: *./src/*, *./tests/*, *./docs/* and *./samples/*, their names implying what is inside of it. 

### ./docs/
Source code documentation, divided in different Markdown files.

### ./samples/
A few SEM images which can be used for testing.

### ./tests/
There are currently not many unit tests and this is something that should be improved, since it will very much increase the certainty that our results are indeed according to the mathematics. It was outside the scope of the project, but can be added later on.

### ./src/
This is where the code of the project is located. It has two subfolders to add more structure in the code organization. These subfolders can be seen as independent modules. These subfolders are:

* **./src/correlation/**: All code concerning correlation is located here. It has several subfolders with somewhat correlated functions.
* **./src/interpolation/**: The Bicubic interpolation code is located here.

All source code is somewhat documented and described in the docs folder. Every function/script is well documented, so *help <function>* in Matlab might prove to be useful if you don't know what to do at a certain point.

# Running the Code
Open Matlab, and select under current folder the directory where you have clone'd this repo into. Select src with a right mouse click and select Add Path -> Add Selected Path and Subfolders. Now run the program by doing

``>> output = dic();``

## Java compilation (priority queue)
The priority queue depends on some Java code. Go to the folder *./src/correlation/priorityqueue/mkgroup/dic/* and execute, from the command line:

``javac *.java``

You have to make sure that you have the right version of Java Development Kit installed. It has to be the same as the JVM version of Matlab. You can find the version by running, in Matlab

``>> version -java``

ans =

Java 1.6.0_12-b04 with Sun Microsystems Inc. Java HotSpot(TM) 64-Bit Server VM mixed mode

This is Java 6, as the version number is behind the 1. 

# (un) necessary updates

* unit tests
* loading bar progress indicator for the ICGN process
* Some subfunctions could be extracted from main functions (like in optimize ICGN)
* vectorization and thereby making speed improvements, making prototyping more useful.
* some renaming of variables, which were programmed before correctly defined. (like all row- and colInits -> gridpointRow, gridpointCol)

