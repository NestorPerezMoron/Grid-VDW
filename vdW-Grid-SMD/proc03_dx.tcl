##Read a file to manipulelate the values
##Useful for add, multiply the field values or change parameters
##recommended comand: array set $list value

###################Guide#######################

#read_dx (FIlE) (NEW_VARIABLE)				
#scale_dx (VARIABLE_1) (NEW_VARIABLE) (MULTIPLIER)	
#add_dx (VARIABLE_1) (VARIABLE_2) (NEW_VARIABLE)	
#write_dx (EXISTING_VARIABLE) (NEW_FILE)		

## FILE, VARIABLE_1 and VARIABLE_2 and EXISTING_VARIABLE must exist

#===================read_dx=================================
#array names (NEW_VARIABLE): hx xmin nz u hy ymin hz zmin nx xyz ny

proc read_dx {fname data} {

    upvar 1 $data dx_data

    ## Unset array holding any current dx data
    catch {[array unset dx_data]}

    ##open file
    set fid [open $fname "r"]

    array set dx_data {}
    set temp {}

    ## Loop over file, read line-by-line, match
    while {[gets $fid line] >= 0} {

        switch -regex $line {

            {\#} {
                lappend dx_data(comments) $line
            }

            object*1* {
                scan $line "object 1 class gridpositions counts %i %i %i"\
                    dx_data(nx) dx_data(ny) dx_data(nz)
                continue
            }

            origin* {
                scan $line "origin %e %e %e"\
                    dx_data(xmin) dx_data(ymin) dx_data(zmin)
                continue
            }

            delta* {
                scan $line "delta %e %e %e" hx hy hz
                lappend delta $hx $hy $hz
                continue
            }

            {[-+]?([0-9]+\.?[0-9]*|\.[0-9]+)([eE][-+]?[0-9]+)?} {
                ## Look for lines starting with some floatingpoints
                scan $line "%e %e %e" u1 u2 u3
                lappend temp $u1 $u2 $u3
                continue
            }

            default {continue}
        }
    }

    close $fid
    #xyz values of delta 
    lappend dx_data(hx) [lindex $delta 0] [lindex $delta 1] [lindex $delta 2] 
    lappend dx_data(hy) [lindex $delta 3] [lindex $delta 4] [lindex $delta 5] 
    lappend dx_data(hz) [lindex $delta 6] [lindex $delta 7] [lindex $delta 8] 

    ## Transpose u so that x dimension
    ## changes fastest, then y then z.
    ## Convert from kT/e =0.0256 V
    upvar 0 dx_data(nx) nx
    upvar 0 dx_data(ny) ny
    upvar 0 dx_data(nz) nz


    #number of items the file have  
    set numbers [expr $dx_data(nx) * $dx_data(ny) * $dx_data(nz)]

    #counters
    set i 0
    
    set x 0
    set y 0
    set z 0

    #add FieldValues and position
    while {$i < $numbers} {
#values of u(FieldValues)
	lappend dx_data(u) [lindex $temp $i]
#position of FieldValues
        if { $z == $dx_data(nz) } {
	    #increase y in delta y -> (hy)
	    set z 0
	    
	    set x [expr $x + [lindex $dx_data(hy) 0]]
	    set y [expr $y + [lindex $dx_data(hy) 1]]
	    set z [expr $z + [lindex $dx_data(hy) 2]]

	    if { $y == $dx_data(ny) } {
		#increase x in delta x -> (hx)        
		set y 0

	        set x [expr $x + [lindex $dx_data(hx) 0]]
	        set y [expr $y + [lindex $dx_data(hx) 1]]
	        set z [expr $z + [lindex $dx_data(hx) 2]]
	    }
        }
	#coordinates of the FieldValue
        set coor_x [expr $dx_data(xmin) + $x]
        set coor_y [expr $dx_data(ymin) + $y]
        set coor_z [expr $dx_data(zmin) + $z]

	#save coordinates
        array set coor_xyz [list $i "$coor_x $coor_y $coor_z" ]
        lappend dx_data(xyz) $coor_xyz($i)

	#increase in delta z -> (hz)
        set x [expr $x + [lindex $dx_data(hz) 0]]
        set y [expr $y + [lindex $dx_data(hz) 1]]
	set z [expr $z + [lindex $dx_data(hz) 2]]
	
	incr i
						
    }
}
######


#================================scale_dx==================================

#Narray= existing variable reading with read_dx
#new_Narray= new variable to save new data
#operator= the operator to multiplied the FieldValues 

proc scale_dx {Narray new_Narray operator} {

	upvar 1 $Narray dx_array
	upvar 1 $new_Narray new_array

	array set new_array {}

	#The values are copy except the FieldValues -> (u)
	set new_array(hx) $dx_array(hx)
	set new_array(hy) $dx_array(hy)
	set new_array(hz) $dx_array(hz)
	set new_array(nx) $dx_array(nx)
	set new_array(ny) $dx_array(ny)	
	set new_array(nz) $dx_array(nz)
	set new_array(xmin) $dx_array(xmin)
	set new_array(ymin) $dx_array(ymin)
	set new_array(zmin) $dx_array(zmin)



	#the Fieldvalues are multiplied by de operator
	set i 0
	set numbers [expr $dx_array(nx) * $dx_array(ny) * $dx_array(nz)]

	foreach x $dx_array(u) {
		#save the new FieldValues in the new variable
		lappend new_array(u) [vecscale $operator [lindex $dx_array(u) $i]]
		incr i

	}
	
}

#===========================add_dx=====================

#fname= Existing variable reading with read_dx
#fname2= Existing variable reading with read_dx
#new_Narray= new variable to save new data

proc add_dx { StartArray NumArray new_Narray ListArray } {
#Sacarlo de una lista
#gets?
	set Iteration [expr ($NumArray-$StartArray)+1]

	upvar 1 $ListArray LiArray
	upvar 1 $new_Narray new_array
	array set new_array {}

	puts $LiArray

#	gets stdin Narray1
	set Narray1 [lindex $LiArray 0]
	upvar 1 $Narray1 dx_array
	set dx_array1(u) $dx_array(u)

	set j 0
	while { $j < $Iteration } {

#		gets stdin Narray2
		set Narray2 [lindex $LiArray $j]
		upvar 1 $Narray2 dx_array2

		puts [ lindex $LiArray $j ]
	
		set i 0
		set numbers [expr $dx_array(nx) * $dx_array(ny) * $dx_array(nz)]

#		puts "Add: $dx_array1(u) "
#		puts "Add: $dx_array2(u) "
	
		#the Fieldvalues of the variables are adding
		while {$i < $numbers} {

			lappend Array(u) [vecadd [lindex $dx_array1(u) $i] [lindex $dx_array2(u) $i]]
			incr i

		}

#		puts $Array(u)

		set dx_array1(u) $Array(u)
		incr j

		if { $j == $Iteration } {		
			set new_array(u) $Array(u)
		}

		unset Array
		puts "Adding $j"
#		after 90000
	}
	
	#The values are copy except the FieldValues -> (u)
	set new_array(hx) $dx_array(hx)
	set new_array(hy) $dx_array(hy)
	set new_array(hz) $dx_array(hz)
	set new_array(nx) $dx_array(nx)
	set new_array(ny) $dx_array(ny)	
	set new_array(nz) $dx_array(nz)
	set new_array(xmin) $dx_array(xmin)
	set new_array(ymin) $dx_array(ymin)
	set new_array(zmin) $dx_array(zmin)

}


#===========================special_add======================

proc especial_add { NumArray new_Narray } {
#Guardar un file con los arrays
#gets?
#	set Iteration [expr ($NumArray-$StartArray)+1]

#	upvar 1 $ListArray LiArray
	upvar 1 $new_Narray new_array
	array set new_array {}

	gets stdin Narray1
#	set Narray1 [lindex $LiArray 0]
	upvar 1 $Narray1 dx_array
	set dx_array1(u) $dx_array(u)

	set j 0
	while { $j < $NumArray } {

		gets stdin Narray2
#		set Narray2 [lindex $LiArray $j]
		upvar 1 $Narray2 dx_array2

		set i 0
		set numbers [expr $dx_array(nx) * $dx_array(ny) * $dx_array(nz)]

		#the Fieldvalues of the variables are adding
		while {$i < $numbers} {

			lappend Array(u) [vecadd [lindex $dx_array1(u) $i] [lindex $dx_array2(u) $i]]
			incr i

		}

#		puts $Array(u)

		set dx_array1(u) $Array(u)
		incr j

		if { $j == $NumArray } {		
			set new_array(u) $Array(u)
		}

		unset Array
		puts "Adding $j"

	}
	
	#The values are copy except the FieldValues -> (u)
	set new_array(hx) $dx_array(hx)
	set new_array(hy) $dx_array(hy)
	set new_array(hz) $dx_array(hz)
	set new_array(nx) $dx_array(nx)
	set new_array(ny) $dx_array(ny)	
	set new_array(nz) $dx_array(nz)
	set new_array(xmin) $dx_array(xmin)
	set new_array(ymin) $dx_array(ymin)
	set new_array(zmin) $dx_array(zmin)

}


#============================write_dx========================
#Narray= existing variable to write in a new .dx file
#outName= Name of the new .dx file

proc write_dx { Narray outName } {

    upvar 1 $Narray dx_array 
    #generate the new file
    set fid_w [open $outName.dx "w"]
    
    
    #====================writing the new file================
    
    #values of: xmin nz hx ymin hy zmin nx hz ny
    set numbers [expr $dx_array(nx) * $dx_array(ny) * $dx_array(nz)]
	
    puts $fid_w "object 1 class gridpositions counts $dx_array(nx) $dx_array(ny) $dx_array(nz)"
    puts $fid_w "origin $dx_array(xmin) $dx_array(ymin) $dx_array(zmin) "
    puts $fid_w "delta $dx_array(hx)" 
    puts $fid_w "delta $dx_array(hy)" 
    puts $fid_w "delta $dx_array(hz)"
    
    puts $fid_w "object 2 class gridconnections counts $dx_array(nx) $dx_array(ny) $dx_array(nz)"
    puts $fid_w "object 3 class array type double rank 0 items $numbers data follows"
    
    
    # field values
    set i 0;
    while {$i < $numbers} {
	lappend dx_array(u) [lindex $dx_array(u) $i];
	puts -nonewline $fid_w "[lindex $dx_array(u) $i] ";
	incr i;
	if {$i%3==0} { 	
	    puts $fid_w " ";
	}		
	
    }
        
    puts $fid_w "\nobject \"DX modified\" class field";
    
    close $fid_w;
}


