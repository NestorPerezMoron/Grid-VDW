#!/bin/bash
#Script to generate grids of each frame
#Each core will run a point in axe X and all Y,Z

#Select the number of core to use
MaxCores="12"

#Select number of frames
StartFrame="38"
FinishFrame="100"

#PointFinish = size in axe X. Change in NewCode10.tcl
#16
PointStart="67"
PointFinish="111"

#Condition ro keep running the script
counter="1"

#Identity of the Grid
name="C"

#Workspace
rm -r CreateDX
rm -r Files

mkdir CreateDX
mkdir CreateDX/Frame.$StartFrame
mkdir Files
mkdir Files/Frame.$StartFrame
mkdir Files/Frame.$StartFrame/Part.$PointStart

######################################################
#Start multicore running
while [ $counter -gt "-1" ]; do


	##############################
	#Process
	if [ $counter -lt $MaxCores ]; then 
		
		#Grid code: NewCode10.tcl
		cp NewCode11.tcl Files/Frame.$StartFrame/Part.$PointStart/Frame.$StartFrame.$PointStart.$name.tcl
		cd Files/Frame.$StartFrame/Part.$PointStart/

		#Running
		ls Frame.$StartFrame.$PointStart.$name.tcl > List.log
		vmd -dispdev text -e Frame.$StartFrame.$PointStart.$name.tcl > Frame.$StartFrame.$PointStart.$name.log &

		cd ../../../

		#Condition
		ps > cores.log
		counter=`grep vmd_LINUXAMD64 cores.log |wc -l`
		PointStart=$[$PointStart+1]


	else

		while [ $counter -ge $MaxCores ]; do

			sensors| grep 83
			Warning1=$?

			sensors| grep 87
			Warning2=$?
			
			if [ $Warning2 -eq "1" ]; then
				if [ $Warning1 -eq "1" ]; then
					sleep 2m
				else 
					sleep 5m
				fi
			else
				sleep 15m
			fi

			
 
#			sleep 5m


			ps > cores.log
			counter=`grep vmd cores.log |wc -l`
			sleep 5

		done	
	fi
	###############################
	grep vmd cores.log 
	grep vmd cores.log |wc -l

	########## Finish ########
	echo "FRAME: $StartFrame"
	echo "PART: $PointStart"
	
	if [ $PointStart -eq $PointFinish ]; then
			
		#New Frame
		if [ $StartFrame -lt $FinishFrame ]; then

			StartFrame=$[$StartFrame+1]
			
			#Clean workspace
			rm -r CreateDX/Frame.$StartFrame
			rm -r Files/Frame.$StartFrame
			
			mkdir CreateDX/Frame.$StartFrame
			mkdir Files/Frame.$StartFrame
			
			#Restart
			PointStart="0"


		else
			#Finish the Script
			counter="-1"
			mv Files/Frame.$delete/Finish.log .
		fi
	fi

	#Clean
	rm -r Files/Frame.$StartFrame/Part.$PointStart
	mkdir Files/Frame.$StartFrame/Part.$PointStart
done





