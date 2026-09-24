# The court of this project. %PROJECT% is the learner's folder; it prints what it found.
cP = "%PROJECT%"
cF = cP + "/narration.en.md"
if fexists(cF)
	oCh = StzChapterQ(cF, "en")
	oCh.Run("")
	? "cells five or more: " + yn(oCh.NumberOfCells() >= 5)
	? "every cell has a promise: " + yn(oCh.NumberOfPromises() >= oCh.NumberOfCells())
	? "every promise kept: " + yn(oCh.AllPromisesKept())
	? "stored output: " + yn(oCh.HasStoredOutput())
else
	? "narration: missing"
ok
func yn(b)
	if b
		return "yes"
	ok
	return "no"

