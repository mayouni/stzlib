# The court of this project. %PROJECT% is the learner's folder; it prints what it found.
cP = "%PROJECT%"
acF = StzEngineDirListFiles(cP)
acEd = []
for i = 1 to len(acF)
	if StzLeft(acF[i], 8) = "chapter." and StzRight(acF[i], 3) = ".md" and acF[i] != "chapter.en.md"
		acEd + acF[i]
	ok
next
if fexists(cP + "/chapter.en.md") and len(acEd) >= 1
	oEn = StzChapterQ(cP + "/chapter.en.md", "en")
	oEn.Run("")
	oOt = StzChapterQ(cP + "/" + acEd[1], "xx")
	oOt.Run("")
	bSame = oEn.NumberOfCells() = oOt.NumberOfCells()
	if bSame
		for j = 1 to oEn.NumberOfCells()
			if @@(oEn.CellPromises(j)) != @@(oOt.CellPromises(j))
				bSame = 0
			ok
		next
	ok
	? "two languages: yes"
	? "cells three or more: " + yn(oEn.NumberOfCells() >= 3 and oOt.NumberOfCells() >= 3)
	? "every promise kept in both: " + yn(oEn.AllPromisesKept() and oOt.AllPromisesKept())
	? "same promises: " + yn(bSame)
else
	? "two languages: no"
ok
func yn(b)
	if b
		return "yes"
	ok
	return "no"

