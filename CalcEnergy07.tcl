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

        #select system
        set selGCCX [ atomselect $molID "all not name $Atomtype" ];
	
	puts [exec pwd]
    	#compute VDW energy between atom and system
	set NamdEnergy [namdenergy -sel $selPart $selGCCX -vdw -tempname GCC.$GridIDx -switch 10 -cutoff 12 -par "../../../01_Parameters/parGrid.inp" -par "../../../01_Parameters/par_all22_prot.prm" -par "../../../01_Parameters/par_all36_prot.prm" -par "../../../01_Parameters/par_all22_prot_cmap.inp" -silent -exe "/usr/local/bin/namd2"];# -silent
	set Energy [lindex [lindex $NamdEnergy 0] 2]

#	set Energy 1.000

        $selGCCX delete;

	unset NamdEnergy selGCCX
        puts "MESSAGE SAVE :: Energy: $Energy "

    } else {

	set Energy 0.000
    }

    return $Energy

    unset Energy CutOff
}





