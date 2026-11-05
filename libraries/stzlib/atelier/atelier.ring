# THE SOFTANZA ATELIER -- the library's own assertions, run live, in one program.
#
# One resident program on Ring++ holds Softanza's library. A check -- one Then(...)
# of base/test, harvested into checks.json -- is code that defines `func Run cInput`
# and returns AtelierThen(actual, expected): the Atelier admits it into the live
# program, calls it, releases it, and answers. Code typed in the page runs the same
# way. The program after a request is the program before it.
#
#     rnxc resident atelier.ring                     from this folder; then http://127.0.0.1:8650/atelier
#     rnxc resident my_settings.ring atelier.ring    with a settings file admitted first:
#         $aAtelierConfig = [ :port = 8650, :library = "<folder holding stzLib.ring>" ]
#     STZ_ATELIER_PORT, STZ_ATELIER_LIBRARY          the same settings, from the environment
#
# The page answers at once; the library is admitted in the background (admitstart)
# and installed between two requests, so the first seconds say "compiling". Only
# released verbs of Ring++ are used: rpp_http_listen / next / method / path / query
# / body / reply, admitcode / releasecode, admitstart / admitstate / admitfinish.
# The natives bind 127.0.0.1 and nothing here can be told otherwise: a run route
# admits any code, and Softanza code can read files and start processes.
#
# ROUTES
#   GET  /atelier            the page (GET / too); /atelier/coverage and /atelier/playground
#                            are the same page opened on its other two sections, and
#                            /atelier/check?id=<id> is one check on its own (?embed=1 drops the chrome)
#   GET  /atelier/i18n       i18n.json, the page's strings in every language it speaks
#   GET  /atelier/checks     checks.json
#   GET  /atelier/results    results.json, the last recording (or null)
#   GET  /atelier/verdicts   verdicts.json, Ring's answers (or null)
#   GET  /atelier/state      JSON: where the library stands, what judges it, the counts
#   POST /atelier/run?input  the body defines `func Run cInput`: 200 and what Run
#                            returned; 500 and its error; 422 when it could not be
#                            admitted, or released (code that defines a class or a
#                            lambda stays, and says so); 503 while the library compiles
#   POST /atelier/tour       the body is a FOLDER on its first line and a whole narrated
#                            test file after it (its loads of the library dropped by the
#                            client, see atelierClient.ring): the Atelier moves to that
#                            folder, admits the file whole -- its top level runs where
#                            admitcode stands, its Scenario/Then calls land on the
#                            recording verbs below -- releases it, moves back, and answers
#                            200 with one header line
#                              end<TAB>finished|broke|not-started<TAB>ms<TAB>released|kept: why<TAB>error
#                            followed by the trail: the very lines base/test/_narrated.ring
#                            would have printed, so testoor's judge reads them unchanged
#   GET  /atelier/tours      tours.json, the last sweep of whole files (or null)
#   POST /atelier/cell       the body is a CELL: code the reader wrote, run top to bottom as
#                            one admission and released. Every `?` line is captured with its
#                            value's FACE (text, list, table, drawing, image, object), and every
#                            `#-->` promise under it judged by testoor's own matcher. Answers
#                            JSON: how the cell ended, its time, and each line seen with its
#                            values, its promise and the promise's state (B0 of the workbench)
#   POST /atelier/notebook   B2: {"run": k, "cells": [{"title", "code"}]} -- cells 1 to k run as ONE
#                            narrated file, top to bottom, so a cell sees the names the cells above
#                            it made; definitions (func, def, class) are moved after every cell's
#                            statements, as Ring requires. Answers the cell JSON, plus "map": the
#                            cell and the cell's own line of every line of the composed file
#   POST /atelier/notebook/save   the cells as a NARRATED TEST FILE: one Scenario per cell, Summary(),
#                            then each cell's definitions under a marker; testoor's reader reads it
#   POST /atelier/notebook/open   such a file, back into cells
#   POST /atelier/stop       answers, then the loop ends
#
# WHAT JUDGES A CHECK is named in /atelier/state and on the page: the library's
# commit (an install's PACKAGE.txt, or the checkout's HEAD), the rnxc build, and
# the engine -- the library's own build when it has one, else the package's, built
# for the library commit the package names. A count without its build is not quoted.
#
# Plan and law: SOFTANZA_ATELIER_PLAN.md.

$cAtelierDir = AtelierOwnFolder()
$cAtelierLibrary = AtelierSetting("library", "STZ_ATELIER_LIBRARY", AtelierParentOf($cAtelierDir))
$nAtelierPort = 0 + AtelierSetting("port", "STZ_ATELIER_PORT", "8650")

# where the library stands: compiling | admitted | refused, and why when refused
$cAtelierState = "compiling"
$cAtelierWhy = ""
$nAtelierStartedAt = AtelierSecondOfDay()
$nAtelierLibrarySeconds = 0
$nAtelierServed = 0
$nAtelierRuns = 0
$nAtelierRefused = 0
$nAtelierTours = 0

# what a cell's `?` lines saw while it ran: [ [ see number, printed text, face ] ]
$aAtelierSeen = []
# B1, the process: each step of an unfolded chain [ see, pass, step, face, ns ], and
# each state of a scene's object after a line [ scene, line, face ]
$aAtelierSteps = []
$aAtelierStates = []
# B2: what a cell's Then(...) lines judged: [ see, kept (1 or 0), the expected value as @@ shows it ]
$aAtelierThens = []

# the trail of a whole file admitted as a tour, and the tallies the narrated
# helper keeps under the names a test may read
$cAtelierTrail = ""
$_zst_total = 0
$_zst_pass = 0
$_zst_fail = 0
$_zst_scen_pass = 0
$_zst_scen_fail = 0
$_zst_scen_title = ""

if NOT fexists($cAtelierLibrary + "/stzLib.ring")
	? "atelier: no stzLib.ring in " + $cAtelierLibrary + " -- set STZ_ATELIER_LIBRARY, or :library in a settings file"
	bye
ok
if NOT fexists($cAtelierDir + "/atelier.html")
	? "atelier: no atelier.html beside atelier.ring in " + $cAtelierDir
	bye
ok

# the library compiles against the current directory, so move there first
# (chdir waits for a compile under way; here none is)
chdir($cAtelierLibrary)
admitstart("admitcode", "softanza", 'load "stzLib.ring"' + char(10))

if rpp_http_listen($nAtelierPort)
	? "atelier: http://127.0.0.1:" + $nAtelierPort + "/atelier -- the library (" + $cAtelierLibrary + ") is compiling in the background"
	AtelierServe()
	? "atelier: stopped after " + $nAtelierServed + " request(s), " + $nAtelierRuns + " run(s) released, " + $nAtelierRefused + " refused"
else
	? "atelier: port " + $nAtelierPort + " is not ours"
ok

#--- the loop --------------------------------------------------------------

func AtelierServe
	while 1
		# while the library compiles the wait is short, so a compile that ends
		# while nobody asks is installed within about 10 ms all the same
		if $cAtelierState = "compiling"
			nGot = rpp_http_next(10)
		else
			nGot = rpp_http_next()
		ok
		if nGot = 0
			exit
		ok
		AtelierAdvance()
		if nGot < 0
			loop
		ok
		$nAtelierServed++
		cMethod = rpp_http_method()
		cPath = rpp_http_path()
		if cMethod = "GET" and (cPath = "/atelier" or cPath = "/" or cPath = "/atelier/" or cPath = "/atelier/coverage" or cPath = "/atelier/playground" or cPath = "/atelier/check" or cPath = "/atelier/library")
			# one page, three addresses: the menu is real links and the back button holds
			rpp_http_reply(200, "text/html; charset=utf-8", read($cAtelierDir + "/atelier.html"))
		but cMethod = "GET" and cPath = "/atelier/i18n"
			rpp_http_reply(200, "application/json; charset=utf-8", AtelierJsonFile("i18n.json"))
		but cMethod = "GET" and cPath = "/atelier/checks"
			rpp_http_reply(200, "application/json; charset=utf-8", AtelierJsonFile("checks.json"))
		but cMethod = "GET" and cPath = "/atelier/results"
			rpp_http_reply(200, "application/json; charset=utf-8", AtelierJsonFile("results.json"))
		but cMethod = "GET" and cPath = "/atelier/verdicts"
			rpp_http_reply(200, "application/json; charset=utf-8", AtelierJsonFile("verdicts.json"))
		but cMethod = "GET" and cPath = "/atelier/tours"
			rpp_http_reply(200, "application/json; charset=utf-8", AtelierJsonFile("tours.json"))
		but cMethod = "POST" and cPath = "/atelier/tour"
			AtelierTourOnce(rpp_http_body())
		but cMethod = "POST" and cPath = "/atelier/cell"
			AtelierCellOnce(rpp_http_body())
		but cMethod = "POST" and cPath = "/atelier/notebook"
			AtelierNotebookOnce(rpp_http_body())
		but cMethod = "POST" and cPath = "/atelier/notebook/save"
			rpp_http_reply(200, "text/plain; charset=utf-8", AtelierNotebookSave(rpp_http_body()))
		but cMethod = "POST" and cPath = "/atelier/notebook/open"
			rpp_http_reply(200, "application/json; charset=utf-8", AtelierNotebookOpen(rpp_http_body()))
		but cMethod = "GET" and cPath = "/atelier/state"
			rpp_http_reply(200, "application/json; charset=utf-8", AtelierStateJson())
		but cMethod = "POST" and cPath = "/atelier/run"
			AtelierRunOnce(rpp_http_body(), rpp_http_query())
		but cMethod = "POST" and cPath = "/atelier/stop"
			rpp_http_reply(200, "text/plain", "stopping")
			AtelierRemovePid()
			exit
		else
			rpp_http_reply(404, "text/plain", "no route for " + cMethod + " " + cPath)
		ok
	end

# between two requests: the library's compile, once over, is installed
func AtelierAdvance
	if $cAtelierState != "compiling"
		return
	ok
	if admitstate() != "compiled"
		return
	ok
	try
		admitfinish()
		$cAtelierState = "admitted"
		AtelierWritePid()
	catch
		$cAtelierState = "refused"
		$cAtelierWhy = cCatchError
	done
	$nAtelierLibrarySeconds = AtelierSecondOfDay() - $nAtelierStartedAt

# code that comes with a request and leaves with it: admitted, run, released.
# The release comes before the reply, so a refusal to release is the answer;
# what Run returned outlives the code that made it
func AtelierRunOnce cSource, cInput
	if $cAtelierState != "admitted"
		rpp_http_reply(503, "text/plain", "the library is " + $cAtelierState + " " + $cAtelierWhy)
		return
	ok
	try
		admitcode("check", cSource)
	catch
		$nAtelierRefused++
		rpp_http_reply(422, "text/plain", cCatchError)
		return
	done
	nStatus = 200
	cOut = ""
	try
		cOut = "" + Run(cInput)
	catch
		nStatus = 500
		cOut = cCatchError
	done
	try
		releasecode("check")
		$nAtelierRuns++
	catch
		nStatus = 422
		cOut = cCatchError
	done
	rpp_http_reply(nStatus, "text/plain; charset=utf-8", cOut)

# a whole test file admitted as one tour: its top level runs inside admitcode,
# in the file's own folder (a test reads its data relative to itself), and
# what its Scenario/Then calls would have printed is the trail answered. A
# runtime error stops the top level and is the tour's ending (broke); a file
# that does not compile never started; a file that defines a class cannot be
# released and stays (kept), so it runs once per server life
func AtelierTourOnce cBody
	if $cAtelierState != "admitted"
		rpp_http_reply(503, "text/plain", "the library is " + $cAtelierState + " " + $cAtelierWhy)
		return
	ok
	nNl = substr(cBody, char(10))
	cFolder = ""
	cSource = cBody
	if nNl > 0
		cFolder = trim(substr(left(cBody, nNl - 1), char(13), ""))
		cSource = substr(cBody, nNl + 1)
	ok
	$cAtelierTrail = ""
	$_zst_total = 0  $_zst_pass = 0  $_zst_fail = 0  $_zst_scen_pass = 0  $_zst_scen_fail = 0  $_zst_scen_title = ""
	if cFolder != ""
		chdir(cFolder)
	ok
	nT0 = clock()
	cEnd = "finished"
	cErr = ""
	bAdmitted = 1
	try
		admitcode("tour", cSource)
	catch
		cErr = substr(substr(cCatchError, char(13), ""), char(10), " ")
		if substr(cErr, "not admitted") > 0
			cEnd = "not-started"
			bAdmitted = 0
		but substr(cErr, "STOPPED!") > 0
			# pf() ends a test by raising its banner: the tour finished, timed
			cEnd = "finished-timed"
			cErr = ""
		else
			cEnd = "broke"
		ok
	done
	nMs = floor((clock() - nT0) * 1000 / clockspersecond())
	cRel = "released"
	if bAdmitted
		try
			releasecode("tour")
			$nAtelierTours++
		catch
			cRel = "kept: " + substr(substr(cCatchError, char(13), ""), char(10), " ")
		done
	else
		cRel = "nothing to release"
	ok
	chdir($cAtelierLibrary)
	cHead = "end" + char(9) + cEnd + char(9) + nMs + char(9) + cRel + char(9) + cErr
	rpp_http_reply(200, "text/plain; charset=utf-8", cHead + char(10) + $cAtelierTrail)

#--- a cell: the reader's code, its `?` lines seen, its promises judged ------
#
# The cell is rewritten line by line before it is admitted: a `?` line becomes
# AtelierSee(<n>, <expression>), so its value comes to the Atelier instead of
# going to the server's stdout, where nobody reads it. A `#-->` promise -- on the
# `?` line itself or on the lines under it, as the library's own files write
# them -- is kept beside its line and judged after the run with testoor's
# matcher (_TravPromiseAt), the function that judges the library's promises:
# one court, never a second. What a method prints on its own (not through `?`)
# still goes to the server's stdout and is not captured: the page says so.

func AtelierCellOnce cSource
	if $cAtelierState != "admitted"
		rpp_http_reply(503, "text/plain", "the library is " + $cAtelierState + " " + $cAtelierWhy)
		return
	ok
	aPlan = AtelierCellPlan(cSource)
	aRun = AtelierRunPlan(aPlan)
	rpp_http_reply(200, "application/json; charset=utf-8", AtelierCellJson(aPlan[2], aRun[1], aRun[2], aRun[3], aRun[4], aPlan[3]))

# a planned cell (or a composed notebook) admitted, run and released: [ end, why, release, ms ]
func AtelierRunPlan aPlan
	$aAtelierSeen = []
	$aAtelierSteps = []
	$aAtelierStates = []
	$aAtelierThens = []
	nT0 = clock()
	cEnd = "finished"
	cErr = ""
	bAdmitted = 1
	try
		admitcode("cell", aPlan[1])
	catch
		cErr = substr(substr(cCatchError, char(13), ""), char(10), " ")
		if substr(cErr, "not admitted") > 0
			cEnd = "not-started"
			bAdmitted = 0
			if substr(cErr, "is already defined") > 0 and substr(lower(cErr), "class") > 0
				cErr += " -- a class a cell defined stays in the live program (Ring++ cannot release a class); restart the Atelier to define it again"
			ok
		else
			cEnd = "broke"
		ok
	done
	nMs = (clock() - nT0) * 1000 / clockspersecond()
	cRel = "released"
	if bAdmitted
		try
			releasecode("cell")
		catch
			cRel = "kept: " + substr(substr(cCatchError, char(13), ""), char(10), " ")
		done
	else
		cRel = "nothing to release"
	ok
	return [ cEnd, cErr, cRel, nMs ]

#--- B2, the notebook: many cells, one file ----------------------------------
#
# A notebook IS a narrated test file: running cell k runs cells 1 to k as one admission,
# top to bottom, so every name a cell reads is the one the cells above made, exactly as a
# file read once would make it. Nothing is kept between two runs: a run is the file from
# its first line. Ring ends a function where the next definition begins, so a cell's
# definitions (from its first line opening with func, def or class) are moved after every
# cell's statements; the map says, for each line of the composed file, which cell and
# which of that cell's lines it came from.

func AtelierNotebookOnce cBody
	if $cAtelierState != "admitted"
		rpp_http_reply(503, "text/plain", "the library is " + $cAtelierState + " " + $cAtelierWhy)
		return
	ok
	aIn = StzJsonToList(cBody)
	aCells = AtelierNotebookCells(aIn)
	nRun = len(aCells)
	if isList(aIn) and HasKey(aIn, :run) and isNumber(aIn[:run]) and aIn[:run] >= 1 and aIn[:run] < nRun
		nRun = aIn[:run]
	ok
	aComp = AtelierNotebookCompose(aCells, nRun)
	aPlan = AtelierCellPlan(aComp[1])
	aRun = AtelierRunPlan(aPlan)
	cJ = AtelierCellJson(aPlan[2], aRun[1], aRun[2], aRun[3], aRun[4], aPlan[3])
	cMap = ',"ran":' + nRun + ',"map":['
	aMap = aComp[2]
	for i = 1 to len(aMap)
		if i > 1
			cMap += ","
		ok
		cMap += "[" + aMap[i][1] + "," + aMap[i][2] + "]"
	next
	cMap += "]}"
	rpp_http_reply(200, "application/json; charset=utf-8", left(cJ, len(cJ) - 1) + cMap)

# the cells of a request: [ [ :title, :code ] ]
func AtelierNotebookCells aIn
	aOut = []
	if NOT (isList(aIn) and HasKey(aIn, :cells))
		return aOut
	ok
	aC = aIn[:cells]
	for i = 1 to len(aC)
		cTitle = ""
		cCode = ""
		if isList(aC[i])
			if HasKey(aC[i], :title)
				cTitle = "" + aC[i][:title]
			ok
			if HasKey(aC[i], :code)
				cCode = "" + aC[i][:code]
			ok
		but isString(aC[i])
			cCode = aC[i]
		ok
		aOut + [ :title = cTitle, :code = cCode ]
	next
	return aOut

# [ the composed source, [ [ cell, line ] ] ] -- statements of cells 1..nRun, then their definitions
func AtelierNotebookCompose aCells, nRun
	cSrc = ""
	aMap = []
	aDefs = []
	for i = 1 to nRun
		acL = str2list(substr(aCells[i][:code], char(13), ""))
		nDef = AtelierFirstDefinition(acL)
		nTo = len(acL)
		if nDef > 0
			nTo = nDef - 1
			aDefs + [ i, nDef, acL ]
		ok
		for j = 1 to nTo
			cSrc += acL[j] + char(10)
			aMap + [ i, j ]
		next
	next
	for k = 1 to len(aDefs)
		acL = aDefs[k][3]
		for j = aDefs[k][2] to len(acL)
			cSrc += acL[j] + char(10)
			aMap + [ aDefs[k][1], j ]
		next
	next
	return [ cSrc, aMap ]

# the first line that opens a definition: func, def or class, then a name
func AtelierFirstDefinition acL
	for j = 1 to len(acL)
		cT = lower(trim(acL[j]))
		if left(cT, 5) = "func " or left(cT, 4) = "def " or left(cT, 6) = "class "
			return j
		ok
	next
	return 0

# the notebook as a narrated test file, which the library's own runners can read and run
func AtelierNotebookSave cBody
	aCells = AtelierNotebookCells(StzJsonToList(cBody))
	cOut = "# An Atelier notebook: " + len(aCells) + " cell(s), saved " + date() + " " + time() + "." + char(10)
	cOut += "# Each cell is a Scenario; each ? line with its #--> promise, and each Then(...), is a claim." + char(10)
	cOut += "# Run it from a folder of base/test, or open it again in the Atelier." + char(10)
	cOut += char(10) + 'load "../../stzBase.ring"' + char(10) + 'load "../_narrated.ring"' + char(10)
	aDefs = []
	for i = 1 to len(aCells)
		cTitle = aCells[i][:title]
		if trim(cTitle) = ""
			cTitle = "Cell " + i
		ok
		# a Ring string has three quote marks: the title keeps its own, and is wrapped in one it does not use
		cTitle = substr(cTitle, char(10), " ")
		cQ = '"'
		if substr(cTitle, '"') > 0
			cQ = "'"
			if substr(cTitle, "'") > 0
				cQ = "`"
				if substr(cTitle, "`") > 0
					cQ = '"'
					cTitle = substr(cTitle, '"', "'")
				ok
			ok
		ok
		cOut += char(10) + "Scenario(" + cQ + cTitle + cQ + ")" + char(10)
		acL = str2list(substr(aCells[i][:code], char(13), ""))
		nDef = AtelierFirstDefinition(acL)
		nTo = len(acL)
		if nDef > 0
			nTo = nDef - 1
			aDefs + [ i, nDef, acL ]
		ok
		for j = 1 to nTo
			cOut += acL[j] + char(10)
		next
	next
	cOut += char(10) + "Summary()" + char(10)
	for k = 1 to len(aDefs)
		cOut += char(10) + "# definitions of cell " + aDefs[k][1] + char(10)
		acL = aDefs[k][3]
		for j = aDefs[k][2] to len(acL)
			cOut += acL[j] + char(10)
		next
	next
	return cOut

# a narrated test file back into cells: one cell per Scenario, its definitions returned to it
func AtelierNotebookOpen cText
	acL = str2list(substr("" + cText, char(13), ""))
	aCells = []
	nCur = 0
	bDefs = 0
	for i = 1 to len(acL)
		cLine = acL[i]
		cT = trim(cLine)
		cLow = lower(cT)
		# the saver writes one blank line before each Scenario, before Summary() and before
		# each block of definitions: that line is the file's, not the cell's, so it goes
		bMarker = (left(cLow, 9) = "scenario(" and NOT bDefs) or cLow = "summary()" or left(cLow, 22) = "# definitions of cell "
		if bMarker and nCur > 0 and right(aCells[nCur][:code], 2) = char(10) + char(10)
			aCells[nCur][:code] = left(aCells[nCur][:code], len(aCells[nCur][:code]) - 1)
		ok
		if left(cLow, 5) = "load " or cLow = "summary()" or cLow = "pf()"
			loop
		ok
		if left(cLow, 22) = "# definitions of cell "
			nCur = 0 + trim(substr(cT, 23))
			if nCur < 1 or nCur > len(aCells)
				nCur = len(aCells)
			ok
			bDefs = 1
			loop
		ok
		if left(cLow, 9) = "scenario(" and NOT bDefs
			cTitle = trim(substr(cT, 10))
			if right(cTitle, 1) = ")"
				cTitle = trim(left(cTitle, len(cTitle) - 1))
			ok
			cTitle = AtelierUnquote(cTitle)
			aCells + [ :title = cTitle, :code = "" ]
			nCur = len(aCells)
			loop
		ok
		if nCur = 0
			# the file's header: its comments go, any code before the first Scenario is a cell
			if cT = "" or left(cT, 1) = "#"
				loop
			ok
			aCells + [ :title = "", :code = "" ]
			nCur = len(aCells)
		ok
		aCells[nCur][:code] = aCells[nCur][:code] + cLine + char(10)
	next
	cJ = '{"cells":['
	for i = 1 to len(aCells)
		if i > 1
			cJ += ","
		ok
		cCode = aCells[i][:code]
		while right(cCode, 2) = char(10) + char(10)
			cCode = left(cCode, len(cCode) - 1)
		end
		while left(cCode, 1) = char(10)
			cCode = substr(cCode, 2)
		end
		cJ += '{"title":' + AtelierJsonStr(aCells[i][:title]) + ',"code":' + AtelierJsonStr(cCode) + '}'
	next
	return cJ + "]}"

func AtelierUnquote cS
	c = trim(cS)
	if len(c) >= 2 and (left(c, 1) = '"' or left(c, 1) = "'" or left(c, 1) = "`") and right(c, 1) = left(c, 1)
		return substr(c, 2, len(c) - 2)
	ok
	return c

# [ the rewritten source, [ [ :n, :line, :expr, :promise, :steps, :forms ] ], [ scenes ] ]
#
# B1, THE PROCESS. A `?` line whose expression is a chain -- a root (a name, a call, or
# `new Class(...)`) followed by method calls -- is UNFOLDED: each step is evaluated once,
# into a variable held by ref(), so a chain that changes its object changes it exactly as
# the line written whole does (plain variables would copy the object and detach the chain
# from it: measured, 2026-11-05), and each step's value and its time on the engine's
# monotonic clock are kept. A scene -- a line `name {` -- has its object's state captured
# after the opening and after every complete statement inside it, so a Verb() that changes
# the object and a Verbed() that leaves it alone are seen apart.
func AtelierCellPlan cSource
	acL = str2list(substr("" + cSource, char(13), ""))
	aSees = []
	aScenes = []
	cOut = ""
	# nLines, never nL: Ring is case-insensitive, so nL spells the NL global.
	# Harmless on rnxc, where an assignment in a function makes a local
	# (measured 2026-11-05), but it reads as a write to NL and is not one.
	nLines = len(acL)
	nScene = 0
	cSceneName = ""
	nBraces = 0
	nBrackets = 0
	for i = 1 to nLines
		cLine = acL[i]
		cT = trim(cLine)
		nIndent = len(cLine) - len(AtelierLeftTrimmed(cLine))
		cPad = left(cLine, nIndent)
		bStatement = 0
		# a scene opens: a line that is only `name {`
		if cSceneName = "" and AtelierIsSceneOpening(cT)
			cSceneName = trim(left(cT, len(cT) - 1))
			nScene++
			aScenes + [ :id = nScene, :name = cSceneName, :line = i, :end = 0 ]
			nBraces = 1
			nBrackets = 0
			cOut += cLine + char(10)
			cOut += cPad + "    AtelierState(" + nScene + ", " + i + ", " + cSceneName + ")" + char(10)
			loop
		ok
		# B2: a Then(...) line on one line is a narrated assertion, judged by `=` as the
		# suite judges it: its actual value seen in its face, its expected value shown
		if lower(left(cT, 5)) = "then(" and AtelierBalanced(substr(cT, 5))
			aArgs = AtelierSplitArgs(substr(cT, 6, len(cT) - 6))
			if len(aArgs) = 3 and (left(aArgs[1], 1) = '"' or left(aArgs[1], 1) = "'" or left(aArgs[1], 1) = "`")
				nN = len(aSees) + 1
				cOut += cPad + "AtelierThenSee(" + nN + ", " + aArgs[2] + ", " + aArgs[3] + ")" + char(10)
				aSees + [ :n = nN, :line = i, :expr = AtelierUnquote(aArgs[1]), :promise = "", :steps = [], :forms = [], :kind = "then" ]
				bStatement = 1
			ok
		ok
		if NOT bStatement and left(cT, 1) = "?" and left(cT, 4) != "?-->"
			cExpr = trim(substr(cT, 2))
			cPromise = ""
			nAt = AtelierLastIndexOf(cExpr, "#-->")
			if nAt > 0
				cPromise = trim(substr(cExpr, nAt + 4))
				cExpr = trim(left(cExpr, nAt - 1))
			else
				j = i + 1
				while j <= nLines and trim(acL[j]) = ""
					j++
				end
				if j <= nLines and left(trim(acL[j]), 4) = "#-->"
					cPromise = trim(substr(trim(acL[j]), 5)) + _TourContinuation(acL, j)
				ok
			ok
			if cExpr != ""
				nN = len(aSees) + 1
				aParts = AtelierChainParts(cExpr)
				# `? @@( chain )` -- the house's way to print a list -- is unfolded inside
				cWrap = ""
				if len(aParts) < 2 and left(cExpr, 3) = "@@(" and right(cExpr, 1) = ")" and AtelierBalanced(substr(cExpr, 3))
					aParts = AtelierChainParts(trim(substr(cExpr, 4, len(cExpr) - 4)))
					if len(aParts) >= 2
						cWrap = "@@"
					ok
				ok
				aSteps = []
				aForms = []
				if len(aParts) >= 2
					# the chain unfolded: one variable per step, held by ref() while a
					# method follows it, timed on the monotonic clock
					nK = len(aParts)
					for k = 1 to nK
						cV = "_atv_" + nN + "_" + k + "_"
						if k = 1
							cRhs = aParts[1]
						else
							cRhs = "_atv_" + nN + "_" + (k - 1) + "_" + aParts[k]
						ok
						if k < nK
							cRhs = "ref(" + cRhs + ")"
						ok
						cOut += cPad + "_att_" + nN + "_ = StzEngineWatchTimestampNs()" + char(10)
						cOut += cPad + cV + " = " + cRhs + char(10)
						cOut += cPad + "AtelierStep(" + nN + ", " + k + ", " + cV + ", StzEngineWatchTimestampNs() - _att_" + nN + "_)" + char(10)
						aSteps + aParts[k]
					next
					if cWrap = "@@"
						cOut += cPad + "AtelierSee(" + nN + ", @@(_atv_" + nN + "_" + nK + "_))" + char(10)
					else
						cOut += cPad + "AtelierSee(" + nN + ", _atv_" + nN + "_" + nK + "_)" + char(10)
					ok
					aForms = AtelierForms(aParts, cSource, cWrap)
				else
					cOut += cPad + "AtelierSee(" + nN + ", " + cExpr + ")" + char(10)
				ok
				aSees + [ :n = nN, :line = i, :expr = cExpr, :promise = cPromise, :steps = aSteps, :forms = aForms, :kind = "see" ]
				bStatement = 1
			ok
		ok
		if NOT bStatement
			cOut += cLine + char(10)
		ok
		# inside a scene: count its braces and brackets, capture the state after a
		# complete statement, close the scene on its last brace
		if cSceneName != ""
			aCount = AtelierBracketCount(cT)
			nBraces += aCount[1]
			nBrackets += aCount[2]
			if nBraces <= 0
				aScenes[len(aScenes)][:end] = i
				cSceneName = ""
				loop
			ok
			if nBraces = 1 and nBrackets = 0 and AtelierIsStatement(cT)
				cOut += cPad + "AtelierState(" + nScene + ", " + i + ", " + cSceneName + ")" + char(10)
			ok
		ok
	next
	return [ cOut, aSees, aScenes ]

func AtelierLeftTrimmed cLine
	for i = 1 to len(cLine)
		if cLine[i] != " " and cLine[i] != char(9)
			return substr(cLine, i)
		ok
	next
	return ""

# `name {` alone on its line opens a scene
func AtelierIsSceneOpening cT
	if right(cT, 1) != "{"
		return 0
	ok
	cName = trim(left(cT, len(cT) - 1))
	if cName = ""
		return 0
	ok
	for i = 1 to len(cName)
		c = cName[i]
		if NOT (isalnum(c) or c = "_" or c = "@" or c = "$")
			return 0
		ok
	next
	return 1

# a line after which the object's state is worth capturing: code, complete, and not a
# keyword that opens a block
func AtelierIsStatement cT
	if cT = "" or left(cT, 1) = "#" or left(cT, 2) = "//" or cT = "}"
		return 0
	ok
	if right(cT, 1) = "," or right(cT, 1) = "+"
		return 0
	ok
	cFirst = lower(cT)
	nSp = substr(cFirst, " ")
	if nSp > 0
		cFirst = left(cFirst, nSp - 1)
	ok
	acOpeners = [ "if", "but", "else", "for", "while", "switch", "on", "other", "try", "catch", "func", "def", "class", "return", "loop", "exit" ]
	return find(acOpeners, cFirst) = 0

# [ braces opened minus closed, brackets and parentheses opened minus closed ], outside strings
func AtelierBracketCount cT
	nB = 0
	nP = 0
	cQ = ""
	for i = 1 to len(cT)
		c = cT[i]
		if cQ != ""
			if c = cQ
				cQ = ""
			ok
			loop
		ok
		if c = '"' or c = "'" or c = "`"
			cQ = c
		but c = "#"
			exit
		but c = "{"
			nB++
		but c = "}"
			nB--
		but c = "(" or c = "["
			nP++
		but c = ")" or c = "]"
			nP--
		ok
	next
	return [ nB, nP ]

# a chain's parts: [ root, ".Method(args)", ... ] -- or [] when the expression is not
# exactly a root followed by method calls (an operator outside a call is not a chain)
func AtelierChainParts cExpr
	c = trim("" + cExpr)
	n = len(c)
	aCuts = []
	nDepth = 0
	cQ = ""
	for i = 1 to n
		ch = c[i]
		if cQ != ""
			if ch = cQ
				cQ = ""
			ok
			loop
		ok
		if ch = '"' or ch = "'" or ch = "`"
			cQ = ch
		but ch = "(" or ch = "["
			nDepth++
		but ch = ")" or ch = "]"
			nDepth--
		but ch = "." and nDepth = 0 and i < n
			if isalpha(c[i + 1]) or c[i + 1] = "_"
				aCuts + i
			ok
		ok
	next
	if len(aCuts) = 0
		return []
	ok
	aParts = [ trim(left(c, aCuts[1] - 1)) ]
	for k = 1 to len(aCuts)
		nTo = n
		if k < len(aCuts)
			nTo = aCuts[k + 1] - 1
		ok
		aParts + trim(substr(c, aCuts[k], nTo - aCuts[k] + 1))
	next
	if NOT AtelierIsRoot(aParts[1])
		return []
	ok
	for k = 2 to len(aParts)
		if NOT AtelierIsCallSegment(aParts[k])
			return []
		ok
	next
	return aParts

# the arguments of a call, split at its top-level commas, outside strings and brackets
func AtelierSplitArgs cInner
	aOut = []
	nD = 0
	cQ = ""
	nFrom = 1
	n = len(cInner)
	for i = 1 to n
		ch = cInner[i]
		if cQ != ""
			if ch = cQ
				cQ = ""
			ok
			loop
		ok
		if ch = '"' or ch = "'" or ch = "`"
			cQ = ch
		but ch = "(" or ch = "[" or ch = "{"
			nD++
		but ch = ")" or ch = "]" or ch = "}"
			nD--
		but ch = "," and nD = 0
			aOut + trim(substr(cInner, nFrom, i - nFrom))
			nFrom = i + 1
		ok
	next
	aOut + trim(substr(cInner, nFrom))
	return aOut

# a root: a name, a call, or new Class(...) -- nothing else before the first method
func AtelierIsRoot cR
	c = trim(cR)
	if lower(left(c, 4)) = "new "
		c = trim(substr(c, 5))
	ok
	i = 1
	n = len(c)
	if n = 0 or NOT (isalpha(c[1]) or c[1] = "_" or c[1] = "@" or c[1] = "$")
		return 0
	ok
	while i <= n and (isalnum(c[i]) or c[i] = "_" or c[i] = "@" or c[i] = "$")
		i++
	end
	if i > n
		return 1
	ok
	return c[i] = "(" and right(c, 1) = ")" and AtelierBalanced(substr(c, i))

# a segment: .Name(args), balanced, and nothing after the closing parenthesis
func AtelierIsCallSegment cS
	if left(cS, 1) != "." or right(cS, 1) != ")"
		return 0
	ok
	nOpen = substr(cS, "(")
	if nOpen < 3
		return 0
	ok
	cName = substr(cS, 2, nOpen - 2)
	for i = 1 to len(cName)
		if NOT (isalnum(cName[i]) or cName[i] = "_" or cName[i] = "@")
			return 0
		ok
	next
	return AtelierBalanced(substr(cS, nOpen))

# "(...)" whose first parenthesis closes at its last character, outside strings
func AtelierBalanced cP
	nD = 0
	cQ = ""
	n = len(cP)
	for i = 1 to n
		ch = cP[i]
		if cQ != ""
			if ch = cQ
				cQ = ""
			ok
			loop
		ok
		if ch = '"' or ch = "'" or ch = "`"
			cQ = ch
		but ch = "(" or ch = "["
			nD++
		but ch = ")" or ch = "]"
			nD--
			if nD = 0 and i < n
				return 0
			ok
		ok
	next
	return nD = 0

# the same move written in the other forms, when it has them: every method but the last
# ends in Q (it returns the object, so the chain is one object changed step by step).
# [ [ "scene", code ], [ "classic", code ] ] -- offered to the reader to run, never run here
func AtelierForms aParts, cSource, cWrap
	nK = len(aParts)
	if nK < 3
		return []   # a root and one call: no other form says it differently
	ok
	for k = 2 to nK - 1
		cName = AtelierSegName(aParts[k])
		if upper(right(cName, 1)) != "Q"
			return []
		ok
	next
	cRoot = aParts[1]
	bName = AtelierIsName(cRoot)
	cObj = cRoot
	if NOT bName
		cObj = AtelierFreeName(cSource)
	ok
	cScene = ""
	cClassic = ""
	if NOT bName
		cClassic = cObj + " = " + cRoot + char(10)
	ok
	cScene = cRoot + " {" + char(10)
	for k = 2 to nK
		cSeg = aParts[k]
		cName = AtelierSegName(cSeg)
		cArgs = substr(cSeg, substr(cSeg, "("))
		if k < nK
			cBare = left(cName, len(cName) - 1)
			cScene += "    " + cBare + cArgs + char(10)
			cClassic += cObj + "." + cBare + cArgs + char(10)
		but cWrap = "@@"
			cScene += "    ? @@( " + cName + cArgs + " )" + char(10)
			cClassic += "? @@( " + cObj + "." + cName + cArgs + " )" + char(10)
		else
			cScene += "    ? " + cName + cArgs + char(10)
			cClassic += "? " + cObj + "." + cName + cArgs + char(10)
		ok
	next
	cScene += "}" + char(10)
	return [ [ "scene", cScene ], [ "classic", cClassic ] ]

func AtelierSegName cSeg
	return substr(cSeg, 2, substr(cSeg, "(") - 2)

func AtelierIsName cR
	c = trim(cR)
	if c = ""
		return 0
	ok
	for i = 1 to len(c)
		if NOT (isalnum(c[i]) or c[i] = "_" or c[i] = "@" or c[i] = "$")
			return 0
		ok
	next
	return isalpha(c[1]) or c[1] = "_"

# o1, o2 ... the first not used as a word in the cell
func AtelierFreeName cSource
	cL = lower(cSource)
	for k = 1 to 99
		cName = "o" + k
		if NOT AtelierHasWord(cL, cName)
			return cName
		ok
	next
	return "oForm"

func AtelierHasWord cText, cWord
	nFrom = 1
	while 1
		nAt = substr(substr(cText, nFrom), cWord)
		if nAt = 0
			return 0
		ok
		nAt = nFrom + nAt - 1
		cBefore = " "
		cAfter = " "
		if nAt > 1
			cBefore = cText[nAt - 1]
		ok
		if nAt + len(cWord) <= len(cText)
			cAfter = cText[nAt + len(cWord)]
		ok
		if NOT (isalnum(cBefore) or cBefore = "_") and NOT (isalnum(cAfter) or cAfter = "_")
			return 1
		ok
		nFrom = nAt + 1
	end
	return 0

func AtelierLastIndexOf cText, cSub
	nLast = 0
	nFrom = 1
	while 1
		nAt = substr(substr(cText, nFrom), cSub)
		if nAt = 0
			exit
		ok
		nLast = nFrom + nAt - 1
		nFrom = nLast + 1
	end
	return nLast

# what a `?` line sees: kept in the order it ran, with what `?` would have printed
# and the value's face; a `?` inside a loop is seen once per pass
func AtelierSee nN, vValue
	add($aAtelierSeen, [ nN, AtelierPrinted(vValue), AtelierFace(vValue) ])

# one step of an unfolded chain: its value in a LIGHT face (an intermediate object is
# never asked to draw itself: a step must not cost a render), and its nanoseconds; kept
# for the first pass of a line only
func AtelierStep nN, nK, vValue, nNs
	nPass = 1
	for i = 1 to len($aAtelierSeen)
		if $aAtelierSeen[i][1] = nN
			nPass++
		ok
	next
	if nPass = 1
		add($aAtelierSteps, [ nN, nK, AtelierLightFace(vValue), nNs ])
	ok

# a cell's Then(...): the actual value seen, judged by `=` as base/test/_narrated.ring judges it
func AtelierThenSee nN, xActual, xExpected
	add($aAtelierSeen, [ nN, AtelierPrinted(xActual), AtelierFace(xActual) ])
	nOk = 0
	try
		if xActual = xExpected
			nOk = 1
		ok
	catch
		nOk = 0
	done
	add($aAtelierThens, [ nN, nOk, @@(xExpected) ])

# a scene's object after a line, in a light face
func AtelierState nScene, nLine, oObject
	add($aAtelierStates, [ nScene, nLine, AtelierLightFace(oObject) ])

func AtelierLightFace vValue
	if isString(vValue)
		return [ "text", left(vValue, 400), "" ]
	but isNumber(vValue)
		return [ "text", "" + vValue, "" ]
	but isList(vValue)
		return [ "list", left(@@(vValue), 400), "" + len(vValue) ]
	but isObject(vValue)
		cClass = classname(vValue)
		if ismethod(vValue, "content")
			try
				return [ "object", left(@@(vValue.Content()), 400), cClass ]
			catch
				cAtelierIgnored = cCatchError   # an empty catch leaks a VM stack slot per raise (F-16)
			done
		ok
		return [ "object", cClass, cClass ]
	ok
	return [ "text", "", "" ]

# the text `?` prints: a list one item per line, as Ring prints it
func AtelierPrinted vValue
	if isString(vValue)
		return vValue
	but isNumber(vValue)
		return "" + vValue
	but isList(vValue)
		cOut = ""
		for i = 1 to len(vValue)
			if i > 1
				cOut += char(10)
			ok
			cOut += AtelierPrinted(vValue[i])
		next
		return cOut
	ok
	return ""

# a value in its own face: [ kind, payload, label ]
#   text    a string or a number, as it prints
#   list    the list as @@ shows it; the label says how many items
#   table   a stzTable as the HTML its ToHtml() writes (the page reads it, never inserts it)
#   svg     anything that answers ToSVG(), as the engine draws it; a string that is an SVG too
#   image   a stzImage, as the PNG data URI its ToPngDataURI() answers
#   object  any other object: its Content() as @@ shows it when it has one, else its class
func AtelierFace vValue
	if isString(vValue)
		if lower(left(trim(vValue), 4)) = "<svg" or (lower(left(trim(vValue), 5)) = "<?xml" and substr(lower(vValue), "<svg") > 0)
			return [ "svg", vValue, "" ]
		ok
		return [ "text", vValue, "" ]
	but isNumber(vValue)
		return [ "text", "" + vValue, "" ]
	but isList(vValue)
		return [ "list", @@(vValue), "" + len(vValue) ]
	but isObject(vValue)
		cClass = classname(vValue)
		if ismethod(vValue, "topngdatauri")
			try
				return [ "image", vValue.ToPngDataURI(), cClass ]
			catch
				cAtelierIgnored = cCatchError   # an empty catch leaks a VM stack slot per raise (F-16)
			done
		ok
		if ismethod(vValue, "tosvg")
			cSvg = ""
			try
				cSvg = vValue.ToSVG()
			catch
				try
					cSvg = vValue.ToSVG([])
				catch
					cSvg = ""
				done
			done
			if isString(cSvg) and cSvg != ""
				return [ "svg", cSvg, cClass ]
			ok
		ok
		if substr(cClass, "table") > 0 and ismethod(vValue, "tohtml")
			try
				return [ "table", vValue.ToHtml(), cClass ]
			catch
				cAtelierIgnored = cCatchError   # an empty catch leaks a VM stack slot per raise (F-16)
			done
		ok
		if ismethod(vValue, "content")
			try
				return [ "object", @@(vValue.Content()), cClass ]
			catch
				cAtelierIgnored = cCatchError   # an empty catch leaks a VM stack slot per raise (F-16)
			done
		ok
		return [ "object", cClass, cClass ]
	ok
	return [ "text", "", "" ]

# the cell's answer: how it ended, and each line seen with its values and its
# promise judged -- kept, diverged; a promise whose line never ran is unreached when
# the cell broke or never started, unjudged when it finished without walking it
func AtelierCellJson aSees, cEnd, cErr, cRel, nMs, aScenes
	nKept = 0  nDiv = 0  nUnr = 0  nUnj = 0
	cJ = '{"end":' + AtelierJsonStr(cEnd) + ',"why":' + AtelierJsonStr(cErr) + ',"release":' + AtelierJsonStr(cRel)
	cJ += ',"ms":' + (floor(nMs * 100 + 0.5) / 100) + ',"sees":['
	for i = 1 to len(aSees)
		aS = aSees[i]
		acPrinted = []
		cVals = ""
		for k = 1 to len($aAtelierSeen)
			if $aAtelierSeen[k][1] = aS[:n]
				acPart = str2list($aAtelierSeen[k][2])
				for m = 1 to len(acPart)
					acPrinted + _TravNorm(acPart[m])
				next
				if len($aAtelierSeen[k][2]) = 0
					acPrinted + ""
				ok
				aF = $aAtelierSeen[k][3]
				if cVals != ""
					cVals += ","
				ok
				cVals += '{"kind":' + AtelierJsonStr(aF[1]) + ',"payload":' + AtelierJsonStr(aF[2]) + ',"label":' + AtelierJsonStr(aF[3]) + '}'
			ok
		next
		cState = ""
		cKind = "see"
		if HasKey(aS, :kind)
			cKind = aS[:kind]
		ok
		if cKind = "then"
			aS[:promise] = ""
			for k = 1 to len($aAtelierThens)
				if $aAtelierThens[k][1] = aS[:n]
					aS[:promise] = $aAtelierThens[k][3]
					if $aAtelierThens[k][2] = 1
						cState = "kept"
						nKept++
					else
						cState = "diverged"
						nDiv++
					ok
					exit
				ok
			next
			if cState = ""
				if cEnd = "finished"
					cState = "unjudged"
					nUnj++
				else
					cState = "unreached"
					nUnr++
				ok
			ok
		but aS[:promise] != ""
			if cVals = ""
				if cEnd = "finished"
					cState = "unjudged"
					nUnj++
				else
					cState = "unreached"
					nUnr++
				ok
			but _TravPromiseAt(aS[:promise], acPrinted, 1) > 0
				cState = "kept"
				nKept++
			else
				cState = "diverged"
				nDiv++
			ok
		ok
		if i > 1
			cJ += ","
		ok
		cJ += '{"n":' + aS[:n] + ',"line":' + aS[:line] + ',"kind":' + AtelierJsonStr(cKind) + ',"expr":' + AtelierJsonStr(aS[:expr]) + ',"promise":' + AtelierJsonStr(aS[:promise])
		cJ += ',"state":' + AtelierJsonStr(cState) + ',"values":[' + cVals + ']'
		# the chain unfolded: each step's text, its value, its nanoseconds
		cJ += ',"steps":['
		bFirst = 1
		for k = 1 to len($aAtelierSteps)
			aT = $aAtelierSteps[k]
			if aT[1] = aS[:n]
				if NOT bFirst
					cJ += ","
				ok
				bFirst = 0
				cText = ""
				if aT[2] <= len(aS[:steps])
					cText = aS[:steps][aT[2]]
				ok
				cJ += '{"k":' + aT[2] + ',"text":' + AtelierJsonStr(cText) + ',"kind":' + AtelierJsonStr(aT[3][1]) + ',"payload":' + AtelierJsonStr(aT[3][2]) + ',"label":' + AtelierJsonStr(aT[3][3]) + ',"ns":' + aT[4] + '}'
			ok
		next
		cJ += '],"forms":['
		for k = 1 to len(aS[:forms])
			if k > 1
				cJ += ","
			ok
			cJ += '{"name":' + AtelierJsonStr(aS[:forms][k][1]) + ',"code":' + AtelierJsonStr(aS[:forms][k][2]) + '}'
		next
		cJ += ']}'
	next
	# the scenes unfolded: the object after each line, and whether that line changed it
	cJ += '],"scenes":['
	for i = 1 to len(aScenes)
		if i > 1
			cJ += ","
		ok
		cJ += '{"id":' + aScenes[i][:id] + ',"name":' + AtelierJsonStr(aScenes[i][:name]) + ',"line":' + aScenes[i][:line] + ',"end":' + aScenes[i][:end] + ',"states":['
		cPrev = ""
		bFirst = 1
		for k = 1 to len($aAtelierStates)
			aT = $aAtelierStates[k]
			if aT[1] = aScenes[i][:id]
				nChanged = 0
				if NOT bFirst and aT[3][2] != cPrev
					nChanged = 1
				ok
				if NOT bFirst
					cJ += ","
				ok
				cJ += '{"line":' + aT[2] + ',"kind":' + AtelierJsonStr(aT[3][1]) + ',"payload":' + AtelierJsonStr(aT[3][2]) + ',"label":' + AtelierJsonStr(aT[3][3]) + ',"changed":' + nChanged + '}'
				cPrev = aT[3][2]
				bFirst = 0
			ok
		next
		cJ += ']}'
	next
	cJ += '],"kept":' + nKept + ',"diverged":' + nDiv + ',"unreached":' + nUnr + ',"unjudged":' + nUnj + '}'
	return cJ

#--- the narrated verbs, recording what base/test/_narrated.ring prints -----
# (same lines, same tallies, so a tour reads as the suite reads it and
# testoor's judge pairs the trail with the reader's claims by text)

func Scenario cTitle
	$_zst_scen_title = cTitle
	$_zst_scen_pass = 0
	$_zst_scen_fail = 0
	$cAtelierTrail += char(10) + "SCENARIO: " + cTitle + char(10)

func Given cText
	$cAtelierTrail += "  GIVEN " + cText + char(10)

func When cText
	$cAtelierTrail += "  WHEN  " + cText + char(10)

func Then cText, xActual, xExpected
	if xActual = xExpected
		$cAtelierTrail += "  THEN  " + cText + "  [PASS]" + char(10)
		$_zst_scen_pass++
		$_zst_pass++
	else
		$cAtelierTrail += "  THEN  " + cText + "  [FAIL]" + char(10)
		$cAtelierTrail += "    expected: " + @@(xExpected) + char(10)
		$cAtelierTrail += "    got:      " + @@(xActual) + char(10)
		$_zst_scen_fail++
		$_zst_fail++
	ok
	$_zst_total++

func EndScenario
	$cAtelierTrail += "  -> " + $_zst_scen_pass + " pass, " + $_zst_scen_fail + " fail" + char(10)

func Summary
	$cAtelierTrail += char(10) + "TOTAL: " + $_zst_total + " assertions, " + $_zst_pass + " pass, " + $_zst_fail + " fail" + char(10)
	if $_zst_fail > 0
		$cAtelierTrail += "STATUS: FAILED" + char(10)
	else
		$cAtelierTrail += "STATUS: OK" + char(10)
	ok

# a tour's own `shutdown(n)` or `bye`, rewritten by the client to this: the
# server is not the tour's to end, so the ask is recorded and the tour goes on
func AtelierShutdown nCode
	$cAtelierTrail += "  (shutdown " + nCode + " asked by the tour; the Atelier stays)" + char(10)

#--- what a check and the playground answer with ---------------------------

# a narrated assertion, decided as base/test/_narrated.ring decides it: `=`,
# and @@ to show what was expected and what came
func AtelierThen xActual, xExpected
	if xActual = xExpected
		return "PASS"
	ok
	return "FAIL" + char(10) + @@(xExpected) + char(10) + @@(xActual)

# what the playground shows: a string as it is, anything else as Softanza shows it
func AtelierShow vValue
	if isString(vValue)
		return vValue
	ok
	return @@(vValue)

# the process id, written beside atelier.ring once the library is admitted
# (ProcessId() is the library's), so a client can end an Atelier that no
# longer answers; removed on a stop
func AtelierWritePid
	try
		write($cAtelierDir + "/_atelier_" + $nAtelierPort + ".pid", "" + ProcessId() + char(10))
	catch
		cAtelierIgnored = cCatchError   # an empty catch leaks a VM stack slot per raise (F-16)
	done

func AtelierRemovePid
	cPid = $cAtelierDir + "/_atelier_" + $nAtelierPort + ".pid"
	if fexists(cPid)
		remove(cPid)
	ok

#--- the state, as JSON written by hand (no library is needed for it) --------

func AtelierStateJson
	cEngine = AtelierEngineFacts()
	cJ = "{"
	cJ += '"library":{"state":' + AtelierJsonStr($cAtelierState) + ',"why":' + AtelierJsonStr($cAtelierWhy)
	cJ += ',"folder":' + AtelierJsonStr($cAtelierLibrary) + ',"commit":' + AtelierJsonStr(AtelierLibraryCommit($cAtelierLibrary))
	cJ += ',"seconds":' + $nAtelierLibrarySeconds + '}'
	cJ += ',"rnxc":{"folder":' + AtelierJsonStr(AtelierSlashes(exefolder())) + ',"build":' + AtelierJsonStr(AtelierRnxcBuild()) + '}'
	cJ += ',"engine":' + AtelierJsonStr(cEngine)
	cJ += ',"served":' + $nAtelierServed + ',"runs":' + $nAtelierRuns + ',"refused":' + $nAtelierRefused
	cJ += ',"functions":' + len(functions())
	cJ += ',"port":' + $nAtelierPort
	cJ += "}"
	return cJ

func AtelierJsonFile cName
	cFile = $cAtelierDir + "/" + cName
	if fexists(cFile)
		return read(cFile)
	ok
	return "null"

func AtelierJsonStr cText
	cText = "" + cText
	cText = substr(cText, "\", "\\")
	cText = substr(cText, '"', '\"')
	cText = substr(cText, char(13), "\r")
	cText = substr(cText, char(10), "\n")
	cText = substr(cText, char(9), "\t")
	return '"' + cText + '"'

#--- what judges a check: the library commit, the rnxc build, the engine -----

# an install names its library commit in PACKAGE.txt two folders up; a checkout
# names it in .git (a folder, or for a worktree a file pointing at one)
func AtelierLibraryCommit cLibrary
	cFromPackage = AtelierPackageWord(cLibrary + "/../../PACKAGE.txt", "stzlib")
	if cFromPackage != ""
		return cFromPackage + " (installed)"
	ok
	cFromGit = AtelierGitHead(cLibrary + "/../..")
	if cFromGit != ""
		return cFromGit
	ok
	return "unknown"

func AtelierRnxcBuild
	cBin = AtelierSlashes(exefolder())
	cFromPackage = AtelierPackageWord(cBin + "/../PACKAGE.txt", "ringpp")
	if cFromPackage != ""
		return "ringpp " + cFromPackage + " (installed)"
	ok
	# a checkout's build: zig-out/bin under the checkout's root
	cFromGit = AtelierGitHead(cBin + "/../..")
	if cFromGit != ""
		return "ringpp checkout " + cFromGit + " (build time not read here)"
	ok
	return "unknown"

# the library's own engine when it built one, else the package's, built for the
# library commit the package names -- a newer library may call what it lacks (R3)
func AtelierEngineFacts
	if AtelierEngineAt($cAtelierLibrary + "/engine/zig-out/bin")
		return "the library's own (engine/zig-out/bin)"
	ok
	cBin = AtelierSlashes(exefolder())
	if AtelierEngineAt(cBin + "/../libraries/stzlib/engine/zig-out/bin")
		cFor = AtelierPackageWord(cBin + "/../PACKAGE.txt", "stzlib")
		if cFor = ""
			cFor = "an unnamed library commit"
		ok
		return "the package's, built for stzlib " + cFor
	ok
	return "none found beside the library or the package"

func AtelierEngineAt cFolder
	return fexists(cFolder + "/stz_string.dll") or fexists(cFolder + "/libstz_string.so") or fexists(cFolder + "/stz_string.so")

# the word after cKey on the line of a PACKAGE.txt that names it, else ""
func AtelierPackageWord cFile, cKey
	if NOT fexists(cFile)
		return ""
	ok
	acLines = str2list(read(cFile))
	for i = 1 to len(acLines)
		cLine = acLines[i]
		nAt = substr(lower(cLine), " " + lower(cKey) + " ")
		if nAt > 0
			cRest = trim(substr(cLine, nAt + len(cKey) + 1))
			nSp = substr(cRest, " ")
			if nSp > 0
				return left(cRest, nSp - 1)
			ok
			return cRest
		ok
	next
	return ""

# the commit a checkout's HEAD names, read from .git: "<sha> on <branch>", or ""
func AtelierGitHead cRoot
	cGitDir = cRoot + "/.git"
	cCommonDir = cGitDir
	cPointer = AtelierOneLine(AtelierReadOr(cGitDir, ""))
	if left(cPointer, 7) = "gitdir:"
		cGitDir = AtelierSlashes(trim(substr(cPointer, 8)))
		cCommonDir = cGitDir
		cCommon = AtelierOneLine(AtelierReadOr(cGitDir + "/commondir", ""))
		if cCommon != ""
			cCommonDir = cGitDir + "/" + AtelierSlashes(cCommon)
		ok
	ok
	cHead = AtelierOneLine(AtelierReadOr(cGitDir + "/HEAD", ""))
	if cHead = ""
		return ""
	ok
	if left(cHead, 5) != "ref: "
		return left(cHead, 9) + " (detached)"
	ok
	cRef = trim(substr(cHead, 6))
	cBranch = cRef
	if left(cRef, 11) = "refs/heads/"
		cBranch = substr(cRef, 12)
	ok
	cSha = AtelierOneLine(AtelierReadOr(cGitDir + "/" + cRef, ""))
	if cSha = ""
		cSha = AtelierOneLine(AtelierReadOr(cCommonDir + "/" + cRef, ""))
	ok
	if cSha = ""
		# packed: a line "<sha> <ref>"
		acLines = str2list(AtelierReadOr(cCommonDir + "/packed-refs", ""))
		for i = 1 to len(acLines)
			if right(trim(acLines[i]), len(cRef) + 1) = " " + cRef
				cSha = left(trim(acLines[i]), 40)
			ok
		next
	ok
	if cSha = ""
		return ""
	ok
	return left(cSha, 9) + " on " + cBranch

# the first line of a small file, without its line ending (trim leaves a newline)
func AtelierOneLine cText
	cText = substr("" + cText, char(13), "")
	nNl = substr(cText, char(10))
	if nNl > 0
		cText = left(cText, nNl - 1)
	ok
	return trim(cText)

func AtelierReadOr cFile, cElse
	cOut = cElse
	try
		cOut = read(cFile)
	catch
		cOut = cElse
	done
	return cOut

#--- settings and folders ---------------------------------------------------

# a settings file admitted before this one, then the environment, then the default
func AtelierSetting cKey, cEnv, cDefault
	if find(globals(), "$aatelierconfig") > 0
		aC = $aAtelierConfig
		if isList(aC)
			for i = 1 to len(aC)
				if isList(aC[i]) and len(aC[i]) = 2 and lower("" + aC[i][1]) = lower(cKey)
					return "" + aC[i][2]
				ok
			next
		ok
	ok
	cFromEnv = sysget(cEnv)
	if cFromEnv != ""
		return cFromEnv
	ok
	return cDefault

# the folder holding this file, from the argument it was started with
func AtelierOwnFolder
	cMe = ""
	for i = 1 to len(sysargv)
		if right(lower(sysargv[i]), 12) = "atelier.ring"
			cMe = sysargv[i]
		ok
	next
	if cMe = ""
		return AtelierSlashes(currentdir())
	ok
	cMe = AtelierSlashes(cMe)
	if NOT (left(cMe, 1) = "/" or substr(cMe, ":") = 2)
		cMe = AtelierSlashes(currentdir()) + "/" + cMe
	ok
	return AtelierParentOf(cMe)

func AtelierParentOf cPath
	cPath = AtelierSlashes(cPath)
	while right(cPath, 1) = "/"
		cPath = left(cPath, len(cPath) - 1)
	end
	for i = len(cPath) to 1 step -1
		if cPath[i] = "/"
			return left(cPath, i - 1)
		ok
	next
	return cPath

func AtelierSlashes cPath
	return substr("" + cPath, "\", "/")

func AtelierSecondOfDay
	cT = time()
	return (0 + left(cT, 2)) * 3600 + (0 + substr(cT, 4, 2)) * 60 + (0 + substr(cT, 7, 2))
