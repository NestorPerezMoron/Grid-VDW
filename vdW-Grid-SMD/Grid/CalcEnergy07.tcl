package require namdenergy
source ../../../Grid/condCutOff02.tcl

proc computeVMDenergy { molID xPart yPart zPart Atomtype selPart GridIDx Frame} {
    #Moving particle
    #Assign new position
    $selPart set x $xPart;
    $selPart set y $yPart;
    $selPart set z $zPart;

    #Condition to use namdenergy
    set CutOff [ condCutOff $molID 10 $Atomtype ];	

    if { $CutOff == 1 } {
	
	#select complete system; to large system are not working
	set selSystem [ atomselect $molID all ];
	#Condition
	set CondNumber [$selSystem num];

	
	puts [exec pwd]
	puts "CondNumber: $CondNumber"

	if { $CondNumber > 50000} {
		puts "Create a short System"
		#Create a short systema to use namdEnergy
		unset selPart
		set selShortSystem [ atomselect $molID "(all within 30 of name $Atomtype) and (not water)" ];
		$selShortSystem writepdb ShortSystem.pdb
		$selShortSystem writepsf ShortSystem.psf

		mol load psf ShortSystem.psf pdb ShortSystem.pdb
		
		set selSystem [ atomselect top "all not name $Atomtype" ];
		set selPart [ atomselect top "name $Atomtype" ];

		#compute VDW energy between atom and system
		set NamdEnergy [namdenergy -sel $selPart $selSystem -vdw -tempname GCC.$GridIDx -switch 10 -cutoff 12 -par "../../../01_Parameters/parGrid.inp" -par "../../../01_Parameters/par_all22_prot.prm" -par "../../../01_Parameters/par_all36_prot.prm" -par "../../../01_Parameters/par_all22_prot_cmap.inp" -silent -exe "/usr/local/bin/namd2"];# -silent

		set Energy [lindex [lindex $NamdEnergy 0] 2]
#		set Energy 1.000

		unset selShortSystem
	} else {


	    	#compute VDW energy between atom and system
		set NamdEnergy [namdenergy -sel $selPart $selSystem -vdw -tempname GCC.$GridIDx -switch 10 -cutoff 12 -par "../../../01_Parameters/parGrid.inp" -par "../../../01_Parameters/par_all22_prot.prm" -par "../../../01_Parameters/par_all36_prot.prm" -par "../../../01_Parameters/par_all22_prot_cmap.inp" -silent -exe "/usr/local/bin/namd2"];# -silent	
	
		set Energy [lindex [lindex $NamdEnergy 0] 2]
#		set Energy 1.000
	}
	

        $selSystem delete;

	unset NamdEnergy selSystem
        puts "MESSAGE SAVE :: Energy: $Energy "

    } else {

	set Energy 0.000
    }

    return $Energy

    unset Energy CutOff
}





