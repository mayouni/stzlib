# Narrative
# --------
# Removing Files and Folders
#
# Extracted from stzfoldertest.ring, block #11.
# Portable + non-destructive: anchored in a local sandbox.

load "../../stzBase.ring"

pr()

cSbx = CurrentDir() + "/_t11"
if dirExists(cSbx) RemoveFolderRecursive(cSbx) ok
QMkdir(cSbx + "/A")  QMkdir(cSbx + "/B")  QMkdir(cSbx + "/C")
QMkdir(cSbx + "/D")  QMkdir(cSbx + "/E")

o1 = new stzFolder(cSbx)
o1 {
    # Batch mode keeps us at the root across actions (no
    # location-follows-action), so create + remove operate at this level.
    SetBatchMode(TRUE)

    # Create one more folder, then remove it
    CreateFolder("ToDelete")
    Refresh()
    ? CountFolders()
    #--> 6

    RemoveFolder("ToDelete") # Or rmdir() or DeleteFolder()
    Refresh()
    ? CountFolders()
    #--> 5

    # File presence checks: absent before creation, present after.
    ? FileExists("test.txt") #--> 0

    CreateFile("test.txt")
    Refresh()
    ? FileExists("test.txt") #--> 1
}

if dirExists(cSbx) RemoveFolderRecursive(cSbx) ok

pf()
# Executed in 0.01 second(s) in Ring 1.23
