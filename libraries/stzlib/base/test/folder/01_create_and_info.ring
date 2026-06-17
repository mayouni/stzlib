# Narrative
# --------
# Basic Folder Creation and Information
#
# Extracted from stzfoldertest.ring, block #1.
# Portable: builds a small local sandbox instead of a machine-specific path.

load "../../stzBase.ring"

pr()

cSbx = CurrentDir() + "/_t01"
if dirExists(cSbx) RemoveFolderRecursive(cSbx) ok
StzMakeDir(cSbx)
write(cSbx + "/a.txt", "x")  write(cSbx + "/b.txt", "x")  write(cSbx + "/c.txt", "x")

o1 = new stzFolder(cSbx)
o1 {

    ? @@NL( Info() )
    #--> A hashlist of name / path / absolutepath / count / files /
    #    folders / isempty / isreadable / isroot for the sandbox folder
    #    (count = 3 files, 0 folders).

    ? Name()
    #--> _t01

    ? IsEmpty()
    #--> 0

    ? Count() # Or Size()
    #--> 3
}

if dirExists(cSbx) RemoveFolderRecursive(cSbx) ok

pf()
# Executed in 0.01 second(s) in Ring 1.23
