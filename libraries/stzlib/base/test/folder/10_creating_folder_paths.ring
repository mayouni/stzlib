# Narrative
# --------
# Creating Folder Paths
#
# Extracted from stzfoldertest.ring, block #10.
# Made portable + non-destructive: the original wrote a deep path onto the
# real C:\ root; here we anchor it in a local sandbox so it runs for real
# without touching the machine. The API exercised (CreatePath / mkpath) is
# unchanged.

load "../../stzBase.ring"

pr()

cSbx = CurrentDir() + "/_fx_path"
if dirExists(cSbx) RemoveFolderRecursive(cSbx) ok
QMkdir(cSbx)

o1 = new stzFolder(cSbx)
o1 {
    # Creating deep path...
    oDeepFolder = CreatePath("TestArea/Level1/Level2/Level3") # Or mkpath()
    ? oDeepFolder.Name()
    #--> Level3

    ? dirExists(cSbx + "/TestArea/Level1/Level2/Level3")
    #--> 1
}

if dirExists(cSbx) RemoveFolderRecursive(cSbx) ok

pf()
# Executed in 0.01 second(s) in Ring 1.23
