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
	$aAtelierSeen = []
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
	rpp_http_reply(200, "application/json; charset=utf-8", AtelierCellJson(aPlan[2], cEnd, cErr, cRel, nMs))

# [ the rewritten source, [ [ :n, :line, :expr, :promise ] ] ]
func AtelierCellPlan cSource
	acL = str2list(substr("" + cSource, char(13), ""))
	aSees = []
	cOut = ""
	nL = len(acL)
	for i = 1 to nL
		cLine = acL[i]
		cT = trim(cLine)
		if left(cT, 1) = "?" and left(cT, 4) != "?-->"
			cExpr = trim(substr(cT, 2))
			cPromise = ""
			nAt = AtelierLastIndexOf(cExpr, "#-->")
			if nAt > 0
				cPromise = trim(substr(cExpr, nAt + 4))
				cExpr = trim(left(cExpr, nAt - 1))
			else
				# the promise on the line under it, and its continuation lines
				j = i + 1
				while j <= nL and trim(acL[j]) = ""
					j++
				end
				if j <= nL and left(trim(acL[j]), 4) = "#-->"
					cPromise = trim(substr(trim(acL[j]), 5)) + _TourContinuation(acL, j)
				ok
			ok
			if cExpr != ""
				nN = len(aSees) + 1
				aSees + [ :n = nN, :line = i, :expr = cExpr, :promise = cPromise ]
				nIndent = substr(cLine, "?")
				cOut += left(cLine, nIndent - 1) + "AtelierSee(" + nN + ", " + cExpr + ")" + char(10)
				loop
			ok
		ok
		cOut += cLine + char(10)
	next
	return [ cOut, aSees ]

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
func AtelierCellJson aSees, cEnd, cErr, cRel, nMs
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
		if aS[:promise] != ""
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
		cJ += '{"n":' + aS[:n] + ',"line":' + aS[:line] + ',"expr":' + AtelierJsonStr(aS[:expr]) + ',"promise":' + AtelierJsonStr(aS[:promise])
		cJ += ',"state":' + AtelierJsonStr(cState) + ',"values":[' + cVals + ']}'
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
