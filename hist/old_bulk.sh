#!/bin/bash
# ====================================================
#   Copyright (C)2019 All rights reserved.
#
#   Author        : Shicheng Liu
#   Email         : shicheng2000@uchicago.edu
#   File Name     : bulk.sh
#   Last Modified : 2019-08-14 17:33
#   Describe      :
#
# ====================================================

if [[ $1 == "--help" ]]
then
	echo -e "\033[1mArguments: --name=[input file] --startnb=[number] --endnb=[number] --time=[time range]\033[0m"
	echo "Note all tables have observation dates. For those that do, the time portion of the date is optional. Separate multiple dates/ranges with semicolons (;)."
	echo "Range operator is '..'. (e.g. 1992-12-31; 48980.5; 1995-01-15 12:00:00; 1997-03-20 .. 2000-10-18)"
fi


input="iden_4FGL.txt"
sb=0
eb=0

while [ $# -ge 1 ]
do
	case "$1" in
		--name=*)
			input="${1#*=}"
			shift;;
		--startnb=*)
			sb="${1#*=}"
			shift;;
		--endnb=*)
			eb="${1#*=}"
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

if [[ $input == "" ]]
then
	echo "No name given"
	exit 1
fi


linenb=$(wc -l $input | cut -d ' ' -f 1)

echo "$linenb lines detected, running on line $sb to $eb"

for i in $(seq $sb 1 $eb)
do
	directory=$(head -$i $input | tail -1 | cut -d ' ' -f 4)
	if [ ! -e $directory ]
	then
		mkdir $directory
	fi
	name1=$(head -$i $input | tail -1 | cut -d ' ' -f 2)
	name2=$(head -$i $input | tail -1 | cut -d ' ' -f 3)	
	ra=$(head -$i $input | tail -1 | cut -d ' ' -f 5)
	dec=$(head -$i $input | tail -1 |cut -d ' ' -f 6)
	./old_download.sh --name="$directory/${name1}_$name2" --position="$ra, $dec" --time="$timerg"
	echo "Doing this for $i"
done
