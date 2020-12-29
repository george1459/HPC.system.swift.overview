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