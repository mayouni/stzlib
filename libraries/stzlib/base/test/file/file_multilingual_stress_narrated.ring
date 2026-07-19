# stzFile / stzFolder STRESS -- real files, real folders, real scripts.
#
# A file module has three places it usually breaks, and this goes at all
# three:
#
#   1. FILENAMES in non-Latin scripts. Content being UTF-8 is the easy half;
#      the path itself crossing Ring -> engine -> the OS is the hard one.
#   2. COUNTING vs LISTING. There are three independent ways to ask how many
#      files are in a folder -- stzFolder.CountFiles(), len(Files()), and the
#      global StzDirCountFiles() -- and they can disagree without any of them
#      looking wrong alone.
#   3. THE INTERLEAVED PATTERN. Creating a file and then asking the folder a
#      question, over and over, is what real code does; a listing rebuilt
#      per query turns that quadratic while a create-then-count-once test
#      stays fast and proves nothing.
#
# All non-ASCII text is built from RAW CODEPOINTS via a UTF-8 encoder, so the
# file is safe to edit anywhere and cannot rot into mojibake.
#
# Everything is written under a scratch folder created here and DELETED at the
# end -- base/test/_tmp is NOT gitignored and already carries tracked files,
# so this must not write there.
#
# Ring traps avoided: main code before the first func; no local named oR (it
# IS the `or` keyword), nL, Try or Show; no inline `new X().M()` (R13).

load "../../stzBase.ring"

nPass = 0
nFail = 0

pr()

cAr   = MkW([ 0x0639, 0x0631, 0x0628, 0x064A ])         # Arabic
cCJK  = MkW([ 0x6771, 0x4EAC, 0x6587, 0x66F8 ])         # CJK
cHeb  = MkW([ 0x05E9, 0x05DC, 0x05D5, 0x05DD ])         # Hebrew
cGr   = MkW([ 0x03B1, 0x03B2, 0x03B3 ])                 # Greek
cEmo  = MkW([ 0x1F600 ])                                # 4-byte codepoint

cRoot = currentdir() + "/_filestress_tmp"

# A clean slate even if a previous run died mid-way.
if StzDirExists(cRoot)
	NukeTree(cRoot)
ok
StzDirCreate(cRoot)

? "-- Scene 1: a large document survives the round trip --"
# 4000 lines, some of them multibyte, so the byte count and the codepoint
# count genuinely differ.
cBig = ""
for i = 1 to 4000
	if i % 4 = 0
		cBig += "line " + i + " " + cAr + nl
	but i % 4 = 1
		cBig += "line " + i + " " + cCJK + nl
	else
		cBig += "line " + i + " plain ascii content" + nl
	ok
next
cBig += "last line with no trailing newline"

cBigPath = cRoot + "/big.txt"
oW = new stzFile(cBigPath)
oW.Write(cBig)
oW.Close()

oR1 = new stzFileReader(cBigPath)
cBack = oR1.Content()
chk("the file reads back BYTE-IDENTICAL", cBack = cBig)
chk("...and that is " + len(cBig) + " bytes, not a truncation", len(cBack) = len(cBig))

oR2 = new stzFileReader(cBigPath)
nLines = oR2.NumberOfLines()
aLines = oR2.Lines()
? "  NumberOfLines()=" + nLines + "   len(Lines())=" + len(aLines)
chk("NumberOfLines() AGREES with len(Lines())", nLines = len(aLines))
chk("...and the count is the real one (4001 lines)", len(aLines) = 4001)
chk("the LAST line is present -- no trailing-newline truncation",
	aLines[len(aLines)] = "last line with no trailing newline")

oI = new stzFileInfo(cBigPath)
chk("FileInfo.Size() agrees with the bytes written", oI.Size() = len(cBig))
chk("the global StzFileSize agrees too", StzFileSize(cBigPath) = len(cBig))

? ""
? "-- Scene 2: filenames in four scripts, not just contents --"
# The content being UTF-8 is the easy half. The PATH is the half that breaks.
aNames = [ cAr, cCJK, cHeb, cGr, cEmo, cAr + "_" + cCJK ]
aBodies = [ cAr + " content", cCJK + " content", cHeb + " content",
	    cGr + " content", cEmo + " content", "mixed " + cAr + cCJK ]

nWrote = 0
nRead = 0
nNL = len(aNames)
for i = 1 to nNL
	cP = cRoot + "/" + aNames[i] + ".txt"
	oNW = new stzFile(cP)
	oNW.Write(aBodies[i])
	oNW.Close()
	if StzFileExists(cP)
		nWrote++
		oNR = new stzFileReader(cP)
		if oNR.Content() = aBodies[i]
			nRead++
		ok
	ok
next
chk("every multibyte FILENAME was created (" + nWrote + "/" + nNL + ")", nWrote = nNL)
chk("...and each reads back its own content (" + nRead + "/" + nNL + ")", nRead = nNL)

# The folder must be able to SEE what it just wrote -- listing is a separate
# path from existence, and a name can survive creation but not enumeration.
oF2 = new stzFolder(cRoot)
aSeen = oF2.Files()
nSeen = 0
nAs = len(aSeen)
for i = 1 to nNL
	for j = 1 to nAs
		if StzFindFirst(aNames[i], aSeen[j]) > 0
			nSeen++
			exit
		ok
	next
next
chk("the folder LISTING shows every multibyte name (" + nSeen + "/" + nNL + ")", nSeen = nNL)

? ""
? "-- Scene 3: counting and listing must agree (three ways to ask) --"
oF3 = new stzFolder(cRoot)
nCount = oF3.CountFiles()
nNumber = oF3.NumberOfFiles()
nHowMany = oF3.HowManyFiles()
nLen = len(oF3.Files())
nGlobal = StzDirCountFiles(cRoot)
? "  CountFiles=" + nCount + " NumberOfFiles=" + nNumber + " HowManyFiles=" +
  nHowMany + " len(Files())=" + nLen + " StzDirCountFiles=" + nGlobal
chk("CountFiles() = len(Files())", nCount = nLen)
chk("NumberOfFiles() = len(Files())", nNumber = nLen)
chk("HowManyFiles() = len(Files())", nHowMany = nLen)
chk("the GLOBAL StzDirCountFiles agrees with the object", nGlobal = nLen)
chk("...and the number is the 7 files actually written", nLen = 7)

? ""
? "-- Scene 4: many files, created and queried INTERLEAVED --"
# A folder listing rebuilt per query makes this quadratic. Creating 600 files
# and counting once at the end would not notice.
cMany = cRoot + "/many"
StzDirCreate(cMany)

t0 = clock()
for i = 1 to 600
	cP = cMany + "/f" + i + ".txt"
	oMW = new stzFile(cP)
	oMW.Write("body " + i)
	oMW.Close()
next
tCreate = (clock() - t0) / clockspersecond()

t0 = clock()
nLast = 0
for i = 1 to 600
	cP = cMany + "/g" + i + ".txt"
	oGW = new stzFile(cP)
	oGW.Write("body " + i)
	oGW.Close()
	oMF = new stzFolder(cMany)
	nLast = oMF.CountFiles()
next
tInterleaved = (clock() - t0) / clockspersecond()

? "  600 creates alone      : " + tCreate + " s"
? "  600 create+count pairs : " + tInterleaved + " s"
chk("creating 600 files is fast (< 20s)", tCreate < 20)
chk("interleaving create with count stays usable (< 40s)", tInterleaved < 40)
chk("the running count ended at 1200", nLast = 1200)

oBig = new stzFolder(cMany)
chk("listing 1200 files agrees with counting them", len(oBig.Files()) = 1200)

? ""
? "-- Scene 5: the missing probe -- absent things must say so --"
# The cheapest bug in a file module is a missing path answered as if it were
# an empty one.
cGhost = cRoot + "/no_such_file.txt"
chk("a missing file does NOT report as existing", StzFileExists(cGhost) = 0)
oGI = new stzFileInfo(cGhost)
chk("...FileInfo agrees it is absent", oGI.Exists() = 0)
chk("a missing DIRECTORY does not report as existing",
	StzDirExists(cRoot + "/no_such_dir") = 0)

# A multibyte name that was never written must be absent too -- not "absent
# because the name got mangled on the way in".
chk("an unwritten multibyte name is absent", StzFileExists(cRoot + "/" + cHeb + cAr + ".txt") = 0)
# ...while the one that WAS written is still found, so the check above is
# measuring absence and not a broken lookup.
chk("...and a written one is still found", StzFileExists(cRoot + "/" + cHeb + ".txt") = 1)

? ""
? "-- Scene 6: nesting, and the deep counters --"
cDeep = cRoot + "/deep"
StzDirCreatePath(cDeep + "/a/b/c")
nMade = 0
aDeepPaths = [ cDeep + "/top.txt", cDeep + "/a/one.txt",
	       cDeep + "/a/b/two.txt", cDeep + "/a/b/c/" + cAr + ".txt" ]
nDP = len(aDeepPaths)
for i = 1 to nDP
	oDW = new stzFile(aDeepPaths[i])
	oDW.Write("depth " + i)
	oDW.Close()
	if StzFileExists(aDeepPaths[i])
		nMade++
	ok
next
chk("files land at every depth, multibyte name included (" + nMade + "/" + nDP + ")", nMade = nDP)

oDF = new stzFolder(cDeep)
nDeepList = len(oDF.DeepFiles())
nDeepCount = oDF.NumberOfDeepFiles()
? "  DeepFiles()=" + nDeepList + "   NumberOfDeepFiles()=" + nDeepCount
chk("NumberOfDeepFiles() AGREES with len(DeepFiles())", nDeepCount = nDeepList)
chk("...and it found all 4, not just the top level", nDeepList = 4)
chk("a shallow count is NOT the deep count", oDF.CountFiles() < nDeepList)

? ""
? "-- Scene 7: appending, repeatedly --"
# Appending should cost what appending costs. Re-reading and rewriting the
# whole file per append turns a log into a quadratic.
cLog = cRoot + "/log.txt"
oLW = new stzFile(cLog)
oLW.Write("start" + nl)
oLW.Close()

t0 = clock()
for i = 1 to 400
	StzFileAppend(cLog, "entry " + i + " " + cAr + nl)
next
tAppend = (clock() - t0) / clockspersecond()
? "  400 appends : " + tAppend + " s"
chk("appending 400 lines stays fast (< 20s)", tAppend < 20)

oLR = new stzFileReader(cLog)
aLogLines = oLR.Lines()
# 402, not 401: the file ENDS with a newline, so the split yields a trailing
# empty line. That is correct and worth pinning -- a splitter that drops it
# cannot tell a line ending in a newline from one that does not, and this
# one used to lose the final element outright.
chk("every append is present, plus the trailing empty (402)", len(aLogLines) = 402)
chk("...the first is the original", aLogLines[1] = "start")
chk("...the last real entry is the last appended", aLogLines[401] = "entry 400 " + cAr)
chk("...and the 402nd is the empty tail, not a lost line", aLogLines[402] = "")

oLR2 = new stzFileReader(cLog)
chk("NumberOfLines() still agrees after appending", oLR2.NumberOfLines() = len(aLogLines))

? ""
? "-- Scene 8: delete, and the counts that follow --"
oDelF = new stzFolder(cRoot)
nBefore = oDelF.CountFiles()
StzFileDelete(cRoot + "/" + cGr + ".txt")
chk("the deleted file is gone", StzFileExists(cRoot + "/" + cGr + ".txt") = 0)
oDelF2 = new stzFolder(cRoot)
chk("...and the folder count DROPPED by exactly one", oDelF2.CountFiles() = nBefore - 1)
chk("...and the listing agrees with the new count", len(oDelF2.Files()) = nBefore - 1)

? ""
? "-- Scene 9: a bad path must return, not take the process down --"
# These are not hypothetical. When the listing mangled names to '?', a delete
# driven from that listing handed the engine a path full of wildcards, and
# Zig's std hit an `unreachable` on the NTSTATUS that came back -- which in a
# DLL kills the whole Ring process. A bad filename must be an answer, not a
# crash.
chk("a path with ? wildcards returns false", StzFileDelete(cRoot + "/??.txt") = 0)
chk("a path with * returns false", StzFileDelete(cRoot + "/*.txt") = 0)
chk("a path with < > | returns false", StzFileExists(cRoot + "/a<b>c|d.txt") = 0)
chk("an empty path returns false", StzFileDelete("") = 0)
chk("size of a bad path is -1, not a crash", StzFileSize(cRoot + "/??.txt") = -1)
chk("listing a MISSING directory is an empty list, not a raise",
	len(StzEngineDirListFiles(cRoot + "/no_such_dir_at_all")) = 0)
chk("...and the process is still alive to say so", TRUE)

# The screen must not reject anything LEGITIMATE -- ':' and separators are
# ordinary parts of a Windows path, and multibyte names are ordinary too.
chk("a normal absolute path still works", StzFileExists(cBigPath) = 1)
chk("...and a multibyte one still works", StzFileExists(cRoot + "/" + cAr + ".txt") = 1)

? ""
? "-- cleanup --"
NukeTree(cRoot)
chk("the scratch tree is gone -- no artifacts left in the repo", StzDirExists(cRoot) = 0)

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

# Depth-first delete: files first, then folders from the inside out.
func NukeTree cPath
	if NOT StzDirExists(cPath)
		return
	ok

	_oNt_ = new stzFolder(cPath)

	_aNtF_ = _oNt_.Files()
	_nNtF_ = len(_aNtF_)
	for _i_ = 1 to _nNtF_
		StzFileDelete(cPath + "/" + TrimLead(_aNtF_[_i_]))
	next

	_aNtD_ = _oNt_.Folders()
	_nNtD_ = len(_aNtD_)
	for _i_ = 1 to _nNtD_
		NukeTree(cPath + "/" + TrimLead(_aNtD_[_i_]))
	next

	StzDirDelete(cPath)

# Files() hands names back with a leading separator ("/probe.txt"); strip it
# so the rejoined path does not double up.
func TrimLead cName
	if len(cName) > 0 and (cName[1] = "/" or cName[1] = char(92))
		return substr(cName, 2, len(cName) - 1)
	ok
	return cName

# codepoint -> UTF-8 bytes, by arithmetic (no literals -> no mojibake risk)
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
