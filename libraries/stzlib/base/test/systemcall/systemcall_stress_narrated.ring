# stzSystemCall STRESS -- running OS commands, and reading back what happened.
#
# The dangerous defect in a command runner is DOUBLE EXECUTION. This one used
# to run the command a SECOND time whenever it wanted the exit code and the
# first run produced no stdout -- so a command that writes a file, sends a
# request, or mutates anything did it TWICE. It also reported the wrong exit
# code whenever a failing command printed something, and threw stderr away.
# All three came from the same root: the engine captured stdout, stderr and
# the exit code in one run, but only stdout was handed back to Ring.
#
# Everything here uses SAFE, read-only or scratch-only commands (echo, exit,
# type, append into a scratch dir that is deleted at the end). Nothing
# destructive, nothing outside the scratch tree.
#
# cmd.exe wants BACKSLASH paths, built with char(92). Non-ASCII is built from
# raw codepoints.
#
# Ring traps avoided: main code before the first func; no local oR / nL / Try
# / Show.

load "../../stzBase.ring"

nPass = 0
nFail = 0

pr()

cBS  = char(92)
cAr  = MkW([ 0x0639, 0x0631, 0x0628, 0x064A ])          # Arabic
cCJK = MkW([ 0x6771, 0x4EAC ])                          # CJK

cRoot = StzReplace(currentdir() + "/_syscall_tmp", "/", cBS)
if StzDirExists(cRoot)
	StzDirDelete(cRoot)
ok
StzDirCreate(cRoot)

? "-- Scene 1: a command runs EXACTLY ONCE --"
# An append with no stdout used to trigger a re-run for the exit code, so the
# file gained two lines from one Run(). This is the headline defect.
cCount = cRoot + cBS + "count.txt"
oAp = new stzSystemCall("cmd.exe /c echo tick >> " + cCount)
oAp.CaptureError()
oAp.Run()
nT1 = 0
if fexists(cCount) nT1 = len(StzFindCS("tick", read(cCount), TRUE)) ok
chk("one Run() of an append command writes 'tick' ONCE, not twice", nT1 = 1)

# ...and a second Run() adds exactly one more.
oAp2 = new stzSystemCall("cmd.exe /c echo tick >> " + cCount)
oAp2.CaptureError()
oAp2.Run()
nT2 = len(StzFindCS("tick", read(cCount), TRUE))
chk("a second Run() writes 'tick' exactly once more", nT2 = 2)

? ""
? "-- Scene 2: the exit code is the REAL one --"
# Fails WITH output: the old code hardcoded 0 whenever stdout was non-empty.
oE1 = new stzSystemCall("cmd.exe /c echo hello & exit /b 3")
oE1.Run()
chk("a command that fails but prints still reports its real exit code", oE1.ExitCode() = 3)
chk("...and its output is intact", trim(oE1.Output()) = "hello")

# Fails with NO output.
oE2 = new stzSystemCall("cmd.exe /c exit /b 7")
oE2.CaptureError()
oE2.Run()
chk("a silent failure reports its exit code", oE2.ExitCode() = 7)

# Succeeds.
oE3 = new stzSystemCall("cmd.exe /c echo ok")
oE3.Run()
chk("a success reports exit 0", oE3.ExitCode() = 0)

? ""
? "-- Scene 3: Succeeded / Failed follow the exit code --"
# These read @nExitCode, so they were wrong exactly when it was.
oS1 = new stzSystemCall("cmd.exe /c exit /b 0")
oS1.Run()
oS2 = new stzSystemCall("cmd.exe /c echo x & exit /b 1")
oS2.Run()
chk("exit 0 -> Succeeded", oS1.Succeeded())
chk("exit 0 -> not Failed", oS1.Failed() = 0)
chk("exit 1 (with output) -> Failed", oS2.Failed())
chk("exit 1 (with output) -> not Succeeded", oS2.Succeeded() = 0)

? ""
? "-- Scene 4: stderr is captured, not discarded --"
oR1 = new stzSystemCall("cmd.exe /c echo oops 1>&2")
oR1.CaptureError()
oR1.Run()
chk("text written to stderr is captured", trim(oR1.Error()) = "oops")
chk("HasError sees it", oR1.HasError())

# stdout and stderr are kept separate.
oR2 = new stzSystemCall("cmd.exe /c echo OUT & echo ERR 1>&2")
oR2.CaptureError()
oR2.Run()
chk("stdout has only the stdout line", trim(oR2.Output()) = "OUT")
chk("stderr has only the stderr line", trim(oR2.Error()) = "ERR")

? ""
? "-- Scene 5: output capture is byte-clean --"
# ASCII exact.
oO1 = new stzSystemCall("cmd.exe /c echo the quick brown fox")
oO1.Run()
chk("ASCII output is exact", trim(oO1.Output()) = "the quick brown fox")

# Multibyte: cmd's own echo mangles non-ASCII via the OEM code page, so route
# the bytes through a file and `type` them -- that proves the ENGINE capture
# is byte-clean even though the shell's echo is not.
cArFile = cRoot + cBS + "ar.txt"
write(cArFile, cAr)
oO2 = new stzSystemCall("cmd.exe /c type " + cArFile)
oO2.Run()
chk("a UTF-8 file typed back survives byte-for-byte", oO2.Output() = cAr)

cCjkFile = cRoot + cBS + "cjk.txt"
write(cCjkFile, cCJK + " mixed " + cAr)
oO3 = new stzSystemCall("cmd.exe /c type " + cCjkFile)
oO3.Run()
chk("...mixed CJK and Arabic too", oO3.Output() = cCJK + " mixed " + cAr)

? ""
? "-- Scene 6: typed return values --"
oT1 = new stzSystemCall("cmd.exe /c echo 42 @RETURN:number")
oT1.Run()
chk("@RETURN:number yields a NUMBER", isNumber(oT1.Output()) and oT1.Output() = 42)

cLinesFile = cRoot + cBS + "lines.txt"
write(cLinesFile, "alpha" + nl + "beta" + nl + "gamma")
oT2 = new stzSystemCall("cmd.exe /c type " + cLinesFile + " @RETURN:list")
oT2.Run()
_aL_ = oT2.Output()
chk("@RETURN:list yields a LIST of the lines", isList(_aL_) and len(_aL_) = 3)
chk("...in order", _aL_[1] = "alpha" and _aL_[3] = "gamma")

? ""
? "-- Scene 7: arguments with spaces stay one argument --"
oG = new stzSystemCall("cmd.exe")
oG.AddArg("/c")
oG.AddArg("echo")
oG.AddArg("a b c")
oG.Run()
chk("a spaced argument is passed as one, not split", trim(oG.Output()) = "a b c")

? ""
? "-- Scene 8: one object reused for many commands --"
oRe = new stzSystemCall("cmd.exe /c echo first")
oRe.Run()
_c1_ = trim(oRe.Output())
oRe.SetProgram("cmd.exe")
oRe.ClearArgs()
oRe.AddArg("/c")
oRe.AddArg("echo")
oRe.AddArg("second")
oRe.Run()
_c2_ = trim(oRe.Output())
chk("the first run's output is correct", _c1_ = "first")
chk("the reused object's second run is independent", _c2_ = "second")

? ""
? "-- Scene 9: scale -- a big capture, and many runs --"
cBigFile = cRoot + cBS + "big.txt"
cBig = ""
for i = 1 to 5000
	cBig += "line " + i + nl
next
write(cBigFile, cBig)
oB = new stzSystemCall("cmd.exe /c type " + cBigFile)
t0 = clock()
oB.Run()
tBig = (clock() - t0) / clockspersecond()
? "  5000-line capture in " + tBig + " s (" + len(oB.Output()) + " bytes)"
chk("a large capture is fast (< 5s)", tBig < 5)
chk("...and complete (all 5000 lines present)", StzFindFirst("line 5000", oB.Output()) > 0)

t0 = clock()
for i = 1 to 50
	oM = new stzSystemCall("cmd.exe /c echo " + i)
	oM.Run()
next
tMany = (clock() - t0) / clockspersecond()
? "  50 sequential commands in " + tMany + " s"
chk("50 sequential runs finish in reasonable time (< 20s)", tMany < 20)

? ""
? "-- cleanup --"
# StzDirDelete removes an EMPTY directory only, so clear the files first.
_oClean_ = new stzFolder(cRoot)
_aFiles_ = _oClean_.Files()
_nCl_ = len(_aFiles_)
for _i_ = 1 to _nCl_
	_cName_ = _aFiles_[_i_]
	if len(_cName_) > 0 and (_cName_[1] = "/" or _cName_[1] = cBS)
		_cName_ = substr(_cName_, 2, len(_cName_) - 1)
	ok
	StzFileDelete(cRoot + cBS + _cName_)
next
StzDirDelete(cRoot)
chk("scratch tree removed", StzDirExists(cRoot) = 0)

? ""
? "=========================================="
? "TOTAL: " + (nPass + nFail) + " assertions, " + nPass + " pass, " + nFail + " fail"
? "=========================================="

pf()

func chk cLabel, bCond
	if bCond
		nPass++
		? "  [OK] " + cLabel
	else
		nFail++
		? "  [FAIL] " + cLabel
	ok

func EncCp c
	if c < 128
		return char(c)
	but c < 2048
		return char(192 + floor(c/64)) + char(128 + (c % 64))
	but c < 65536
		return char(224 + floor(c/4096)) + char(128 + floor((c%4096)/64)) + char(128 + (c%64))
	else
		return char(240 + floor(c/262144)) + char(128 + floor((c%262144)/4096)) +
		       char(128 + floor((c%4096)/64)) + char(128 + (c%64))
	ok

func MkW aCp
	cW = ""
	_nCount_ = len(aCp)
	for _k_ = 1 to _nCount_
		cW += EncCp(aCp[_k_])
	next
	return cW
