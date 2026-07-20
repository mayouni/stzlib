# stzProcess CHILD (Phase 1) STRESS -- managed child processes.
#
# The difference from stzSystemCall (spawn, drain, return everything at once):
# a MANAGED child is started, its output STREAMED while it runs, then waited
# on or KILLED. This is what a long-running or streaming child needs.
#
# SAFE commands only (echo, exit, ping to loopback which we kill). A scratch
# dir is created and removed. cmd.exe wants BACKSLASH paths (char 92); an
# ampersand in a command is built with char(38) because a literal & in a Ring
# string upsets the parser.
#
# The lifecycle contract under test: Spawn -> ReadOutput* to EOF -> Wait, then
# Close(); Kill() ends a running child; Close() on a running child does not
# leak it.
#
# Ring traps avoided: main code before the first func; no inline new X().M();
# no literal & in a string; no local oR / nL / Try / Show.

load "../../stzBase.ring"

nPass = 0
nFail = 0

pr()

cAmp = char(38)     # &

? "-- Scene 1: spawn, stream stdout to EOF, wait --"
oC = SpawnProcess("cmd.exe /c echo alpha " + cAmp + " echo beta " + cAmp + " echo gamma")
chk("the child has a positive pid", oC.ChildPid() > 0)
chk("HasChild reports the managed child", oC.HasChild())

cCollected = ""
nChunks = 0
cChunk = oC.ReadOutput()
while cChunk != ""
	cCollected += cChunk
	nChunks = nChunks + 1
	cChunk = oC.ReadOutput()
end
nExit = oC.Wait()
chk("all three lines were streamed",
	StzFindFirst("alpha", cCollected) > 0 and StzFindFirst("beta", cCollected) > 0 and StzFindFirst("gamma", cCollected) > 0)
chk("the child exited 0", nExit = 0)
chk("Succeeded() agrees", oC.Succeeded())
chk("at least one chunk was read", nChunks >= 1)
oC.Close()
chk("HasChild is false after Close", oC.HasChild() = 0)

? ""
? "-- Scene 2: ReadOutputAll convenience --"
oC2 = SpawnProcess("cmd.exe /c echo one " + cAmp + " echo two")
cOut = oC2.ReadOutputAll()
chk("Output() collects the whole stream",
	StzFindFirst("one", cOut) > 0 and StzFindFirst("two", cOut) > 0)
chk("ExitCode() is 0 after draining", oC2.ExitCode() = 0)
oC2.Close()

? ""
? "-- Scene 3: a failing child reports its real exit code --"
oF = SpawnProcess("cmd.exe /c exit /b 9")
_cDrain_ = oF.ReadOutputAll()
chk("a child that exits 9 reports 9", oF.Wait() = 9)
chk("Failed() agrees", oF.Failed())
oF.Close()

? ""
? "-- Scene 4: a child that writes to stderr --"
oE = SpawnProcess("cmd.exe /c echo boom 1>" + cAmp + "2")
_cO_ = oE.ReadOutputAll()
cErr = oE.ReadErrorAll()
chk("stderr is captured on the child's error stream", StzFindFirst("boom", cErr) > 0)
oE.Close()

? ""
? "-- Scene 5: kill a long-running child --"
oK = SpawnProcess("cmd.exe /c ping -n 30 127.0.0.1")
nKilledPid = oK.ChildPid()
chk("the long child is running (has a pid)", nKilledPid > 0)
t0 = clock()
chk("Kill() returns success", oK.Kill())
tKill = (clock() - t0) / clockspersecond()
chk("...and returns promptly, not after the ping finishes (< 5s)", tKill < 5)
oK.Close()
chk("HasChild is false after killing and closing", oK.HasChild() = 0)

? ""
? "-- Scene 6: Close() on a still-running child does not hang or leak --"
oD = SpawnProcess("cmd.exe /c ping -n 30 127.0.0.1")
t0 = clock()
oD.Close()
tClose = (clock() - t0) / clockspersecond()
chk("Close on a running child returns promptly (< 5s)", tClose < 5)
chk("...and the child is released", oD.HasChild() = 0)

? ""
? "-- Scene 7: a control method with no child raises, not crashes --"
oN = new stzProcess()
bRaised = FALSE
try
	oN.Wait()
catch
	bRaised = TRUE
done
chk("Wait() on a child-less process raises cleanly", bRaised)
chk("...and HasChild is false", oN.HasChild() = 0)

? ""
? "-- Scene 8: the SAME class still does introspection --"
oI = new stzProcess()
chk("introspection works alongside the control face", oI.BitSize() = 64 or oI.BitSize() = 32)
chk("a plain process object has no child", oI.HasChild() = 0)

? ""
? "-- Scene 9: many short children in sequence --"
t0 = clock()
nOk = 0
for i = 1 to 30
	oS = SpawnProcess("cmd.exe /c echo n" + i)
	cR = oS.ReadOutputAll()
	if StzFindFirst("n" + i, cR) > 0 and oS.Wait() = 0
		nOk = nOk + 1
	ok
	oS.Close()
next
tMany = (clock() - t0) / clockspersecond()
? "  30 spawn/read/wait/close cycles in " + tMany + " s"
chk("30 child cycles all succeeded", nOk = 30)
chk("...in reasonable time (< 20s)", tMany < 20)

? ""
? "-- Scene 10: a nonexistent program answers, not crashes --"
oBad = SpawnProcess("this_program_does_not_exist_stz_12345")
_cBadOut_ = oBad.ReadOutputAll()
chk("a missing program yields a non-zero exit, no crash", oBad.Wait() != 0)
oBad.Close()

? ""
? "-- Scene 11: output larger than one read buffer (many chunks) --"
# 3000 lines forces the 64KB read to return in multiple chunks -- the
# streaming loop must reassemble them without loss.
cLoopCmd = "cmd.exe /c for /L %i in (1,1,3000) do @echo item-%i"
oBig = SpawnProcess(cLoopCmd)
cGot = ""
nBigChunks = 0
cChunk = oBig.ReadOutput()
while cChunk != ""
	cGot += cChunk
	nBigChunks = nBigChunks + 1
	cChunk = oBig.ReadOutput()
end
oBig.Wait()
oBig.Close()
? "  " + len(cGot) + " bytes over " + nBigChunks + " chunk(s)"
chk("the last line survived the multi-chunk stream", StzFindFirst("item-3000", cGot) > 0)
chk("the first line is there too", StzFindFirst("item-1", cGot) > 0)
chk("it genuinely spanned more than one chunk", nBigChunks > 1)

? ""
? "-- Scene 12: Close is idempotent --"
oDbl = SpawnProcess("cmd.exe /c echo hi")
_cH_ = oDbl.ReadOutputAll()
oDbl.Close()
oDbl.Close()
chk("a second Close does not crash and leaves no child", oDbl.HasChild() = 0)

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
