# Narrative
# --------
# pr()
#
# Extracted from stzsystemcalltest.ring, block #19.

load "../../stzBase.ring"

pr()

# System info (truncated)
oCall = new stzSystemCall(Sys(:SystemInfo))
oCall.Run()
cInfo = oCall.Output()

# System info (first 200 chars):
? left(cInfo, 200) + "..."
#-->
'
Host Name:                             DESKTOP-CICEMOO  
Operating System Name:                 Microsoft Windows 11 Professional  
Operating System Version:              10.0.26...
'

pf()
# Executed in 3.82 second(s) in Ring 1.24
