# StzDirDeleteAll -- recursive directory delete.
#
# The gap it fixes: StzEngineDirDelete (and its thin wrapper StzDirDelete) only
# remove an EMPTY directory -- they silently no-op on a non-empty one, so scratch
# and test directories leak across runs. StzDirDeleteAll empties the tree bottom-up
# (files + subdirs + DOTFILES like .stzsite) and then removes it. The engine's dir
# listings include dotfiles, so nothing is left behind.

load "../../stzBase.ring"

nPass = 0
nFail = 0

pr()

cB = WorkingDirectory() + "/_dda_guard"
StzDirDeleteAll(cB)   # fresh start (recursive)

# a nested tree with dotfiles at every level
StzEngineDirCreatePath(cB + "/sub/deep")
write(cB + "/a.txt", "a")
write(cB + "/.hidden", "h")
write(cB + "/sub/b.txt", "b")
write(cB + "/sub/.stzsite", "s")
write(cB + "/sub/deep/c.txt", "c")
write(cB + "/sub/deep/.dot", "d")

? "-- Scene 1: the gap -- StzDirDelete no-ops on a NON-empty directory --"
StzDirDelete(cB)
chk("StzDirDelete leaves a non-empty tree standing (the bug it works around)",
	StzEngineDirExists(cB) = 1 and StzEngineFileExists(cB + "/a.txt") = 1)

? ""
? "-- Scene 2: StzDirDeleteAll removes the WHOLE tree, dotfiles and all --"
bR = StzDirDeleteAll(cB)
chk("...it returns TRUE", bR)
chk("...the directory is gone", StzEngineDirExists(cB) = 0)
chk("...every nested file is gone -- INCLUDING the dotfiles (.hidden / .stzsite / .dot)",
	StzEngineFileExists(cB + "/.hidden") = 0 and StzEngineFileExists(cB + "/sub/.stzsite") = 0 and StzEngineFileExists(cB + "/sub/deep/.dot") = 0)

? ""
? "-- Scene 3: graceful on a directory that does not exist --"
chk("deleting a missing dir returns TRUE (no error)", StzDirDeleteAll(cB + "/never") = TRUE)

? ""
? "=========================================="
? "TOTAL: " + (nPass + nFail) + " assertions, " + nPass + " pass, " + nFail + " fail"
? "=========================================="

pf()

func chk cLabel, bCond
	if bCond
		nPass++
		? "  [OK] " + cLabel
	else
		nFail++
		? "  [FAIL] " + cLabel
	ok
