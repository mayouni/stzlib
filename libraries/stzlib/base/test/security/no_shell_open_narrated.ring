load "../../stzBase.ring"
load "../_narrated.ring"

# SECURITY-R11-01 -- a path handed to a shell is code.
#
# Three planes still build shell strings from paths: graphics opens a render
# with system('start "" "' + path + '"'), math makes a folder with
# system('mkdir "' + dir + '"'), extercode opens its output the same way. A
# `"` in the path ends the quoting and the rest RUNS. The safe forms already
# exist or are added here: StzMakeDir (engine, no shell) and
# StzOpenInDefaultApp (ShellExecuteW / open / xdg-open with the path as one
# argument, and nothing launched unless the path exists).
#
# The guard never opens a real viewer -- that would put a window on the
# screen of whoever runs it. The shell is shown running injected code through
# the mkdir shape, which needs no window; the safe forms are shown refusing
# the same string.

$cMarker = "_r11_marker.txt"
$cEvil = '_r11_dir" & echo pwned> ' + $cMarker + ' & rem "'
CleanUp()

Scenario("the old shape runs whatever a path smuggles in")
	system('mkdir "' + $cEvil + '"')
	Then("the shell ran the injected command", fexists($cMarker), 1)
	CleanUp()
EndScenario()

Scenario("StzMakeDir takes the same string as a name, not as code")
	StzMakeDir($cEvil)
	Then("nothing was run", fexists($cMarker), 0)
	CleanUp()
EndScenario()

Scenario("StzOpenInDefaultApp launches nothing for a path that is not there")
	Then("the smuggling string is refused", Raises($cEvil), 1)
	Then("...and nothing was run", fexists($cMarker), 0)
	Then("a missing file is refused", Raises("no_such_render_r11.png"), 1)
	Then("an empty path is refused", Raises(""), 1)
	Then("the engine itself refuses an empty path", StzEngineSystemOpenDefault(""), -1)
EndScenario()

CleanUp()
Summary()

# -- helpers (after the main code) ------------------------------------

func Raises cPath
	bR = 0
	try  StzOpenInDefaultApp(cPath)  catch  bR = 1  done
	return bR

func CleanUp
	if fexists($cMarker)  remove($cMarker)  ok
	if direxists("_r11_dir")  StzEngineDirDelete("_r11_dir")  ok
