load "../../stzBase.ring"
load "../_narrated.ring"

# stzReactor (base/reactive/stzReactor.ring) -- the two register rows kept as a guard now that the class answers.
# Run from inside this folder:
#     rnxc stzReactor_defects_narrated.ring
# It needs the engine's reactor and string modules and no network. The programs it starts are children of its own
# folder (stzReactor_defects_fixture/, six tiny scripts run by the interpreter that runs the guard) and `hostname`;
# none of them writes a file or opens a socket, every output is small but one (20000 short lines), and every job is
# awaited so no child outlives the guard.
#
# THE HISTORY: the register said SubmitSpawn raised R21 when given a plain text instead of a list, "because the wrap
# into a list is skipped inside the method" (CLAUDE.md trap 6: a one-clause `if isString(p) p = [p] ok` that
# reassigns the PARAMETER can no-op), and that Spawn raised it too because it goes through SubmitSpawn.
#   Measured under rnxc, before the change: the wrap DID fire -- Spawn("hostname") and SubmitSpawn("hostname") both
#   answered the host name, no R21. The symptom was Ring 1.27's; the shape that produced it was still in the method,
#   and what rnxc did NOT do was any better: a number instead of a list raised the VM's "Bad parameter type!", a list
#   inside the list raised R21 from the `+` of the join, and a number inside the list was run as a program named 123.
#
# THE RULES the guard holds the class to:
#   SubmitSpawn(acArgv), Spawn(acArgv, nTimeoutMs)
#     a TEXT is one program with no arguments, exactly as the one-item list holding it; a LIST is the program and its
#     arguments, one item each, kept apart whatever they hold (spaces, quotes); a number in the list is the text of
#     that number; the list the caller passed is not changed. The argument list is built in a fresh variable, never by
#     reassigning the parameter.
#     Anything else -- a number, a list inside the list, an object -- raises the named error "Incorrect param type!
#     acArgv ...", never R21 and never the VM's own message, and nothing is started.
#     An empty text or an empty list starts no program: the job it gets ends at once, with no output and the status -1.
#   SpawnLastStatus   the exit code of the last program whose output was fetched: 0 after a success, the code the
#     program ended with after a failure, a negative libuv code when the program could not start (a program that does
#     not exist), and -1 for an empty text or an empty list.
#   AwaitSpawn / PollSpawn / JobState   a job is spent once drained (JobState -2, the output empty); an await that
#     times out leaves the job alone, so a later await still gets the output.
#   Nothing else moves: the output of the child is returned as it was written, byte for byte, Hebrew and emoji too.
#
# The text of a result is compared EXACTLY (RxSame, through hex): Ring's = on text ignores case. Every positive
# carries a negative sibling. ASCII only on the console.

$cRxExe = exefilename()
$cRxFix = "stzReactor_defects_fixture/"
$oRx = new stzReactor()
$cRxRaised = ""
$vRxGot = ""
$nRxI = 0
$aRxArgs = []

# ---------------------------------------------------------------------------------------------------------------
Scenario("0. the interpreter that runs this guard can start itself")
try
	Given("the path of the running interpreter, and a child script beside the guard")
	Then("the path is not empty", len($cRxExe) > 0, 1)
	cOut = $oRx.Spawn([ $cRxExe, $cRxFix + "c_hello.ring" ], 20000)
	Then("a child ran and printed hello and a line break, exactly", RxSame(cOut, "hello" + char(10)), 1)
	Then("its exit code is 0", $oRx.SpawnLastStatus(), 0)
catch
	RxAbort()
done
EndScenario()

# ---------------------------------------------------------------------------------------------------------------
Scenario("1. a plain text is a program with no arguments")
try
	Given("hostname, as a list and as a text")
	cList = $oRx.Spawn([ "hostname" ], 20000)
	nListSt = $oRx.SpawnLastStatus()
	cText = $oRx.Spawn("hostname", 20000)
	nTextSt = $oRx.SpawnLastStatus()
	Then("the list form answers a host name", len(cList) > 0, 1)
	Then("the text form answers the same bytes", RxSame(cText, cList), 1)
	Then("the text form ended with 0", nTextSt, 0)
	Then("...as the list form did", nListSt, 0)
	When("SubmitSpawn is given the text and the list")
	nIdText = $oRx.SubmitSpawn("hostname")
	nIdList = $oRx.SubmitSpawn([ "hostname" ])
	Then("each gave a job id above 0", nIdText > 0 and nIdList > 0, 1)
	Then("the ids differ: two jobs", nIdText != nIdList, 1)
	Then("the text job's output is the host name", RxSame($oRx.AwaitSpawn(nIdText, 20000), cList), 1)
	Then("the list job's output is the host name", RxSame($oRx.AwaitSpawn(nIdList, 20000), cList), 1)
	Then("NEGATIVE: a text with a space is ONE program name, not split into arguments",
		RxSpawnText($cRxExe + " " + $cRxFix + "c_hello.ring"), "")
	Then("...and its status is a start failure, below 0", $oRx.SpawnLastStatus() < 0, 1)
catch
	RxAbort()
done
EndScenario()

# ---------------------------------------------------------------------------------------------------------------
Scenario("2. arguments reach the program one each, whatever they hold")
try
	Given("a child that prints each argument between brackets")
	cOut = $oRx.Spawn([ $cRxExe, $cRxFix + "c_args.ring", "a b", 'q"x', "", "tab" + char(9) + "end" ], 20000)
	Then("a space stays inside its argument, a quote stays, an empty argument is kept, a tab stays",
		RxSame(cOut, "[a b]" + char(10) + '[q"x]' + char(10) + "[]" + char(10) + "[tab" + char(9) + "end]" + char(10)), 1)
	When("a number is one of the items")
	cOut = $oRx.Spawn([ $cRxExe, $cRxFix + "c_args.ring", 7, "x", -3 ], 20000)
	Then("it arrives as the text of the number", RxSame(cOut, "[7]" + char(10) + "[x]" + char(10) + "[-3]" + char(10)), 1)
	Then("NEGATIVE: a number is not run as a program named 7", RxSameQ(cOut, ""), 0)
	When("the list is kept in a variable and passed")
	$aRxArgs = [ $cRxExe, $cRxFix + "c_args.ring", "k", 9 ]
	$oRx.Spawn($aRxArgs, 20000)
	Then("the list the caller passed still has its four items", len($aRxArgs), 4)
	Then("...and its number is still a number", isNumber($aRxArgs[4]), 1)
catch
	RxAbort()
done
EndScenario()

# ---------------------------------------------------------------------------------------------------------------
Scenario("3. the exit code is recorded after every fetch")
try
	Given("a child that ends with 3")
	cOut = $oRx.Spawn([ $cRxExe, $cRxFix + "c_exit.ring", 3 ], 20000)
	Then("its output came back", RxSame(cOut, "bye" + char(10)), 1)
	Then("the status is 3", $oRx.SpawnLastStatus(), 3)
	When("a child that ends with 0 runs next")
	$oRx.Spawn([ $cRxExe, $cRxFix + "c_exit.ring", 0 ], 20000)
	Then("the status is 0 again: the code of the LAST fetch", $oRx.SpawnLastStatus(), 0)
	When("the same child is run through Submit and Await, with code 7")
	nId = $oRx.SubmitSpawn([ $cRxExe, $cRxFix + "c_exit.ring", 7 ])
	cOut = $oRx.AwaitSpawn(nId, 20000)
	Then("the output came back", RxSame(cOut, "bye" + char(10)), 1)
	Then("the status is 7", $oRx.SpawnLastStatus(), 7)
	When("a program that does not exist is run")
	cOut = $oRx.Spawn([ "definitely-not-a-real-program-xyz" ], 20000)
	Then("the output is empty", RxSame(cOut, ""), 1)
	Then("the status is not 0", $oRx.SpawnLastStatus() != 0, 1)
	Then("...it is a start failure, below 0", $oRx.SpawnLastStatus() < 0, 1)
catch
	RxAbort()
done
EndScenario()

# ---------------------------------------------------------------------------------------------------------------
Scenario("4. output is returned as written")
try
	Given("a child that prints Hebrew, Arabic, an emoji, a symbol and an accent")
	cOut = $oRx.Spawn([ $cRxExe, $cRxFix + "c_utf8.ring" ], 20000)
	cWant = hex2str("D7A9D79CD795D79D20D985D8B1D8ADD8A8D8A720F09F988020E299A520C3A90A")
	Then("32 bytes", len(cOut), 32)
	Then("the bytes are exactly the UTF-8 of the line and its line break", RxSame(cOut, cWant), 1)
	Given("a child that prints 20000 lines")
	cOut = $oRx.Spawn([ $cRxExe, $cRxFix + "c_big.ring" ], 60000)
	nWant = 0
	for nRxI = 1 to 20000
		nWant += len("line number " + nRxI + " of the big output") + 1
	next
	Then("every byte arrived", len(cOut), nWant)
	Then("it begins at line 1", RxSame(left(cOut, 33), "line number 1 of the big output" + char(10) + "l"), 1)
	Then("it ends with the last line", RxSame(right(cOut, 36), "line number 20000 of the big output" + char(10)), 1)
	Then("the status is 0", $oRx.SpawnLastStatus(), 0)
catch
	RxAbort()
done
EndScenario()

# ---------------------------------------------------------------------------------------------------------------
Scenario("5. an empty text and an empty list start no program")
try
	Given("an empty text and an empty list")
	nIdText = $oRx.SubmitSpawn("")
	nIdList = $oRx.SubmitSpawn([])
	Then("each is a job that ends at once with no output", RxSame($oRx.AwaitSpawn(nIdText, 20000) + $oRx.AwaitSpawn(nIdList, 20000), ""), 1)
	Then("...and the status -1: nothing could be started", $oRx.SpawnLastStatus(), -1)
	Then("Spawn of an empty text answers an empty text", RxSame($oRx.Spawn("", 20000), ""), 1)
	Then("...with the status -1", $oRx.SpawnLastStatus(), -1)
	Then("Spawn of an empty list answers an empty text", RxSame($oRx.Spawn([], 20000), ""), 1)
	Then("...with the status -1", $oRx.SpawnLastStatus(), -1)
	Then("NEGATIVE: the status is not the one of the program before", $oRx.SpawnLastStatus() != 0, 1)
catch
	RxAbort()
done
EndScenario()

# ---------------------------------------------------------------------------------------------------------------
Scenario("6. what is neither a text nor a list of texts is refused by name")
try
	Given("a number, a list inside the list, and an object that would stringify itself")
	cNumber = RxRaised('$oRx.SubmitSpawn(123)')
	cNested = RxRaised('$oRx.SubmitSpawn([ [ $cRxExe ] ])')
	cObject = RxRaised('$oRx.SubmitSpawn([ new stzString("x") ])')
	cSpawn = RxRaised('$oRx.Spawn(123, 1000)')
	Then("a number raises the named error", WsHasRx(cNumber, "Incorrect param type!"), 1)
	Then("...and names the parameter", WsHasRx(cNumber, "acArgv"), 1)
	Then("NEGATIVE: it is not the VM's message", WsHasRx(cNumber, "Bad parameter type"), 0)
	Then("a list inside the list raises the named error", WsHasRx(cNested, "Incorrect param type!"), 1)
	Then("NEGATIVE: it is not R21", WsHasRx(cNested, "R21"), 0)
	Then("an object in the list raises the named error", WsHasRx(cObject, "Incorrect param type!"), 1)
	Then("Spawn refuses a number by the same name", WsHasRx(cSpawn, "Incorrect param type!"), 1)
	Then("a text raises nothing", RxRaised('$oRx.SubmitSpawn("")'), "")
	$oRx.AwaitSpawn($vRxGot, 20000)
	Then("a list of texts raises nothing", RxRaised('$oRx.SubmitSpawn([ "" ])'), "")
	$oRx.AwaitSpawn($vRxGot, 20000)
catch
	RxAbort()
done
EndScenario()

# ---------------------------------------------------------------------------------------------------------------
Scenario("7. Submit, JobState, Poll and Await: a job is spent once drained")
try
	Given("a child that works for a moment")
	nId = $oRx.SubmitSpawn([ $cRxExe, $cRxFix + "c_slow.ring" ])
	Then("SubmitSpawn returned at once with an id", nId > 0, 1)
	Then("the job is still running: JobState -1", $oRx.JobState(nId), -1)
	Then("PollSpawn of a running job answers an empty text", RxSame($oRx.PollSpawn(nId), ""), 1)
	When("an await gives up after 1 ms")
	Then("it answers an empty text", RxSame($oRx.AwaitSpawn(nId, 1), ""), 1)
	When("the job is awaited properly after that")
	cOut = $oRx.AwaitSpawn(nId, 30000)
	Then("the output is still there: a timed-out await did not spend the job", RxSame(cOut, "slow" + char(10)), 1)
	Then("the job is spent: JobState -2", $oRx.JobState(nId), -2)
	Then("a second await answers an empty text", RxSame($oRx.AwaitSpawn(nId, 100), ""), 1)
	Then("an id that never existed is -2 too", $oRx.JobState(987654), -2)
	Then("...and answers an empty text to both fetches", RxSame($oRx.AwaitSpawn(987654, 50) + $oRx.PollSpawn(987654), ""), 1)
	When("a job is fetched by polling")
	nId = $oRx.SubmitSpawn([ $cRxExe, $cRxFix + "c_exit.ring", 5 ])
	cOut = ""
	for nRxI = 1 to 600
		cOut = $oRx.PollSpawn(nId)
		if len(cOut) > 0  exit  ok
		$oRx.AwaitTimer($oRx.SubmitTimer(25), 2000)
	next
	Then("the output came by polling", RxSame(cOut, "bye" + char(10)), 1)
	Then("and its status is 5", $oRx.SpawnLastStatus(), 5)
catch
	RxAbort()
done
EndScenario()

# ---------------------------------------------------------------------------------------------------------------
Scenario("8. teardown")
try
	$oRx.Destroy()
	Then("the reactor is destroyed without a crash", 1, 1)
catch
	RxAbort()
done
EndScenario()

Summary()

# ---------------------------------------------------------------------------------------------------------------
# helpers: every name a function reads is a $global (Rule A)

# an EXACT, case-sensitive comparison of two texts through their hex: Ring's = on text ignores case
func RxSame(a, b)
	if isString(a) and isString(b)
		if str2hex(a) = str2hex(b)  return 1  ok
	ok
	? "      (exact compare failed)  got hex [" + left(str2hex("" + a), 80) + "]  wanted hex [" + left(str2hex("" + b), 80) + "]"
	return 0

# the same, quietly: for the negative siblings, which are expected to differ
func RxSameQ(a, b)
	if isString(a) and isString(b)
		if str2hex(a) = str2hex(b)  return 1  ok
	ok
	return 0

# what Spawn answers for a program given as one text
func RxSpawnText(cProgram)
	$vRxGot = $oRx.Spawn(cProgram, 20000)
	return $vRxGot

# the text of the error a statement raises, "" when it raises nothing
func RxRaised(cCode)
	$cRxRaised = ""
	try
		eval("$vRxGot = " + cCode)
	catch
		$cRxRaised = cCatchError
	done
	return $cRxRaised

func WsHasRx(cHay, cNeedle)
	if StzFindFirst(cNeedle, cHay) > 0  return 1  ok
	return 0

func RxAbort()
	? "  ABORTED by an uncaught error: " + cCatchError
	$_zst_fail++
	$_zst_total++
