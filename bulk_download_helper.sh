#!/bin/bash
# ====================================================
#   Copyright (C)2019 All rights reserved.
#
#   Author        : Shicheng Liu
#   Email         : shicheng2000@uchicago.edu
#   File Name     : download.sh
#   Last Modified : 2019-08-14 14:32
#   Describe      : Automated pipeline for downloading Swift data from NASA's archive website
#
# ====================================================

# Default values:
table="swiftmastr"
radius="30"
resultmax="10000"

while [ $# -ge 1 ]
do
	case "$1" in
		--name=*)
			name="${1#*=}"
			shift;;
		--position=*)
			position="${1#*=}"
			shift;;
		--table=*)
			table="${1#*=}"
			shift;;
		--time=)
			time="${1#*=}"
			shift;;
		--coordinates=*)
			coordinates="${1#*=}"
			shift;;
		--equinox=*)
			equinox="${1#*=}"
			shift;;
		--radius=*)
			radius="${1#*=}"
			shift;;
		--fields=*)
			fields="${1#*=}"
			shift;;
		--name_resolver=*)
			name_resolver="${1#*=}"
			shift;;
		--infile=*)
			infile="${1#*=}"
			shift;;
		--outfile=*)
			outfile="${1#*=}"
			shift;;
		--format=*)
			format="${1#*=}"
			shift;;
		--sortvar=*)
			sortvar="${1#*=}"
			shift;;
		--resultmax=*)
			resultmax="${1#*=}"
			shift;;
		--param=*)
			param="${1#*=}"
			shift;;
		--time=*)
			timerg="${1#*=}"
			shift;;
		*)
			echo "Unrecognized arguments"
			exit 1
			break;;
	esac
done

if [[ $position == "" ]]
then
	echo "No position given"
	exit 1
fi

if [[ $name == "" ]]
then
	echo "No name given"
	exit 1
fi

#rm -rf $name
mkdir -p $name 
outest=$(pwd)
rm -f $name/$(date '+%d_%m_%Y')_queryres.txt

# Use NASA-provided PERL script to query the swift master catalog table
perl utils/new_browse_extract.pl table=$table position="$position" resultmax=$resultmax radius=$radius outfile="$name/$(date '+%d_%m_%Y')_queryres.txt" time="$timerg"

cd $name
rownb=$(cat $(date '+%d_%m_%Y')_queryres.txt | tail -1 | cut -d s -f 5 | cut -d r -f 1 | awk '$1=$1')

if [[ $rownb == $resultmax ]]
then
	echo -e "\033[41;37mWarning: Queried rows equal to Max Query Row, consider raising resultmax to prevent missing files\033[0m"
fi

for i in $(seq 3 1 $(($rownb + 2)))
do
	line=$(cat $(date '+%d_%m_%Y')_queryres.txt | head -$i | tail -1)
	obsid=$(echo $line | cut -d '|' -f 3 | awk '$1=$1')
	starttime1=$(echo $line | cut -d '|' -f 6 | cut -d T -f 1 | cut -d '-' -f 1)
	starttime2=$(echo $line | cut -d '|' -f 6 | cut -d T -f 1 | cut -d '-' -f 2)
	
	# Added for batch processing
	until [ $(ps -ef | grep "wget" | wc -l) -le 300 ]
	do
		echo "Stalling, current wget commands in process: $(ps -ef | grep "wget" | wc -l)"
		sleep 10
	done
	
	if [ ! -e $obsid ]
	then
		nohup wget -nH --no-check-certificate --cut-dirs=5 -r -l0 -c -N -np -R 'index*' -erobots=off --retr-symlinks https://heasarc.gsfc.nasa.gov/FTP/swift/data/obs/${starttime1}_${starttime2}//$obsid/xrt/ > download_xrt_$obsid.log 2>&1 &
		nohup wget -nH --no-check-certificate --cut-dirs=5 -r -l0 -c -N -np -R 'index*' -erobots=off --retr-symlinks https://heasarc.gsfc.nasa.gov/FTP/swift/data/obs/${starttime1}_${starttime2}//$obsid/auxil/ > download_auxil_$obsid.log 2>&1 &
		#nohup wget -nH --no-check-certificate --cut-dirs=5 -r -l0 -c -N -np -R 'index*' -erobots=off --retr-symlinks https://heasarc.gsfc.nasa.gov/FTP/swift/data/obs/${starttime1}_${starttime2}//$obsid/bat/ > download_bat_$obsid.log 2>&1 &
		nohup wget -nH --no-check-certificate --cut-dirs=5 -r -l0 -c -N -np -R 'index*' -erobots=off --retr-symlinks https://heasarc.gsfc.nasa.gov/FTP/swift/data/obs/${starttime1}_${starttime2}//$obsid/log/ > download_log_$obsid.log 2>&1 &
	else 
		echo "$name/$obsid folder already exists, skipping"
	fi
done

if [[ "$rownb" == " " ]]
then
	echo -e "Started initiating \033[1;4m0\033[0m wget commands"
else
	echo -e "Started initiating \033[1;4m$(($rownb * 4))\033[0m wget commands"
fi
