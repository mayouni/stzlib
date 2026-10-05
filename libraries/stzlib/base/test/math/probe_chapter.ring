# PROBE M3 -- run one chapter file through the education plane's own runner
# (stzChapter: every cell in ONE fresh process, promises matched) and print
# what each cell printed, so the promises are written from a RUN.
#     ring probe_chapter.ring <chapter file> [world file]
load "../../stzBase.ring"
cFile = sysargv[3]
cWorld = ""
if len(sysargv) >= 4  cWorld = sysargv[4]  ok
oCh = StzChapterQ(cFile, "en")
? "title: " + oCh.Title() + " | cells " + oCh.NumberOfCells() + " | promises " + oCh.NumberOfPromises() + " | exercises " + @@(oCh.ExerciseIds()) + " | stored outputs " + oCh.NumberOfStoredOutputs()
t0 = clock()
oCh.Run(cWorld)
? "ran in " + ((clock() - t0) / clockspersecond()) + " s; all ran " + oCh.AllCellsRan() + ", all kept " + oCh.AllPromisesKept()
for i = 1 to oCh.NumberOfCells()
	cK = "kept"
	if oCh.CellKept(i) = 0  cK = "BROKEN"  but oCh.CellKept(i) = -1  cK = "(no promise)"  ok
	? "--- cell " + i + " " + cK
	if oCh.CellError(i) != ""  ? "    ERROR: " + oCh.CellError(i)  ok
	aL = StzSplit(ring_trim(oCh.CellOutput(i)), char(10))
	for k = 1 to len(aL)  ? "    | " + aL[k]  next
next
? "recap: " + oCh.RecapAchieved()
? "names taught: " + @@(oCh.CalledNames())
