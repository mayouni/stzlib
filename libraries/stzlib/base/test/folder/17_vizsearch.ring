# Narrative
# --------
# Visual search across a folder tree
#
# Extracted from stzfoldertest.ring, block #17.
# Portable: a local sandbox replaces the machine-specific core/ path.

load "../../stzBase.ring"

pr()

cSbx = CurrentDir() + "/_t17"
if dirExists(cSbx) RemoveFolderRecursive(cSbx) ok
QMkdir(cSbx + "/common")
QMkdir(cSbx + "/data")
write(cSbx + "/common/memory.ring", "x")
write(cSbx + "/common/cache.ring", "x")
write(cSbx + "/notes.txt", "x")

o1 = new stzFolder(cSbx)
? o1.VizDeepSearch("*memory*")
#--> a tree marking every file whose name contains 'memory'
#    (here: common/memory.ring), with a target stat label at the root.

if dirExists(cSbx) RemoveFolderRecursive(cSbx) ok

pf()
# Executed in 0.01 second(s) in Ring 1.23
