xselect << EOF

read event
/home/georgejar/Parkinson/HPC.system.swift.overview/test/processed_4FGL_J0540.3-6920/pc_data/
sw00033603054xpcw3po_cl.evt,sw00033650001xpcw3po_cl.evt,sw00045451001xpcw3po_cl.evt,sw00045451002xpcw3po_cl.evt,sw00045452001xpcw3po_cl.evt,sw00045453001xpcw3po_cl.evt,sw00045453002xpcw3po_cl.evt,sw00045453003xpcw3po_cl.evt,sw00053400001xpcw4po_cl.evt
yes
read event
sw00053400002xpcw4po_cl.evt,sw00053400003xpcw4po_cl.evt,sw00053400004xpcw4po_cl.evt,sw00053400005xpcw4po_cl.evt,sw00053400006xpcw3po_cl.evt,sw00053400007xpcw3po_cl.evt,sw00053400008xpcw3po_cl.evt,sw00053400009xpcw3po_cl.evt,sw00053400010xpcw3po_cl.evt

read event
sw00053400011xpcw3po_cl.evt,sw00053400012xpcw3po_cl.evt,sw00053400013xpcw3po_cl.evt,sw00053400014xpcw3po_cl.evt,sw00053400015xpcw3po_cl.evt,sw00053402004xpcw2po_cl.evt,sw00053402005xpcw2po_cl.evt,sw00053402006xpcw2po_cl.evt,sw00053402007xpcw2po_cl.evt

read event
sw00053402008xpcw2po_cl.evt,sw00053402009xpcw2po_cl.evt,sw00053402010xpcw2po_cl.evt,sw00081677001xpcw3po_cl.evt,sw00081677002xpcw3po_cl.evt

filter region loc_1.reg
extract image
save image im_1.im
extract spec
save spec spec_1.im
extract curve
save curve lc_1.im
filter pha_cutoff 30 100
extract curve
save curve lc_1_cutoff_1.im
clear pha_cutoff
filter pha_cutoff 100 200
extract curve
save curve lc_1_cutoff_2.im
clear pha_cutoff
filter pha_cutoff 200 1000
extract curve
save curve lc_1_cutoff_3.im
clear pha_cutoff
clear region
filter region loc_5.reg
extract image
save image im_5.im
extract spec
save spec spec_5.im
extract curve
save curve lc_5.im
filter pha_cutoff 30 100
extract curve
save curve lc_5_cutoff_1.im
clear pha_cutoff
filter pha_cutoff 100 200
extract curve
save curve lc_5_cutoff_2.im
clear pha_cutoff
filter pha_cutoff 200 1000
extract curve
save curve lc_5_cutoff_3.im
clear pha_cutoff
clear region
quit
EOF
