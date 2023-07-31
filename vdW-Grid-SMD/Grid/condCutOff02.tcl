#This script will reduce the number of point to evalueta depending in the space between the atom and the system

proc condCutOff { molID cutOff Atomtype } {

    # select atom
    set aroundAtom [ atomselect $molID "(all within $cutOff of name $Atomtype) and not name $Atomtype" ];

    # number of atoms around
    set NumaroundAtom [ $aroundAtom num ];

    if { $NumaroundAtom > 0 } {
	set condCutOff 1;
    } else {
	set condCutOff 0;
    }

    puts "message cutoff: $condCutOff"

    return $condCutOff;

    unset aroundAtom NumaroundAtom condCutOff
}





