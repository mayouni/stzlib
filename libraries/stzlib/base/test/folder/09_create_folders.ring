# Narrative
# --------
# Creating Multiple Folders
#
# Extracted from stzfoldertest.ring, block #9.
# Portable + non-destructive: anchored in a local sandbox.

load "../../stzBase.ring"

pr()

cSbx = CurrentDir() + "/_t09"
if dirExists(cSbx) RemoveFolderRecursive(cSbx) ok
QMkdir(cSbx)

o1 = new stzFolder(cSbx)
o1 {

    aCreated = CreateFolders([ "Docs", "Images", "Videos", "Music" ])

    nLen = len(aCreated)
    for i = 1 to nLen
        oFolder = aCreated[i]
        ? oFolder.Name()
    next
    #--> Docs
    #    Images
    #    Videos
    #    Music
}

if dirExists(cSbx) RemoveFolderRecursive(cSbx) ok

pf()
# Executed in almost 0 second(s) in Ring 1.23
