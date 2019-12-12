#!/bin/csh

set echo
#
# --- convert depth to landsea
#
/bin/rm -f landsea_GOMb0.08_09m11s_clip.a
hycom_clip depth_GOMb0.08_09m11s.a 263 193 1.0 1.0 landsea_GOMb0.08_09m11s_clip.a
#
/bin/rm -f landsea_GOMb0.08_09m11s.a
hycom_void landsea_GOMb0.08_09m11s_clip.a 263 193 0.0 landsea_GOMb0.08_09m11s.a
/bin/rm -f landsea_GOMb0.08_09m11s_clip.a
