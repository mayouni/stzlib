# Narrative
# --------
# Refresh Operation
#
# Extracted from stzfoldertest.ring, block #31.
# Portable + non-destructive: anchored in a local sandbox.

load "../../stzBase.ring"

pr()

cSbx = CurrentDir() + "/_t31"
if dirExists(cSbx) RemoveFolderRecursive(cSbx) ok
StzMakeDir(cSbx + "/A")  StzMakeDir(cSbx + "/B")  StzMakeDir(cSbx + "/C")
StzMakeDir(cSbx + "/D")  StzMakeDir(cSbx + "/E")

o1 = new stzFolder(cSbx)
o1 {
    # Batch mode keeps the current position put across actions (no
    # location-follows-action), so we stay at the root while creating.
    SetBatchMode(TRUE)

    # Count before refresh
    ? Count() # or CountFilesAndFolders()
    #--> 5

    CreateFolder("NewlyAdded")

    Refresh()
    ? Count()
    #--> 6
}

if dirExists(cSbx) RemoveFolderRecursive(cSbx) ok

pf()
# Executed in 0.02 second(s) in Ring 1.23
