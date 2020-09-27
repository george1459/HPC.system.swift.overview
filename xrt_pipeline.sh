#!/bin/bash
# ====================================================
#   Copyright (c) 2020 All rights reserved
#
#   Author        : Shicheng Liu
#   Email         : shicheng2000@uchicago.edu
#   File Name     : xrt_pipeline.sh
#   Last Modified : Sun Sep 27 2020 09:42:56 (UTC +8)
#
# ====================================================



outest=$(pwd)
SCRIPT=$(readlink -f "$0")
SCRIPTPATH=$(dirname "$SCRIPT")

if [[ $1 == "--help" ]]
then
	echo -e "\033[1mDefault settings:\033[0m"
	echo -e "\033[1m--spec=no --graph=no --xrtppl=no --onlyxrtppl=no --useunpiped=no --bckcorr=no --snrcutoff 3 --lccutoff 3 30 100 100 200 200 1000\033[0m"
	echo ""
	echo "  --spec       controls whether or not to generate spectrum/lightcurve for each individual source."
	echo "  --graph      controls whether or not to employ the energy.py python script to graph spectrum & lightcurve for each source. The global ones are plotted regardless of this command."
	echo "  --xrtppl     controls whether or not to run xrtpipeline before copying event files."
	echo "  --onlyxrtppl controls whether or not to exit after running xrtpipeline."
	echo "  --useunpiped controls whether or not to use the unpiped folders (i.e. the 9-digit folders) instead of the piped folders."
	echo "  --snrcutoff  controls the snr ratio cutoff for ximage (in pc mode)."
	echo "  --lccutoff   controls the lightcurve pha_cutoff thresholds when extracting lightcurves."
	exit 0
fi

if [ ! -e $1 ]
then
	echo "Error: No such directory"
	exit 1
fi

echo "Making directory processed_$1 and removing directory with the same name..."

rm -rf processed_$1
mkdir processed_$1
chmod 775 processed_$1
cd processed_$1
mkdir pc_data

# Pass in default parameters, generate spectrum (for each source)
spec=0
graph=0
xrtppl=0
onlyxrtppl=0
useunpiped=0
bckcorr=0
snrcutoff=3

lccutofflen=3
lccutoff=(30 100 100 200 200 1000)

FGL_cpt_hms_file="/home/georgejar/Parkinson/FGL/4FGL_cpt_hms_new_new.txt"
FGL_cpt_deg_file="/home/georgejar/Parkinson/FGL/4FGL_cpt_deg_new_new.txt"

filepath=$1
shift

while [ $# -ge 1 ]
do
	case "$1" in
		--spec=yes)
			spec=1
			shift;;
		--spec=no)
			spec=0
			shift;;
		--graph=yes)
			graph=1
			shift;;
		--graph=no)
			graph=0
			shift;;
		--xrtppl=yes)
			xrtppl=1
			shift;;
		--xrtppl=no)
			xrtppl=0
			shift;;
		--onlyxrtppl=yes)
			onlyxrtppl=1
			shift;;
		--onlyxrtppl=no)
			onlyxrtppl=0
			shift;;
		--useunpiped=yes)
			useunpiped=1
			shift;;
		--useunpiped=no)
			useunpiped=0
			shift;;
		--bckcorr=yes)
			bckcorr=1
			shift;;
		--bckcorr=no)
			bckcorr=0
			shift;;
		--snrcutoff)
			snrcutoff=$2
			shift 2;;
		--lccutoff)
			lccutofflen=$2
			shift 2
			for i in $(seq 1 1 $lccutofflen)
			do
				lccutoff[$(($i * 2 - 2))]=$1
				shift
				lccutoff[$(($i * 2 - 1))]=$1
				shift
			done;;
		*)
			echo "Unrecognized arguments"
			exit 1
			break;;
	esac
done

cd $outest

# Querying the 4FGL-listed counterpart file for location information
# IMPORTANT: The counterpart file needs to be generated at this point
if grep -q "${filepath:5}" ${FGL_cpt_hms_file}
then
	catalogra=$(grep "${filepath:5}" "${FGL_cpt_hms_file}" | cut -d '|' -f 2 | tr -s ' ' | cut -d ' ' -f 1,2,3)
	catalogdec=$(grep "${filepath:5}" "${FGL_cpt_hms_file}" | cut -d '|' -f 2 | tr -s ' ' | cut -d ' ' -f 4,5,6)
	cpt_identifier=1
elif grep -q "${filepath:5}" ${4FGL_cpt_deg_file}
then
	catalogra=$(grep "${filepath:5}" "${FGL_cpt_deg_file}" | cut -d '|' -f 2 | tr -s ' ' | cut -d ' ' -f 1)
	catalogdec=$(grep "${filepath:5}" "${FGL_cpt_deg_file}" | cut -d '|' -f 2 | tr -s ' ' | cut -d ' ' -f 2)
	cpt_identifier=2
else
	cpt_identifier=3
fi

# If cannot find counterpart location, there is nothing to do, quit
if [ $cpt_identifier -eq 3 ]
then
	echo "Cannot find counterpart information, quitting ..."
	exit 1
fi

echo -e "Resolved counterpart location to RA:\033[1;4m$catalogra\033[0m ;DEC:\033[1;4m$catalogdec\033[0m and will be drawing error circle of 10'' around it"

cd "$filepath"

echo "Running on folder $filepath:"
if [ $xrtppl -eq 1 ]
then
	if [ $cpt_identifier -eq 3 ]
	then
		echo "No counterpart location found, using POINT as input"
	else
		echo "Using counterpart location in input to source location. Running xrtpipeline..."
	fi
	
	filenumber=$(ls -1 -d [0-9][0-9]*/ | wc -l)
	i=0
	for d in $(ls -d [0-9][0-9]*/ | cut -d '/' -f 1)
	do
		# Skipping those that were already processed
		if cat ${filepath}_${i}_xrtpipeline.log | tail -20 | grep -q "Exit with no errors"
		then
			i=$(($i+1))
			echo -e "\033[1mXrtpipeline on $i out of $filenumber oberservation folders was finished, skipping\033[0m"
		else
			rm -rf 3_$d
			rm -f ${filepath}_${i}_xrtpipeline.log
			if [ $cpt_identifier -eq 3 ]
			then
				xrtpipeline indir=$d outdir=3_$d steminputs=sw$d srcra="POINT" srcdec="POINT" > ${filepath}_${i}_xrtpipeline.log
			else
				xrtpipeline indir=$d outdir=3_$d steminputs=sw$d srcra="$catalogra" srcdec="$catalogdec" > ${filepath}_${i}_xrtpipeline.log
			fi
			i=$(($i+1))
			echo -e "\033[1mFinished running xrtpipeline on $i out of $filenumber oberservation folders\033[0m"
		fi
	done
fi

if [ $onlyxrtppl -eq 1 ]
then
	exit 0;
fi

# first deal with the pc_po_cl files
if [ $useunpiped -eq 0 ]
then
	for d in 3_[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]
	do
		(
		cd "$d"
		cp *pc*po_cl.evt $outest/processed_$filepath/pc_data) 2>/dev/null
	done
else
	for d in [0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]
	do
		(
		cd "$d"/xrt/event
		cp *pc*po_cl* $outest/processed_$filepath/pc_data) 2>/dev/null
	done
fi


cd $outest/processed_$filepath/pc_data
filenumber=$(ls -l|grep "^-"| wc -l)
if [ $filenumber -ne 0 ]
then
	echo -e "\033[1mDetected pc files, running on pc files\033[0m"
	gunzip * 2>/dev/null
	
	filename=""
	for entry in *
	do
		filename+=",$entry"
	done
	filename=${filename#?}  # Discard the first comma

	strlen=$(echo -n $filename | wc -m)
	arrlen=$((strlen/252 + 1))

	# 28 * 9 = 252
	# The entire filename string is chopped off to 9 parts, each contains an entry and a comma
	# This is needed for the xselect pipeline, which only takes in a maximum of 1000 chars at a time
	for i in $(seq 1 1 $arrlen)
	do
		entry[i]=${filename:$((i - 1))*252:252}
		if [ $i -ne $arrlen ]
		then
			entry[i]=${entry[i]::-1}
		fi
		# echo "${entry[i]}"
	done

	echo "xselect <<EOF" >> xselect.sh
	echo "${filepath}_pc_po_cl" >> xselect.sh
	echo "read event" >> xselect.sh
	echo "./" >> xselect.sh
	echo "${entry[1]}" >> xselect.sh
	echo "yes" >> xselect.sh

	for i in $(seq 2 1 $arrlen)
	do
		echo "read event" >> xselect.sh
		echo "${entry[i]}" >> xselect.sh
		echo "" >> xselect.sh
	done

	echo "extract image" >> xselect.sh
	echo "save image im.im" >> xselect.sh
	echo "quit" >> xselect.sh
	echo "EOF" >> xselect.sh

	echo "Excuting xselect.sh ..."
	chmod 775 xselect.sh
	source xselect.sh >> sh_xselect.log

	echo "ximage <<EOF" >> ximage.sh
	echo "read im.im" >> ximage.sh
	echo "cpd ./pgplot.gif/gif" >> ximage.sh
	echo "display" >> ximage.sh
	echo "ra_dec_to_pixel/circle=10" >> ximage.sh
	echo "$catalogra" >> ximage.sh
	echo "$catalogdec" >> ximage.sh
	echo "cpd /xs" >> ximage.sh
	echo "cpd ./1_pgplot.gif/gif" >> ximage.sh
	echo "display" >> ximage.sh
	echo "detect/bright/snr=$snrcutoff" >> ximage.sh
	echo "ra_dec_to_pixel/circle=10" >> ximage.sh
	echo "$catalogra" >> ximage.sh
	echo "$catalogdec" >> ximage.sh
	echo "grid" >> ximage.sh
	echo "sosta/detect_sources" >> ximage.sh
	echo "cpd /xs" >> ximage.sh
	echo "quit" >> ximage.sh
	echo "EOF" >> ximage.sh

	echo "Excuting ximage.sh"
	chmod 775 ximage.sh
	source ximage.sh >> sh_ximage.log

	# Finally, read the im.det file and display relevant information
	mkdir output
	
	if [ -e im.det ]
	then
		detexist=1
		mv im.det $outest/processed_$filepath/pc_data/output
	else
		detexist=0
		echo -e "\033[41;37mNote: No detection was made at SNR ratio: $snrcutoff\033[0m"
		echo -e "\033[41;37mSource 1 will be the same as global background\033[0m"
	fi
	
	mv sh_xselect.log $outest/processed_$filepath/pc_data/output
	mv sh_ximage.log $outest/processed_$filepath/pc_data/output
	mv pgplot.gif output/${filepath}_pc_detection_clean.gif
	mv 1_pgplot.gif output/${filepath}_pc_detection.gif
	mv xselect.log output
	cd output
	echo "Counterpart position: $catalogra $catalogdec" >> ${filepath}_pc_output.txt

	startline=$(grep -n 'HK Directory' xselect.log |cut -d : -f 1 | tail -1)
	endline=$(($(grep -n 'extract image' xselect.log |cut -d : -f 1 | tail -1) - 1))

	cat xselect.log | head -$endline | tail -$(($endline - $startline)) >> ${filepath}_pc_output.txt
	if [ $detexist -eq 1 ]
	then
		cat im.det >> ${filepath}_pc_output.txt
		echo "Sosta output for the source identified above:" >> ${filepath}_pc_output.txt
		grep -n 'Signal to Noise Ratio' sh_ximage.log  >> ${filepath}_pc_output.txt
	fi

	cd $outest

	# Now get the identified coordinates
	cd processed_$filepath/pc_data/output
	startline=$(grep -n 'snr' ${filepath}_pc_output.txt |cut -d : -f 1 | tail -1)
	endline=$(grep -n 'Sosta output for the source identified above:' ${filepath}_pc_output.txt |cut -d : -f 1 | tail -1)

	echo "Now saving identified source location info source_location folder..."
	mkdir source_location
	cp ${filepath}_pc_output.txt source_location
	cd source_location
	for i in $(seq 1 1 $(($endline - $startline - 1)))
	do
		line=$(sed -n $((${startline} + $i))p ${filepath}_pc_output.txt)
		if (( i < 10 ))
		then
			x_coor1="$(cut -d' ' -f10 <<<"$line")"
			x_coor2="$(cut -d' ' -f11 <<<"$line")"
			x_coor3="$(cut -d' ' -f12 <<<"$line")"
			y_coor1="$(cut -d' ' -f13 <<<"$line")"
			y_coor2="$(cut -d' ' -f14 <<<"$line")"
			y_coor3="$(cut -d' ' -f15 <<<"$line")"
		# If within tens lines, do the command above. Otherwise, slightly change the field name since the number of spaces will vary with line number
		else
			x_coor1="$(cut -d' ' -f9 <<<"$line")"
			x_coor2="$(cut -d' ' -f10 <<<"$line")"
			x_coor3="$(cut -d' ' -f11 <<<"$line")"
			y_coor1="$(cut -d' ' -f12 <<<"$line")"
			y_coor2="$(cut -d' ' -f13 <<<"$line")"
			y_coor3="$(cut -d' ' -f14 <<<"$line")"
		fi

		# Use xrtcentroid to determine source error radius
		# NOTE: "boxradius" is set to 1 arcmin
		xrtcentroid boxra="${x_coor1} ${x_coor2} ${x_coor3}" boxdec="${y_coor1} ${y_coor2} ${y_coor3}" boxradius="1" calcpos="yes" infile="$outest/processed_$filepath/pc_data/im.im" interactive="no" outdir="./" outfile="centroid_$i.txt"
		cent_x="$(cat "centroid_$i.txt" | grep "RA(degrees)" | cut -d '=' -f 2 | awk '$1=$1')"
		cent_y="$(cat "centroid_$i.txt" | grep "Dec(degrees)" | cut -d '=' -f 2 | awk '$1=$1')"
		cent_err="$(cat "centroid_$i.txt" | grep "Error radius (arcsec)" | cut -d '=' -f 2 | awk '$1=$1')"
		
		ret="$(python $SCRIPTPATH/utils/distance.py ${cent_x} ${cent_y} "${catalogra}" "${catalogdec}" ${cent_err})"
		bool=$(echo $ret | cut -d ' ' -f 1)
		val=$(echo $ret | cut -d ' ' -f 2)
		# radius_check.txt stores the information of if detected source falls into the error circle
		if [[ $bool == "False" ]]
		then
			echo -e "Detected source at location \033[1;4m${cent_x}\033[0m ;DEC:\033[1;4m${cent_y}\033[0m NOT within \033[1;4m${cent_err}\033[0m arcsec of the counterpart location"
			echo -e "Actual difference in locations \033[1;4m${val}\033[0m arcsec"
			echo "Neglecting ..."
		else
			echo "${i} ${cent_x} ${cent_y} ${catalogra} ${catalogdec} ${cent_err}" >> radius_check.txt
			echo -e "Detected source at location \033[1;4m${cent_x}\033[0m ;DEC:\033[1;4m${cent_y}\033[0m within \033[1;4m${cent_err}\033[0m arcsec of the counterpart location"
		fi

		echo "Writing loc_$i.reg..."
		echo "# Region file format: DS9 version 4.1" >> loc_$i.reg
		echo "global color=green dashlist=8 3 width=1 font=\"helvetica 10 normal roman\" select=1 highlite=1 dash=0 fixed=0 edit=1 move=1 delete=1 include=1 source=1" >> loc_$i.reg
		echo "fk5" >> loc_$i.reg
		echo "circle($cent_x,$cent_y,$cent_err\")" >> loc_$i.reg
	done


	if [ ! -e radius_check.txt ]
	then
		echo -e "\033[1mNo source detected within error circle, exiting ...\033[0m"
		cd $outest/processed_$filepath/pc_data/output
		mkdir global_view
		mkdir log_file
		# Do some cleaning
		cd $outest/processed_$filepath/pc_data/
		mkdir original_file
		mv *pc* original_file
		rm -f ximage.sh
		rm -f xselect.sh
		mv im.im output/global_view/global_im.im
		cd output
		rm -f im.det
		mv sh_ximage.log log_file
		mv sh_xselect.log log_file
		mv xselect.log log_file
		exit 0
	else
		source_number=$(cat radius_check.txt | wc -l | awk '$1=$1')
		if [ ${source_number} -eq 1 ]
		then
			echo -e "\033[1mOne source detected within error circle\033[0m"
		else
			echo -e "\033[1mNOTICE: More than one source detected within error circle\033[0m"
		fi
	fi

	if [ $spec -eq 1 ]
	then
		echo "Extracting spectrum & lightcurve for source identified within error circle..."
		echo "xselect << EOF" >> loop.sh
		echo "$filepath_each_spec" >> loop.sh
		echo "read event" >> loop.sh
		echo "$outest/processed_$filepath/pc_data/" >> loop.sh
		echo "${entry[1]}" >> loop.sh
		echo "yes" >> loop.sh

		for i in $(seq 2 1 $arrlen)
		do
			echo "read event" >> loop.sh
			echo "${entry[i]}" >> loop.sh
			echo "" >> loop.sh
		done

		for i in $(seq 1 1 ${source_number})
		do
			k=$(cat radius_check.txt | head -$i | tail -1 | cut -d ' ' -f 1)
			echo "filter region loc_$k.reg" >> loop.sh
			echo "extract image" >> loop.sh
			echo "save image im_$k.im" >> loop.sh
			echo "extract spec" >> loop.sh
			echo "save spec spec_$k.im" >> loop.sh
			echo "extract curve" >> loop.sh
			echo "save curve lc_$k.im" >> loop.sh
			for j in $(seq 1 1 $lccutofflen)
			do
				echo "filter pha_cutoff ${lccutoff[$(($j * 2 - 2))]} ${lccutoff[$(($j * 2 - 1))]}" >> loop.sh
				echo "extract curve" >> loop.sh
				echo "save curve lc_${k}_cutoff_$j.im" >> loop.sh
				echo "clear pha_cutoff" >> loop.sh
			done
			echo "clear region" >> loop.sh
		done
		echo "quit" >> loop.sh
		echo "EOF" >> loop.sh
		chmod 775 loop.sh
		source loop.sh >> sh_loop.log
		mv sh_loop.log $outest/processed_$filepath/pc_data/output

		echo "Making each_source directory and copying all relevant files, drawing spectrum graphs..."
		cd $outest/processed_$filepath/pc_data/output
		mkdir each_source
		
		for i in $(seq 1 1 ${source_number})
		do
			(cd each_source
			mkdir $k)
			cd source_location
			echo "Doing this for source $k..."
			k=$(cat radius_check.txt | head -$i | tail -1 | cut -d ' ' -f 1)
			mv spec_$k.im $outest/processed_$filepath/pc_data/output/each_source/$k
			mv im_$k.im $outest/processed_$filepath/pc_data/output/each_source/$k
			mv lc_$k.im $outest/processed_$filepath/pc_data/output/each_source/$k

			for j in $(seq 1 1 $lccutofflen)
			do
				mv lc_${k}_cutoff_$j.im $outest/processed_$filepath/pc_data/output/each_source/$k
			done

			cd $outest/processed_$filepath/pc_data/output/each_source/$k
			ftconvert spec_$k.im spec_$k.txt "-" "-"
			ftconvert lc_$k.im lc_$k.txt "-" "-"

			for j in $(seq 1 1 $lccutofflen)
			do
				ftconvert lc_${k}_cutoff_$j.im lc_${k}_cutoff_$j.txt "-" "-"
			done

			if [ $graph -eq 1 ]
			then
				(
				cd $outest
				python energy.py $outest/processed_$filepath/pc_data/output/each_source/$k/spec_$k.txt $outest/processed_$filepath/pc_data/output/each_source/$k/ 'spec' 2>/dev/null
				python energy.py $outest/processed_$filepath/pc_data/output/each_source/$k/lc_$k.txt $outest/processed_$filepath/pc_data/output/each_source/$k/ 'lc' 2>/dev/null
				)
				mv spec.png spec_$k.png
				mv lc.png lc_$k.png

				(
				cd $outest
				for j in $(seq 1 1 $lccutofflen)
				do
					python energy.py $outest/processed_$filepath/pc_data/output/each_source/$k/lc_${k}_cutoff_$j.txt $outest/processed_$filepath/pc_data/output/each_source/$k/$j 'lc' 2>/dev/null
				done
				)

				for j in $(seq 1 1 $lccutofflen)
				do
					mv ${j}lc.png lc_${k}_cutoff_$j.png
				done
			fi

			cd $outest/processed_$filepath/pc_data/output
		done

		cd $outest/processed_$filepath/pc_data/output

		# No longer extracing specturm for the whole image. If wanted, uncomment the lines below
		# Note that the spectrum for the whole image is not extracted at this point, one needs to modify the code before to do that job

		# globalspec=$(grep "Spectrum         has" xselect.log | cut -d r -f 3 | cut -d c -f 1 | awk '$1=$1' | awk '{print $0*1}' )
		# call=$(expr $globalspec \> 0.5)
		# if [ $call -eq 1 ]
		# then
		# 	echo -e "\033[41;37mNOTE: Global spectrum over threhold 0.5 counts/s. Consider pile-up suppression:\033[0m"
		# 	echo -e "\033[41;37m$globalspec\033[0m"
		# else
		# 	echo "Global spectrum within 0.5 counts/s:"
		# 	echo "$globalspec"
		# fi

		for i in $(seq 1 1 ${source_number})
		do
			(cd $outest/processed_$filepath/pc_data/output/source_location)
			sourcespec=$(grep "Spectrum         has" sh_loop.log | head -$i | tail -1 | cut -d r -f 3 | cut -d c -f 1 | awk '$1=$1' | awk '{print $0*1}')
			call=$(expr $sourcespec \> 0.5)
			if [ $call -eq 1 ]
			then
				echo -e "\033[41;37mNOTE: No. $k source spectrum over threhold 0.5 counts/s. Consider pile-up suppression:\033[0m"
				echo -e "\033[41;37m$sourcespec\033[0m"
			else
				echo "Source $k spectrum within 0.5 counts/s:"
				echo "$sourcespec"
			fi
		done
		echo "Done:)"
	fi 

	echo "Cleaning-up"
	cd $outest/processed_$filepath/pc_data
	rm -f ximage.sh
	rm -f xselect.sh
	(cd output
	mkdir global_view)
	mv im.im output/global_view/global_im.im

	cd output
	rm -f im.det
	mkdir log_file
	mv sh_ximage.log log_file
	mv sh_xselect.log log_file
	mv sh_loop.log log_file
	mv xselect.log log_file
	cd $outest/processed_$filepath/pc_data
	mkdir original_file
	mv *pc* original_file

	# Background subtraction
	if [ $bckcorr -eq 1 ]
	then
		mkdir exposure_map
		cd $outest/$filepath
		for d in 1_[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]
		do
			(
			cd $d
			cp *po*ex.img $outest/processed_$filepath/pc_data/exposure_map
			)
		done
		cd $outest/processed_$filepath/pc_data/exposure_map
		echo "ximage <<EOF" >> expo_ximage.sh
	fi

	echo -e "\033[1mFinished with pc files\033[0m"
	echo "*******************************************************"
	echo "*******************************************************"
else
	echo -e "\033[1mNo cleaned pc & po data found, skipping\033[0m"
fi