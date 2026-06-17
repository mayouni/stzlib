# Narrative
# --------
# Recursive Removal
#
# Extracted from stzfoldertest.ring, block #12.
# Portable + non-destructive: anchored in a local sandbox.

load "../../stzBase.ring"

pr()

cSbx = CurrentDir() + "/_t12"
if dirExists(cSbx) RemoveFolderRecursive(cSbx) ok
StzMakeDir(cSbx + "/Level1/Level2/Level3")
write(cSbx + "/Level1/a.txt", "x")
write(cSbx + "/Level1/Level2/b.txt", "x")

o1 = new stzFolder(cSbx + "/Level1")
o1 {
    # Current path before removal
    ? Path()
    #--> <sandbox>/Level1

    # Removing the whole folder and its subfolders (recursively)
    bSuccess = DeepRemoveAll()
    ? bSuccess
    #--> 1 (removal successful)
}

? dirExists(cSbx + "/Level1")
#--> 0

if dirExists(cSbx) RemoveFolderRecursive(cSbx) ok

pf()
# Executed in almost 0 second(s) in Ring 1.23
