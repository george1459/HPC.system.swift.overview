#!/bin/bash
# ====================================================
#   Copyright (C)2019 All rights reserved.
#
#   Author        : 在 vimrc 文件中添加 let g:file_copyright_name = 'your name'
#   Email         : 在 vimrc 文件中添加 let g:file_copyright_email = 'your email'
#   File Name     : check_bulk.sh
#   Last Modified : 2019-08-15 17:34
#   Describe      :
#
# ====================================================


if [ $# -eq 0 ]
then
	echo -e "\033[1mArguments: --name=[input folder] --nf=[whether to display not finished] -- ns=[whether to display which doesn't contain swift data]\033[0m"
fi


while [ $# -ge 1 ]
do
	case "$1" in
		--name=*)
			name="${1#*=}"
			shift;;
		--nf=*)
			nf="${1#*=}"
			shift;;
		--ns=*)
			ns="${1#*=}"
			shift;;
		*)
			echo "Unrecognized arguments"
			exit 1
			break;;
	esac
done

if [[ $name == "" ]]
then
	echo "No name given"
	exit 1
fi

outest=$(pwd)
cd $name

fd_nb=$(ls -1 | wc -l)

total_dl_nb=0
total_finished=0
t_uvot=0
#size=0
is_detect=0
errored=0

echo ""
echo "Running on folder $name:"

for d in $(ls -1)
do
	cd $d
	dl_nb=0
	if [ $(ls -1 | wc -l) -ne 1 ]
	then
		dl_nb=$(ls -1 download*log | wc -l )
	fi
	finished=0

	if [ $dl_nb -ne 0 ]
	then
		is_detect=$(($is_detect + 1))
		for de in download*log
		do
			keyline=$(tail -3 $de)
			keyword=$(echo $keyline | grep -oh "FINISHED")
			if [[ $keyword == "FINISHED" ]]
			then
				finished=$(($finished + 1))
				#size_kw=$(echo $keyline | tail -1 | cut -d ',' -f 2 | cut -d 'M' -f 1 | awk '$1=$1')
				#size=$(echo "$size_kw + $size" | bc)
			else
				# check for "ERROR message"
				new_keyword=$(echo $keyline | grep -oh "ERROR")
				if [[ $new_keyword == "ERROR" ]]
				then
					errored=$(($errored + 1))
					if [[ $nf == "yes" ]]
					then
						echo -e "\033[1mGenerated Errors: $de\033[0m"
					fi
				else 
					if [[ $nf == "yes" ]]
					then
						echo -e "Haven't finished: $de"
					fi
				fi
			fi
		done
	else
		if [[ $ns == "yes" ]]
		then
			echo "$d does not have swift data"
		fi
	fi

	total_dl_nb=$(($total_dl_nb + $dl_nb))
	total_finished=$(($total_finished + $finished))

	cd - &> /dev/null
done


echo "Overview of folder $name:"
echo -e "\033[1mTotal folder detected: $fd_nb"
echo -e "Of which $is_detect has Swift data"
echo -e "Out of $total_dl_nb downloads, $total_finished have finished, $errored generated errors, $(($total_dl_nb - $total_finished - $errored)) still being downloaded"
cd $outest
size=$(du -bsh "$name" | cut -d$'\t' -f 1)

echo -e "Total size downloaded: $size \033[0m"
echo ""
echo "**********************************************************************************************"



