source proc03_dx.tcl
exec date

set NameGrid Trial
set NumFrames FRAME-X
set StartFrame 1

set Frame 1
set counter 1

while { $counter <= $NumFrames } {

	read_dx $NameGrid.$counter.dx F${counter}
#	file delete F.$Current-SubFrame.${counter}.dx
	puts F${counter}

#	after 90000

	lappend Flist F${counter}

	incr counter
}
puts "Read: complete"

add_dx $StartFrame $NumFrames $NameGrid Flist
puts "Add: complete"
write_dx $NameGrid $NameGrid.AllFrames
puts "Write: complete"
unset Flist

exec date

exit


