#!/bin/bash
#Script to generate grids of each frame
#Each core will run a point in axe X and all Y,Z
#All the parameters are in the file: GridParameters.txt
#Make changes in GridParameters.txt
#The script are going to make a grid of each frame
#Each frame is the sum of all the parts especified in X axe inside GridParameters.txt
#If Grid points are {3 4 7}, the number of parts are 3, and each part have a file with 4x7 points
#All the parts are going to be addeed at the final

#Number of core to use
MaxCores=`sed '4q;d' GridParameters.txt | awk '{print $2}'`

#Structures
FilePDB=`sed '6q;d' GridParameters.txt | awk '{print $2}'`
FilePSF=`sed '7q;d' GridParameters.txt | awk '{print $2}'`
FileDCD=`sed '8q;d' GridParameters.txt | awk '{print $2}'`

#Output
Output=`sed '10q;d' GridParameters.txt | awk '{print $2}'`

######################## GRID PARAMETERS ################

#Number of frames
StartFrame=`sed '14q;d' GridParameters.txt | awk '{print $2}'`
FinishFrame=`sed '15q;d' GridParameters.txt | awk '{print $2}'`

#PointFinish = size in axe X
PointFinish=`sed '18q;d' GridParameters.txt | awk '{print $1}'`

#Point to Start
PointStart=`sed '20q;d' GridParameters.txt | awk '{print $2}'`

name=`sed '33q;d' GridParameters.txt | awk '{print $2}'`

VerificationAxeY=`sed '18q;d' GridParameters.txt | awk '{print $2}'`
VerificationAxeZ=`sed '18q;d' GridParameters.txt | awk '{print $3}'`
Verification=$((($VerificationAxeY*$VerificationAxeZ)/3))


###################### GridPaerameters.txt
echo "Cores:" $MaxCores
echo "PDB:" $FilePDB
echo "PSF:" $FilePSF
echo "DCD:" $FileDCD
echo "Output:" $Output
echo "StartFrame" $StartFrame
echo "FinishFrame" $FinishFrame
echo "PointFinish:" $PointFinish
echo "PointStart:" $PointStart
echo "Atom:" $name

########################  WORKSPACE

#Condition to keep running the script
counter="1"

######

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
		
		#Grid code: NewCode12.tcl
		cp NewCode12.tcl Files/Frame.$StartFrame/Part.$PointStart/Frame.$StartFrame.$PointStart.$name.tcl
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

#			sensors| grep 83
#			Warning1=$?

#			sensors| grep 87
#			Warning2=$?
			
#			if [ $Warning2 -eq "1" ]; then
#				if [ $Warning1 -eq "1" ]; then
#					sleep 2m
#				else 
#					sleep 5m
#				fi
#			else
#				sleep 10m
#			fi
 
			sleep 20s

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


############# FINISH A FRAME ##################	
	if [ $PointStart -eq $PointFinish ]; then

		#New Frame
		if [ $StartFrame -lt $FinishFrame ]; then

			#Join all parts of the grid
			echo "COUNTER: CICLO"
			sleep 30s

			#Verification of files to have all the files complete and generate de DX file of the frame. It will wait until everything are finished

			PointVerification=$[$PointStart-1]
			FinalLines=`wc -l CreateDX/Frame.$StartFrame/$Output.$StartFrame.P.$PointVerification.dx | awk '{print $1}'`
			echo "Actual Lines: $FinalLines"
			echo "Verification: $Verification"

			while [ $Verification -ne $FinalLines ]; do

				echo "Wait 1 min"
				sleep 30s
				FinalLines=`wc -l CreateDX/Frame.$StartFrame/$Output.$StartFrame.P.$PointVerification.dx | awk '{print $1}'`
				echo "Actual Lines: $FinalLines"

			done
			echo "File complete. Create DX file Frame: $StartFrame"
			#Finish of the verification. The files are complete

######################## Create DX ##############################
######################## Condition to join all the data 
			DXsize=`ls CreateDX/Frame.$StartFrame/ | wc -l`

			if  [ $DXsize -lt 11 ]; then

				cat CreateDX/Header.dx CreateDX/Frame.$StartFrame/$Output.$StartFrame.P.?.dx > CreateDX/$Output.$StartFrame.dx

			elif [ $DXsize -lt 101 ]; then

				cat CreateDX/Header.dx CreateDX/Frame.$StartFrame/$Output.$StartFrame.P.?.dx CreateDX/Frame.$StartFrame/$Output.$StartFrame.P.??.dx > CreateDX/$Output.$StartFrame.dx


			elif [ $DXsize -lt 1001 ]; then

				cat CreateDX/Header.dx CreateDX/Frame.$StartFrame/$Output.$StartFrame.P.?.dx CreateDX/Frame.$StartFrame/$Output.$StartFrame.P.??.dx CreateDX/Frame.$StartFrame/$Output.$StartFrame.P.???.dx > CreateDX/$Output.$StartFrame.dx

			elif [ $DXsize -lt 10001 ]; then

				cat CreateDX/Header.dx CreateDX/Frame.$StartFrame/$Output.$StartFrame.P.?.dx CreateDX/Frame.$StartFrame/$Output.$StartFrame.P.??.dx CreateDX/Frame.$StartFrame/$Output.$StartFrame.P.???.dx CreateDX/Frame.$StartFrame/$Output.$StartFrame.P.????.dx > CreateDX/$Output.$StartFrame.dx

			else

				cat CreateDX/Header.dx CreateDX/Frame.$StartFrame/$Output.$StartFrame.P.?.dx CreateDX/Frame.$StartFrame/$Output.$StartFrame.P.??.dx CreateDX/Frame.$StartFrame/$Output.$StartFrame.P.???.dx CreateDX/Frame.$StartFrame/$Output.$StartFrame.P.????.dx CreateDX/Frame.$StartFrame/$Output.$StartFrame.P.?????.dx > CreateDX/$Output.$StartFrame.dx

			fi

######################## Create DX ##############################

			
			
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

			sleep 30s

			#Verification of files to have all the files complete and generate de DX file of the frame. It will wait until everything are finished
			PointVerification=$[$PointStart-1]
			FinalLines=`wc -l CreateDX/Frame.$StartFrame/$Output.$StartFrame.P.$PointVerification.dx | awk '{print $1}'`
			echo "Actual Lines: $FinalLines"
			echo "Verification: $Verification"

			while [ $Verification -ne $FinalLines ]; do

				echo "Wait 1 min"
				sleep 30s
				FinalLines=`wc -l CreateDX/Frame.$StartFrame/$Output.$StartFrame.P.$PointVerification.dx | awk '{print $1}'`
				echo "Actual Lines: $FinalLines"

			done
			echo "File complete. Create DX file Frame: $StartFrame"
			#Finish of the verification. The files are complete


######################## Create DX ##############################
######################## Condition to join all the data 
			DXsize=`ls CreateDX/Frame.$StartFrame/ | wc -l`

			if  [ $DXsize -lt 11 ]; then

				cat CreateDX/Header.dx CreateDX/Frame.$StartFrame/$Output.$StartFrame.P.?.dx > CreateDX/$Output.$StartFrame.dx

			elif [ $DXsize -lt 101 ]; then

				cat CreateDX/Header.dx CreateDX/Frame.$StartFrame/$Output.$StartFrame.P.?.dx CreateDX/Frame.$StartFrame/$Output.$StartFrame.P.??.dx > CreateDX/$Output.$StartFrame.dx


			elif [ $DXsize -lt 1001 ]; then

				cat CreateDX/Header.dx CreateDX/Frame.$StartFrame/$Output.$StartFrame.P.?.dx CreateDX/Frame.$StartFrame/$Output.$StartFrame.P.??.dx CreateDX/Frame.$StartFrame/$Output.$StartFrame.P.???.dx > CreateDX/$Output.$StartFrame.dx

			elif [ $DXsize -lt 10001 ]; then

				cat CreateDX/Header.dx CreateDX/Frame.$StartFrame/$Output.$StartFrame.P.?.dx CreateDX/Frame.$StartFrame/$Output.$StartFrame.P.??.dx CreateDX/Frame.$StartFrame/$Output.$StartFrame.P.???.dx CreateDX/Frame.$StartFrame/$Output.$StartFrame.P.????.dx > CreateDX/$Output.$StartFrame.dx

			else

				cat CreateDX/Header.dx CreateDX/Frame.$StartFrame/$Output.$StartFrame.P.?.dx CreateDX/Frame.$StartFrame/$Output.$StartFrame.P.??.dx CreateDX/Frame.$StartFrame/$Output.$StartFrame.P.???.dx CreateDX/Frame.$StartFrame/$Output.$StartFrame.P.????.dx CreateDX/Frame.$StartFrame/$Output.$StartFrame.P.?????.dx > CreateDX/$Output.$StartFrame.dx

			fi

######################## Create DX ##############################

			mv Files/Frame.$delete/Finish.log .
		fi
	fi

	#Clean
	rm -r Files/Frame.$StartFrame/Part.$PointStart
	mkdir Files/Frame.$StartFrame/Part.$PointStart


done

cp JoinGrids.tcl CreateDX/JoinGrids.$Output.tcl
cp proc03_dx.tcl CreateDX/.

cd CreateDX/.
sed -i "s/FRAME-X/$FinishFrame/" JoinGrids.$Output.tcl
vmd -dispdev text -e JoinGrids.$Output.tcl
cd ..
