# THE RECORDER -- boots an Atelier on the library this folder sits in (or the one
# STZ_ATELIER_LIBRARY names), runs every check of checks.json over HTTP, writes
# results.json -- what judged the checks, the counts, each check's state -- and
# stops the Atelier. The guard compares a live run against that file.
#
#     rnxc record.ring              from this folder; RNXC names the rnxc to boot
#                                   with when it is not the one running this
#     STZ_ATELIER_PORT              the port to boot on (default 8650)
#
# A maintainer's tool: run it after a change that moves a verdict on purpose, read
# the diff of results.json, and commit the two together.

load "../stzLib.ring"
load "atelierClient.ring"

$cRecDir = substr(currentdir(), "\", "/")
$cRecLibrary = sysget("STZ_ATELIER_LIBRARY")
if $cRecLibrary = ""
	$cRecLibrary = $cRecDir + "/.."
ok
$nRecPort = 8650
if sysget("STZ_ATELIER_PORT") != ""
	$nRecPort = 0 + sysget("STZ_ATELIER_PORT")
ok
$cRecSettings = $cRecDir + "/_record_settings.ring"

? "atelier record: booting on port " + $nRecPort + " with the library at " + $cRecLibrary
$oRec = AtelierBoot($cRecDir, $nRecPort, $cRecLibrary, $cRecSettings)
$aRecState = AtelierWaitReady($nRecPort, 180000, $oRec)
if $aRecState[:library][:state] != "admitted"
	? "atelier record: the library is " + $aRecState[:library][:state] + " " + $aRecState[:library][:why]
	$oRec.Kill()
	shutdown(2)
ok
? "  the library " + $aRecState[:library][:commit] + ", admitted in " + $aRecState[:library][:seconds] + " s; rnxc " + $aRecState[:rnxc][:build] + "; the engine: " + $aRecState[:engine]

$aRecChecks = StzJsonToList(read($cRecDir + "/checks.json"))
? "  " + len($aRecChecks[:checks]) + " checks, harvested from " + $aRecChecks[:source] + " at " + $aRecChecks[:commit]
$aRecRun = AtelierRunChecks($nRecPort, $aRecChecks[:checks], 200)
$cRecOut = AtelierResultsJson($aRecState, $aRecRun, $aRecChecks[:commit], len($aRecChecks[:checks]))
write($cRecDir + "/results.json", $cRecOut)
? "  " + $aRecRun[:pass] + " pass, " + $aRecRun[:fail] + " fail, " + $aRecRun[:err] + " error; a check " + _AtelierNum($aRecRun[:median_ms]) + " ms median, " + _AtelierNum($aRecRun[:total_ms] / 1000) + " s in all"
? "  wrote results.json"
AtelierStop($nRecPort)
$oRec.WaitFor(5000)
remove($cRecSettings)
