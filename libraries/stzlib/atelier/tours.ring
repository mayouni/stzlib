# THE SWEEP -- every narrated test file of base/test run WHOLE as one tour on a
# booted Atelier, judged by testoor's judge, and tours.json written: what judged
# them, the totals, every domain, every file. Coverage is the Then lines the
# reader read that were judged (kept or diverged) over all the Then lines it read,
# per domain; the checks of checks.json are the floor, this is the ceiling.
#
#     rnxc tours.ring                 from this folder; RNXC names the rnxc to boot
#                                     with when it is not the one running this
#     rnxc tours.ring --topic uuid    one topic only (tours.json then holds it alone)
#     STZ_ATELIER_PORT                the port to boot on (default 8650)
#     STZ_ATELIER_LIBRARY             the library to judge (default: the one above)
#
# A tour that does not answer in 60 s holds the Atelier: it is reported hung, the
# Atelier is killed and booted again (about 20 s), and the sweep goes on. A file
# that defines a class is admitted once and stays (the Atelier cannot release a
# class): the sweep reports it as kept code. One job at a time: this is a heavy one.

load "../stzLib.ring"
load "atelierClient.ring"

$cSwDir = substr(currentdir(), "\", "/")
$cSwLibrary = sysget("STZ_ATELIER_LIBRARY")
if $cSwLibrary = ""
	$cSwLibrary = $cSwDir + "/.."
ok
$cSwTests = $cSwDir + "/../base/test"
$nSwPort = 8650
if sysget("STZ_ATELIER_PORT") != ""
	$nSwPort = 0 + sysget("STZ_ATELIER_PORT")
ok
$cSwTopic = ""
$nSwArgs = len(sysargv)
for i = 3 to $nSwArgs - 1
	if sysargv[i] = "--topic"
		$cSwTopic = sysargv[i + 1]
	but sysargv[i] = "--root"
		$cSwTests = substr(sysargv[i + 1], "\", "/")
	ok
next
# tours that boot a program of their own -- the Atelier's guards, testoor's
# runner guards -- are not for the resident program: skipped by name
$acSwSkip = [ "atelier", "testoor" ]
$cSwSettings = $cSwDir + "/_record_settings.ring"
$nSwTimeoutS = 60
# a boot compiles the library: 20 to 45 s on a quiet machine, measured, and
# past three minutes on a throttled one beside other desks' guards (2026-11-03)
$nSwBootMs = 600000

# the tours: every readable narrated file under the tests, in path order
? "atelier tours: reading " + $cSwTests + iif($cSwTopic != "", "/" + $cSwTopic, "")
$oSwBook = StzLogbookQ()
$oSwBook.ReadTree($cSwTests + iif($cSwTopic != "", "/" + $cSwTopic, ""), ".ring")
$aSwAll = $oSwBook.Records()
$aSwTours = []
$nSwSkipped = 0
for i = 1 to len($aSwAll)
	if $aSwAll[i][:readable] = 1 and $aSwAll[i][:dialect] = "narrated"
		cRelI = substr(substr($aSwAll[i][:file], "\", "/"), len($cSwTests) + 2)
		nSl = substr(cRelI, "/")
		cDomI = cRelI
		if nSl > 0  cDomI = left(cRelI, nSl - 1)  ok
		if find($acSwSkip, cDomI) > 0
			$nSwSkipped++
			? "  skipped by name: " + cRelI + " (a tour that boots a program of its own)"
			loop
		ok
		$aSwTours + $aSwAll[i][:file]
	ok
next
? "  " + len($aSwAll) + " files read, " + len($aSwTours) + " narrated tours to run, " + $nSwSkipped + " skipped by name"

? "atelier tours: booting on port " + $nSwPort + " with the library at " + $cSwLibrary
write($cSwDir + "/_atelier_" + $nSwPort + ".log", "")
$oSw = AtelierBoot($cSwDir, $nSwPort, $cSwLibrary, $cSwSettings)
$aSwState = AtelierWaitReady($nSwPort, $nSwBootMs, $oSw)
if $aSwState[:library][:state] != "admitted"
	? "atelier tours: the library is " + $aSwState[:library][:state] + " " + $aSwState[:library][:why]
	$oSw.Kill()
	shutdown(2)
ok
AtelierScrubInit($cSwLibrary, $aSwState[:rnxc][:folder])
? "  the library " + $aSwState[:library][:commit] + ", admitted in " + $aSwState[:library][:seconds] + " s; rnxc " + $aSwState[:rnxc][:build] + "; the engine: " + $aSwState[:engine]

$aSwTotal = AtelierCountsRow()
$aSwDomains = []
$aSwFiles = []
$nSwT0 = clock()
$cSwLastDomain = ""
for i = 1 to len($aSwTours)
	cPath = $aSwTours[i]
	cRel = substr(substr(cPath, "\", "/"), len(substr($cSwTests, "\", "/")) + 2)
	nSlash = substr(cRel, "/")
	cDomain = cRel
	if nSlash > 0  cDomain = left(cRel, nSlash - 1)  ok
	if cDomain != $cSwLastDomain
		? "  " + cDomain
		$cSwLastDomain = cDomain
	ok
	aRec = AtelierRunTour($nSwPort, cPath, $nSwTimeoutS)
	bReboot = 0
	if aRec[:hung] = 1
		? "    HUNG " + cRel + " -- the Atelier is killed and booted again"
		AtelierKill($cSwDir, $nSwPort)
		$oSw.WaitFor(5000)
		bReboot = 1
	but left("" + aRec[:release], 5) = "kept:"
		# a class cannot be released and its file's helpers stay with it, so the
		# next file sharing a helper's name would be refused (C22): a fresh
		# program for the next tour, at the price of one boot
		? "    KEPT CODE " + cRel + " -- the Atelier is booted again so nothing of it reaches the next tour"
		AtelierStop($nSwPort)
		$oSw.WaitFor(10000)
		bReboot = 1
	ok
	if bReboot
		$oSw = _SwBoot()
	ok
	$aSwTotal = AtelierCountsAdd($aSwTotal, aRec)
	nD = 0
	for k = 1 to len($aSwDomains)
		if $aSwDomains[k][1] = cDomain  nD = k  ok
	next
	if nD = 0
		$aSwDomains + [ cDomain, AtelierCountsRow() ]
		nD = len($aSwDomains)
	ok
	$aSwDomains[nD][2] = AtelierCountsAdd($aSwDomains[nD][2], aRec)
	aC = AtelierClaimCounts(aRec[:run])
	$aSwFiles + [ :file = cRel, :domain = cDomain, :end = aRec[:run][:end], :state = aRec[:run][:state],
	              :claims = aC[:claims], :kept = aC[:kept], :diverged = aC[:diverged], :unreached = aC[:unreached],
	              :unjudged = aC[:unjudged], :extra = aC[:extra], :ms = aRec[:ms], :why = aRec[:why] ]
	if aRec[:run][:end] != "finished" and aRec[:run][:end] != "finished-timed"
		? "    " + upper(aRec[:run][:end]) + " " + cRel + "  " + left(aRec[:why], 110)
	ok
next

# the tests judged are the tree's own (base/test beside the library) unless --root named
# another folder: then the commit of the tests is not known here and is said so
cTestsCommit = $aSwState[:library][:commit]
if $cSwTests != $cSwDir + "/../base/test"
	cTestsCommit = "a folder named with --root"
ok
write($cSwDir + "/tours.json", AtelierToursJson($aSwState, cTestsCommit, $aSwTotal, $aSwDomains, $aSwFiles))
? ""
? "  " + $aSwTotal[:files] + " tours: " + $aSwTotal[:finished] + " finished, " + $aSwTotal[:broke] + " broke, " + $aSwTotal[:not_started] + " not started, " + $aSwTotal[:hung] + " hung, " + $aSwTotal[:kept_code] + " kept code"
? "  Then lines read " + $aSwTotal[:claims] + ": judged " + $aSwTotal[:judged] + " (" + $aSwTotal[:kept] + " kept, " + $aSwTotal[:diverged] + " diverged), " + $aSwTotal[:unreached] + " unreached, " + $aSwTotal[:unjudged] + " unjudged; " + $aSwTotal[:extra] + " verdicts the reader had no line for"
? "  " + floor($aSwTotal[:ms] / 1000) + " s of tours, " + floor((clock() - $nSwT0) / clockspersecond()) + " s of sweep"
? "  wrote tours.json"
AtelierStop($nSwPort)
$oSw.WaitFor(5000)
remove($cSwSettings)

# boots the Atelier for the sweep, twice if the first boot does not come back
# (a port held a moment longer by the process just ended)
func _SwBoot()
	for _try_ = 1 to 2
		_oP_ = AtelierBoot($cSwDir, $nSwPort, $cSwLibrary, $cSwSettings)
		_aS_ = AtelierWaitReady($nSwPort, $nSwBootMs, _oP_)
		if _aS_[:library][:state] = "admitted"
			return _oP_
		ok
		? "    the Atelier did not come back (state " + _aS_[:library][:state] + ": " + left(_aS_[:library][:why], 700) + ")" + iif(_try_ = 1, "; once more", "")
		AtelierKill($cSwDir, $nSwPort)
		_oP_.WaitFor(15000)
	next
	? "atelier tours: the Atelier could not be booted again; stopping the sweep here"
	shutdown(3)
