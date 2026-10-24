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

# THE CALLERS, not only the helper. The helper being safe proves nothing about
# a plane that never calls it: the migrated library carried the shell string in
# stzCanvas.Show() and stzScene.Show() long after the helper existed, and no
# guard noticed because nothing asked the callers.
Scenario("the render viewers hand their path to no shell")
	Then("stzCanvas builds no shell command", ShellOpenIn("../../graphics/stzCanvas.ring"), 0)
	Then("stzScene builds no shell command", ShellOpenIn("../../graphics/stzScene.ring"), 0)
	Then("stzCanvas opens through StzOpenInDefaultApp", CallsHelper("../../graphics/stzCanvas.ring"), 1)
	Then("stzScene opens through StzOpenInDefaultApp", CallsHelper("../../graphics/stzScene.ring"), 1)
	Then("NEGATIVE: the scan sees the old shape when it is there",
	     StzFindFirst("system('start", "x system('start x") > 0, 1)
EndScenario()

# NOT RUN HERE, BY NAME: calling Show() itself. It tries a native window FIRST
# (a machine with a GPU and a windowing library gets one), and STZ_NO_VIEW gates
# only the file-opening branch after it -- so a guard that called it would put a
# window on the screen of whoever runs it, and could wait for it to be closed.
# The scan above reads the source instead, which needs no window.

CleanUp()
Summary()

# -- helpers (after the main code) ------------------------------------

# how many lines of a source file hand a path to a shell to open it
func ShellOpenIn cFile
	cSrc = read(cFile)
	# the SHAPE, a system(...) call that starts with a viewer, not the bare word:
	# a comment may say "xdg-open" and be right to
	return StzFindFirst("system('start", cSrc) + StzFindFirst("system('open", cSrc) + StzFindFirst("system('xdg-open", cSrc)

func CallsHelper cFile
	if StzFindFirst("StzOpenInDefaultApp(", read(cFile)) > 0  return 1  ok
	return 0

func Raises cPath
	bR = 0
	try  StzOpenInDefaultApp(cPath)  catch  bR = 1  done
	return bR

func CleanUp
	if fexists($cMarker)  remove($cMarker)  ok
	if direxists("_r11_dir")  StzEngineDirDelete("_r11_dir")  ok
