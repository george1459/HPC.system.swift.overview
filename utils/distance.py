# ====================================================
#   Copyright (c) 2020 All rights reserved
#
#   Author        : Shicheng Liu
#   Email         : shicheng2000@uchicago.edu
#   File Name     : distance.py
#   Last Modified : Sun Sep 27 2020 09:43:09 (UTC +8)
#
# ====================================================


from astropy.coordinates import SkyCoord
import sys
import re

def check_format_hms(loc):
    ret = bool(re.match("\d\d[\sh]\d\d[\sm][\S]*", loc))
    return ret

def check_format_dms(loc):
    ret =  bool(re.match("[+-]\d\d[\sd]\d\d[\sm][\S]*", loc))
    return ret

def replace_hms(loc):
    loc = loc.replace(" ", "h", 1)
    loc = loc.replace(" ", "m", 1)
    if not bool(re.match("[\S]*s$", loc)):
        loc = loc + "s"
    return loc

def replace_dms(loc):
    loc = loc.replace(" ", "d", 1)
    loc = loc.replace(" ", "m", 1)
    if not bool(re.match("[\S]*s$", loc)):
        loc = loc + "s"
    return loc



if __name__ == "__main__":
    loc1 = sys.argv[1]
    loc2 = sys.argv[2]
    loc3 = sys.argv[3]
    loc4 = sys.argv[4]

    if check_format_hms(loc1) and check_format_dms(loc2):
        p1 = SkyCoord(replace_hms(loc1), replace_dms(loc2), frame = "galactic")
    else:
        p1 = SkyCoord(loc1, loc2, unit='deg', frame = "galactic")

    if check_format_hms(loc3) and check_format_dms(loc4):
        p2 = SkyCoord(replace_hms(loc3), replace_dms(loc4), frame = "galactic")
    else:
        p2 = SkyCoord(loc3, loc4, unit='deg', frame = "galactic")

    error = float(sys.argv[5])
    sep = p1.separation(p2).arcsecond
    if sep < error:
        print("True {}".format(sep))
    else:
        print("False {}".format(sep))

