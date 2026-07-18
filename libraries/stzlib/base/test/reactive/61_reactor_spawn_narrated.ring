load "../../stzBase.ring"
load "../_narrated.ring"

# R7 finish -- the reactor grows ASYNC PROCESS SPAWN (uv_spawn): the
# polyglot fleet floor. A non-Ring worker runs OFF-THREAD on the libuv
# loop; its stdout is captured and its exit code reported through the
# same submit -> poll/await job idiom (no callback crosses into Ring).
# This is what lets EXCIS-style workers (Python/node/...) join the
# reactor -- and what a true-ast stzPyCodeGraph backend would ride.
#
# Uses the platform shell for a guaranteed subprocess: 'cmd /c ...' on
# Windows, '/bin/sh -c ...' elsewhere.

$bWin = isWindows()

$oRct = new stzReactor()

Scenario("a subprocess runs off-thread and its stdout is captured")
	Given("a shell command that echoes a marker")
	cOut = $oRct.Spawn(EchoCmd("softanza-spawn"), 5000)
	Then("the child's stdout came back", StzFindFirst("softanza-spawn", cOut) > 0, TRUE)
	Then("its exit code is 0", $oRct.SpawnLastStatus(), 0)
EndScenario()

Scenario("a non-zero exit code is reported")
	Given("a command that exits 3")
	$oRct.Spawn(ExitCmd(3), 5000)
	Then("the exit code is surfaced", $oRct.SpawnLastStatus(), 3)
EndScenario()

Scenario("many workers run concurrently, drained independently")
	Given("three echo workers submitted at once (non-blocking)")
	nA = $oRct.SubmitSpawn(EchoCmd("AAA"))
	nB = $oRct.SubmitSpawn(EchoCmd("BBB"))
	nC = $oRct.SubmitSpawn(EchoCmd("CCC"))
	Then("three job ids were issued", nA > 0 and nB > 0 and nC > 0, TRUE)
	When("each is awaited in turn")
	cA = $oRct.AwaitSpawn(nA, 5000)
	cB = $oRct.AwaitSpawn(nB, 5000)
	cC = $oRct.AwaitSpawn(nC, 5000)
	Then("each returned its own output",
		StzFindFirst("AAA", cA) > 0 and StzFindFirst("BBB", cB) > 0 and
		StzFindFirst("CCC", cC) > 0, TRUE)
EndScenario()

Scenario("a missing program surfaces an error, no crash")
	Given("a program that does not exist")
	$oRct.Spawn([ "definitely-not-a-real-program-xyz" ], 3000)
	Then("the status is a non-zero (uv/spawn) error",
		$oRct.SpawnLastStatus() != 0, TRUE)
EndScenario()

Scenario("teardown")
	$oRct.Destroy()
	Then("teardown completes without crash", TRUE, TRUE)
EndScenario()

Summary()


# -- helpers (after all top-level code; Ring hoists func defs) --------

func EchoCmd(cMarker)
	if $bWin
		return [ "cmd", "/c", "echo " + cMarker ]
	ok
	return [ "/bin/sh", "-c", "echo " + cMarker ]

func ExitCmd(nCode)
	if $bWin
		return [ "cmd", "/c", "exit " + nCode ]
	ok
	return [ "/bin/sh", "-c", "exit " + nCode ]
