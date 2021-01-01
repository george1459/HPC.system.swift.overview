#!/bin/bash
# ====================================================
#   Copyright (C)2019 All rights reserved.
#
#   Author        : 在 vimrc 文件中添加 let g:file_copyright_name = 'your name'
#   Email         : 在 vimrc 文件中添加 let g:file_copyright_email = 'your email'
#   File Name     : check_download.sh
#   Last Modified : 2019-08-20 12:57
#   Describe      :
#
# ==========================================

for i in $(seq 1 1 26)
do
	check=$(cat check_download.txt | head -$i | tail -1)
	output=$(find $(pwd) -name $check)
	echo "**************"
	echo "$i:"
	echo "HERE:$output:"
	echo ""
	tail $output
	echo ""
done
