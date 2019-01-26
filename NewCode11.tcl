#This script generate a Van-der-Walls grid
#The type of grid can be of Carbon, Nitrogen, Oxygen, etc
#To representate the properties of the System, is necessary a grid of each type of atom  
#This script will add a atom in a grid with a system
#The atom will analize all the points in the grid
#The energy between the atom and the system will be save in a dx file, example.dx

######################## Procedures ##########################
#Everything in the dir Grid/

source ../../../Grid/CalcEnergy07.tcl; 
source ../../../Grid/JoinSystem.tcl
source ../../../Grid/Header.tcl

#################### System #############
#System could be any macromolecule 

set SystemPSF ionMHC.psf;					#psf file of system
set SystemPDB ionMHC.pdb;					#pdb file of system
set SystemDCD backup03.dcd;					#dcd file of equilibration


#Running
#set GridType O;			#Type of grid				
set Output MHC;							#Output Name


#The segment of frame created by core are specify in List.log
set FileCore [open List.log r];

#Extract the information of List.log
while {[gets $FileCore line] != -1} {
        set Data [split $line .]
        set Frame [lindex $Data 1];                       
        set PointStart [lindex $Data 2];
	set PointFinish [ expr $PointStart + 1 ]
        set GridType [lindex $Data 3];                  #Type of grid                           
}

close $FileCore
unset Data FileCore


###
######################### Grid Parameters #####################
#Parameters specify in a dx file
#(111*111*177)/3=entero       ===============================
set GridPoints {111 111 177};					#Points in each axes[111 111 177]
set GridOrigin {88.589 -2.76 -61.669};			
set GridDeltaX { 0.9 0 0 };
set GridDeltaY { 0 0.9 0 };
set GridDeltaZ { 0 0 0.9 };
set GridNumbers [expr 1*[lindex $GridPoints 1]*[lindex $GridPoints 2]];

#Imaginary value, related to position
set GridID { 0 0 0 };						


########################### Divide frames #########################

set TotalPoints $GridNumbers


#Atomtype -> Particle used to establish de VDW energy (Epsilon, Rmin)
#The parameters of each atom must be especify in dir 01_parameters
#The pdb and psf file must be in Grid/01_Structures
#Atom could be any atom specified below in Atomtype
set Atomtype ${GridType}VW;	
set AtomPSF Particle.$Atomtype.psf;				
set AtomPDB Particle.$Atomtype.pdb;		

############ New Files ##############

set CreateCond [file exists ../SysAtm.$Frame.pdb]

if { $CreateCond == 0 } {
	#Create workspace
	set SystemAtom [ JoinSystem $SystemPDB $SystemPSF $SystemDCD $AtomPDB $AtomPSF SysAtm.$Frame $Frame]; 
	file copy SysAtm.$Frame.pdb ../
	file copy SysAtm.$Frame.psf ../

	#Header have the parameters of all the grids
	[ WriteHeader $GridPoints $GridOrigin $GridDeltaX $GridDeltaY $GridDeltaZ $Frame ]; 

} else {

	set SystemAtom SysAtm.${Frame}
#	file copy ../Part.0/SysAtm.$Frame.pdb ../
#	file copy ../Part.0/SysAtm.$Frame.psf ../
}



#Load workspace
mol new ../$SystemAtom.psf type psf waitfor all;
mol addfile ../$SystemAtom.pdb type pdb waitfor all;
set molID [ molinfo top ];

#Separate the ID in each XYZ axes
#IDx, IDy, IDz start in 0
#set GridIDx [lindex $GridID 0];				#ID in X
set GridIDx $PointStart;
set GridIDy [lindex $GridID 1];				#ID in Y
set GridIDz [lindex $GridID 2];				#ID in Z

#GridPoints define the lenght of the grid
#Separate the number of points in each XYZ axes
#ID will increase until: GridIDx < GridPointX
set GridPointX $PointFinish;
set GridPointY [lindex $GridPoints 1];
set GridPointZ [lindex $GridPoints 2];

############# Deltas ############
#Everything is getting in Grid Parameters
#GridDeltaX = { 1 0 0 }
#DeltaXx = 1
#DeltaXy = 0
#DeltaXz = 0

#in X
set DeltaXx [lindex $GridDeltaX 0]
set DeltaXy [lindex $GridDeltaX 1]
set DeltaXz [lindex $GridDeltaX 2]

#in Y
set DeltaYx [lindex $GridDeltaY 0]
set DeltaYy [lindex $GridDeltaY 1]
set DeltaYz [lindex $GridDeltaY 2]

#in Z
set DeltaZx [lindex $GridDeltaZ 0]
set DeltaZy [lindex $GridDeltaZ 1]
set DeltaZz [lindex $GridDeltaZ 2]


#Separate the position in each XYZ axes
#The position will start in the origin
#set PositionX [lindex $GridOrigin 0];			

set PositionX [expr ([lindex $GridOrigin 0] + ($GridIDx*$DeltaXx)) ];
set PositionY [lindex $GridOrigin 1];
set PositionZ [lindex $GridOrigin 2];

#Restart values are the backup of the origin
set RestartX $PositionX;
set RestartY $PositionY;
set RestartZ $PositionZ;

set Counter1 0
set Counter2 0





#Selection of the atom to calculate energies
set selPart [ atomselect $molID "name $Atomtype" ];

#dx file
#	file copy ../CreateDX/Header.dx ../CreateDX/$Output.$CurrentFrame.dx;
set FileDX  [ open ../../../CreateDX/Frame.$Frame/$Output.$Frame.P.$PointStart.dx "w" ];	

################ Process #################
#Each time GridIDz = GridPointZ, GridIDz return to 0 and PositionZ restart to origin
#The grid increase first in Z, then in Y and finally in X axes

while { $GridIDx < $GridPointX } {

#Increase Z, then Y and finally X, example:
#New grid
#GridPoints = { 2 2 2}
#GridOrigin = { 0 0 0}	
#GridDeltaX = { 1 0 0 }
#GridDeltaY = { 0 1 0 }
#GridDeltaZ = { 0 0 1 }

    if { $GridIDz == $GridPointZ } {

	#Increase Position with DeltaY
	set PositionX [expr $PositionX + $DeltaYx]
	set PositionY [expr $PositionY + $DeltaYy]
	set PositionZ [expr $PositionZ + $DeltaYz]

	#If GridIDz = GridPointZ
	#Restart GridIDz to 0
	#Restart PositionZ to origin(RestartZ)
	#GridIDy increase by 1
	set GridIDz 0;					
	set PositionZ $RestartZ;
	incr GridIDy

	if { $GridIDy == $GridPointY } {

	    #Increase Position/Coordinates with DeltaX
	    #To evade the moving of the particle en the axe X by other Deltas(Y or Z)
	    #RestartX have to increase and replace PositionX
	    #If GridIDy = GridPointY
	    #Restart GridIDy to 0
	    #Restart PositionY to origin(RestartY)
	    #GridIDx increase by 1
	    set RestartX [expr $RestartX + $DeltaXx];	

	    set PositionX $RestartX
	    set PositionY [expr $PositionY + $DeltaXy]
	    set PositionZ [expr $PositionZ + $DeltaXz]

		    
	    set GridIDy 0;	
	    set PositionY $RestartY;
	    incr GridIDx
		    
	}
    }     

    set timerNow [ exec date ]
    puts "MESSAGE :: time start $Frame: $Counter1 of $GridNumbers :: $timerNow" 
    unset timerNow	

    #Calculate VDW energy
    set VDW [ computeVMDenergy $molID $PositionX $PositionY $PositionZ $Atomtype $selPart $GridIDx $Frame];
	    
    #Condition to write the new files
    #The dx file have three columns
    #...
    #object 3 class array type double rank 0 items 8 data follows
    #1 1 1 	 
    #1 0 0 	 
    #0 0
	    
    if { $GridIDx != $GridPointX } {
	set GridCounter [expr $Counter2 + 1]

	#Write in dx file
	if { $GridCounter % 3 == 0 } {
	    puts $FileDX "$VDW "  

	} else {

	    if { $GridCounter == 0 } {
	    	puts -nonewline $FileDX "$VDW "   

	    } else {
		puts -nonewline $FileDX "$VDW "

	    }
	}
	unset VDW GridCounter
    }

    set timerNow [ exec date ];
    puts "MESSAGE :: time finish $Frame: $Counter1 of $GridNumbers :: $timerNow" 
    unset timerNow

    #Increase Position/Coordinates with DeltaZ
    #GridIDz have to increase in each iteration
    set PositionX [expr $PositionX + $DeltaZx]
    set PositionY [expr $PositionY + $DeltaZy]
    set PositionZ [expr $PositionZ + $DeltaZz]

    incr GridIDz 
    incr Counter1
    incr Counter2
}

#Close files
close $FileDX

file rename Frame.$Frame.$PointStart.$GridType.log ../

#delete files
if { $PointFinish == [lindex $GridPoints 0] } {
	file delete 
	set FileFinish [ open ../Finish.log "w" ];
	puts $FileFinish [ exec date ]
	close $FileFinish
	unset FileFinish
}

cd ..
file delete -force Part.$PointStart

unset Frame PointStart GridType molID PositionX PositionY PositionZ RestartX RestartY RestartZ Atomtype selPart GridIDx GridIDy GridIDz Counter1 Counter2

exit;

# pmepot -mol $mol -cell {{ 138.539 42.69 -10.819 } { 129.6 0 0 } { 0 108 0 } { 0 0 230.40 } } -grid {144 120 256} -grid 0.9 -dxfile G-electro.dx

