load "../../stzBase.ring"

# RX4 -- the render benchmark, ONE process of it. See BENCH_METHOD.md beside
# the plan for the method; this file only measures and prints.
#
#   ring bench_render.ring [iterations]      default 30
#
# It prints one line per fact, machine-readable, and nothing else:
#   OUT   <name> <bytes> <sha256>            the canonical output, as bytes
#   TIME  <name> <n> <p50_ms> <p95_ms> <worst_ms>
#   RSS   <label> <bytes>                    the process's resident set
#
# THE THREE CANONICAL OUTPUTS, each timed on the work the library does to
# produce it and not on building its inputs:
#   table200  a 200-row, 5-column table through stzHtmlBuilder, construction
#             and Build() together
#   panel     the .panel document test/gui/showcase.panel through
#             stzUiDocument.ToHtml(), the document already parsed and judged
#   chapter   ONE education chapter in English through stzEduReader (an
#             AddChapter and Html()), the chapter already run
# The clock is the engine's monotonic one (StzEngineWatchTimestampNs), never
# wall time. Memory is the engine's resident-set reading (StzEnginePerfMemRss).

nIter = 30
if len(sysargv) > 0
	nIterArg = 0 + sysargv[len(sysargv)]
	if nIterArg >= 3
		nIter = nIterArg
	ok
ok

BenchMain()

func BenchMain()
	? "RSS after-load " + StzEnginePerfMemRss()

	# ---- inputs, built once and never timed ---------------------------------
	cPanelSrc = read("../gui/showcase.panel")
	oPanel = new stzUiDocument(cPanelSrc)
	if NOT oPanel.IsClean()
		? "ERR the showcase panel is not clean"
		shutdown(2)
	ok
	aRows = BenchRows()
	oP = StzProgramQ("../../education/program")
	oC = oP.CourseQ("elementary-introduction")
	aCh = oC.RunChapterInQ("find-then-apply", [ "en" ])
	? "RSS after-inputs " + StzEnginePerfMemRss()

	# ---- the timed loops ------------------------------------------------------
	aT1 = []
	aT2 = []
	aT3 = []
	cO1 = ""
	cO2 = ""
	cO3 = ""
	for i = 1 to nIter
		nS = StzEngineWatchTimestampNs()
		cO1 = BenchTable(aRows)
		aT1 + ((StzEngineWatchTimestampNs() - nS) / 1000000)

		nS = StzEngineWatchTimestampNs()
		cO2 = oPanel.ToHtml()
		aT2 + ((StzEngineWatchTimestampNs() - nS) / 1000000)

		nS = StzEngineWatchTimestampNs()
		oRd = new stzEduReader(oC)
		oRd.AddChapter(aCh[1])
		cO3 = oRd.Html()
		aT3 + ((StzEngineWatchTimestampNs() - nS) / 1000000)

		if i = 1
			? "OUT table200 " + len(cO1) + " " + StzEngineCryptoSha256(cO1)
			? "OUT panel " + len(cO2) + " " + StzEngineCryptoSha256(cO2)
			? "OUT chapter " + len(cO3) + " " + StzEngineCryptoSha256(cO3)
		else
			# every iteration must be the first one's bytes: parity inside the process
			if StzEngineCryptoSha256(cO1) != $cFirst1 or StzEngineCryptoSha256(cO2) != $cFirst2 or
			   StzEngineCryptoSha256(cO3) != $cFirst3
				? "ERR iteration " + i + " differs from iteration 1"
				shutdown(1)
			ok
		ok
		if i = 1
			$cFirst1 = StzEngineCryptoSha256(cO1)
			$cFirst2 = StzEngineCryptoSha256(cO2)
			$cFirst3 = StzEngineCryptoSha256(cO3)
		ok
	next
	BenchReport("table200", aT1)
	BenchReport("panel", aT2)
	BenchReport("chapter", aT3)
	? "RSS after-loops " + StzEnginePerfMemRss()

# 200 rows of 5 cells, deterministic, with characters the escaper must handle
func BenchRows()
	aRows = []
	for i = 1 to 200
		aRow = []
		aRow + ("" + i)
		aRow + ("Item " + i + " & co <" + (i % 7) + ">")
		aRow + ("" + (i * 37 % 1000) + "." + (i % 100))
		aRow + ("say " + char(34) + "hi" + char(34) + " #" + i)
		aRow + ("row " + i + " of 200")
		aRows + aRow
	next
	return aRows

func BenchTable(aRows)
	oB = new stzHtmlBuilder()
	oT = oB.CreateNode("table")
	oB.AppendToCurrent(oT)
	oB.GoToLastChild()
	oHead = oB.CreateNode("tr")
	oB.AppendToCurrent(oHead)
	oB.GoToLastChild()
	for cH in [ "id", "name", "value", "note", "tag" ]
		oTh = oB.CreateNode("th")
		oTh.SetText(cH)
		oB.AppendToCurrent(oTh)
	next
	oB.GoUp()
	nRows = len(aRows)
	for i = 1 to nRows
		oTr = oB.CreateNode("tr")
		for j = 1 to 5
			oTd = oB.CreateNode("td")
			oTd.SetText(aRows[i][j])
			oTr.AppendChild(oTd)
		next
		oB.AppendToCurrent(oTr)
	next
	oB.GoToRoot()
	return oB.Build()

# p50, p95 and worst of a list of milliseconds, nearest-rank on the sorted list
func BenchReport(cName, aMs)
	aS = sort(aMs)
	n = len(aS)
	nP50 = aS[ceil(n * 0.50)]
	nP95 = aS[ceil(n * 0.95)]
	? "TIME " + cName + " " + n + " " + BenchFmt(nP50) + " " + BenchFmt(nP95) + " " + BenchFmt(aS[n])

func BenchFmt(nMs)
	return "" + (floor(nMs * 100 + 0.5) / 100)
