# Narrative
# --------
# Getting Folder Names and Paths
#
# Extracted from stzfoldertest.ring, block #2.
# Portable: a local sandbox replaces the machine-specific path.

load "../../stzBase.ring"

pr()

cSbx = CurrentDir() + "/_t02"
if dirExists(cSbx) RemoveFolderRecursive(cSbx) ok
QMkdir(cSbx + "/projects")

o1 = new stzFolder(cSbx + "/projects")
o1 {

    ? Name()
    #--> projects

    ? Path() # the folder original path (real case preserved)
    #--> <sandbox>/projects

    ? FullPath() # Or AbsolutePath()
    #--> <sandbox>/projects

    ? IsAbsolute()
    #--> 1

    ? IsRoot()
    #--> 0
}

if dirExists(cSbx) RemoveFolderRecursive(cSbx) ok

pf()
# Executed in almost 0 second(s) in Ring 1.23
