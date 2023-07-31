DO NOT ADD OR REMOVE LINES OF THE FILES

To generate the van der Waals GRID, follow the next steps

1.- move your PDB, PSF and DCD file to dir ./StructuresGrid/
2.- Open the file GridParameters.txt and put the name files of your system
3.- Change the parameters to the size of your system (see below)
4.- Run the script ./Run05.sh
5.- Go to dir ./CreateDX and you will find the grids when the script finish to run. Trial.AllFrames.dx is the final DX file with the sum of all the energies in each frame

Chose the size system:

1. Get the minmax values of the system in the water box
	measure minmax $SELECTION
2. In GridParameters.txt, replace the line 23 of GridOrigin with the min values
3. Calculate the distance in the water box: [MAX(x,y,z) - MIN(x,y,z)] and replace the line 18 of GridPoints with the result in integer number. The Y value or the Z value must be the number must be divisible by 3 to work:

EXAMPLE
GridPoints: 140 150 170
in Z value, 170 are not divisible by 3 (170/3=56.667) but in Y value, 150 is divisble by 3(150/3=50), is only necessary that one of these two values are divisible by 3


########
The Origin of the Grid(GridOrigin) is the lowest value in the grid
The particle which will scan all the grid, start in the origin and increase with a delta value (GridDeltaX, GridDeltaY and GridDeltaZ)



################# EXPLANATION OF THE SCRIPT ############

The script have to follow the format of a .dx file to represent the energies in NAMD
NAMD read the values in .dx file starting in Z axe, then Y axe is completed and finally, the X axe

For example, in a grid with 8 points, divided in 2x2x2 that is represent as 2 2 2 (X Y Z)

0 1 2 
3 4 5
6 7 

			 X Y Z
			 _____
0 - correspond to points 0 0 0		
1 - correspond to points 0 0 1		
2 - correspond to points 0 1 0		
3 - correspond to points 0 1 1		
4 - correspond to points 1 0 0		
5 - correspond to points 1 0 1		
6 - correspond to points 1 1 0		
7 - correspond to points 1 1 1		


When Z is equal to the parameter especified, it is return to 0 and Y increase in 1
When Y is equal to the parameter especified, it is return to 0 and X increase in 1
When X is equal to the parameter especified, the script stops


The script are design to create 1 grid for each frame in a simulation.
To create the grid, the script will divide the grid in X files 
(the X points specified in the parameters)
When the script calculate all the values of a frame, it will add each file and create the dx file

Example: 
1 Frame with a grid size of 2x3x4(2 3 4) = 2 .dx files of 1x3x4
1 Frame with a grid size of 10x11x12(10 11 12) = 10 .dx files of 1x11x12
