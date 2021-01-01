**Note: 12/22 This repo is being constantly updated**

- 1 Generate cleaned 4FGL source location files

Given `gll_psc_v22.fit`, `gll_psc_v23.fit`, and `gll_psc_v27.fit`, generate cleaned files in the following way:

```
cp gll_psc_v22.fit sorted_gll_psc_v22.fit
fsort sorted_gll_psc_v22.fit "CLASS2, CLASS1" ascend=no
ftlist sorted_gll_psc_v22.fit T columns="Source_Name, CLASS2, RAJ2000, DEJ2000" | sed 's/\t//' | head -5069 | tail -5066 | head -169 > iden_4FGL_v22.txt
ftlist sorted_gll_psc_v22.fit T columns="Source_Name, CLASS1, RAJ2000, DEJ2000" | sed 's/\t//' | head -5069 | tail -5066 | head -3898 >> iden_4FGL_v22.txt
ftlist sorted_gll_psc_v22.fit T columns="Source_Name, CLASS1, RAJ2000, DEJ2000" | sed 's/\t//' | head -5068 | tail -1167 > unid_4FGL_v22.txt
```

```
cp gll_psc_v23.fit sorted_gll_psc_v23.fit
fsort sorted_gll_psc_v23.fit "CLASS2, CLASS1" ascend=no
ftlist sorted_gll_psc_v23.fit T columns="Source_Name, CLASS2, RAJ2000, DEJ2000" | sed 's/\t//' | head -5792 | tail -n +4| head -202 > iden_4FGL_v23.txt
ftlist sorted_gll_psc_v23.fit T columns="Source_Name, CLASS1, RAJ2000, DEJ2000" | sed 's/\t//' | head -5792 | tail -n +206 | head -4109 >> iden_4FGL_v23.txt
ftlist sorted_gll_psc_v23.fit T columns="Source_Name, CLASS1, RAJ2000, DEJ2000" | sed 's/\t//' | head -5792 | tail -1478 > unid_4FGL_v23.txt
```

**v27 from Pablo on 20/12/29**
```
cp gll_psc_v27.fit sorted_gll_psc_v27.fit
fsort sorted_gll_psc_v27.fit "CLASS2, CLASS1" ascend=no
ftlist sorted_gll_psc_v27.fit T columns="Source_Name, CLASS2, RAJ2000, DEJ2000" | sed 's/\t//' | head -5792 | tail -n +4| head -198 > iden_4FGL_v27.txt
ftlist sorted_gll_psc_v27.fit T columns="Source_Name, CLASS1, RAJ2000, DEJ2000" | sed 's/\t//' | head -5792 | tail -n +202 | head -4121 >> iden_4FGL_v27.txt
ftlist sorted_gll_psc_v27.fit T columns="Source_Name, CLASS2, RAJ2000, DEJ2000" | sed 's/\t//' | head -5791 | tail -1470 > unid_4FGL_v27.txt
```

There might be a clever way to do this. TODO for the future.

Meanwhile, one should start preparing the `database.csv` file, which records a particular source is in v22 or v27, or in both. It also records the location of source. It will be appended in the next rounds to include more columns when source analysis is carried out. The initialization of this source is done with a Julia file. Execute `julia csv_generate.jl` inside the `utils` folder.

- 2
Use `bulk_download.sh` (which in turn calls `bulk_download_helper.sh`, which relies on NASA's script to query SWIFT catalog) to run on these two files and download data. The following set of `wget` commands are carried out:

```
nohup wget -nH --no-check-certificate --cut-dirs=5 -r -l0 -c -N -np -R 'index*' -erobots=off --retr-symlinks https://heasarc.gsfc.nasa.gov/FTP/swift/data/obs/${starttime1}_${starttime2}//$obsid/xrt/ > download_xrt_$obsid.log 2>&1 &
nohup wget -nH --no-check-certificate --cut-dirs=5 -r -l0 -c -N -np -R 'index*' -erobots=off --retr-symlinks https://heasarc.gsfc.nasa.gov/FTP/swift/data/obs/${starttime1}_${starttime2}//$obsid/auxil/ > download_auxil_$obsid.log 2>&1 &
#nohup wget -nH --no-check-certificate --cut-dirs=5 -r -l0 -c -N -np -R 'index*' -erobots=off --retr-symlinks https://heasarc.gsfc.nasa.gov/FTP/swift/data/obs/${starttime1}_${starttime2}//$obsid/bat/ > download_bat_$obsid.log 2>&1 &
nohup wget -nH --no-check-certificate --cut-dirs=5 -r -l0 -c -N -np -R 'index*' -erobots=off --retr-symlinks https://heasarc.gsfc.nasa.gov/FTP/swift/data/obs/${starttime1}_${starttime2}//$obsid/log/ > download_log_$obsid.log 2>&1 &
```

So it downloads `xrt`, `auxil`, and `log` data, the `bat` data wasn't downloaded. I think we were going to download `bat` data, but after a few tries, it turned out that `bat` files are very large and do not contribute a lot to our project.

`bulk_download.sh` passes in the 4FGL catalog position and desired timeframe to `bulk_download_helper.sh`. This will generate a file in the format of `$(date '+%d_%m_%Y')_queryres.txt` in the respective 4FGL folders (e.g. `/BLL/4FGL_J1653.8+3945/29_08_2019_queryres.txt` and `/BLL/4FGL_J1653.8+3945/queryres.txt`)  **A new download is executed as of Jan. 1st 2021 and is currently in progress.**

~~`old_download.sh` should generate a list of `echo -e "Started initiating \033[1;4m$(($rownb * 4))\033[0m wget commands"`. The actual number is `$(($rownb * 4))`. The rest is command-related parameters to make output more beautiful. These outputs are recorded in `nohup.out` for identified sources (3743 lines) and in `nohup_unid.log` for unidentified sources (1154 lines). Sometime, the output for one line is `* 4: syntax error: operand expected (error token is "* 4")`. I think it corresponds to when no SWIFT data was present for that source. Caching is implemented in this file: if an observation id is already present, do not download the relevant files.~~

`check_bulk.sh` could be used to check the status of download.

~~It seems a file renaming took place. `old_download.sh` (and `old_bulk.sh`) were previously named `download.sh` (`bulk.sh`). It was renamed to give rooom to the currently named `download.sh` and `bulk.sh`, which were used to create folders with suffix `_arcmin_20` (e.g. `PSR_arcmin_20`). The currently named `download.sh` file does a query and then copy observation folders from the non-suffixed folders (e.g. `PSR`) to the suffxied folders (e.g. `PSR_arcmin_20`). The only difference between these two files (and thus these two sorts of folders) is that `old_download.sh` or non-suffixed folders ran the query with `radius = 30` while the `download.sh` or suffixed folders ran the query with `radius = 20`.~~

NB: I remember we had a problem with downloading using the computation nodes at HPC - those were not connected to the internet. So, the downloads should have been carried out on the front node.


- 3 Prepare 4FGL counterpart locations file

**12/23** I discovered that the 4FGL catalog actually contains two columns, named `RA_Counterpart` and `DEC_Counterpart`. I compared half of the pulsar counterpart information `4FGL_cpt_deg_new_new.txt` I had from querying some database with the `RA_Counterpart` and `DEC_Counterpart` columns in `gll_psc_v20.fit`. I found out that the information is almost identical, stored here:

Result from the `gll_psc_v20.fit` file, with **the last two columns** being the counterpart information

```
ftlist sorted_gll_psc_v20.fit T columns="Source_Name, ASSOC1, ASSOC2, RAJ2000, DEJ2000, RA_Counterpart, DEC_Counterpart"
59 4FGL J1203.9-6242                               PSR J1203-63               180.9843 -62.7095 180.9242 -62.7190
3631 4FGL J1641.2-5317  PSR J1641-5317                                          250.3250 -53.2989 250.3165 -53.2970
3660 4FGL J1714.4-3830  PSR J1714-3830                                          258.6124 -38.5070 258.5825 -38.5064
3704 4FGL J1513.4-2549  PSR J1513-2550                                          228.3728 -25.8271 228.3470 -25.8420
3705 4FGL J1817.1-1742  PSR J1817-1742                                          274.2920 -17.7023 274.2876 -17.7002
3741 4FGL J2017.7-1612  PSR J2017-1614                                          304.4414 -16.2039 304.4423 -16.2376
3757 4FGL J1855.9-1435  PSR J1855-1436                                          283.9946 -14.5908 283.9760 -14.6025
3771 4FGL J1641.2+8049  PSR J1641+8049                                          250.3029  80.8292 250.3369  80.8314
3777 4FGL J2115.1+5449  PSR J2115+5448                                          318.7845  54.8206 318.7990  54.8125
3797 4FGL J1921.4+0136  PSR J1921+0137                                          290.3570   1.6066 290.3762   1.6230
3806 4FGL J2310.0-0555  PSR J2310-0555                                          347.5183  -5.9251 347.5268  -5.9267
3807 4FGL J1536.4-4948  PSR J1536-49                                            234.1003 -49.8164 234.0968 -49.8152
```

and this is the result from querying pulsar database online:

```
PSR J1641-5317|250.31629 -53.29689  |4FGL J1641.2-5317
PSR J1513-2550|228.34717 -25.84202|4FGL J1513.4-2549
PSR J1817-1742|274.28764 -17.70031|4FGL J1817.1-1742
PSR J2017-1614|304.44228 -16.23764|4FGL J2017.7-1612
PSR J1855-1436|283.97595 -14.60249|4FGL J1855.9-1435
PSR J1641+8049|250.33683 80.83137|4FGL J1641.2+8049
PSR J2115+5448|318.79903 54.81254|4FGL J2115.1+5449
PSR J1921+0137|290.37628 1.62376|4FGL J1921.4+0136
PSR J2310-0555|347.52679 -5.92664|4FGL J2310.0-0555
PSR J1714-3830|258.5825 -38.506389|4FGL J1714.4-3830
PSR J1536-49|234.100667 -49.812608|4FGL J1536.4-4948
PSR J1203-63|180.9843 -62.7095|4FGL J1203.9-6242
```

**TODO** This is something we need to determine at some point. Maybe we knew this before and decided to use the counterpart locations by querying SIMBAD and other databases?

- `xrt_pipeline.sh`

This is the main file for analyzing downloaded SWIFT data, which should be funneled to this file. This file is ran with options `--xrtppl=yes --spec=yes` in its latest depolyment.

When ran in the above configuration, this file will:
  1. Query `/group/phys_heastro/swift/download/4FGL_cpt_hms_new_new.txt` or `/group/phys_heastro/swift/download/4FGL_cpt_deg_new_new.txt` for RA/DEC in either hms or deg format of counterpart information. If no counterpart information in found, use "POINT" as input to `xrtpipeline` in the next step.
  
  2. Run `xrtpipeline` command on all obeservation folders using RA/DEC of counterpart information or "POINT" if no counterpart is found.
  
  3. Process `pc` files, use `xselect` to read all event files in and extract an image. (`xselect` is invoked with a `source` command because `xselect` only supports command-line prompts, same in next steps)
  
  4. Draw **error circle** of **60''** around the location info at step 2,  use **signal-to-noise ratio** of **3** to detect sources in the image by `sosta` command. Note that the error circle of **60''** is only for clarity reason. If we were to draw a circle of **10''**, it sometimes get blurred into a bright source. Thus, a **60''** circle is drawn to make sure we can see where the counterpart location is on the generated photos.
  
  5. Write the identified sources information into folder `source_location`. These will be a collection of `loc_$i.reg` files, where `loc_0.reg` stores the counterpart position. These files will be in a specical format.

  6. **Source filter**: Determine if the distance between the source location and the 4FGL-listed counterpart location is smaller than the uncertainty from X-Ray source detection. This step is done using **xrtcentroid** at https://www.swift.ac.uk/analysis/xrt/xrtcentroid.php. The calculation is done with `distance.py` inside `utils`. **Make sure to have the required python modules installed**. Notice the user on how many sources are left after filter (0, 1, or more).
  
  7. Use `xselect` to again read in all event files, filter on sources selected in the previous step **with the uncertainty from the xrtcentriod source detection**, carry out `extract image`, carry out `extract spec`, carry out `extract curve`, and `filter pha_cutoff` where the endpoints are set at `lccutoff=(30 100 100 200 200 1000)`.
  
  8. Use `ftconvert` to the `im` files generated in step 7 to `txt files`.
  
  9. If the Global spectrum or the particular source spectrum has count rate bigger than 0.5 counts/s, generate a warning.
  
  10. Clean up.
  
This file has a cache feature implemented. If a result from `xrtpipeline` is present, then do not run step 2 of the above procedure.

This file, when ran on HPC, is submitted to its job system through a bunch of `.cmd` files. The `.cmd` files are generated by `jobsubmission.sh`, and they are submitted to the queuing system by `jobtry.sh`.

~~**Note**: For the `UNASSOC` folder, there is a specifically designed `info_point_unassoc.sh` that actually extracts information around each X-Ray source. Use it for anything in `UNASSOC`.~~