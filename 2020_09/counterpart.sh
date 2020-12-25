#!/bin/bash
# ====================================================
#   Copyright (C)2020 All rights reserved.
#
#   Author        : Shicheng Liu
#   Email         : shicheng2000@uchicago.edu
#   File Name     : counterpart.sh
#   Last Modified : 2020-09-21 22:32
#   Describe      :
#
# ====================================================


# Run this file after simbad.txt is ready from querying the SIMBAD database

cat simbad.txt | tail -n +2903 | sed -e "s/Identifier not found in the database : //" | grep "CRATES" | sed -e "s/'//g" | sed -e "s/: this identifier has an incorrect format for catalog://" | sed -e "s/\tCRATES : Combined Radio All-Sky Targeted Eight GHz Survey//" | tr -s ' ' | sed '/^$/d' | cut -d ' ' -f 2 > not_searched_crates.txt
cat simbad.txt | tail -n +2903 | sed -e "s/Identifier not found in the database : //" | sed -e "s/': No known catalog could be found//" | grep "NVSS" > NVSS_to_search.txt
cat simbad.txt | tail -n +2903 | grep "Identifier not found in the database"  | sed "/NVSS/d" | grep "PSR" | cut -d 'R' -f 2 | sed "s/ //" > PSR_to_search.txt
cat simbad.txt | tail -n +2903 | grep "Identifier not found in the database"  | sed "/NVSS/d" | sed "/PSR/d" | sed "/CRATES/d" | grep "2MASS" | cut -d ':' -f 2 > 2MASS_to_search.txt
cat simbad.txt | tail -n +2903 | sed "/NVSS/d" | sed "/PSR/d" | sed "/CRATES/d" | sed "/2MASS/d" | grep "GB6" | cut -d ':' -f 2 > GB6_to_search.txt
cat simbad.txt | tail -n +2903 | sed "/NVSS/d" | sed "/PSR/d" | sed "/CRATES/d" | sed "/2MASS/d" | sed "/GB6/d"  | grep "PMN" | cut -d ':' -f 2 > PMN_to_search.txt
cat simbad.txt | tail -n +2903 | sed "/NVSS/d" | sed "/PSR/d" | sed "/CRATES/d" | sed "/2MASS/d" | sed "/GB6/d"  | sed "/PMN/d" | sed "/SDSS/d" | grep "MG1" | cut -d ':' -f 1 | sed -e "s/'//g" >> MG_to_search.txt
cat simbad.txt | tail -n +2903 | sed "/NVSS/d" | sed "/PSR/d" | sed "/CRATES/d" | sed "/2MASS/d" | sed "/GB6/d"  | sed "/PMN/d" | sed "/SDSS/d" | grep "MG2" | cut -d ':' -f 1 | sed -e "s/'//g" >> MG_to_search.txt
cat simbad.txt | tail -n +2903 | sed "/NVSS/d" | sed "/PSR/d" | sed "/CRATES/d" | sed "/2MASS/d" | sed "/GB6/d"  | sed "/PMN/d" | sed "/SDSS/d" | grep "MG3" | cut -d ':' -f 1 | sed -e "s/'//g" >> MG_to_search.txt
cat simbad.txt | tail -n +2903 | sed "/NVSS/d" | sed "/PSR/d" | sed "/CRATES/d" | sed "/2MASS/d" | sed "/GB6/d"  | sed "/PMN/d" | sed "/SDSS/d" | grep "MG4" | cut -d ':' -f 1 | sed -e "s/'//g" >> MG_to_search.txt

# crates_catalog.txt needs to be present
for i in $(seq 1 1 49) 
do
    if ! grep -q "$(head -$i not_searched_crates.txt | tail -1)" crates_catalog.txt
    then
        echo "$(head -$i not_searched_crates.txt | tail -1)"
    fi
done

for i in $(seq 1 1 212)
do
    perl new_browse_extract.pl table="NVSS" position="$(head -$i NVSS_to_search.txt | tail -1)" resultmax=1500 radius=1 >> nvss_individual_search.txt
    echo "for $i" >> nvss_individual_search.txt
    echo "for $i" 
done

# psrcat executable needs to be present
for i in $(seq 1 1 25)
do
    ./psrcat -db_file psrcat.db -c "name RaJD DecJD" $(head -$i PSR_to_search.txt | tail -1) >> PSR_individual_search.txt
    echo "for $i" 
done

for i in $(seq 1 1 135)
do
    perl new_browse_extract.pl table="B/2mass" position="$(head -$i 2MASS_to_search.txt | tail -1)" resultmax=1500 radius=0.1 >> 2mass_individual_search.txt
    echo "for $i" >> 2mass_individual_search.txt
    echo "for $i" 
done

for i in $(seq 1 1 90)
do
    perl new_browse_extract.pl table="GB6" position="$(head -$i GB6_to_search.txt | tail -1)" resultmax=1500 radius=1 >> GB6_individual_search.txt
    echo "for $i" >> GB6_individual_search.txt
    echo "for $i" 
done

for i in $(seq 1 1 54)
do
    perl new_browse_extract.pl table="pmn" position="$(head -$i PMN_to_search.txt | tail -1)" resultmax=1500 radius=1 >> PMN_individual_search.txt
    echo "for $i" >> PMN_individual_search.txt
    echo "for $i" 
done

for i in $(seq 1 1 125)
do
    perl new_browse_extract.pl table="mitgb6cm" position="$(head -$i MG_to_search.txt | tail -1)" resultmax=1500 radius=1 >> MG_individual_search.txt
    echo "for $i" >> MG_individual_search.txt
    echo "for $i" 
done

# Prepare the final counterpart information

cat simbad.txt | head -2903 | tail -n +8 | cut -d '|' -f2,4 | tr -s ' ' > 4FGL_cpt_hms.txt
cat PSR_individual_search.txt | sed "/WARNING/d" > PSR_individual_search_new.txt
cat PSR_individual_search_new.txt | grep "1" | tr -s ' ' | cut -d ' ' -f 2,4,5 | sed "s/^/PSR /" > 4FGL_cpt_deg.txt

for i in $(seq 1 1 2911)
do
    tosearch=$(cat 4FGL_cpt_hms.txt | head -$i |tail -1 | cut -d '|' -f 1)
    toadd=$(grep "$tosearch" <<< $ftsource | cut -d ' ' -f 2,3)
    cat 4FGL_cpt_hms.txt | head -$i |tail -1 | sed -e "s/$/|$toadd/" >> 4FGL_cpt_hms_new_new.txt
    echo $i
done

for i in $(seq 1 1 12)
do
    tosearch=$(cat 4FGL_cpt_deg.txt | head -$i |tail -1 | cut -d '|' -f 1)
    toadd=$(grep "$tosearch" <<< $ftsource | cut -d ' ' -f 2,3)
    cat 4FGL_cpt_deg.txt | head -$i |tail -1 | sed -e "s/$/|$toadd/" >> 4FGL_cpt_deg_new_new.txt
    echo $i
done
