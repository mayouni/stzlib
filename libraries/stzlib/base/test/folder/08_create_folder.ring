# Narrative
# --------
# Creating Single Folders
#
# Extracted from stzfoldertest.ring, block #8.
# Portable + non-destructive: anchored in a local sandbox.

load "../../stzBase.ring"

pr()

cSbx = CurrentDir() + "/_t08"
if dirExists(cSbx) RemoveFolderRecursive(cSbx) ok
StzMakeDir(cSbx)

o1 = new stzFolder(cSbx)
o1 {
    oNewFolder = CreateFolderQ("TestSubFolder") # Q form returns the new folder object
    ? oNewFolder.Name()
    #--> TestSubFolder
}

if dirExists(cSbx) RemoveFolderRecursive(cSbx) ok

pf()
# Executed in almost 0 second(s) in Ring 1.23
