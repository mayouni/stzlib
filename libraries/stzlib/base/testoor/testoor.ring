# Testoor -- the runner at the shell. ONE process per batch, many tours.
#
# Run it FROM THIS FOLDER (Ring resolves `load` against the current directory):
#
#   rnxc testoor.ring --topic uuid                 one topic under ../test
#   rnxc testoor.ring --topic uuid --json          the logbook as JSON, for a pipe
#   rnxc testoor.ring --file ../test/uuid/00_uuid_narrated.ring
#   rnxc testoor.ring --all                        every topic (hours; the gate)
#   rnxc testoor.ring --topic uuid --root D:\elsewhere\test --timeout 60000 --by "the author"
#
# rnxc is Ring++'s compiler and VM (Ring is retired, RING-RETIRED-01). Each
# tour runs as a child rnxc: the one RNXC names, else the one running this
# runner, else `rnxc` on the path (TestoorProgram() in stzTraveller.ring).
# Measured 2026-11-03: a child rnxc on a tour loading stzBase starts in
# 0.44 to 0.60 s with its compiled image cached, against 4 to 5 s on Ring.
#
# Exit code (the runner's, never Ring's): 0 every stop kept or unperceived;
# 1 a stop diverged or a tour did not start, broke or hung; 2 the runner
# refused (no such root or topic, no scope given). Full law and the five
# stop states: stzTraveller.ring. The stz desk's `stz guard` calls this as
# its child.

load "../stzBase.ring"

cTrRoot = currentdir() + "/../test"
cTrTopic = ""
cTrFile = ""
bTrAll = 0
bTrJson = 0
nTrTimeout = 120000
cTrBy = "shell"
bTrUsage = 0

nTrArgs = len(sysargv)
nTrI = 3
while nTrI <= nTrArgs
	cTrA = sysargv[nTrI]
	if cTrA = "--topic" and nTrI < nTrArgs
		cTrTopic = sysargv[nTrI + 1]
		nTrI++
	but cTrA = "--root" and nTrI < nTrArgs
		cTrRoot = sysargv[nTrI + 1]
		nTrI++
	but cTrA = "--file" and nTrI < nTrArgs
		cTrFile = sysargv[nTrI + 1]
		nTrI++
	but cTrA = "--timeout" and nTrI < nTrArgs
		nTrTimeout = 0 + sysargv[nTrI + 1]
		nTrI++
	but cTrA = "--by" and nTrI < nTrArgs
		cTrBy = sysargv[nTrI + 1]
		nTrI++
	but cTrA = "--all"
		bTrAll = 1
	but cTrA = "--json"
		bTrJson = 1
	else
		bTrUsage = 1
	ok
	nTrI++
end

oTr = TravellerQ().By(cTrBy).Timeout(nTrTimeout)
if bTrJson  oTr.Silent()  ok

if bTrUsage or (cTrTopic = "" and cTrFile = "" and NOT bTrAll)
	# a refusal, in the logbook's own words, and exit 2
	if bTrJson
		? '{"testoor":"logbook","kind":"run","refusal":"no scope: give --topic NAME, --file PATH or --all","exit":2,"owned":0,"run":0,"tours":[]}'
	else
		? "REFUSED: no scope. Give --topic NAME, --file PATH or --all (see the header of testoor.ring)."
		? "exit 2"
	ok
	shutdown(2)
ok

if cTrFile != ""
	oTr.Walk(cTrFile)
but bTrAll
	oTr.WalkTopic(cTrRoot, "")
else
	oTr.WalkTopic(cTrRoot, cTrTopic)
ok

if bTrJson
	? oTr.Json()
else
	? ""
	? oTr.Summary()
ok
shutdown(oTr.ExitCode())
