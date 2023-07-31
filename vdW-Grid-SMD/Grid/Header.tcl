#This script will write a file with the parameters of the Grid
#The parameters are specified in NewCode06.tcl
proc WriteHeader { GridPoints GridOrigin GridDeltaX GridDeltaY GridDeltaZ Frame } {

	set Header [ open ../../../CreateDX/Header.dx "w"];

	set PointX [lindex $GridPoints 0];
	set PointY [lindex $GridPoints 1];
	set PointZ [lindex $GridPoints 2];

#	set OriX [lindex $GridOrigin 0]
#	set OriY [lindex $GridOrigin 1]
#	set OriZ [lindex $GridOrigin 2]

#	set X_dx [lindex $GridDeltaX 0]
#	set X_dy [lindex $GridDeltaX 1]
#	set X_dz [lindex $GridDeltaX 2]

#	set Y_dx [lindex $GridDeltaY 0]
#	set Y_dy [lindex $GridDeltaY 1]
#	set Y_dz [lindex $GridDeltaY 2]

#	set Z_dx [lindex $GridDeltaZ 0]
#	set Z_dy [lindex $GridDeltaZ 1]
#	set Z_dz [lindex $GridDeltaZ 2]

	set GridNumbers [expr $PointX*$PointY*$PointZ ];

	puts $Header "object 1 class gridpositions counts $GridPoints ";
	puts $Header "origin $GridOrigin ";
	puts $Header "delta $GridDeltaX ";
	puts $Header "delta $GridDeltaY ";
	puts $Header "delta $GridDeltaZ ";
	puts $Header "object 2 class gridconnections counts $GridPoints ";
	puts $Header "object 3 class array type double rank 0 items $GridNumbers data follows";

	close $Header;
	
	unset GridPoints GridOrigin GridDeltaX GridDeltaY GridDeltaZ PointX PointY PointZ GridNumbers Frame;

}
