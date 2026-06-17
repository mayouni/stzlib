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
QMkdir(cSbx)

o1 = new stzFolder(cSbx)
o1 {
    oNewFolder = CreateFolder("TestSubFolder") # Or mkdir() or MakeFolder()
    ? oNewFolder.Name()
    #--> TestSubFolder
}

if dirExists(cSbx) RemoveFolderRecursive(cSbx) ok

pf()
# Executed in almost 0 second(s) in Ring 1.23
