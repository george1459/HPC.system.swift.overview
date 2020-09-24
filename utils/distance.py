# ====================================================
#   Copyright (c) 2020 All rights reserved
#
#   Author        : Shicheng Liu
#   Email         : shicheng2000@uchicago.edu
#   File Name     : distance.py
#   Last Modified : Thu Sep 24 2020 23:50:08 (UTC +8)
#
# ====================================================

from astropy.coordinates import SkyCoord
import sys

if __name__ == "__main__":
    p1 = SkyCoord(sys.argv[1], sys.argv[2] , frame = "galactic")
    p2 = SkyCoord(sys.argv[3], sys.argv[4] , frame = "galactic")
    error = float(sys.argv[5])
    sep = p1.separation(p2).arcsecond
    if sep < error:
        print("True")
    else:
        print("False")

