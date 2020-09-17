# HPC.system.swift.overview

**09/16 Note: This document is being constantly updated as I recollect source files**

This gives an overview of the structure of `/group/phys_heastro/swift/download` folder.

## Directory Overview

Within this folder, you can find numerous files (Many will be cleaned up soon! Hopefully...), but the most important are of the followings:

- 1
`info_point.sh`

The main Swift XRT pipeline file, an upgraded version of `info.sh` (which was its previous name).

`info_point.sh` is ran with options `--xrtppl=yes --spec=yes`. Check `info_point.sh` for its exact behaviors.

- 2 : Sources Folders
`AGN` `PSR` `BLL` `UNASOOC` ...

The main folders containing Swift obervations. Within each of these folders, you can find a list of folders with the 4FGL name: e.g. `4FGL_J2055.8+2540`. After jobs finish running `info_point.sh`, folders with names like `point_v3_info_caches_4FGL_J2055.8+2540` can be found. Future analysis should be done on folders with names like such. The outputs of these folders were generated with feeding the **Counterpart** location to XRT pipeline:

- [ ] Inputting 4FGL locations
- [x] Inputting counterpart locations
- [ ] Inputting "POINT" (Uses information from fits header )
- [ ] Inputting "OBJECT" (Uses information form fits header)
- [ ] Do not run xrtpipeline, uses cleaned events from NASA's archive

> A Note: Within some Source Folders you can find folders with names like `point_v2_info_caches` or `info_caches` or `point_v4_info_caches`, please ignore them for now. They were ran with different XRT pipeline input (ones not implemented with the above choice). I hope to remove them after all analysis are done. 

- 3 : Submission Code Folders
`submission_code_point_2_BLL` `submission_code_point_6_PSR` ...

These folders contain the submission codes for the Sources Folders with the respective name. For example, `submission_code_point_2_BLL` contains submission codes for `BLL`. Submission code refers to the `.cmd` files to be submitted to HPC's file system. For example, within `submission_code_point_2_BLL` you can find: 

```
[georgel2@hpc2015 submission_code_point_2_BLL]$ ls -1
BLL_run_10.cmd
BLL_run_20.cmd
BLL_run_22.cmd
```
This is because the `BLL` folder contains 22 4FGL sources. `BLL_run_10.cmd` deals with the first 10 of them, `BLL_run_20.cmd` deals with the next 10 of them, and `BLL_run_2.cmd` deals with the last two of them. Each of these `.cmd` will become a **job** after submitted, e.g., a job named BLL_run_10 is the job created by `qsub BLL_run_10.cmd`. Thus, each job deals with 10 4FGL source folders, with the exception of the last one that deals with the last folders. Since each 4FGL source folder (e.g. `4FGL_J2055.8+2540`) can contain lots of observations, it is difficult to estimate the amount of time needed for each job. 

The reason why there are different version number (i.e. the number between `point_` and `_BLL`) is because sometimes, these jobs are not successfully completed (due to Permission errors, e.g.), and a new folder with a new version number is created to contain the jobs that need to be re-ran.

- 4
`jobtry.sh`

This shell script takes in a folder name and keeps trying to run the `qsub` command on each file that it contains until `qsub` returns success. Because the number of jobs allowed to be in queue at the same time is capped (at around 2-7, dependent on conditions), this file is created to help submitting jobs. Once executed, it will keep on submitting a job at 2-minute intervals. You are recommended to run it with nohup as follows:

``nohup ./jobtry.sh submission_code_point_3_agn > submission_code_point_3_agn.log &``

Then, by using `tail -f submission_code_point_3_agn.log`, you can check its output on real-time basis. 

## Some useful commands
If the `jobtry.sh` is ran with nohup command, to stop it from still trying to proceed:

``ps -ef | grep "jobtry.sh"``

The above command will return the job id for such nohup command, which can be used to terminate the program.


## Other not-so-important files

- 1
`4FGL_cpt_deg_new_new.txt`
`4FGL_cpt_hms_new_new.txt`
  
Files containing associated 4FGL sources' names, counterpart names, and counterpart locations. The reason why there are two of them is because one contains coordinates in degree format while the other contains coordinates in hms format. These files were also uploaded on google drive. 

- 2
`0819_2.cmd`

Sorry for the bad naming, but this is actually the main cmd (submission) model file. All other cmd files are created from this file.


## Order to run pipeline files

- 1
Generate files in the format of `iden_4FGL.txt` and `unid_4FGL.txt` (still figuring out which file was used to generate these two)

- 2
Use `old_bulk.sh` (which in turn calls `old_download.sh`, which relies on NASA's script to query SWIFT catalog) to run on these two files and download data. The following set of `wget` commands are carried out:

```
nohup wget -nH --no-check-certificate --cut-dirs=5 -r -l0 -c -N -np -R 'index*' -erobots=off --retr-symlinks https://heasarc.gsfc.nasa.gov/FTP/swift/data/obs/${starttime1}_${starttime2}//$obsid/xrt/ > download_xrt_$obsid.log 2>&1 &
nohup wget -nH --no-check-certificate --cut-dirs=5 -r -l0 -c -N -np -R 'index*' -erobots=off --retr-symlinks https://heasarc.gsfc.nasa.gov/FTP/swift/data/obs/${starttime1}_${starttime2}//$obsid/auxil/ > download_auxil_$obsid.log 2>&1 &
#nohup wget -nH --no-check-certificate --cut-dirs=5 -r -l0 -c -N -np -R 'index*' -erobots=off --retr-symlinks https://heasarc.gsfc.nasa.gov/FTP/swift/data/obs/${starttime1}_${starttime2}//$obsid/bat/ > download_bat_$obsid.log 2>&1 &
nohup wget -nH --no-check-certificate --cut-dirs=5 -r -l0 -c -N -np -R 'index*' -erobots=off --retr-symlinks https://heasarc.gsfc.nasa.gov/FTP/swift/data/obs/${starttime1}_${starttime2}//$obsid/log/ > download_log_$obsid.log 2>&1 &
```

So it downloads `xrt`, `auxil`, and `log` data, the `bat` data wasn't downloaded. I think we were going to download `bat` data, but after a few tries, it turned out that `bat` files are very large and do not contribute a lot to our project.

`old_bulk.sh` passes in the 4FGL catalog position and desired timeframe to `old_download.sh`. This will generate a file in the format of `$(date '+%d_%m_%Y')_queryres.txt` in the respective 4FGL folders (e.g. `/BLL/4FGL_J1653.8+3945/29_08_2019_queryres.txt` and `/BLL/4FGL_J1653.8+3945/queryres.txt`)  **It seems there are two queries queried out: one without an exact date and one on 29th Aug. 2019. I cannot retrieve the exact timeframe for each download. I believe the first one was carried on all avaliable time frames, while the other were carried out on files spanning from the time first download finished to 29th Aug. 2019.**

`old_download.sh` should generate a list of `echo -e "Started initiating \033[1;4m$(($rownb * 4))\033[0m wget commands"`. The actual number is `$(($rownb * 4))`. The rest is command-related parameters to make output more beautiful. These outputs are recorded in `nohup.out` for identified sources (3743 lines) and in `nohup_unid.log` for unidentified sources (1154 lines). Sometime, the output for one line is `* 4: syntax error: operand expected (error token is "* 4")`. I think it corresponds to when no SWIFT data was present for that source.

`check_bulk.sh` could be used to check the status of download.

It seems a file renaming took place. `old_download.sh` (and `old_bulk.sh`) were previously named `download.sh` (`bulk.sh`). It was renamed to give rooom to the currently named `download.sh` and `bulk.sh`, which were used to create folders with suffix `_arcmin_20` (e.g. `PSR_arcmin_20`). The currently named `download.sh` file does a query and then copy observation folders from the non-suffixed folders (e.g. `PSR`) to the suffxied folders (e.g. `PSR_arcmin_20`). The only difference between these two files (and thus these two sorts of folders) is that `old_download.sh` or non-suffixed folders ran the query with `radius = 30` while the `download.sh` or suffixed folders ran the query with `radius = 20`.

NB: I remember we had a problem with downloading using the computation nodes at HPC - those were not connected to the internet. So, the downloads should have been carried out on the front node.

- 3 
`info_point.sh`

This is the main file for analyzing downloaded SWIFT data, which should be funneled to this file. This file is ran with options `--xrtppl=yes --spec=yes` in its latest depolyment.

When ran in the above configuration, this file will:
  - 1. Query `/group/phys_heastro/swift/download/4FGL_cpt_hms_new_new.txt` or `/group/phys_heastro/swift/download/4FGL_cpt_deg_new_new.txt` for RA/DEC in either hms or deg format of counterpart information. If no counterpart information in found, use "POINT" as input to `xrtpipeline` in the next step.
  
  - 2. Run `xrtpipeline` command on all obeservation folders using RA/DEC of counterpart information or "POINT" if no counterpart is found.
  
  - 3. Process `pc` files, use `xselect` to read all event files in and extract an image. (`xselect` is invoked with a `source` command because `xselect` only supports command-line prompts, same in next steps)
  
  - 4. Draw **error circle** of **60''** around the location info at step 2,  use **signal-to-noise ratio** of **3** to detect sources in the image by `sosta` command. 
  
  - 5. Write the identified sources information into folder `source_location`. These will be a collection of `loc_$i.reg` files, where `loc_0.reg` stores the counterpart position. These files will be in a specical format.
  
  - 6. Use `xselect` to again read in all event files, filter on region `loc_0.reg`, carry out `extract image`, carry out `extract spec`, carry out `extract curve`, and `filter pha_cutoff` where the endpoints are set at `lccutoff=(30 100 100 200 200 1000)`.
  
  - 7. Use `ftconvert` to the `im` files generated in step 6 to `txt files`.
  
  - 8. If the Global spectrum or the spectrum generated from the 60'' error circle of the counterpart location has count rate bigger than 0.5 counts/s, generate a warning.
  
  - 9. Clean up.
  
This file has a cache feature implemented. If a result from `xrtpipeline` is present, then do not run step 2 of the above procedure.

This file, when ran on HPC, is submitted to its job system through a bunch of `.cmd` files. The `.cmd` files are generated by `jobsubmission.sh`, and they are submitted to the queuing system by `jobtry.sh`.

**Note**: For the `UNASSOC` folder, there is a specifically designed `info_point_unassoc.sh` that actually extracts information around each X-Ray source. Use it for anything in `UNASSOC`.

- 4 Data Extraction & Cleaning files

Run the following in sequence:

  - 1. `feature_extract.sh` and `feature_extract_unassoc.sh`. These files will create a collection of folders with prefixs `cpt_list_` (e.g. `cpt_list_BCU`) inside the Sources Folders (e.g. `BCU`).

  - 2. **From this step forward, files were run on my local laptop**: Run `correlate.sh` in folder `8_swift` and `9_swift`.
  
  - 3. Run `cleangeneration.sh` in folder `8_swift` (designed for associated sources) and `cleangeneration.sh` in folder `9_swift` (designed for unassociated sources). These two files will generate `ASSOC_CLEANED_DATA.txt` and `UNASSOC_CLEANED_DATA.txt`, respectively. These two files differ a bit in the number of columns, as `UNASSOC_CLEANED_DATA.txt` have the following columns in addition to those in `ASSOC_CLEANED_DATA.txt`:

  ``sourcename,numbercount,ofnumbercount,sourcera,sourcedec``

  - 4. Run `postclean.sh` in folder `8_swift` and `9_swift`. This will generate files `new_ASSOC_CLEANED_DATA.txt` and `new_UNASSOC_CLEANED_DATA.txt`.

  - 5. Run `get_binaryness.sh` in folder `8_swift`.

- 5 **FINALLY!!** ML files
