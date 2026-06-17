# Narrative
# --------
# Creating Folder Paths
#
# Extracted from stzfoldertest.ring, block #10.
# Portable + non-destructive: anchored in a local sandbox.
#
# CreatePath creates every missing intermediate folder in one call. Per the
# Q convention: CreatePathQ() returns the DEEPEST folder OBJECT (so you can
# chain .Name() / .Path()); the bare CreatePath() returns TRUE/FALSE.

load "../../stzBase.ring"

pr()

cSbx = CurrentDir() + "/_t10"
if dirExists(cSbx) RemoveFolderRecursive(cSbx) ok
StzMakeDir(cSbx)

o1 = new stzFolder(cSbx)
o1 {
    # Creating a deep path; Q form hands back the deepest folder object
    oDeepFolder = CreatePathQ("TestArea/Level1/Level2/Level3") # Or MkPathQ()
    ? oDeepFolder.Name()
    #--> Level3

    ? dirExists(cSbx + "/TestArea/Level1/Level2/Level3")
    #--> 1

    # The bare (value) form just reports success
    ? CreatePath("Other/Deep/Path")
    #--> 1
}

if dirExists(cSbx) RemoveFolderRecursive(cSbx) ok

pf()
# Executed in 0.01 second(s) in Ring 1.23
