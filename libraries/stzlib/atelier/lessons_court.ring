load "../base/stzBase.ring"
load "atelierClient.ring"

# THE LESSONS' COURT, measured: every written English chapter of the Learning System judged
# twice, by the education plane's own runner (stzChapter.Run, a fresh process per chapter)
# and by a running Atelier, cell by cell. A maintainer's instrument, not a guard: one heavy
# job (about a minute warm), never beside another. From this folder, with an Atelier up:
#     rnxc lessons_court.ring 8650
# Prints one line per chapter, every cell where the two disagree, and the totals. Measured
# 2026-11-06 at B3: 199 cells, 196 agree, 3 unperceived (they draw with Show()), 0 disagree.
nPort = 8650
if len(sysargv) >= 3  nPort = 0 + sysargv[len(sysargv)]  ok
oProg = StzProgramQ(currentdir() + "/../base/education/program")
acCourses = [ "elementary-introduction", "math" ]
nCells = 0  nAgree = 0  nDis = 0  nUnseen = 0
for c = 1 to len(acCourses)
	oCourse = oProg.CourseQ(acCourses[c])
	acCh = oCourse.ChapterIds()
	for i = 1 to len(acCh)
		if oCourse.ChapterFile(acCh[i], "en") = ""  loop  ok
		oChap = oCourse.ChapterQ(acCh[i], "en")
		nT = clock()
		oChap.Run(oCourse.WorldFileOf(acCh[i]))
		nEdu = (clock() - nT) / clockspersecond()
		acCells = oChap.Cells()
		cBody = '{"course":' + _AtelierJsonStr(acCourses[c]) + ',"chapter":' + _AtelierJsonStr(acCh[i]) + ',"lang":"en","cells":['
		for k = 1 to len(acCells)
			if k > 1  cBody += ","  ok
			cBody += _AtelierJsonStr(acCells[k])
		next
		cBody += "]}"
		oH = new stzHttpClient()
		oH.SetTimeout(300)
		nT = clock()
		oH.Post("http://127.0.0.1:" + nPort + "/atelier/lesson/run", cBody)
		nAt = (clock() - nT) / clockspersecond()
		if oH.ResponseCode() != 200
			? acCourses[c] + "/" + acCh[i] + ": the Atelier answered " + oH.ResponseCode() + " " + left(oH.ResponseBody(), 200)
			loop
		ok
		aR = StzJsonToList(oH.ResponseBody())
		cDis = ""
		for k = 1 to len(acCells)
			nCells++
			nEduKept = oChap.CellKept(k)
			nAtKept = aR[:verdicts][k][:kept]
			if nEduKept = nAtKept
				nAgree++
			but nAtKept = 2
				nUnseen++
				cDis += "    cell " + k + ": unperceived by the Atelier (it prints by itself), education " + nEduKept + char(10)
			else
				nDis++
				cDis += "    cell " + k + ": education " + nEduKept + " (" + left(oChap.CellError(k), 80) + "), Atelier " + nAtKept + " (" + left(aR[:verdicts][k][:error], 80) + ")" + char(10)
				cDis += "      education printed: " + left(substr(oChap.CellOutput(k), char(10), " / "), 160) + char(10)
			ok
		next
		? acCourses[c] + "/" + acCh[i] + ": " + len(acCells) + " cells, education " + _AtelierNum(nEdu) + " s, Atelier " + _AtelierNum(nAt) + " s (" + aR[:end] + ")"
		if cDis != ""  ? cDis  ok
	next
next
? "CELLS " + nCells + ", AGREE " + nAgree + ", UNPERCEIVED " + nUnseen + ", DISAGREE " + nDis
