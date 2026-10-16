load "../../stzBase.ring"
load "../_narrated.ring"

# stzFileManager and its neighbours in base/file/stzFile.ring -- the register rows, run on invented files.
#
# THE ROOT CAUSE this guard pins: the path helpers _FileName, _FileDirPath, _FileExtension and
# _FileCompleteBaseName were written BETWEEN two classes, so Ring made them methods of stzFileXT and
# every stzFileManager call that used one raised R3. They are global functions now.
#
# SAFETY. This suite copies, moves, renames, splits, zips and DELETES files. Every one of those calls
# runs inside ONE fixture folder, <this folder>/_fixture, created fresh at the start and removed at the
# end. Every path handed to the library is built by FxP(), and FxGuard() refuses -- before the call --
# any path that is relative, contains .., is the fixture root itself, or does not start with the
# fixture root. Delete/Remove/SafeDelete are only ever tried on files this suite has just written there.
#
# Content is compared byte for byte (= is case sensitive on Ring strings), with a Hebrew line, a CRLF
# file, an empty file, a binary string with a NUL, a file name with no extension inside a folder whose
# name has a dot, and a Hebrew file name. Run from inside this folder. ASCII only on the console.

$cFx = StzReplace(currentdir(), "\", "/") + "/_fixture"
if FxRootOk() = 0
	? "GUARD: the fixture root is not acceptable: " + $cFx
	shutdown(9)
ok
FxRemoveRoot()
StzDirCreatePath($cFx)

cLF = char(10)
cCRet = char(13)
cHeb1 = "שלום"
cHeb2 = "עולם"
cText = "alpha" + cLF + cHeb1 + " " + cHeb2 + cLF + "gamma"
cBin = "ab" + char(0) + "cd" + cCRet + cLF + "e" + char(255)

Scenario("The path helpers are global functions, and read every shape of path alike")
	Then("the last segment of a path is its file name", _FileName("d.v1/Makefile"), "Makefile")
	Then("the extension comes without its dot", _FileExtension("x/a.tar.gz"), "gz")
	Then("a dot in a FOLDER name is not an extension", _FileExtension("d.v1/Makefile"), "")
	Then("a name that only starts with a dot has no extension", _FileExtension(".hid"), "")
	Then("the complete base name drops only the last extension", _FileCompleteBaseName("a.tar.gz"), "a.tar")
	Then("and a name with no extension stays whole", _FileCompleteBaseName("d.v1/Makefile"), "Makefile")
	Then("the folder part of a nested path", _FileDirPath("a/b/c.txt"), "a/b")
	Then("a backslash path is read too", _FileDirPath("a\b\c.txt"), "a\b")
	Then("a bare name lives in .", _FileDirPath("c.txt"), ".")
	Then("a file at the root has an empty folder part", _FileDirPath("/c.txt"), "")
	Then("a Hebrew file name comes back whole", _FileName("d/" + cHeb1 + ".txt"), cHeb1 + ".txt")
	Then("and its extension is txt", _FileExtension("d/" + cHeb1 + ".txt"), "txt")
	cStamp = _FileBackupStamp()
	Then("the backup stamp has 15 characters", len(cStamp), 15)
	Then("the stamp has no slash", StzFindFirst("/", cStamp), 0)
	Then("the stamp has no colon", StzFindFirst(":", cStamp), 0)
	Then("the stamp joins date and time with an underscore", StzMid(cStamp, 9, 1), "_")
	Then("one place is one place whatever the separator and the case", _FileSamePath("./A\b.txt", "a/B.txt"), iif(isWindows(), 1, 0))
	Then("two places are two places", _FileSamePath("a/b.txt", "a/c.txt"), 0)
	oXTProbe = new stzFileXT(FxP("none.txt"), "info")
	Then("the helpers are no longer methods of stzFileXT", isMethod(oXTProbe, "_FileName"), 0)
	Then("and stzFileXT has the method it really owns", isMethod(oXTProbe, "Intent"), 1)
EndScenario()

Scenario("CopyTo, CopyAs, CopyToAs: the copy is byte for byte, the original stays, a bad target changes nothing")
	FxReset("copy")
	FxMakeDir("copy/out")
	FxMakeDir("copy/d.v1")
	FxWrite("copy/a.txt", cText)
	oM = FxMgr("copy/a.txt")
	Then("CopyTo into an existing folder answers 1", oM.CopyTo(FxP("copy/out")), 1)
	Then("the copy has the same bytes (Hebrew line included)", FxRead("copy/out/a.txt"), cText)
	Then("the original is still there", FxExists("copy/a.txt"), 1)
	Then("and has not changed", FxRead("copy/a.txt"), cText)
	Then("the manager still points at the original", oM.FileName(), FxP("copy/a.txt"))
	Then("CopyTo a folder that does not exist answers 0", oM.CopyTo(FxP("copy/nodir")), 0)
	Then("and creates no folder", FxDirExists("copy/nodir"), 0)
	Then("CopyTo the folder the file is in answers 0, it cannot copy onto itself", oM.CopyTo(FxP("copy")), 0)
	Then("and the file is intact", FxRead("copy/a.txt"), cText)
	Then("CopyTo the empty text answers 0", oM.CopyTo(""), 0)
	Then("CopyAs a new name in the same folder answers 1", oM.CopyAs("a2.txt"), 1)
	Then("the new name holds the same bytes", FxRead("copy/a2.txt"), cText)
	Then("CopyAs its own name answers 0", oM.CopyAs("a.txt"), 0)
	Then("and leaves the file intact", FxRead("copy/a.txt"), cText)
	Then("CopyAs the empty text answers 0", oM.CopyAs(""), 0)
	Then("CopyToAs a folder and a name answers 1", oM.CopyToAs(FxP("copy/out"), "b.txt"), 1)
	Then("it holds the same bytes", FxRead("copy/out/b.txt"), cText)
	Then("CopyToAs a missing folder answers 0", oM.CopyToAs(FxP("copy/nodir"), "b.txt"), 0)
	FxWrite("copy/empty.txt", "")
	oE = FxMgr("copy/empty.txt")
	Then("an empty file is copied", oE.CopyTo(FxP("copy/out")), 1)
	Then("the copy exists", FxExists("copy/out/empty.txt"), 1)
	Then("and is empty too", StzEngineFileSize(FxP("copy/out/empty.txt")), 0)
	FxWrite("copy/d.v1/Makefile", "all:" + cLF + "x")
	oK = FxMgr("copy/d.v1/Makefile")
	Then("a file with no extension in a folder with a dot is copied", oK.CopyAs("Makefile2"), 1)
	Then("next to the original, not in a folder named after the dot", FxExists("copy/d.v1/Makefile2"), 1)
	FxWrite("copy/" + cHeb1 + ".txt", cText)
	oH = FxMgr("copy/" + cHeb1 + ".txt")
	Then("a Hebrew file name is copied under the same name", oH.CopyTo(FxP("copy/out")), 1)
	Then("it exists under the Hebrew name", FxExists("copy/out/" + cHeb1 + ".txt"), 1)
	Then("with the same bytes", FxRead("copy/out/" + cHeb1 + ".txt"), cText)
EndScenario()

Scenario("MoveTo, MoveAs, MoveToAs, RenameAs: the original is gone after a move, kept when the move fails")
	FxReset("move")
	FxMakeDir("move/out")
	FxWrite("move/m1.txt", cText)
	oM = FxMgr("move/m1.txt")
	Then("MoveTo an existing folder answers 1", oM.MoveTo(FxP("move/out")), 1)
	Then("the original is gone", FxExists("move/m1.txt"), 0)
	Then("the file is in the folder with the same bytes", FxRead("move/out/m1.txt"), cText)
	Then("FileName follows the file", oM.FileName(), FxP("move/out") + "/m1.txt")
	Then("MoveAs a new name in that folder answers 1", oM.MoveAs("m3.txt"), 1)
	Then("the old name is gone", FxExists("move/out/m1.txt"), 0)
	Then("the new name holds the bytes", FxRead("move/out/m3.txt"), cText)
	Then("MoveAs its own name answers 1", oM.MoveAs("m3.txt"), 1)
	Then("and does NOT delete the file", FxExists("move/out/m3.txt"), 1)
	Then("with its bytes", FxRead("move/out/m3.txt"), cText)
	Then("MoveTo the folder it is already in answers 1", oM.MoveTo(FxP("move/out")), 1)
	Then("and does NOT delete the file", FxRead("move/out/m3.txt"), cText)
	Then("RenameAs a new name answers 1", oM.RenameAs("r.txt"), 1)
	Then("the old name is gone", FxExists("move/out/m3.txt"), 0)
	Then("the renamed file holds the bytes", FxRead("move/out/r.txt"), cText)
	Then("RenameAs the empty text answers 0", oM.RenameAs(""), 0)
	Then("and the file stays", FxExists("move/out/r.txt"), 1)
	FxWrite("move/m2.txt", cText)
	oN = FxMgr("move/m2.txt")
	Then("MoveTo a folder that does not exist answers 0", oN.MoveTo(FxP("move/nodir")), 0)
	Then("the original stays where it was", FxRead("move/m2.txt"), cText)
	Then("FileName did not change", oN.FileName(), FxP("move/m2.txt"))
	Then("MoveTo the empty text answers 0", oN.MoveTo(""), 0)
	Then("MoveToAs a missing folder answers 0", oN.MoveToAs(FxP("move/nodir"), "z.txt"), 0)
	Then("and the original stays", FxExists("move/m2.txt"), 1)
	Then("MoveToAs a folder and a name answers 1", oN.MoveToAs(FxP("move/out"), "z.txt"), 1)
	Then("the original is gone", FxExists("move/m2.txt"), 0)
	Then("the new file holds the bytes", FxRead("move/out/z.txt"), cText)
	FxWrite("move/empty.txt", "")
	oE = FxMgr("move/empty.txt")
	Then("an empty file moves", oE.MoveTo(FxP("move/out")), 1)
	Then("it is empty in its new place", FxExists("move/out/empty.txt") + StzEngineFileSize(FxP("move/out/empty.txt")), 1)
	FxMakeDir("move/d.v1")
	FxWrite("move/d.v1/Makefile", "all:")
	oK = FxMgr("move/d.v1/Makefile")
	Then("a file with no extension in a dotted folder is renamed in place", oK.RenameAs("Makefile.old"), 1)
	Then("it is next to where it was", FxRead("move/d.v1/Makefile.old"), "all:")
	Then("and the old name is gone", FxExists("move/d.v1/Makefile"), 0)
EndScenario()

$cStzFrozenDate = "16/10/2026"
$cStzFrozenTime = "01:02:03"

Scenario("Backup writes a copy named file.backup.<yyyyMMdd_HHmmss> and says 1 only when it did")
	FxReset("bak")
	FxMakeDir("bak/d.v1")
	FxWrite("bak/a.txt", cText)
	oM = FxMgr("bak/a.txt")
	Then("Backup answers 1", oM.Backup(), 1)
	Then("the file has the documented shape", FxExists("bak/a.txt.backup.20261016_010203"), 1)
	Then("it holds the same bytes", FxRead("bak/a.txt.backup.20261016_010203"), cText)
	Then("the original is untouched", FxRead("bak/a.txt"), cText)
	Then("the folder holds the original and the backup, nothing else", @@(FxLs("bak")), @@([ "a.txt", "a.txt.backup.20261016_010203" ]))
	Then("a second Backup in the same second answers 1", oM.Backup(), 1)
	Then("it is named with _2 and does not replace the first", FxRead("bak/a.txt.backup.20261016_010203_2"), cText)
	FxWrite("bak/a.txt.backup.20261016_010203", "an older backup, kept")
	Then("an existing backup is never replaced", oM.Backup() + FxExists("bak/a.txt.backup.20261016_010203_3"), 2)
	Then("the older backup still says what it said", FxRead("bak/a.txt.backup.20261016_010203"), "an older backup, kept")
	$cStzFrozenDate = ""
	$cStzFrozenTime = ""
	FxWrite("bak/live.txt", "x")
	oL = FxMgr("bak/live.txt")
	Then("with the real clock Backup answers 1", oL.Backup(), 1)
	aLive = FxLsLike("bak", "live.txt.backup.")
	Then("one file carries the real stamp", len(aLive), 1)
	Then("its name is the prefix and 15 stamp characters", len(aLive[1]), len("live.txt.backup.") + 15)
	Then("and holds the bytes", FxRead("bak/" + aLive[1]), "x")
	$cStzFrozenDate = "16/10/2026"
	$cStzFrozenTime = "01:02:03"
	FxWrite("bak/gone.txt", "x")
	oG = FxMgr("bak/gone.txt")
	FxRemove("bak/gone.txt")
	Then("Backup of a file that vanished answers 0, not 1", oG.Backup(), 0)
	Then("and writes nothing", len(FxLsLike("bak", "gone.txt.backup.")), 0)
EndScenario()

Scenario("CreateBackup and CreateBackupAs give the path of the copy, or the empty text")
	FxReset("cb")
	FxMakeDir("cb/d.v1")
	FxWrite("cb/a.txt", cText)
	oM = FxMgr("cb/a.txt")
	cPath = oM.CreateBackup()
	Then("CreateBackup gives the stamped path", cPath, FxP("cb/a_backup_20261016_010203.txt"))
	Then("the copy exists with the same bytes", FxRead("cb/a_backup_20261016_010203.txt"), cText)
	Then("the original is untouched", FxRead("cb/a.txt"), cText)
	cPath2 = oM.CreateBackup()
	Then("a second backup in the same second gets another path", cPath2, FxP("cb/a_backup_20261016_010203_2.txt"))
	Then("and the first one is still there", FxRead("cb/a_backup_20261016_010203.txt"), cText)
	FxWrite("cb/d.v1/Makefile", "all:")
	oK = FxMgr("cb/d.v1/Makefile")
	Then("a name with no extension gets no trailing dot (and the dot of the folder is not used)",
		oK.CreateBackup(), FxP("cb/d.v1/Makefile_backup_20261016_010203"))
	Then("CreateBackupAs gives the path of a named copy", oM.CreateBackupAs("keep.txt"), FxP("cb/keep.txt"))
	Then("it holds the same bytes", FxRead("cb/keep.txt"), cText)
	Then("CreateBackupAs its own name gives the empty text", oM.CreateBackupAs("a.txt"), "")
	Then("CreateBackupAs the empty text gives the empty text", oM.CreateBackupAs(""), "")
	Then("and the original is intact after both", FxRead("cb/a.txt"), cText)
	FxWrite("cb/gone.txt", "x")
	oG = FxMgr("cb/gone.txt")
	FxRemove("cb/gone.txt")
	Then("CreateBackup of a vanished file gives the empty text", oG.CreateBackup(), "")
	Then("and CreateBackupAs too", oG.CreateBackupAs("g2.txt"), "")
	Then("nothing was written for it", FxExists("cb/g2.txt"), 0)
EndScenario()

Scenario("SafeDelete and SafeRemove keep a backup, then delete; Delete alone keeps nothing")
	FxReset("sd")
	FxWrite("sd/s.txt", cText)
	oM = FxMgr("sd/s.txt")
	Then("SafeDelete answers 1", oM.SafeDelete(), 1)
	Then("the file is gone", FxExists("sd/s.txt"), 0)
	Then("the manager is closed", oM.IsClosed(), 1)
	Then("the backup is there with the same bytes", FxRead("sd/s_backup_20261016_010203.txt"), cText)
	FxWrite("sd/t.txt", "second")
	oT = FxMgr("sd/t.txt")
	oT.SafeRemove()
	Then("SafeRemove deletes the file too", FxExists("sd/t.txt"), 0)
	Then("and keeps its backup", FxRead("sd/t_backup_20261016_010203.txt"), "second")
	FxWrite("sd/u.txt", "plain")
	oU = FxMgr("sd/u.txt")
	Then("Delete answers 1", oU.Delete(), 1)
	Then("it leaves no backup", len(FxLsLike("sd", "u_backup_")), 0)
	FxWrite("sd/v.txt", "stays")
	oV = FxMgr("sd/v.txt")
	FxRemove("sd/v.txt")
	bRaised = 0
	cMsg = ""
	try
		oV.SafeDelete()
	catch
		bRaised = 1
		cMsg = cCatchError
	done
	Then("SafeDelete raises when the backup cannot be made", bRaised, 1)
	Then("and says why", StzFindFirst("Cannot create backup before deletion", cMsg) > 0, 1)
	Then("no backup was written for it", len(FxLsLike("sd", "v_backup_")), 0)
	Then("the manager is not closed by the failure", oV.IsClosed(), 0)
EndScenario()

Scenario("SplitByLines: parts of N lines, joined they are the original")
	FxReset("sp")
	FxMakeDir("sp/d.v1")
	cFive = "1" + cLF + "2" + cLF + "3" + cLF + "4" + cLF + "5"
	FxWrite("sp/five.txt", cFive)
	oM = FxMgr("sp/five.txt")
	aP = oM.SplitByLines(2)
	Then("SplitByLines(2) of 5 lines gives 3 parts", len(aP), 3)
	Then("they are named name_1.ext, name_2.ext, name_3.ext", @@(aP), @@([ FxP("sp/five_1.txt"), FxP("sp/five_2.txt"), FxP("sp/five_3.txt") ]))
	Then("the first part has 2 lines", FxLineCount(FxRead("sp/five_1.txt")), 2)
	Then("the second part has 2 lines", FxLineCount(FxRead("sp/five_2.txt")), 2)
	Then("the third part has 1 line", FxLineCount(FxRead("sp/five_3.txt")), 1)
	Then("the first part is lines 1 and 2", FxRead("sp/five_1.txt"), "1" + cLF + "2" + cLF)
	Then("the parts joined are the original, byte for byte", FxRead("sp/five_1.txt") + FxRead("sp/five_2.txt") + FxRead("sp/five_3.txt"), cFive)
	Then("the original is untouched", FxRead("sp/five.txt"), cFive)
	bRaised = 0
	cMsg = ""
	try
		oM.SplitByLines(2)
	catch
		bRaised = 1
		cMsg = cCatchError
	done
	Then("splitting again raises, the parts are taken", bRaised, 1)
	Then("and says so", StzFindFirst("already exists", cMsg) > 0, 1)
	Then("the parts of the first split were not overwritten", FxRead("sp/five_3.txt"), "5")
	FxWrite("sp/q.txt", "a" + cLF + "b")
	oQ = FxMgr("sp/q.txt")
	aBad = [ 0, -1, 1.5, "x" ]
	nBad = len(aBad)
	nRaised = 0
	for i = 1 to nBad
		try
			oQ.SplitByLines(aBad[i])
		catch
			nRaised++
		done
	next
	Then("0, -1, 1.5 and a text are all refused", nRaised, 4)
	Then("and no part was written for them", len(FxLsLike("sp", "q_")), 0)
	FxWrite("sp/hund.txt", cFive)
	Then("100 lines per part of a 5 line file gives one part", len(FxLines("sp/hund.txt", 100)), 1)
	Then("equal to the file", FxRead("sp/hund_1.txt"), cFive)
EndScenario()

Scenario("SplitByLines: the awkward files")
	FxReset("sp2")
	FxMakeDir("sp2/d.v1")
	cHebLines = cHeb1 + cLF + cHeb2 + cLF + "abc"
	FxWrite("sp2/heb.txt", cHebLines)
	aP = FxLines("sp2/heb.txt", 2)
	Then("a Hebrew file gives 2 parts", len(aP), 2)
	Then("joined they are the original, Hebrew bytes included", FxRead("sp2/heb_1.txt") + FxRead("sp2/heb_2.txt"), cHebLines)
	Then("the first part holds the two Hebrew lines", FxRead("sp2/heb_1.txt"), cHeb1 + cLF + cHeb2 + cLF)
	cCrlf = "a" + cCRet + cLF + "b" + cCRet + cLF + "c" + cCRet + cLF
	FxWrite("sp2/crlf.txt", cCrlf)
	aP = FxLines("sp2/crlf.txt", 2)
	Then("a CRLF file with a final line break gives 2 parts", len(aP), 2)
	Then("the line breaks are kept as they were", FxRead("sp2/crlf_1.txt") + FxRead("sp2/crlf_2.txt"), cCrlf)
	Then("and the last part is the last line alone", FxRead("sp2/crlf_2.txt"), "c" + cCRet + cLF)
	FxWrite("sp2/trail.txt", "1" + cLF + "2" + cLF + "3" + cLF)
	aP = FxLines("sp2/trail.txt", 2)
	Then("a final line break does not make an extra empty line", len(aP), 2)
	Then("the last part keeps it", FxRead("sp2/trail_2.txt"), "3" + cLF)
	FxWrite("sp2/blank.txt", "a" + cLF + cLF + cLF + "b")
	aP = FxLines("sp2/blank.txt", 1)
	Then("blank lines count as lines", len(aP), 4)
	Then("and join back", FxRead("sp2/blank_1.txt") + FxRead("sp2/blank_2.txt") + FxRead("sp2/blank_3.txt") + FxRead("sp2/blank_4.txt"), "a" + cLF + cLF + cLF + "b")
	FxWrite("sp2/empty.txt", "")
	aP = FxLines("sp2/empty.txt", 2)
	Then("an empty file gives no part", len(aP), 0)
	Then("and writes none", len(FxLsLike("sp2", "empty_")), 0)
	FxWrite("sp2/d.v1/Makefile", "a" + cLF + "b" + cLF + "c")
	aP = FxLines("sp2/d.v1/Makefile", 2)
	Then("a file with no extension in a dotted folder: first part", aP[1], FxP("sp2/d.v1/Makefile_1"))
	Then("second part, no trailing dot", aP[2], FxP("sp2/d.v1/Makefile_2"))
	Then("the parts hold the lines", FxRead("sp2/d.v1/Makefile_1") + FxRead("sp2/d.v1/Makefile_2"), "a" + cLF + "b" + cLF + "c")
EndScenario()

Scenario("SplitBySize and SplitByPattern")
	FxReset("sp3")
	FxWrite("sp3/size.txt", "abcdefghij")
	aP = FxSize("sp3/size.txt", 4)
	Then("SplitBySize(4) of 10 bytes gives 3 parts", len(aP), 3)
	Then("the parts are abcd, efgh and ij", FxRead("sp3/size_1.txt") + "|" + FxRead("sp3/size_2.txt") + "|" + FxRead("sp3/size_3.txt"), "abcd|efgh|ij")
	Then("the original is untouched", FxRead("sp3/size.txt"), "abcdefghij")
	FxWrite("sp3/hebs.txt", cHeb1)
	aP = FxSize("sp3/hebs.txt", 3)
	Then("a Hebrew word of 8 bytes cut by 3 bytes gives 3 parts", len(aP), 3)
	Then("the cut counts bytes: 3, 3 and 2", StzEngineFileSize(FxP("sp3/hebs_1.txt")) * 100 + StzEngineFileSize(FxP("sp3/hebs_2.txt")) * 10 + StzEngineFileSize(FxP("sp3/hebs_3.txt")), 332)
	Then("joined the parts are the Hebrew word again", FxRead("sp3/hebs_1.txt") + FxRead("sp3/hebs_2.txt") + FxRead("sp3/hebs_3.txt"), cHeb1)
	FxWrite("sp3/bin.dat", cBin)
	aP = FxSize("sp3/bin.dat", 4)
	Then("a binary string of 9 bytes with a NUL and a high byte is split in 3", len(aP), 3)
	Then("and joins back byte for byte", FxRead("sp3/bin_1.dat") + FxRead("sp3/bin_2.dat") + FxRead("sp3/bin_3.dat"), cBin)
	FxWrite("sp3/big.txt", "ab")
	Then("a size larger than the file gives one part", len(FxSize("sp3/big.txt", 100)), 1)
	FxWrite("sp3/e.txt", "")
	Then("an empty file gives no part", len(FxSize("sp3/e.txt", 4)), 0)
	oS = FxMgr("sp3/size.txt")
	nRaised = 0
	aBad = [ 0, -3, 2.5, "x" ]
	for i = 1 to 4
		try
			oS.SplitBySize(aBad[i])
		catch
			nRaised++
		done
	next
	Then("0, -3, 2.5 and a text are refused", nRaised, 4)
	cPat = "head" + cLF + "## one" + cLF + "x" + cLF + "## two" + cLF + "y"
	FxWrite("sp3/pat.txt", cPat)
	aP = FxPattern("sp3/pat.txt", "##")
	Then("SplitByPattern opens a part at every matching line: 3 parts", len(aP), 3)
	Then("the first part is the lines before the first match", FxRead("sp3/pat_1.txt"), "head" + cLF)
	Then("the second starts at its matching line", FxRead("sp3/pat_2.txt"), "## one" + cLF + "x" + cLF)
	Then("the third is the last", FxRead("sp3/pat_3.txt"), "## two" + cLF + "y")
	Then("joined they are the original", FxRead("sp3/pat_1.txt") + FxRead("sp3/pat_2.txt") + FxRead("sp3/pat_3.txt"), cPat)
	FxWrite("sp3/first.txt", "## a" + cLF + "b" + cLF + "## c")
	aP = FxPattern("sp3/first.txt", "##")
	Then("a match on the very first line leaves no empty part before it", len(aP), 2)
	Then("the first part starts with that line", FxRead("sp3/first_1.txt"), "## a" + cLF + "b" + cLF)
	FxWrite("sp3/none.txt", "abc" + cLF + "def")
	aP = FxPattern("sp3/none.txt", "zzz")
	Then("a pattern found nowhere gives one part", len(aP), 1)
	Then("equal to the file", FxRead("sp3/none_1.txt"), "abc" + cLF + "def")
	FxWrite("sp3/case.txt", "abc" + cLF + "ABC" + cLF + "abc")
	aP = FxPattern("sp3/case.txt", "ABC")
	Then("the pattern is case sensitive: only the capital line opens a part", len(aP), 2)
	FxWrite("sp3/hp.txt", cHeb1 + cLF + "## " + cHeb2 + cLF + cHeb1)
	aP = FxPattern("sp3/hp.txt", cHeb2)
	Then("a Hebrew pattern works", len(aP), 2)
	Then("and the parts join back", FxRead("sp3/hp_1.txt") + FxRead("sp3/hp_2.txt"), cHeb1 + cLF + "## " + cHeb2 + cLF + cHeb1)
	bRaised = 0
	try
		FxPattern("sp3/none.txt", "")
	catch
		bRaised = 1
	done
	Then("the empty pattern is refused", bRaised, 1)
EndScenario()

Scenario("ZipBackup: a stamped or a named archive in the file's own folder")
	FxReset("zip")
	FxWrite("zip/z.txt", cText)
	oM = FxMgr("zip/z.txt")
	Then("before the call there is no archive", len(FxLsLike("zip", "z_backup_")), 0)
	oM.ZipBackup("")
	Then("the empty name gives a stamped archive name", FxExists("zip/z_backup_20261016_010203.zip"), 1)
	Then("it is not empty", StzEngineFileSize(FxP("zip/z_backup_20261016_010203.zip")) > 0, 1)
	Then("it is a zip (PK header)", left(read(FxP("zip/z_backup_20261016_010203.zip")), 2), "PK")
	oM.ZipBackup("named.zip")
	Then("a given name is used as it is", FxExists("zip/named.zip"), 1)
	Then("and it is a zip too", left(read(FxP("zip/named.zip")), 2), "PK")
	Then("the zipped file itself is untouched", FxRead("zip/z.txt"), cText)
	Then("no file name in the folder has a colon", StzFindFirst(":", @@(FxLs("zip"))), 0)
EndScenario()

$cStzFrozenDate = ""
$cStzFrozenTime = ""

Scenario("IsExecutable goes by the extension, whatever the folder name")
	FxReset("ex")
	FxMakeDir("ex/d.exe")
	FxWrite("ex/prog.exe", "MZ")
	FxWrite("ex/run.BAT", "echo")
	FxWrite("ex/a.txt", "t")
	FxWrite("ex/d.exe/Makefile", "t")
	FxWrite("ex/exe", "t")
	nWin = isWindows()
	Then("stzFileInfo: prog.exe is executable", FxExecInfo("ex/prog.exe"), 1)
	Then("stzFileInfo: run.BAT is executable, the case is ignored", FxExecInfo("ex/run.BAT"), 1)
	Then("stzFileInfo: a.txt is not", FxExecInfo("ex/a.txt"), 0)
	Then("stzFileInfo: a file with no extension in a folder named d.exe is not", FxExecInfo("ex/d.exe/Makefile"), 0)
	Then("stzFileInfo: a file named exe, with no dot, is not", FxExecInfo("ex/exe"), 0)
	Then("stzFileManager: prog.exe is executable (Windows)", FxExecMgr("ex/prog.exe"), nWin)
	Then("stzFileManager: run.BAT is executable (Windows)", FxExecMgr("ex/run.BAT"), nWin)
	Then("stzFileManager: a.txt is not", FxExecMgr("ex/a.txt"), 0)
	Then("stzFileManager: a file with no extension in a folder named d.exe is not", FxExecMgr("ex/d.exe/Makefile"), 0)
	Then("stzFileManager: a file named exe, with no dot, is not", FxExecMgr("ex/exe"), 0)
EndScenario()

Scenario("IsWritable and Info on a missing path create nothing")
	FxReset("wr")
	oI = new stzFileInfo(FxP("wr/ghost.txt"))
	Then("a missing path is not writable", oI.IsWritable(), 0)
	Then("and asking did not create it", FxExists("wr/ghost.txt"), 0)
	Then("a missing path is not readable", oI.IsReadable(), 0)
	aInfo = oI.Info()
	Then("Info says the path does not exist", aInfo[:exists], 0)
	Then("Info says it is not writable", aInfo[:isWritable], 0)
	Then("and Info did not create it either", FxExists("wr/ghost.txt"), 0)
	Then("the folder still holds nothing", len(FxLs("wr")), 0)
	FxWrite("wr/real.txt", "12345")
	oRd = new stzFileInfo(FxP("wr/real.txt"))
	Then("an existing file is writable", oRd.IsWritable(), 1)
	Then("asking did not change its size", StzEngineFileSize(FxP("wr/real.txt")), 5)
	Then("nor its content", FxRead("wr/real.txt"), "12345")
	oM = FxMgr("wr/real.txt")
	Then("the manager sees it writable too", oM.IsWritable(), 1)
	oM.MakeReadOnly()
	Then("after MakeReadOnly stzFileInfo says not writable", oRd.IsWritable(), 0)
	Then("and the manager says so too", oM.IsWritable(), 0)
	Then("IsReadOnly agrees", oM.IsReadOnly(), 1)
	Then("the read-only file is still readable", oRd.IsReadable(), 1)
	oM.MakeWritable()
	Then("MakeWritable gives the right back", oRd.IsWritable(), 1)
	FxWrite("wr/gone.txt", "x")
	oG = FxMgr("wr/gone.txt")
	oG.Delete()
	Then("after Delete the manager says not writable", oG.IsWritable(), 0)
	Then("and does not bring the file back", FxExists("wr/gone.txt"), 0)
	Then("Exists agrees", oG.Exists(), 0)
	Then("LastModified of a gone file is the empty text", oG.LastModified(), "")
	Then("LastModified of a file that is there is a date and time", len(oM.LastModified()) >= 19, 1)
EndScenario()

Scenario("stzFileOverwriter.PreserveAndModify writes the old text back, then the change")
	FxReset("ov")
	FxWrite("ov/o.txt", "old " + cHeb1)
	oO = new stzFileOverwriter(FxP("ov/o.txt"))
	Then("building the overwriter empties the file", StzEngineFileSize(FxP("ov/o.txt")), 0)
	Then("PreserveAndModify answers 1", oO.PreserveAndModify(" + change"), 1)
	Then("the file holds the old text then the change", FxRead("ov/o.txt"), "old " + cHeb1 + " + change")
	FxWrite("ov/e.txt", "")
	oE = new stzFileOverwriter(FxP("ov/e.txt"))
	Then("with an empty old text it still works", oE.PreserveAndModify("only"), 1)
	Then("and writes just the change", FxRead("ov/e.txt"), "only")
	FxWrite("ov/n.txt", "keep")
	oN = new stzFileOverwriter(FxP("ov/n.txt"))
	Then("an empty change writes the old text back alone", oN.PreserveAndModify(""), 1)
	Then("so the file is as it was", FxRead("ov/n.txt"), "keep")
	FxWrite("ov/b.txt", "old")
	oB = new stzFileOverwriter(FxP("ov/b.txt"))
	bRaised = 0
	try
		oB.PreserveAndModify(5)
	catch
		bRaised = 1
	done
	Then("a change that is not a text is refused", bRaised, 1)
EndScenario()

Scenario("stzFileModifier.InsertLine and the :With form of Modify")
	FxReset("mo")
	FxWrite("mo/m.txt", "one" + cLF + "two" + cLF + "three")
	oMod = new stzFileModifier(FxP("mo/m.txt"))
	Then("InsertLine at 2 answers 1", oMod.InsertLine(2, "X"), 1)
	Then("the line is at position 2", FxRead("mo/m.txt"), "one" + cLF + "X" + cLF + "two" + cLF + "three")
	Then("InsertLine beyond the end adds at the end", oMod.InsertLine(99, "end"), 1)
	Then("the last line is the new one", FxRead("mo/m.txt"), "one" + cLF + "X" + cLF + "two" + cLF + "three" + cLF + "end")
	Then("Modify with :With answers 1", oMod.Modify("two", :With = "2"), 1)
	Then("the text was replaced", FxRead("mo/m.txt"), "one" + cLF + "X" + cLF + "2" + cLF + "three" + cLF + "end")
	Then("the plain form still works", oMod.Modify("one", "1"), 1)
	Then("and replaced", FxRead("mo/m.txt"), "1" + cLF + "X" + cLF + "2" + cLF + "three" + cLF + "end")
	Then("Modify of a text that is absent changes nothing", oMod.Modify("zzz", :With = "q"), 1)
	Then("the file is as it was", FxRead("mo/m.txt"), "1" + cLF + "X" + cLF + "2" + cLF + "three" + cLF + "end")
	Then("Modify with a Hebrew text through :With", oMod.Modify("three", :With = cHeb1), 1)
	Then("the Hebrew bytes are in the file", FxRead("mo/m.txt"), "1" + cLF + "X" + cLF + "2" + cLF + cHeb1 + cLF + "end")
	FxWrite("mo/e.txt", "")
	oEmpty = new stzFileModifier(FxP("mo/e.txt"))
	bRaised = 0
	cMsg = ""
	try
		oEmpty.InsertLine(1, "x")
	catch
		bRaised = 1
		cMsg = cCatchError
	done
	Then("InsertLine on an empty file raises the real message", bRaised, 1)
	Then("it is the empty file message, not an uninitialized variable", StzFindFirst("Cannot insert line in empty file", cMsg) > 0, 1)
	Then("the empty file stays empty", StzEngineFileSize(FxP("mo/e.txt")), 0)
EndScenario()

Scenario("stzFileXT holds the object of its intent; erase names the class that exists")
	FxReset("xt")
	cNote = "alpha" + cLF + "beta gamma" + cLF + "end"
	FxWrite("xt/n.txt", cNote)
	oX = new stzFileXT(FxP("xt/n.txt"), "info")
	Then("the info intent: the file exists", oX.Intent().Exists(), 1)
	Then("and its size is 20", oX.Intent().Size(), 20)
	oX = new stzFileXT(FxP("xt/n.txt"), "READ")
	Then("the read intent (any case): the content is read", oX.Intent().Content(), cNote)
	oX = new stzFileXT(FxP("xt/n.txt"), "append")
	oX.Intent().Write("!")
	Then("the append intent adds at the end", FxRead("xt/n.txt"), cNote + "!")
	FxWrite("xt/n.txt", cNote)
	oX = new stzFileXT(FxP("xt/n.txt"), "modify")
	oX.Intent().ModifyLine(2, "BETA")
	Then("the modify intent changes a line", FxRead("xt/n.txt"), "alpha" + cLF + "BETA" + cLF + "end")
	FxWrite("xt/n.txt", cNote)
	oX = new stzFileXT(FxP("xt/n.txt"), "manage")
	Then("the manage intent gives a manager that sees the file", oX.Intent().Exists(), 1)
	oX = new stzFileXT(FxP("xt/n.txt"), "mange")
	Then("the old misspelling is still accepted", oX.Intent().Size(), 20)
	Then("before the erase intent the file has 20 bytes", StzEngineFileSize(FxP("xt/n.txt")), 20)
	oX = new stzFileXT(FxP("xt/n.txt"), "erase")
	Then("the erase intent builds the class that exists: it remembers 3 lines", oX.Intent().OriginalLineCount(), 3)
	Then("and has emptied the file", StzEngineFileSize(FxP("xt/n.txt")), 0)
	FxWrite("xt/o.txt", cNote)
	oX = new stzFileXT(FxP("xt/o.txt"), "overwrite")
	Then("the overwrite intent empties the file and remembers the old text", oX.Intent().OriginalContent(), cNote)
	oX = new stzFileXT(FxP("xt/new.txt"), "create")
	Then("the create intent makes a new empty file", FxExists("xt/new.txt") + StzEngineFileSize(FxP("xt/new.txt")), 1)
	bRaised = 0
	try
		oX = new stzFileXT(FxP("xt/new.txt"), "create")
	catch
		bRaised = 1
	done
	Then("the create intent refuses a file that exists", bRaised, 1)
	bRaised = 0
	try
		oX = new stzFileXT(FxP("xt/n.txt"), "garbage")
	catch
		bRaised = 1
	done
	Then("an unknown intent raises", bRaised, 1)
EndScenario()

Scenario("stzFileAppender.Write with a number no longer ends the process")
	FxReset("ap")
	FxWrite("ap/l.txt", "")
	oA = new stzFileAppender(FxP("ap/l.txt"))
	Then("Write(5) answers 1", oA.Write(5), 1)
	Then("the process is alive and 5 is in the file as text", FxRead("ap/l.txt"), "5")
	Then("Write(1.5) answers 1", oA.Write(1.5), 1)
	Then("1.5 is written as Ring prints it", FxRead("ap/l.txt"), "51.50")
	Then("WriteLine(7) answers 1", oA.WriteLine(7), 1)
	Then("a number gets its line break too", FxRead("ap/l.txt"), "51.507" + cLF)
	Then("a text is still a text", oA.Write("tail " + cHeb1), 1)
	Then("with its Hebrew bytes", FxRead("ap/l.txt"), "51.507" + cLF + "tail " + cHeb1)
	bRaised = 0
	cMsg = ""
	try
		oA.Write([ 1, 2 ])
	catch
		bRaised = 1
		cMsg = cCatchError
	done
	Then("a list is refused with a normal error", bRaised, 1)
	Then("whose message names what is accepted", StzFindFirst("text or a number", cMsg) > 0, 1)
	Then("and nothing was written", FxRead("ap/l.txt"), "51.507" + cLF + "tail " + cHeb1)
	Then("the empty text adds nothing", oA.Write(""), 1)
	Then("so the file is as it was", FxRead("ap/l.txt"), "51.507" + cLF + "tail " + cHeb1)
	oA.WriteLines([ 1, "two" ])
	Then("WriteLines takes numbers in its list", FxRead("ap/l.txt"), "51.507" + cLF + "tail " + cHeb1 + "1" + cLF + "two" + cLF)
EndScenario()

FxRemoveRoot()
Scenario("Nothing is left behind")
	Then("the fixture folder is gone", dirExists($cFx), 0)
EndScenario()

Summary()

#------------------------------------------------------------------------------------------
# Fixture helpers. Every path the library sees comes from FxP(); every destructive step is
# behind FxGuard().
#------------------------------------------------------------------------------------------

func FxRootOk()
	c = $cFx
	if NOT isString(c)
		return 0
	ok
	if len(c) < 20
		return 0
	ok
	if StzFindFirst("..", c) > 0
		return 0
	ok
	if StzRight(c, 9) != "/_fixture"
		return 0
	ok
	if c[2] != ":" or c[3] != "/"
		return 0
	ok
	if StzRight(StzReplace(currentdir(), "\", "/"), 10) != "/test/file"
		return 0
	ok
	return 1

# Refuses (and stops the process) any path that is not strictly inside the fixture root.
func FxGuard(cPath, bAllowRoot)
	if FxRootOk() = 0
		? "GUARD REFUSED: bad fixture root"
		shutdown(9)
	ok
	if NOT isString(cPath) or cPath = ""
		? "GUARD REFUSED: not a path"
		shutdown(9)
	ok
	p = StzReplace(cPath, "\", "/")
	if StzFindFirst("..", p) > 0
		? "GUARD REFUSED: contains .."
		shutdown(9)
	ok
	if p[2] != ":" or p[3] != "/"
		? "GUARD REFUSED: not absolute"
		shutdown(9)
	ok
	if bAllowRoot = 1 and p = $cFx
		return 1
	ok
	nRoot = len($cFx)
	if len(p) <= nRoot + 1 or left(p, nRoot + 1) != $cFx + "/"
		? "GUARD REFUSED: outside the fixture"
		shutdown(9)
	ok
	return 1

func FxP(cRel)
	p = $cFx + "/" + cRel
	FxGuard(p, 0)
	return p

func FxMgr(cRel)
	return new stzFileManager(FxP(cRel))

func FxWrite(cRel, cContent)
	StzEngineFileWrite(FxP(cRel), cContent)

func FxRead(cRel)
	return StzEngineFileRead(FxP(cRel))

func FxExists(cRel)
	return StzEngineFileExists(FxP(cRel))

func FxDirExists(cRel)
	return StzEngineDirExists(FxP(cRel))

func FxMakeDir(cRel)
	return StzDirCreatePath(FxP(cRel))

# Removes ONE file that this suite wrote in the fixture.
func FxRemove(cRel)
	return StzEngineFileDelete(FxP(cRel))

func FxLs(cRel)
	return sort(StzEngineDirListFiles(FxP(cRel)))

func FxLsLike(cRel, cPrefix)
	aAll = FxLs(cRel)
	aOut = []
	nAll = len(aAll)
	for i = 1 to nAll
		if left(aAll[i], len(cPrefix)) = cPrefix
			aOut + aAll[i]
		ok
	next
	return aOut

func FxLineCount(cText)
	if cText = ""
		return 0
	ok
	aParts = @split(cText, char(10))
	n = len(aParts)
	if aParts[n] = ""
		n--
	ok
	return n

func FxReset(cRel)
	p = FxP(cRel)
	FxClearTree(p)
	StzDirCreatePath(p)

# Empties and removes a folder INSIDE the fixture (read-only flags cleared first).
func FxClearTree(cPath)
	FxGuard(cPath, 0)
	if StzEngineDirExists(cPath) = 0
		return 1
	ok
	aFiles = StzEngineDirListFiles(cPath)
	for i = 1 to len(aFiles)
		StzEngineFileSetReadOnly(cPath + "/" + aFiles[i], 0)
	next
	for i = 1 to len(aFiles)
		pf = cPath + "/" + aFiles[i]
		FxGuard(pf, 0)
		StzEngineFileDelete(pf)
	next
	aDirs = StzEngineDirListDirs(cPath)
	for i = 1 to len(aDirs)
		if aDirs[i] != "." and aDirs[i] != ".."
			FxClearTree(cPath + "/" + aDirs[i])
		ok
	next
	StzEngineDirDelete(cPath)
	return 1

func FxRemoveRoot()
	if StzEngineDirExists($cFx) = 1
		FxGuard($cFx, 1)
		aFiles = StzEngineDirListFiles($cFx)
		for i = 1 to len(aFiles)
			StzEngineFileSetReadOnly(FxP(aFiles[i]), 0)
			StzEngineFileDelete(FxP(aFiles[i]))
		next
		aDirs = StzEngineDirListDirs($cFx)
		for i = 1 to len(aDirs)
			if aDirs[i] != "." and aDirs[i] != ".."
				FxClearTree(FxP(aDirs[i]))
			ok
		next
		FxGuard($cFx, 1)
		StzEngineDirDelete($cFx)
	ok

func FxLines(cRel, n)
	o = FxMgr(cRel)
	return o.SplitByLines(n)

func FxSize(cRel, n)
	o = FxMgr(cRel)
	return o.SplitBySize(n)

func FxPattern(cRel, cPat)
	o = FxMgr(cRel)
	return o.SplitByPattern(cPat)

func FxExecInfo(cRel)
	o = new stzFileInfo(FxP(cRel))
	return o.IsExecutable()

func FxExecMgr(cRel)
	o = FxMgr(cRel)
	return o.IsExecutable()
