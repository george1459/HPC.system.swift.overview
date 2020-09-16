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

``
nohup wget -nH --no-check-certificate --cut-dirs=5 -r -l0 -c -N -np -R 'index*' -erobots=off --retr-symlinks https://heasarc.gsfc.nasa.gov/FTP/swift/data/obs/${starttime1}_${starttime2}//$obsid/xrt/ > download_xrt_$obsid.log 2>&1 &
nohup wget -nH --no-check-certificate --cut-dirs=5 -r -l0 -c -N -np -R 'index*' -erobots=off --retr-symlinks https://heasarc.gsfc.nasa.gov/FTP/swift/data/obs/${starttime1}_${starttime2}//$obsid/auxil/ > download_auxil_$obsid.log 2>&1 &
nohup wget -nH --no-check-certificate --cut-dirs=5 -r -l0 -c -N -np -R 'index*' -erobots=off --retr-symlinks https://heasarc.gsfc.nasa.gov/FTP/swift/data/obs/${starttime1}_${starttime2}//$obsid/log/ > download_log_$obsid.log 2>&1 &
``

So it downloads `xrt`, `auxil`, and `log` data, the `bat` data wasn't downloaded.

`old_bulk.sh` passes in the 4FGL catalog position and desired timeframe to `old_download.sh`. **TODO: I need to find out what time was passed to this file**

`check_bulk.sh` could be used to check the status of download.

I remember we had a problem with downloading using the computation nodes at HPC - those were not connected to the internet. So, the downloads, if I remember clearly, were carried out on the front node