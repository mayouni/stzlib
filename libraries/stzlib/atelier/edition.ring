# THE EDITION OF A NOTEBOOK -- the maintainer's three verbs (B4). The functions are in
# atelierEdition.ring; this file reads the command line and says what happened.
#
#     rnxc edition.ring record <notebook.ring> [--port N]
#         runs the notebook on an Atelier and writes <notebook>.recording.json beside it. With
#         --port, on the Atelier already running there; without, on one this boots on port
#         8670 (STZ_ATELIER_PORT) with the library this folder sits in, stopped after
#     rnxc edition.ring build <notebook.ring> --out <folder>
#         writes <folder>/<commit>/notebook/<name>/index.html and <folder>/notebooks.json;
#         refuses with exit 2 and the reasons when the recording does not describe this notebook
#         at a commit of this history
#     rnxc edition.ring cite <commit>:notebook/<name>#<hash> --data <recording.json> [--format json|markdown|html]
#         resolves a cell's citation, or refuses with exit 2 and the reason
#
# From this folder. ORDER OF A LANDING, as for the checks: push the code, record at that
# commit, then commit the notebook and its recording together.

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
if len($aEdArgs) < 2
	? "usage: rnxc edition.ring record <notebook.ring> [--port N]"
	? "       rnxc edition.ring build <notebook.ring> --out <folder>"
	? "       rnxc edition.ring cite <commit>:notebook/<name>#<hash> --data <recording.json> [--format json|markdown|html]"
	shutdown(2)
ok
$cEdVerb = lower($aEdArgs[1])
$cEdWhat = $aEdArgs[2]

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
but $cEdVerb = "cite"
	$aEdC = AtelierCiteNotebook($cEdWhat, EdOption("--data", ""))
	if NOT $aEdC[:ok]
		? "edition cite: REFUSED: " + $aEdC[:why]
		shutdown(2)
	ok
	? AtelierCiteRender($aEdC[:record], EdOption("--format", "json"))
	shutdown(0)
ok
? "edition: no verb " + $cEdVerb + " (record, build, cite)"
shutdown(2)

func EdOption(pcName, pcDefault)
	for _i_ = 3 to len($aEdArgs) - 1
		if $aEdArgs[_i_] = pcName
			return $aEdArgs[_i_ + 1]
		ok
	next
	return pcDefault
