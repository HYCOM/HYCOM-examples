#
# --- JSL has units of 1/s
# --- lim10: set   JSL in JSLH to 0 if < 1/10-days
# --- lim23: limit JSL in JSLH to no more than 1/24-hrs
# --- lim24: lim10 and lim23
#
set echo
#
cd ~/HYCOM-examples/GOMb0.08/relax/DRAG
setenv IDM 263
setenv JDM 193
#
#/bin/rm -f     JSL_lim10.A
#hycom_bandmask JSL.a       ${IDM} ${JDM} 0.0 1.1574e-6 JSL_lim10.A >! JSL_lim10.B
#/bin/rm -f     JSL_lim10.a
#hycom_void     JSL_lim10.A ${IDM} ${JDM} 0.0           JSL_lim10.a >! JSL_lim10.b
#
/bin/rm -f     JSL_lim23.a
hycom_clip     JSL.a       ${IDM} ${JDM} 0.0 1.1574e-5 JSL_lim23.a >! JSL_lim23.b
#
/bin/rm -f     JSL_lim24.A
hycom_bandmask JSL_lim23.a ${IDM} ${JDM} 0.0 1.1574e-6 JSL_lim24.A >! JSL_lim24.B
/bin/rm -f     JSL_lim24.a
hycom_void     JSL_lim24.A ${IDM} ${JDM} 0.0           JSL_lim24.a >! JSL_lim24.b
