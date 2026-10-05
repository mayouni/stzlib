load "../../stzBase.ring"
load "../_narrated.ring"

# SECURITY-SPAWN-NOSHELL-01 -- data handed to a program is never parsed by
# a shell.
#
# Two ways it was, both closed here:
#
#   stzSystemCall with a LIST of arguments (StzSystemXT, SetArgs) joined
#   the list into one string, quoted an argument only when it held a
#   space, and gave the string to cmd.exe /c (or /bin/sh -c). An argument
#   holding a double quote, &, %VAR% or $(...) was shell syntax. A list
#   now reaches the program argument by argument through the engine's
#   argv runner, unless the program IS a shell (cmd.exe /c ... stays a
#   shell call, on purpose).
#
#   stzFileManager.MakeReadOnly / MakeWritable / MakeExecutable built
#   `attrib +R "<name>"` or `chmod a-w "<name>"` for a shell. They are
#   engine calls now; the name goes to the OS as a path.
#
# The witness is a tiny Ring program that prints each argument it gets
# between brackets, and a MARKER file that exists only if an injected
# command ran.

$cDir = "_tmp_spawn"
if NOT direxists($cDir)  StzEngineDirCreate($cDir)  ok
$cEcho = $cDir + "/argecho.ring"
write($cEcho, 'for i = 3 to len(sysargv)  see "[" + sysargv[i] + "]" + char(10)  next' + char(10))
$cMarker = $cDir + "/INJECTED.txt"
if fexists($cMarker)  remove($cMarker)  ok
$cRing = exefilename()

# =====================================================================
#  ARGUMENT LISTS
# =====================================================================

Scenario("a plain argument list reaches the program intact")
	When("a program is called with two ordinary arguments")
	cOut = StzSystemXT($cRing, [ $cEcho, "alpha", "beta gamma" ])
	Then("each argument arrived as itself",
		StzFindFirst("[alpha]", cOut) > 0 and StzFindFirst("[beta gamma]", cOut) > 0, 1)
EndScenario()

Scenario("an argument holding a quote and & cannot start a second command")
	cEvil = 'a" & echo pwned> ' + $cMarker + ' & "b'
	When("the argument is: " + cEvil)
	cOut = StzSystemXT($cRing, [ $cEcho, cEvil ])
	# before the fix: cmd.exe saw  "a" & echo pwned> ... & "b"  and ran echo
	Then("no injected command ran (no marker file)", fexists($cMarker), 0)
	Then("the program received the argument byte for byte",
		StzFindFirst("[" + cEvil + "]", cOut) > 0, 1)
	if fexists($cMarker)  remove($cMarker)  ok
EndScenario()

Scenario("an argument holding %VAR% is not expanded")
	When("the argument is %USERNAME%")
	cOut = StzSystemXT($cRing, [ $cEcho, "%USERNAME%" ])
	# before the fix: cmd.exe replaced it with the account name
	Then("the program received the literal text", StzFindFirst("[%USERNAME%]", cOut) > 0, 1)
EndScenario()

Scenario("a program that IS a shell keeps shell semantics")
	When("cmd.exe /c is given 'echo one & echo two' as a list")
	if isWindows()
		cOut = StzSystemXT("cmd.exe", [ "/c", "echo", "one", "&", "echo", "two" ])
		Then("both commands ran -- shell syntax on purpose, for a shell",
			StzFindFirst("one", cOut) > 0 and StzFindFirst("two", cOut) > 0, 1)
	else
		cOut = StzSystemXT("sh", [ "-c", "echo one; echo two" ])
		Then("both commands ran -- shell syntax on purpose, for a shell",
			StzFindFirst("one", cOut) > 0 and StzFindFirst("two", cOut) > 0, 1)
	ok
EndScenario()

# =====================================================================
#  FILE PERMISSIONS
# =====================================================================

Scenario("MakeReadOnly works on a name a shell would rewrite")
	cName = $cDir + "/perm %USERNAME% $(whoami) & x.txt"
	write(cName, "data")
	oF = new stzFileManager(cName)
	Given("a writable file named: " + cName)
	Then("it starts writable", oF.IsReadOnly(), 0)
	When("MakeReadOnly() is called")
	oF.MakeReadOnly()
	# before the fix: cmd.exe expanded %USERNAME% and attrib missed the file
	Then("THAT file is now read-only", oF.IsReadOnly(), 1)
	When("MakeWritable() is called")
	oF.MakeWritable()
	Then("it is writable again", oF.IsReadOnly(), 0)
	remove(cName)
EndScenario()

Scenario("MakeReadOnly still works on an ordinary name")
	cName = $cDir + "/plain.txt"
	write(cName, "data")
	oF = new stzFileManager(cName)
	oF.MakeReadOnly()
	Then("read-only after MakeReadOnly()", oF.IsReadOnly(), 1)
	oF.MakeWritable()
	Then("writable after MakeWritable()", oF.IsReadOnly(), 0)
	remove(cName)
EndScenario()

if isWindows()
	? char(10) + "SKIPPED (POSIX only): a filename holding a double quote -- Windows"
	? "  forbids the character in a name, so the chmod quote-breakout case"
	? "  cannot be staged here. It runs on Linux and macOS."
else
	Scenario("chmod cannot be broken out of by a quote in the name (POSIX)")
		cName = $cDir + '/q" ; touch ' + $cMarker + ' ; ".txt'
		write(cName, "data")
		oF = new stzFileManager(cName)
		oF.MakeReadOnly()
		Then("no injected command ran", fexists($cMarker), 0)
		Then("THAT file is read-only", oF.IsReadOnly(), 1)
		oF.MakeWritable()
		remove(cName)
	EndScenario()
ok

remove($cEcho)
StzEngineDirDelete($cDir)

Summary()
