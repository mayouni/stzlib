load "../../stzBase.ring"
load "../_narrated.ring"

# stzImgToAscii -- the six register rows, reproduced and then held.
#
# Run it from inside test/extercode. All six rows had ONE cause: the file did not parse in Ring 1.27
# (C27 Syntax Error: blocks in braces after if and in method bodies, default values on parameters, and
# two methods named OutputFile), so the class did not exist in a normal session. Nothing loads the file
# (it is in no loader), so this guard loads it by name, after setting the key Img2AnsiPath of
# $aStzLibConfig, which is how the tool path is configured.
#
# The real im2ansi tool is NOT used and is not in the library. The guard writes a stand-in program (a .bat
# file, in a folder whose name holds a space) that records every argument it receives, one per line, prints
# a known text or writes a known file, and fails when told to. So what BuildArgs builds is proved to REACH a
# program intact, spaces included. No viewer is ever opened: STZ_NO_VIEW is set, and the Show scenarios use a
# subclass that counts the open request and launches nothing. The stand-in is a Windows .bat, so the scenarios
# that start a process are SKIPPED, by name, on another system.
#
# The guard works in a folder of its own (_ia_work) and removes it at the end; the class creates the folders
# temp and output in the current folder, and they land there.

if sysget("STZ_NO_VIEW") = ""
	sysset("STZ_NO_VIEW", "1")
ok

cStart = currentdir()
cWork  = cStart + "/_ia_work"
cToolDir = cWork + "/sp ace"
cTool  = cToolDir + "/tool.bat"
bWin   = isWindows()

IaRm(cWork)
StzMakeDir(cToolDir)
write(cWork + "/my pic.png", "x")
write(cWork + "/plain.png", "x")

if bWin
	write(cTool,
		"@echo off" + char(13) + char(10) +
		'set "HERE=%~dp0"' + char(13) + char(10) +
		'set "LOG=%HERE%argv.log"' + char(13) + char(10) +
		'if exist "%LOG%" del "%LOG%"' + char(13) + char(10) +
		'set "OUT="' + char(13) + char(10) +
		":loop" + char(13) + char(10) +
		'if "%~1"=="" goto done' + char(13) + char(10) +
		'>> "%LOG%" echo [%~1]' + char(13) + char(10) +
		'if "%~1"=="-o" set "OUT=%~2"' + char(13) + char(10) +
		"shift" + char(13) + char(10) +
		"goto loop" + char(13) + char(10) +
		":done" + char(13) + char(10) +
		'set "MODE=ok"' + char(13) + char(10) +
		'if exist "%HERE%mode.txt" set /p MODE=<"%HERE%mode.txt"' + char(13) + char(10) +
		'if "%MODE%"=="fail" goto fail' + char(13) + char(10) +
		"if defined OUT goto tofile" + char(13) + char(10) +
		"echo STUB-TEXT" + char(13) + char(10) +
		"exit /b 0" + char(13) + char(10) +
		":tofile" + char(13) + char(10) +
		'if "%MODE%"=="nofile" exit /b 0' + char(13) + char(10) +
		'>"%OUT%" echo STUB-FILE' + char(13) + char(10) +
		"exit /b 0" + char(13) + char(10) +
		":fail" + char(13) + char(10) +
		"echo STUB-ERROR 1>&2" + char(13) + char(10) +
		"exit /b 3" + char(13) + char(10))
ok

$aStzLibConfig[:Img2AnsiPath] = cTool
load "../../extercode/stzImageToAscii.ring"

chdir(cWork)

# =============================================================
Scenario("Row 1 -- init: the class exists, builds, and keeps the tool path from the configuration")
	Then("the configured tool path is the default of the converter", $cImg2AnsiExe, cTool)
	o = new stzImgToAscii("")
	Then("a converter with no image builds", isObject(o), 1)
	Then("it has no output file yet", o.OutputFile(), "")
	o = new stzImgToAscii("my pic.png")
	Then("a converter with an image that exists builds", isObject(o), 1)
	Then("the folder temp was created by the build", direxists("temp"), 1)
	Then("the folder output was created by the build", direxists("output"), 1)
	Then("a missing image is refused with a clear message",
		IaHas(IaErr("new stzImgToAscii('nosuch.png')"), "Image not found: nosuch.png"), 1)
	Then("an existing image raises nothing", IaErr("new stzImgToAscii('plain.png')"), "")
EndScenario()

# =============================================================
Scenario("Row 2 -- EnsureDirs: both folders are made, from the fields the class really has")
	IaRm("temp")
	IaRm("output")
	Then("the folders are gone before the call", direxists("temp") + direxists("output"), 0)
	o = new stzImgToAscii("")
	o.EnsureDirs()
	Then("temp is back", direxists("temp"), 1)
	Then("output is back (the field is @cOutDir, not @cOutputDir)", direxists("output"), 1)
	Then("a second call finds them and raises nothing", IaErr("o.EnsureDirs()"), "")
	Then("they are still there", direxists("temp") + direxists("output"), 2)
	ob = new stzImgToAsciiBadTemp
	Then("a folder that cannot be created is refused with its name",
		IaHas(IaErr("ob.EnsureDirs()"), "Cannot create folder"), 1)
EndScenario()

# =============================================================
Scenario("Row 6 -- BuildArgs: the options come as one text per argument, in a fixed order")
	o = new stzImgToAsciiProbe("my pic.png")
	Then("the defaults are the image and the height", @@(o.ArgsOf()), @@([ "-p", "my pic.png", "-s", "30" ]))
	Then("the image path holds a space and stays ONE argument, with no quotes added", o.ArgsOf()[2], "my pic.png")
	Then("every argument is a text, the numbers included", IaAllStrings(o.ArgsOf()), 1)
	o.Format("svg")
	Then("a format other than ansi is announced", @@(o.ArgsOf()), @@([ "-p", "my pic.png", "-f", "svg", "-s", "30" ]))
	o.Format("ASCII")
	Then("the format is read in any case, and ascii adds its ramp",
		@@(o.ArgsOf()), @@([ "-p", "my pic.png", "-f", "ascii", "-s", "30", "-r", "1" ]))
	o.Height(12)
	o.Width(40)
	o.Ramp(7)
	o.Invert()
	o.NoColor()
	o.Seed(5)
	o.Chars(" .:#")
	Then("every option appears, in the order f s w i no-color seed c r",
		@@(o.ArgsOf()), @@([ "-p", "my pic.png", "-f", "ascii", "-s", "12", "-w", "40", "-i", "--no-color",
		                      "--seed", "5", "-c", " .:#", "-r", "7" ]))
	Then("the characters hold a space and stay one argument", o.ArgsOf()[14], " .:#")
	o2 = new stzImgToAsciiProbe("plain.png")
	Then("no width, no seed, no characters and no flag means none of their options",
		@@(o2.ArgsOf()), @@([ "-p", "plain.png", "-s", "30" ]))
	o2.Invert()
	o2.SetInvert(0)
	o2.NoColor()
	o2.SetNoColor(0)
	Then("the explicit switches turn the flags off again", @@(o2.ArgsOf()), @@([ "-p", "plain.png", "-s", "30" ]))
	o2.Format("html")
	o2.Format("ansi")
	Then("ansi is the default and is not announced", @@(o2.ArgsOf()), @@([ "-p", "plain.png", "-s", "30" ]))
	Then("a format the tool does not know is refused",
		IaHas(IaErr("o2.Format('png')"), "Unsupported format"), 1)
	Then("a ramp above 12 is refused", IaHas(IaErr("o2.Ramp(13)"), "Ramp 1-12 only"), 1)
	Then("a ramp below 1 is refused", IaHas(IaErr("o2.Ramp(0)"), "Ramp 1-12 only"), 1)
	Then("the limits 1 and 12 are accepted", IaErr("o2.Ramp(1)") + IaErr("o2.Ramp(12)"), "")
	Then("a missing image is refused", IaHas(IaErr("o2.Image('nosuch.png')"), "Image not found"), 1)
EndScenario()

# =============================================================
if bWin

Scenario("Row 3 -- Execute: the arguments reach the stand-in intact, and the text is kept")
	IaMode("ok")
	remove(cToolDir + "/argv.log")
	o = new stzImgToAscii("my pic.png")
	o.Height(12)
	o.Width(40)
	Then("the stand-in has not run yet", fexists(cToolDir + "/argv.log"), 0)
	o.Execute()
	Then("the stand-in ran", fexists(cToolDir + "/argv.log"), 1)
	Then("it received exactly the arguments BuildArgs builds, the path with a space as one",
		@@(IaLog(cToolDir)), @@([ "-p", "my pic.png", "-s", "12", "-w", "40" ]))
	Then("the text it printed is kept", trim(o.Content()), "STUB-TEXT")
	Then("a text run keeps no file", o.OutputFile(), "")
	Then("a text run writes nothing in the output folder", len(dir("output")), 0)
	Then("Run is the same call", IaViaAlias("Run", cToolDir), 1)
	Then("Go is the same call", IaViaAlias("Go", cToolDir), 1)
EndScenario()

Scenario("Row 3 -- Execute: a file format is written to a file, in the output folder or where asked")
	IaMode("ok")
	o = new stzImgToAscii("my pic.png")
	o.Format("svg")
	o.Execute()
	cF = o.OutputFile()
	Then("the file is in the output folder", left(cF, 7), "output/")
	Then("it carries the format as extension", right(cF, 4), ".svg")
	Then("it exists", fexists(cF), 1)
	Then("the stand-in was told where to write", IaLog(cToolDir)[len(IaLog(cToolDir))], cF)
	Then("the option before the path is -o", IaLog(cToolDir)[len(IaLog(cToolDir)) - 1], "-o")
	Then("Content reads the file the tool wrote", trim(o.Content()), "STUB-FILE")
	o = new stzImgToAscii("my pic.png")
	o.Format("html")
	o.Execute()
	Then("html gets its own extension", right(o.OutputFile(), 5), ".html")
	o = new stzImgToAscii("my pic.png")
	o.SetOutputFile("output/my result.txt")
	o.Execute()
	Then("a chosen output file is used, even for ansi, and its name keeps the space", o.OutputFile(), "output/my result.txt")
	Then("the file holds what the tool wrote", trim(read("output/my result.txt")), "STUB-FILE")
	Then("the stand-in received it as one argument",
		IaLog(cToolDir)[len(IaLog(cToolDir))], "output/my result.txt")
	Then("Content returns that file", trim(o.Content()), "STUB-FILE")
EndScenario()

Scenario("Row 3 -- Execute: a refusal or a failure keeps nothing, and the stand-in is not started for a refusal")
	IaMode("ok")
	remove(cToolDir + "/argv.log")
	o = new stzImgToAscii("")
	Then("no image is refused with a clear message", IaHas(IaErr("o.Execute()"), "No image set"), 1)
	Then("the stand-in did not run", fexists(cToolDir + "/argv.log"), 0)

	o = new stzImgToAsciiProbe("my pic.png")
	o.Execute()
	Then("a good run keeps its text", trim(o.KeptContent()), "STUB-TEXT")
	IaMode("fail")
	cErr = IaErr("o.Execute()")
	Then("a tool that exits with a code other than 0 is reported", IaHas(cErr, "im2ansi failed (exit 3"), 1)
	Then("the report carries what the tool wrote on its error output", IaHas(cErr, "STUB-ERROR"), 1)
	Then("the report names the tool", IaHas(cErr, "tool.bat"), 1)
	Then("the text of the earlier run is not kept", o.KeptContent(), "")
	Then("the run is not counted as done", o.Ran(), 0)
	Then("Content tries again and reports the failure again", IaHas(IaErr("o.Content()"), "im2ansi failed"), 1)
	o = new stzImgToAsciiProbe("my pic.png")
	o.Format("svg")
	IaMode("ok")
	o.Execute()
	Then("a good file run keeps its file", o.OutputFile() != "", 1)
	IaMode("fail")
	cErr = IaErr("o.Execute()")
	Then("the same tool failing on a file run is reported", IaHas(cErr, "im2ansi failed (exit 3"), 1)
	Then("the file of the earlier run is not kept", o.OutputFile(), "")
	IaMode("nofile")
	o = new stzImgToAscii("my pic.png")
	o.SetOutputFile("output/never written.txt")
	cErr = IaErr("o.Execute()")
	Then("a tool that exits 0 without writing the file asked is reported", IaHas(cErr, "no output file"), 1)
	Then("it names the file", IaHas(cErr, "never written.txt"), 1)
	Then("no file is kept", o.OutputFile(), "")
	IaMode("ok")
	$cImg2AnsiExe = cWork + "/nosuch/tool.exe"
	o = new stzImgToAscii("my pic.png")
	cErr = IaErr("o.Execute()")
	$cImg2AnsiExe = cTool
	Then("a tool that does not exist is reported with its path", IaHas(cErr, "im2ansi failed") + IaHas(cErr, "nosuch"), 2)
EndScenario()

Scenario("Row 4 -- Content: runs the tool once when needed, then answers from what it kept")
	IaMode("ok")
	remove(cToolDir + "/argv.log")
	o = new stzImgToAscii("my pic.png")
	Then("nothing ran yet", fexists(cToolDir + "/argv.log"), 0)
	Then("Content runs the tool and returns its text", trim(o.Content()), "STUB-TEXT")
	Then("the stand-in ran", fexists(cToolDir + "/argv.log"), 1)
	remove(cToolDir + "/argv.log")
	Then("a second Content answers the same", trim(o.Content()), "STUB-TEXT")
	Then("without running the tool again", fexists(cToolDir + "/argv.log"), 0)
	o = new stzImgToAscii("")
	Then("with no image it is refused", IaHas(IaErr("o.Content()"), "No image set"), 1)
EndScenario()

Scenario("Row 5 -- Show: a text is printed, a file is handed to the viewer, and the viewer is never really opened")
	IaMode("ok")
	remove(cToolDir + "/argv.log")
	o = new stzImgToAsciiProbe("my pic.png")
	o.Verbose()
	? "  (the next line is Show printing the converted image, then Verbose printing the command)"
	o.Show()
	Then("Show ran the tool first", fexists(cToolDir + "/argv.log"), 1)
	Then("a text result is printed and the viewer is not asked", o.Viewed(), 0)
	o.View()
	o.Display()
	Then("View and Display are the same call: still no viewer for a text", o.Viewed(), 0)
	o = new stzImgToAsciiProbe("my pic.png")
	o.Format("svg")
	o.Show()
	Then("a file result is handed to the viewer once", o.Viewed(), 1)
	Then("with the path of the file the tool wrote", o.ViewedFile(), o.OutputFile())
	Then("and that file exists", fexists(o.ViewedFile()), 1)
	o.View()
	Then("View asks the viewer again", o.Viewed(), 2)
	o = new stzImgToAsciiProbe("my pic.png")
	o.ExecuteAndShow()
	Then("ExecuteAndShow runs then prints, with no viewer", o.Viewed() + o.Ran(), 1)
	o = new stzImgToAsciiProbe("my pic.png")
	o.Format("html")
	o.RunAndView()
	Then("RunAndView runs then opens the viewer", o.Viewed(), 1)
	o = new stzImgToAsciiProbe("my pic.png")
	o.Format("html")
	o.XT()
	o.GoXT()
	Then("XT and GoXT do the same", o.Viewed(), 2)
	o = new stzImgToAsciiProbe("")
	Then("Show with no image is refused, and no viewer is asked",
		IaHas(IaErr("o.Show()"), "No image set") + o.Viewed(), 1)
EndScenario()

else
	? char(10) + "SKIPPED: the scenarios that start a process (Execute, Content, Show) need Windows, the stand-in is a .bat"
ok

# =============================================================
Scenario("Row 5 -- the real viewer step does nothing while STZ_NO_VIEW is set")
	Then("STZ_NO_VIEW is set for this run", sysget("STZ_NO_VIEW") != "", 1)
	oV = new stzImgToAsciiViewer
	Then("asking the real viewer step to open a file raises nothing and returns", IaErr("oV.OpenIt('plain.png')"), "")
	Then("and a path that does not exist is not even looked at", IaErr("oV.OpenIt('nosuch.svg')"), "")
EndScenario()

chdir(cStart)
IaRm(cWork)
Then("the guard left its work folder gone", direxists(cWork), 0)

Summary()

# removes a folder with all it holds, when it exists
func IaRm(cDir)
	if direxists(cDir)
		RemoveFolderRecursive(cDir)
	ok

# the error text of a Ring expression, "" when it ran
func IaErr(cCall)
	cErr = ""
	try
		eval(cCall)
	catch
		cErr = cCatchError
	done
	return cErr

# 1 when cNeedle occurs in cText
func IaHas(cText, cNeedle)
	if StzFindFirst(cNeedle, cText) > 0
		return 1
	ok
	return 0

# 1 when every item of the list is a text
func IaAllStrings(aList)
	nLen = len(aList)
	for i = 1 to nLen
		if NOT isString(aList[i])
			return 0
		ok
	next
	return 1

# what the stand-in recorded, one argument per item
func IaLog(cDir)
	aOut = []
	aLines = str2list(read(cDir + "/argv.log"))
	nLen = len(aLines)
	for i = 1 to nLen
		cL = aLines[i]
		if right(cL, 1) = char(13)
			cL = left(cL, len(cL) - 1)
		ok
		if len(cL) >= 2
			aOut + substr(cL, 2, len(cL) - 2)
		ok
	next
	return aOut

# tells the stand-in how to behave: ok, fail or nofile
func IaMode(cMode)
	write(cToolDir + "/mode.txt", cMode + char(13) + char(10))

# runs the object o through an alias and says whether the stand-in ran
func IaViaAlias(cAlias, cDir)
	remove(cDir + "/argv.log")
	oA = new stzImgToAscii("my pic.png")
	eval("oA." + cAlias + "()")
	return fexists(cDir + "/argv.log")

# a converter whose temp folder name is empty, which cannot be created
class stzImgToAsciiBadTemp from stzImgToAscii
	@cTempDir = ""

# a converter that counts the viewer requests instead of opening a viewer, and shows its private parts
class stzImgToAsciiProbe from stzImgToAscii
	@nViewed = 0
	@cViewed = ""

	def OpenViewer(pcFile)
		@nViewed++
		@cViewed = pcFile

	def Viewed()
		return @nViewed

	def ViewedFile()
		return @cViewed

	def ArgsOf()
		return This.BuildArgs()

	def KeptContent()
		return @cContent

	def Ran()
		return @bRan

# a converter that exposes the real viewer step
class stzImgToAsciiViewer from stzImgToAscii

	def OpenIt(pcFile)
		This.OpenViewer(pcFile)
