# THE EDITIONS -- the maintainer's verbs, for a notebook (B4) and for the library's checks
# (A3). The functions are in atelierEdition.ring; this file reads the command line and says
# what happened.
#
#     rnxc edition.ring record <notebook.ring> [--port N]
#         runs the notebook on an Atelier and writes <notebook>.recording.json beside it. With
#         --port, on the Atelier already running there; without, on one this boots on port
#         8670 (STZ_ATELIER_PORT) with the library this folder sits in, stopped after
#     rnxc edition.ring build <notebook.ring> --out <folder>
#         writes <folder>/<commit>/notebook/<name>/index.html and <folder>/notebooks.json;
#         refuses with exit 2 and the reasons when the recording does not describe this notebook
#         at a commit of this history
#     rnxc edition.ring build-checks --out <folder> [--allow-mixed] [--from <folder>]
#         the static edition of the checks (EMBED.md section 5): writes <folder>/<commit>/ --
#         index.html, coverage.html, check.html, data/, edition.json -- and <folder>/editions.json;
#         refuses with exit 2 and the reasons when the checks, the recording and the sweep do not
#         name one commit of this history (--allow-mixed builds anyway, and the edition says so)
#     rnxc edition.ring cite <commit>:<id> [--data <folder>] [--format json|markdown|html]
#         resolves a check's citation from the data of a folder (this one, or an edition's data/)
#     rnxc edition.ring cite <commit>:notebook/<name>#<hash> --data <recording.json> [--format ...]
#         resolves a cell's citation from its recording; both refuse with exit 2 and the reason
#
# From this folder. ORDER OF A LANDING: push the code, record at that commit, then commit the
# data (the checks' recording and sweep, or the notebook and its recording) together.

load "../stzLib.ring"
load "atelierClient.ring"
load "atelierEdition.ring"

$cEdDir = substr(currentdir(), "\", "/")
$aEdArgs = []
for $nEdI = 1 to len(sysargv)
	if lower(right(sysargv[$nEdI], 12)) = "edition.ring"
		for $nEdJ = $nEdI + 1 to len(sysargv)
			$aEdArgs + sysargv[$nEdJ]
		next
		exit
	ok
next
$cEdVerb = ""
if len($aEdArgs) >= 1  $cEdVerb = lower($aEdArgs[1])  ok
$cEdWhat = ""
if len($aEdArgs) >= 2 and left($aEdArgs[2], 2) != "--"  $cEdWhat = $aEdArgs[2]  ok
if $cEdVerb != "build-checks" and $cEdWhat = ""
	? "usage: rnxc edition.ring record <notebook.ring> [--port N]"
	? "       rnxc edition.ring build <notebook.ring> --out <folder>"
	? "       rnxc edition.ring build-checks --out <folder> [--allow-mixed] [--from <folder>]"
	? "       rnxc edition.ring cite <commit>:<id> [--data <folder>] [--format json|markdown|html]"
	? "       rnxc edition.ring cite <commit>:notebook/<name>#<hash> --data <recording.json> [--format json|markdown|html]"
	shutdown(2)
ok

if $cEdVerb = "record"
	$nEdPort = 0 + EdOption("--port", "0")
	$oEdBooted = NULL
	if $nEdPort = 0
		$nEdPort = 8670
		if sysget("STZ_ATELIER_PORT") != ""  $nEdPort = 0 + sysget("STZ_ATELIER_PORT")  ok
		? "edition record: booting an Atelier on port " + $nEdPort + " with the library at " + $cEdDir + "/.."
		$oEdBooted = AtelierBoot($cEdDir, $nEdPort, $cEdDir + "/..", $cEdDir + "/_record_settings.ring")
		$aEdState = AtelierWaitReady($nEdPort, 600000, $oEdBooted)
		if $aEdState[:library][:state] != "admitted"
			? "edition record: the library is " + $aEdState[:library][:state] + " " + $aEdState[:library][:why]
			$oEdBooted.Kill()
			shutdown(2)
		ok
	ok
	$aEdR = AtelierRecordNotebook($nEdPort, $cEdWhat)
	if isObject($oEdBooted)
		AtelierStop($nEdPort)
		$oEdBooted.WaitFor(10000)
		remove($cEdDir + "/_record_settings.ring")
	ok
	if NOT $aEdR[:ok]
		? "edition record: REFUSED: " + $aEdR[:why]
		shutdown(2)
	ok
	? "edition record: " + $aEdR[:cells] + " cells, " + $aEdR[:kept] + " kept, " + $aEdR[:diverged] + " diverged; written to " + $aEdR[:file]
	shutdown(0)
but $cEdVerb = "build"
	$aEdB = AtelierBuildNotebook($cEdWhat, EdOption("--out", ""), $cEdDir)
	if NOT $aEdB[:ok]
		? "edition build: REFUSED:"
		for $nEdI = 1 to len($aEdB[:why])
			? "   - " + $aEdB[:why][$nEdI]
		next
		shutdown(2)
	ok
	? "edition build: written to " + $aEdB[:file] + " (nothing runs on it, nothing is fetched)"
	shutdown(0)
but $cEdVerb = "build-checks"
	$aEdB = AtelierBuildChecks(EdOption("--out", ""), EdOption("--from", ""), EdFlag("--allow-mixed"), $cEdDir)
	if NOT $aEdB[:ok]
		if $aEdB[:mixed]
			? "edition build-checks: REFUSED, the three files do not describe one commit:"
		else
			? "edition build-checks: REFUSED:"
		ok
		for $nEdI = 1 to len($aEdB[:why])
			? "   - " + $aEdB[:why][$nEdI]
		next
		if $aEdB[:mixed]  ? "(--allow-mixed builds anyway; each file then says at which commit it was taken)"  ok
		shutdown(2)
	ok
	for $nEdI = 1 to len($aEdB[:notes])
		? "edition build-checks: " + $aEdB[:notes][$nEdI]
	next
	$cEdLine = "edition build-checks: edition " + $aEdB[:commit] + " written to " + $aEdB[:dest] + " (" + $aEdB[:files] + " files, " +
	           floor($aEdB[:bytes] / 1024 + 0.5) + " KB): " + $aEdB[:checks] + " checks recorded " +
	           $aEdB[:counts][1] + " / " + $aEdB[:counts][2] + " / " + $aEdB[:counts][3] + " (pass/fail/error)"
	if $aEdB[:claims] != "null"  $cEdLine += "; " + $aEdB[:judged] + " of " + $aEdB[:claims] + " Then lines judged"  ok
	? $cEdLine
	? "edition build-checks: no Ring column, no playground, nothing runs; open " + $aEdB[:dest] + "/index.html"
	shutdown(0)
but $cEdVerb = "cite"
	$cEdFormat = EdOption("--format", "json")
	if $cEdFormat != "json" and $cEdFormat != "markdown" and $cEdFormat != "html"
		? "edition cite: REFUSED: no format " + $cEdFormat + " (json, markdown, html)"
		shutdown(2)
	ok
	$nEdColon = StzFindFirst(":", $cEdWhat)
	if $nEdColon > 0 and left(substr($cEdWhat, $nEdColon + 1), 9) = "notebook/"
		$aEdC = AtelierCiteNotebook($cEdWhat, EdOption("--data", ""))
		if NOT $aEdC[:ok]
			? "edition cite: REFUSED: " + $aEdC[:why]
			shutdown(2)
		ok
		? AtelierCiteRender($aEdC[:record], $cEdFormat)
		shutdown(0)
	ok
	$aEdC = AtelierCiteCheck($cEdWhat, EdOption("--data", $cEdDir))
	if NOT $aEdC[:ok]
		? "edition cite: REFUSED: " + $aEdC[:why]
		shutdown(2)
	ok
	? AtelierCiteCheckRender($aEdC[:record], $cEdFormat)
	shutdown(0)
ok
? "edition: no verb " + $cEdVerb + " (record, build, build-checks, cite)"
shutdown(2)

func EdOption(pcName, pcDefault)
	for _i_ = 2 to len($aEdArgs) - 1
		if $aEdArgs[_i_] = pcName
			return $aEdArgs[_i_ + 1]
		ok
	next
	return pcDefault

func EdFlag(pcName)
	for _i_ = 2 to len($aEdArgs)
		if $aEdArgs[_i_] = pcName  return 1  ok
	next
	return 0
