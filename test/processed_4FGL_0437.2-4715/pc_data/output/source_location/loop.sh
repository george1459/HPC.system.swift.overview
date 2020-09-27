xselect << EOF

read event
/home/georgejar/Parkinson/HPC.system.swift.overview/test/processed_4FGL_0437.2-4715/pc_data/
sw00035763001xpcw2po_cl.evt,sw00035763001xpcw3po_cl.evt,sw00035763002xpcw2po_cl.evt,sw00080337001xpcw3po_cl.evt,sw00080960001xpcw3po_cl.evt,sw00080960002xpcw3po_cl.evt,sw00091622001xpcw3po_cl.evt,sw00093034001xpcw3po_cl.evt,sw00093034002xpcw3po_cl.evt
yes
read event
sw00095034001xpcw3po_cl.evt,sw00095034002xpcw3po_cl.evt

filter region loc_2.reg
extract image
save image im_2.im
extract spec
save spec spec_2.im
extract curve
save curve lc_2.im
filter pha_cutoff 30 100
extract curve
save curve lc_2_cutoff_1.im
clear pha_cutoff
filter pha_cutoff 100 200
extract curve
save curve lc_2_cutoff_2.im
clear pha_cutoff
filter pha_cutoff 200 1000
extract curve
save curve lc_2_cutoff_3.im
clear pha_cutoff
clear region
quit
EOF
