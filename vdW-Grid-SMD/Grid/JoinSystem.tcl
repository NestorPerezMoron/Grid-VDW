#Scrip to join a System and a particle specified in GridParameters.txt

proc JoinSystem { SystemPDB SystemPSF SystemDCD AtomPDB AtomPSF Output Frame} {
	package require psfgen
##############rev

#	mol new ../../../Grid/01_Structures/$SystemPSF type psf waitfor all
#	mol addfile ../../../Grid/01_Structures/$SystemDCD type dcd waitfor all

	mol new ../../../StructuresGrid/$SystemPSF type psf waitfor all
	mol addfile ../../../StructuresGrid/$SystemDCD type dcd waitfor all

#9913
	set System [atomselect top protein frame $Frame]
	$System writepdb Frame.$Frame.pdb

	resetpsf;

#	puts "read $SystemPSF"
	#PSF have to be protein alone
#	readpsf ../../../Grid/01_Structures/$SystemPSF
	readpsf ../../../StructuresGrid/$SystemPSF
	coordpdb Frame.$Frame.pdb

	readpsf ../../../Grid/01_Structures/$AtomPSF
	coordpdb ../../../Grid/01_Structures/$AtomPDB

	writepsf $Output.psf
	writepdb $Output.pdb

	resetpsf;	

	unset System
	return $Output

}

