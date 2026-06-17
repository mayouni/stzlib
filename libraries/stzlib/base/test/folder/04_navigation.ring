# Narrative
# --------
# Basic Navigation
#
# Extracted from stzfoldertest.ring, block #4.
# Portable: a local sandbox replaces C:\Users. Location follows action --
# GoTo/Up move the folder's current position; the original path is "home".

load "../../stzBase.ring"

pr()

cSbx = CurrentDir() + "/_t04"
if dirExists(cSbx) RemoveFolderRecursive(cSbx) ok
QMkdir(cSbx + "/Public/Shared")

o1 = new stzFolder(cSbx)
o1 {
    # Current path
    ? Path()
    #--> <sandbox> (the home/original path)

    GoTo("Public") # Or MoveTo() or cd()
    ? Path()
    #--> <sandbox>/Public/

    Up() # Or GoUp() or cdUp()
    ? Path()
    #--> <sandbox>

    GoHome()
    ? Path()
    #--> <sandbox> (back to where we started)
}

if dirExists(cSbx) RemoveFolderRecursive(cSbx) ok

pf()
# Executed in almost 0 second(s) in Ring 1.23
