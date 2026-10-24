load "../../stzBase.ring"
load "../_narrated.ring"

# stzZipFile -- the two register rows (CreateFromDirectory, AddString), the zip slip review of the
# extraction methods, and every public method run once on a small archive.
#
# THE ROOT CAUSES this guard pins:
#   CreateFromDirectory called FilesInDir, which exists nowhere in the library (R3).
#   AddString called zip_newentry, which exists nowhere (R3). The Ring zip library has
#     zip_entry_open / zip_entry_write(archive, text, size) / zip_entry_close, so a text is stored with
#     its length and never through a file: any byte survives.
#   ExtractTo handed the archive straight to the library, which writes an entry named ../x or ..\x
#     OUTSIDE the target folder (zip slip) and ends the whole Ring process on an absolute name.
#
# SAFETY. Every file this guard writes or extracts lives under ONE fixture folder,
# <this folder>/_zffx_tmp, created fresh at the start and removed at the end. The hostile archives are
# built here with the library's own writer (which does not check names) and, for backslashes, by a
# same-length byte patch of the archive. Each is extracted into <fixture>/ss/dest/out, so that the
# worst escape (../../ev.txt) still lands inside the fixture, where the guard looks for it.
#
# Expectations are literals written before the code ran: entry names, contents, sizes and the CRC32
# values come from Python's zlib, not from the library under test. Content is compared with strcmp AND
# by length. Every positive has a negative sibling. Run from inside this folder. ASCII only on the
# console (Hebrew, Arabic and emoji are built with char()).

$cFx = StzReplace(currentdir(), "\", "/") + "/_zffx_tmp"
$cFxRel = "_zffx_tmp"
StzDirDeleteAll($cFx)
StzDirCreatePath($cFx)

cLF = char(10)
cCRet = char(13)
cHeb = char(215) + char(169) + char(215) + char(156) + char(215) + char(149) + char(215) + char(157)
cAra = char(217) + char(133) + char(216) + char(177) + char(216) + char(173) + char(216) + char(168) + char(216) + char(167)
cEmo = char(240) + char(159) + char(152) + char(128)
cAllBytes = ""
for nB = 0 to 255
	cAllBytes += char(nB)
next

# ---------------------------------------------------------------------------------------------
Scenario("The register rows reproduced: neither call exists in the library, and neither is called now")
	cSrc = read("../../file/stzZipFile.ring")
	aHit1 = StzFind("FilesInDir(", cSrc)
	aHit2 = StzFind("zip_newentry(", cSrc)
	aHit3 = StzFind("zip_entry_writestring(", cSrc)
	Then("the class no longer calls FilesInDir", len(aHit1), 0)
	Then("nor zip_newentry", len(aHit2), 0)
	Then("nor zip_entry_writestring, which does not exist either", len(aHit3), 0)
	aHit4 = StzFind("zip_entry_write(", cSrc)
	Then("it calls the zip function that does exist, zip_entry_write", len(aHit4) > 0, 1)
EndScenario()

# ---------------------------------------------------------------------------------------------
Scenario("CreateFromDirectory zips every file under a folder, names relative to it, sorted")
	cSrcDir = $cFx + "/src"
	StzDirCreatePath(cSrcDir + "/sub/deep")
	StzDirCreatePath(cSrcDir + "/uni")
	StzFileWrite(cSrcDir + "/b.txt", "bee")
	StzFileWrite(cSrcDir + "/A.txt", "AAA")
	StzFileWrite(cSrcDir + "/.hidden", "h")
	StzFileWrite(cSrcDir + "/empty.txt", "")
	StzFileWrite(cSrcDir + "/sub/c.txt", "cee")
	StzFileWrite(cSrcDir + "/sub-x.txt", "x")
	StzFileWrite(cSrcDir + "/uni/" + cHeb + ".txt", cHeb + " " + cAra)
	write(cSrcDir + "/bin.dat", cAllBytes)
	Given("a folder of 8 files: one hidden, one empty, one binary, one in a subfolder, one with a Hebrew name, and an empty subfolder")
	oZ = new stzZipFile($cFx + "/out.zip")
	When("the archive is created from the folder")
	cRet = oZ.CreateFromDirectory(cSrcDir)
	Then("it returns the archive path", cRet, $cFx + "/out.zip")
	Then("the archive exists", oZ.Exists(), 1)
	aNames = oZ.ListContents()
	cExpected = ".hidden|A.txt|b.txt|bin.dat|empty.txt|sub-x.txt|sub/c.txt|uni/" + cHeb + ".txt"
	Then("the entries are the 8 files, relative, sorted in byte order", ZfJoin(aNames), cExpected)
	Then("FileCount is 8", oZ.FileCount(), 8)
	Then("the empty subfolder is not an entry (nor any folder)", ZfCountStarting(aNames, "sub/deep"), 0)
	Then("no entry carries the folder's own path", ZfCountStarting(aNames, "src"), 0)
	Then("no entry carries a backslash", ZfCountHaving(aNames, "\"), 0)
	Then("the order is not the creation order: A.txt sorts before b.txt, .hidden before both", aNames[1] + "|" + aNames[2], ".hidden|A.txt")
	Then("sub-x.txt sorts before sub/c.txt (a dash is below a slash)", ZfIndexOf(aNames, "sub-x.txt") < ZfIndexOf(aNames, "sub/c.txt"), 1)
	Then("a name is not found under another letter case", oZ.Contains("a.txt"), 0)
	Then("the exact name is found", oZ.Contains("A.txt"), 1)
	Then("the byte size of the archive is its real file size", oZ.Size(), len(read($cFx + "/out.zip")))
	Then("and it is not zero for an archive that holds files", oZ.Size() > 100, 1)
	When("it is extracted into a new folder")
	StzDirCreatePath($cFx + "/x1")
	oZ.ExtractTo($cFx + "/x1")
	Then("b.txt comes back as bee", ZfSame(read($cFx + "/x1/b.txt"), "bee"), 1)
	Then("A.txt comes back as AAA", ZfSame(read($cFx + "/x1/A.txt"), "AAA"), 1)
	Then("the hidden file comes back", ZfSame(read($cFx + "/x1/.hidden"), "h"), 1)
	Then("the empty file comes back empty", len(read($cFx + "/x1/empty.txt")), 0)
	Then("the file of a subfolder comes back", ZfSame(read($cFx + "/x1/sub/c.txt"), "cee"), 1)
	Then("the binary file of all 256 byte values comes back byte for byte", ZfSame(read($cFx + "/x1/bin.dat"), cAllBytes), 1)
	Then("the Hebrew-named file comes back with its content", ZfSame(read($cFx + "/x1/uni/" + cHeb + ".txt"), cHeb + " " + cAra), 1)
	Then("a name that is not in the archive is not extracted", StzFileExists($cFx + "/x1/zzz.txt"), 0)
	nCrc = ZfCentralCrc($cFx + "/out.zip", "b.txt")
	Then("the CRC32 stored for b.txt is the one Python gives for bee (2436942953)", nCrc, 2436942953)
	nCrc = ZfCentralCrc($cFx + "/out.zip", "bin.dat")
	Then("the CRC32 stored for bin.dat is the one Python gives for bytes 0..255 (688229491)", nCrc, 688229491)
	Then("a name that is not stored has no CRC (-1)", ZfCentralCrc($cFx + "/out.zip", "nope.txt"), -1)
	When("the same folder is archived a second time to another file")
	oZ2 = new stzZipFile($cFx + "/out2.zip")
	oZ2.CreateFromDirectory(cSrcDir)
	Then("the entry list is identical: the order is deterministic", ZfJoin(oZ2.ListContents()), cExpected)
EndScenario()

# ---------------------------------------------------------------------------------------------
Scenario("CreateFromDirectory in awkward shapes: a trailing slash, a relative folder, the archive inside the folder")
	cSrcDir = $cFx + "/src"
	cExpected = ".hidden|A.txt|b.txt|bin.dat|empty.txt|sub-x.txt|sub/c.txt|uni/" + cHeb + ".txt"
	oZ = new stzZipFile($cFx + "/slash.zip")
	oZ.CreateFromDirectory(cSrcDir + "/")
	Then("a trailing slash gives the same entries", ZfJoin(oZ.ListContents()), cExpected)
	oZ = new stzZipFile($cFx + "/bslash.zip")
	oZ.CreateFromDirectory(StzReplace(cSrcDir, "/", "\"))
	Then("a folder written with backslashes gives the same entries", ZfJoin(oZ.ListContents()), cExpected)
	oZ = new stzZipFile($cFxRel + "/rel.zip")
	oZ.CreateFromDirectory($cFxRel + "/src")
	Then("a relative folder gives the same entries", ZfJoin(oZ.ListContents()), cExpected)
	Given("the archive path lies INSIDE the folder being archived")
	oZ = new stzZipFile(cSrcDir + "/inside.zip")
	oZ.CreateFromDirectory(cSrcDir)
	Then("the first run leaves the archive out of itself", ZfJoin(oZ.ListContents()), cExpected)
	oZ.CreateFromDirectory(cSrcDir)
	Then("a second run, when the old archive is there to be seen, still leaves it out", ZfJoin(oZ.ListContents()), cExpected)
	oZ = new stzZipFile(cSrcDir + "/sub/../inside2.zip")
	oZ.CreateFromDirectory(cSrcDir)
	oZ.CreateFromDirectory(cSrcDir)
	Then("the same when the archive path is written with a .. segment", ZfJoin(oZ.ListContents()), ".hidden|A.txt|b.txt|bin.dat|empty.txt|inside.zip|sub-x.txt|sub/c.txt|uni/" + cHeb + ".txt")
	Then("(inside.zip, the OTHER archive, is an ordinary file there and is stored)", ZfIndexOf(oZ.ListContents(), "inside.zip") > 0, 1)
	StzFileDelete(cSrcDir + "/inside.zip")
	StzFileDelete(cSrcDir + "/inside2.zip")
	Given("an archive in a sibling folder, the folder name being a prefix of the other")
	StzDirCreatePath($cFx + "/src2")
	StzFileWrite($cFx + "/src2/k.txt", "kay")
	oZ = new stzZipFile($cFx + "/src2/../src2.zip")
	oZ.CreateFromDirectory($cFx + "/src2")
	Then("an archive beside the folder (src2.zip) is not mistaken for one inside it", oZ.FileCount(), 1)
EndScenario()

# ---------------------------------------------------------------------------------------------
Scenario("CreateFromDirectory refuses what it cannot do well, and says so before writing")
	oZ = new stzZipFile($cFx + "/never.zip")
	cErr = ZfCreateDirErr(oZ, $cFx + "/no_such_folder")
	Then("a missing folder raises Directory does not exist", ZfHas(cErr, "Directory does not exist"), 1)
	Then("and creates no archive", oZ.Exists(), 0)
	cErr = ZfCreateDirErr(oZ, "")
	Then("an empty folder name raises", ZfHas(cErr, "non-empty text"), 1)
	cErr = ZfCreateDirErr(oZ, 42)
	Then("a number as folder raises too", ZfHas(cErr, "non-empty text"), 1)
	cErr = ZfCreateDirErr(oZ, $cFx + "/src/b.txt")
	Then("a FILE given as the folder raises Directory does not exist", ZfHas(cErr, "Directory does not exist"), 1)
	Given("an empty folder")
	StzDirCreatePath($cFx + "/emptyfolder")
	oZ = new stzZipFile($cFx + "/empty.zip")
	oZ.CreateFromDirectory($cFx + "/emptyfolder")
	Then("it gives an archive with no entry: it exists", oZ.Exists(), 1)
	Then("FileCount is 0", oZ.FileCount(), 0)
	Then("IsEmpty is true", oZ.IsEmpty(), 1)
	oFull = new stzZipFile($cFx + "/out.zip")
	Then("and a folder with files is not empty", oFull.IsEmpty(), 0)
	Given("a folder holding only an empty subfolder")
	StzDirCreatePath($cFx + "/onlydirs/a/b")
	oZ = new stzZipFile($cFx + "/onlydirs.zip")
	oZ.CreateFromDirectory($cFx + "/onlydirs")
	Then("the archive has no entry (folders are not stored)", oZ.FileCount(), 0)
	Given("the archive path cannot be written (its folder is missing)")
	oZ = new stzZipFile($cFx + "/nofolder/x.zip")
	cErr = ZfCreateDirErr(oZ, $cFx + "/src2")
	Then("it raises instead of claiming success", len(cErr) > 0, 1)
	Then("and nothing is created", oZ.Exists(), 0)
EndScenario()

# ---------------------------------------------------------------------------------------------
Scenario("The walk is iterative and bounded: depth, folders and files (the helper takes the limits)")
	Given("a chain of 65 nested folders with a file at the bottom, and a chain of 64")
	cChain = $cFx + "/chain64"
	for nD = 1 to 64
		cChain += "/d"
	next
	StzDirCreatePath(cChain)
	StzFileWrite(cChain + "/deep.txt", "bottom")
	cChain65 = $cFx + "/chain65"
	for nD = 1 to 65
		cChain65 += "/d"
	next
	StzDirCreatePath(cChain65)
	StzFileWrite(cChain65 + "/deep.txt", "bottom")
	oZ = new stzZipFile($cFx + "/chain64.zip")
	oZ.CreateFromDirectory($cFx + "/chain64")
	Then("64 levels are walked", oZ.FileCount(), 1)
	sExpected = copy("d/", 64) + "deep.txt"
	Then("and the entry is the 64-level path", oZ.ListContents()[1], sExpected)
	oZ = new stzZipFile($cFx + "/chain65.zip")
	cErr = ZfCreateDirErr(oZ, $cFx + "/chain65")
	Then("65 levels raise, saying deeper than 64", ZfHas(cErr, "deeper than 64 levels"), 1)
	Then("and no archive is created", oZ.Exists(), 0)
	Given("the walk helper with small limits on the src folder (8 files, 4 folders counting the root)")
	cErr = ZfWalkErr($cFx + "/src", 64, 100000)
	Then("with the real limits it walks without error", cErr, "")
	cErr = ZfWalkErr($cFx + "/src", 64, 7)
	Then("a limit of 7 files raises, saying more than 7 files", ZfHas(cErr, "more than 7 files, nothing archived"), 1)
	cErr = ZfWalkErr($cFx + "/src", 64, 8)
	Then("a limit of 8 files (exactly the count) is fine: the cap raises only when it is passed", cErr, "")
	cErr = ZfWalkErr($cFx + "/src", 1, 100000)
	Then("a depth limit of 1 raises on the 2-level subfolder", ZfHas(cErr, "deeper than 1 levels"), 1)
	cErr = ZfWalkErr($cFx + "/src", 2, 100000)
	Then("a depth limit of 2 is enough for sub/deep", cErr, "")
	cErr = ZfWalkErrFolders($cFx + "/src", 3)
	Then("a limit of 3 folders raises (src, sub, sub/deep, uni = 4)", ZfHas(cErr, "folders"), 1)
	cErr = ZfWalkErrFolders($cFx + "/src", 4)
	Then("a limit of 4 folders is exactly enough", cErr, "")
EndScenario()

# ---------------------------------------------------------------------------------------------
Scenario("AddString stores a text byte for byte, creating the archive when it is missing")
	cArc = $cFx + "/str.zip"
	oZ = new stzZipFile(cArc)
	Given("no archive yet")
	Then("it does not exist", oZ.Exists(), 0)
	When("a text is added")
	cRet = oZ.AddString("hello.txt", "hello world")
	Then("it returns the archive path", cRet, cArc)
	Then("the archive now exists", oZ.Exists(), 1)
	Then("it holds one entry, hello.txt", ZfJoin(oZ.ListContents()), "hello.txt")
	Then("read back by the library's own reader it is the same text", ZfSame(zip_extract_file(cArc, "hello.txt"), "hello world"), 1)
	cUtf8 = cHeb + " " + cAra + " " + cEmo + " caf" + char(195) + char(169)
	oZ.AddString("utf8.txt", cUtf8)
	cNul = "ab" + char(0) + "cd" + char(0) + char(0) + "ef"
	oZ.AddString("nul.bin", cNul)
	cCrlf = "l1" + cCRet + cLF + "l2" + cLF + "l3" + cCRet
	oZ.AddString("crlf.txt", cCrlf)
	oZ.AddString("all256.bin", cAllBytes)
	oZ.AddString("empty.txt", "")
	cBig = ""
	for nB = 1 to 2000
		cBig += "line " + nB + " " + cHeb + cLF
	next
	oZ.AddString("big.txt", cBig)
	oZ.AddString("docs/sub/nested.txt", "nested")
	oZ.AddString("num.txt", 12345)
	Then("eight more entries make nine, in the order added", ZfJoin(oZ.ListContents()), "hello.txt|utf8.txt|nul.bin|crlf.txt|all256.bin|empty.txt|big.txt|docs/sub/nested.txt|num.txt")
	Then("FileCount agrees", oZ.FileCount(), 9)
	Then("a UTF-8 text (Hebrew, Arabic, emoji, accent) round-trips: same bytes", ZfSame(zip_extract_file(cArc, "utf8.txt"), cUtf8), 1)
	Then("a text with NULs round-trips and keeps its length 9", len(zip_extract_file(cArc, "nul.bin")), 9)
	Then("and its bytes", ZfSame(zip_extract_file(cArc, "nul.bin"), cNul), 1)
	Then("CR LF and a lone CR survive", ZfSame(zip_extract_file(cArc, "crlf.txt"), cCrlf), 1)
	Then("all 256 byte values survive, 256 bytes", len(zip_extract_file(cArc, "all256.bin")), 256)
	Then("byte for byte", ZfSame(zip_extract_file(cArc, "all256.bin"), cAllBytes), 1)
	Then("an empty text gives an empty entry", len(zip_extract_file(cArc, "empty.txt")), 0)
	Then("and the entry exists", oZ.Contains("empty.txt"), 1)
	Then("a 2000-line text round-trips", ZfSame(zip_extract_file(cArc, "big.txt"), cBig), 1)
	Then("a number is stored as its text", zip_extract_file(cArc, "num.txt"), "12345")
	Then("a different text is not equal to the stored one (negative sibling)", ZfSame(zip_extract_file(cArc, "all256.bin"), copy("x", 256)), 0)
	Then("a one-byte difference is seen", ZfSame(zip_extract_file(cArc, "nul.bin"), "ab" + char(0) + "cd" + char(0) + char(1) + "ef"), 0)
	nCrc = ZfCentralCrc(cArc, "hello.txt")
	Then("the CRC32 stored for hello.txt is Python's (222957957)", nCrc, 222957957)
	nCrc = ZfCentralCrc(cArc, "all256.bin")
	Then("the CRC32 stored for all256.bin is Python's (688229491)", nCrc, 688229491)
	Then("and the engine's CRC32 of the bytes agrees with the stored one", StzEngineCompressCrc32(cAllBytes), ZfCentralCrc(cArc, "all256.bin"))
	Then("a wrong CRC literal would fail (negative sibling)", ZfCentralCrc(cArc, "hello.txt") = 222957958, 0)
	When("the archive is extracted")
	StzDirCreatePath($cFx + "/x2")
	oZ.ExtractTo($cFx + "/x2")
	Then("the files on disk hold the same bytes (UTF-8)", ZfSame(read($cFx + "/x2/utf8.txt"), cUtf8), 1)
	Then("(NUL)", ZfSame(read($cFx + "/x2/nul.bin"), cNul), 1)
	Then("(all 256 values)", ZfSame(read($cFx + "/x2/all256.bin"), cAllBytes), 1)
	Then("a nested entry makes its folders", read($cFx + "/x2/docs/sub/nested.txt"), "nested")
	Then("the file size on disk is the entry size", StzFileSize($cFx + "/x2/big.txt"), len(cBig))
EndScenario()

# ---------------------------------------------------------------------------------------------
Scenario("AddString on an existing archive keeps what is there, and a name added twice is stored twice")
	cArc = $cFx + "/mix.zip"
	StzFileWrite($cFx + "/one.txt", "one")
	oZ = new stzZipFile(cArc)
	oZ.CreateFrom([$cFxRel + "/one.txt"])
	Then("an archive made by CreateFrom has the file under the path as given", oZ.ListContents()[1], $cFxRel + "/one.txt")
	oZ.AddString("added.txt", "text-1")
	Then("AddString appends to it", ZfJoin(oZ.ListContents()), $cFxRel + "/one.txt|added.txt")
	Then("the file entry is intact", ZfSame(zip_extract_file(cArc, $cFxRel + "/one.txt"), "one"), 1)
	oZ.AddString("added.txt", "text-2")
	Then("the same name again is stored a second time (as AddFile does)", ZfJoin(oZ.ListContents()), $cFxRel + "/one.txt|added.txt|added.txt")
	Then("a lookup by name finds the first (documented)", zip_extract_file(cArc, "added.txt"), "text-1")
	Given("an existing file that is not a zip")
	write($cFx + "/notzip.zip", "this is not a zip file at all, only text, padded padded padded padded")
	oZ = new stzZipFile($cFx + "/notzip.zip")
	cBefore = read($cFx + "/notzip.zip")
	cErr = ZfAdd(oZ, "a.txt", "x")
	Then("AddString raises instead of claiming success", len(cErr) > 0, 1)
	Then("the file is left as it was", ZfSame(read($cFx + "/notzip.zip"), cBefore), 1)
	Given("an archive path whose folder is missing")
	oZ = new stzZipFile($cFx + "/nofolder/y.zip")
	cErr = ZfAdd(oZ, "a.txt", "x")
	Then("AddString raises", len(cErr) > 0, 1)
	Then("and creates nothing", oZ.Exists(), 0)
	oCont = new stzZipFile($cFx + "/content.zip")
	cErr = ZfAdd(oCont, "a.txt", [ 1, 2 ])
	Then("a list as content raises Content must be a text", ZfHas(cErr, "Content must be a text"), 1)
	Then("and creates no archive", StzFileExists($cFx + "/content.zip"), 0)
EndScenario()

# ---------------------------------------------------------------------------------------------
Scenario("The entry name is client data: names that could escape are refused and the archive is untouched")
	cArc = $cFx + "/names.zip"
	oZ = new stzZipFile(cArc)
	oZ.AddString("keep.txt", "keep")
	cBefore = read(cArc)
	nLong = copy("a", 256)
	aBad = [
		[ "",                      "empty" ],
		[ "/abs.txt",              "absolute" ],
		[ "\abs.txt",              "backslash" ],
		[ "C:\x.txt",              "backslash" ],
		[ "C:/x.txt",              "colon" ],
		[ "c:x.txt",               "colon" ],
		[ "a:b",                   "colon" ],
		[ "../x.txt",              ".. segment" ],
		[ "a/../../x.txt",         ".. segment" ],
		[ "a/..",                  ".. segment" ],
		[ "..",                    ".. segment" ],
		[ "a/../b",                ".. segment" ],
		[ "...",                   ".. segment" ],
		[ "a/. ./b",               ".. segment" ],
		[ ".. /x",                 ".. segment" ],
		[ "a\b.txt",               "backslash" ],
		[ "a" + char(0) + "b",     "control" ],
		[ "a" + char(10) + "b",    "control" ],
		[ "a" + char(13) + "b",    "control" ],
		[ "a" + char(9) + "b",     "control" ],
		[ "a" + char(127) + "b",   "control" ],
		[ nLong,                   "255 bytes" ],
		[ "dir/",                  "folder" ],
		[ "a//b",                  "empty segment" ],
		[ "a/./b",                 "dot segment" ],
		[ ".",                     "dot segment" ]
	]
	for nI = 1 to len(aBad)
		cErr = ZfAdd(oZ, aBad[nI][1], "EVIL")
		Then("refused: " + ZfShow(aBad[nI][1]) + " (" + aBad[nI][2] + ")", ZfHas(cErr, "Invalid entry name"), 1)
		Then("  and the archive bytes are unchanged", ZfSame(read(cArc), cBefore), 1)
	next
	cErr = ZfAdd(oZ, 5, "EVIL")
	Then("a number as the name is refused", ZfHas(cErr, "not a text"), 1)
	cErr = ZfAdd(oZ, [ "a" ], "EVIL")
	Then("a list as the name is refused", ZfHas(cErr, "not a text"), 1)
	Then("still one entry, keep.txt", ZfJoin(oZ.ListContents()), "keep.txt")
	Then("the refusal names the rule in words", ZfHas(ZfAdd(oZ, "../x", "E"), "holds a .. segment"), 1)
	aGood = [
		"ok.txt", "a/b/c.txt", "..a", "a..", "a.b..c", "...x", ".hidden", "a b.txt", "a-b_c+d(e).txt",
		"with" + cHeb + ".txt", "x." , "f/.hid", "UPPER.TXT", copy("a", 255)
	]
	for nI = 1 to len(aGood)
		cErr = ZfAdd(oZ, aGood[nI], "fine" + nI)
		Then("accepted: " + ZfShow(aGood[nI]), cErr, "")
		Then("  and stored under exactly that name", oZ.Contains(aGood[nI]), 1)
	next
	aAll = oZ.ListContents()
	Then("the 255-byte name is the limit: its entry has 255 bytes", len(aAll[len(aAll)]), 255)
	Then("a name a library never rewrites: a backslash name cannot reach the archive (so none is stored)", ZfCountHaving(oZ.ListContents(), "\"), 0)
	Then("and no stored name starts with a slash or holds ..", ZfCountStarting(oZ.ListContents(), "/") + ZfCountHaving(oZ.ListContents(), "/../"), 0)
EndScenario()

# ---------------------------------------------------------------------------------------------
Scenario("ZIP SLIP: hostile archives are refused before one byte is written")
	cSS = $cFx + "/ss"
	cOut = cSS + "/dest/out"
	aHostile = [
		[ "../ev.txt",            "../ev.txt" ],
		[ "../../ev.txt",         "../../ev.txt" ],
		[ "a/../../ev.txt",       "a/../../ev.txt" ],
		[ "/abs_ev.txt",          "/abs_ev.txt" ],
		[ cSS + "/abs_ev.txt",    "an absolute path with a drive" ],
		[ "C:/drive_ev.txt",      "C:/drive_ev.txt" ],
		[ "..#..#bs_ev.txt",      "..\..\bs_ev.txt" ],
		[ "C:#cd_ev.txt",         "C:\cd_ev.txt" ],
		[ "a#..#..#bs2_ev.txt",   "a\..\..\bs2_ev.txt" ]
	]
	for nI = 1 to len(aHostile)
		StzDirDeleteAll(cSS)
		StzDirCreatePath(cOut)
		cZ = cSS + "/h.zip"
		ZfBuildHostile(cZ, [ "ok_first.txt", aHostile[nI][1] ])
		if ZfHas(aHostile[nI][1], "#") = 1
			ZfPatchHash(cZ, aHostile[nI][1])
		ok
		oZ = new stzZipFile(cZ)
		aL = oZ.ListContents()
		Given("an archive of two entries: ok_first.txt, then " + ZfShow(aHostile[nI][2]))
		Then("the library lists the hostile name as stored", len(aL), 2)
		cErr = ZfExtractErr(oZ, cOut)
		Then("ExtractTo raises Unsafe entry name", ZfHas(cErr, "Unsafe entry name"), 1)
		Then("nothing at all is written in the fixture besides the archive (not even ok_first.txt)", ZfFilesUnder(cSS), 1)
		Then("the target folder is empty", ZfFilesUnder(cOut), 0)
		Then("no ev.txt anywhere in the fixture", ZfFilesNamed($cFx, "ev.txt"), 0)
	next
	Given("the same hostile archive reached by the other two extraction methods")
	StzDirDeleteAll(cSS)
	StzDirCreatePath(cSS + "/hz")
	cZ = cSS + "/hz/h.zip"
	ZfBuildHostile(cZ, [ "../ev.txt" ])
	oZ = new stzZipFile(cZ)
	cErr = ZfHereErr(oZ)
	Then("ExtractHere raises Unsafe entry name", ZfHas(cErr, "Unsafe entry name"), 1)
	Then("and wrote nothing (no ev.txt in ss, nor in hz)", ZfFilesNamed(cSS, "ev.txt"), 0)
	cErr = ZfNewFolderErr(oZ)
	Then("ExtractToNewFolder raises Unsafe entry name", ZfHas(cErr, "Unsafe entry name"), 1)
	Then("and wrote nothing", ZfFilesNamed(cSS, "ev.txt"), 0)
	Then("no folder was made for it", StzDirExists(cSS + "/hz/h"), 0)
	Given("an archive made by CreateFrom with an absolute path (this ended the Ring process with exit 127)")
	StzDirDeleteAll(cSS)
	StzDirCreatePath(cSS + "/dest/out")
	StzFileWrite(cSS + "/src.txt", "SRC")
	oZ = new stzZipFile(cSS + "/abs.zip")
	oZ.CreateFrom([cSS + "/src.txt"])
	Then("the entry is stored as the absolute path given", oZ.ListContents()[1], cSS + "/src.txt")
	cErr = ZfExtractErr(oZ, cSS + "/dest/out")
	Then("ExtractTo now raises Unsafe entry name instead of exiting", ZfHas(cErr, "Unsafe entry name"), 1)
	Then("the process is alive to say so (this line ran) and nothing was extracted", ZfFilesUnder(cSS + "/dest/out"), 0)
	Given("a benign archive: plain names, a nested one, a name starting with two dots, and a folder entry")
	StzDirDeleteAll(cSS)
	StzDirCreatePath(cSS + "/dest/out")
	cZ = cSS + "/good.zip"
	oZ = new stzZipFile(cZ)
	oZ.AddString("ok.txt", "fine")
	oZ.AddString("d/e.txt", "deep")
	oZ.AddString("..a/b.txt", "dots")
	ZfAddFolderEntry(cZ, "emptydir/")
	cErr = ZfExtractErr(oZ, cSS + "/dest/out")
	Then("it extracts without error", cErr, "")
	Then("ok.txt", read(cSS + "/dest/out/ok.txt"), "fine")
	Then("d/e.txt", read(cSS + "/dest/out/d/e.txt"), "deep")
	Then("a segment that merely starts with two dots is a plain name", read(cSS + "/dest/out/..a/b.txt"), "dots")
	Then("the folder entry became a folder", StzDirExists(cSS + "/dest/out/emptydir"), 1)
	Then("and nothing was written above the target", ZfFilesUnder(cSS + "/dest"), 3)
	Given("an entry whose path with the folder is too long for the library (it ended the Ring process)")
	StzDirDeleteAll(cSS)
	StzDirCreatePath(cSS + "/dest/out")
	cZ = cSS + "/long.zip"
	cLongName = copy("d/", 124) + "f.txt"
	ZfBuildHostile(cZ, [ cLongName ])
	oZ = new stzZipFile(cZ)
	cErr = ZfExtractErr(oZ, cSS + "/dest/out")
	Then("ExtractTo raises Entry path is too long (and this line ran: the process lived)", ZfHas(cErr, "Entry path is too long"), 1)
	Then("nothing was written", ZfFilesUnder(cSS + "/dest/out") + ZfFilesNamed(cSS, "f.txt"), 0)
	Given("an entry that fits the limit exactly is extracted")
	nRoomName = 250 - (len(cSS + "/dest/out") + 1)
	cFitName = copy("e", nRoomName - 2) + ".x"
	cFitName = left(cFitName, nRoomName)
	ZfBuildHostile(cZ, [ cFitName ])
	oZ = new stzZipFile(cZ)
	cErr = ZfExtractErr(oZ, cSS + "/dest/out")
	Then("a name that brings the total to 250 bytes goes through", cErr, "")
	Then("and its file is there", StzFileExists(cSS + "/dest/out/" + cFitName), 1)
	ZfBuildHostile(cZ, [ cFitName + "y" ])
	oZ = new stzZipFile(cZ)
	cErr = ZfExtractErr(oZ, cSS + "/dest/out")
	Then("one byte more is refused", ZfHas(cErr, "Entry path is too long"), 1)
	Given("a file entry the library cannot write: the folder it needs is taken by a FILE")
	StzDirDeleteAll(cSS)
	StzDirCreatePath(cSS + "/dest/out")
	StzFileWrite(cSS + "/dest/out/d", "I am a file")
	ZfBuildHostile(cZ, [ "d/x.txt" ])
	oZ = new stzZipFile(cZ)
	cErr = ZfExtractErr(oZ, cSS + "/dest/out")
	Then("ExtractTo reports Entry was not extracted instead of answering as if all went well", ZfHas(cErr, "Entry was not extracted"), 1)
	Then("the file that was in the way is untouched", read(cSS + "/dest/out/d"), "I am a file")
	Given("target folders that are not a folder name")
	oFull = new stzZipFile($cFx + "/out.zip")
	cErr = ZfExtractErr(oFull, "")
	Then("an empty target raises", ZfHas(cErr, "non-empty text"), 1)
	oNone = new stzZipFile($cFx + "/no_such.zip")
	cErr = ZfExtractErr(oNone, cSS + "/dest/out2")
	Then("a missing archive still raises Zip file does not exist", ZfHas(cErr, "Zip file does not exist"), 1)
	Then("and made no folder", StzDirExists(cSS + "/dest/out2"), 0)
EndScenario()

# ---------------------------------------------------------------------------------------------
Scenario("Every public method once, on a small archive")
	StzDirCreatePath($cFx + "/pm")
	StzFileWrite($cFx + "/pm/f1.txt", "first")
	StzFileWrite($cFx + "/pm/f2.txt", "second")
	StzFileWrite($cFx + "/pm/f3.txt", "third")
	cArc = $cFxRel + "/pm/m.zip"
	oZ = ZipFile(cArc)
	Then("ZipFile() builds the object", classname(oZ), "stzzipfile")
	Then("FileName is the path given", oZ.FileName(), cArc)
	Then("Exists is false before anything", oZ.Exists(), 0)
	Then("FileCount is 0", oZ.FileCount(), 0)
	Then("IsEmpty is true for a missing archive", oZ.IsEmpty(), 1)
	Then("Size is 0 for a missing archive", oZ.Size(), 0)
	cErr = ZfListErr(oZ)
	Then("ListContents raises for a missing archive", ZfHas(cErr, "Zip file does not exist"), 1)
	cRet = oZ.CreateFrom([$cFxRel + "/pm/f1.txt", $cFxRel + "/pm/missing.txt"])
	Then("CreateFrom returns the path", cRet, cArc)
	Then("it skips the missing file and keeps the other", ZfJoin(oZ.ListContents()), $cFxRel + "/pm/f1.txt")
	oZ.CreateFromSingleFile($cFxRel + "/pm/f2.txt")
	Then("CreateFromSingleFile replaces the archive by one file", ZfJoin(oZ.ListContents()), $cFxRel + "/pm/f2.txt")
	oZ.AddFile($cFxRel + "/pm/f1.txt")
	Then("AddFile appends", ZfJoin(oZ.ListContents()), $cFxRel + "/pm/f2.txt|" + $cFxRel + "/pm/f1.txt")
	oZ.AddFiles([$cFxRel + "/pm/f3.txt", $cFxRel + "/pm/none.txt"])
	Then("AddFiles appends the existing ones", oZ.FileCount(), 3)
	oZ.AddString("s.txt", "text")
	Then("AddString appends", oZ.FileCount(), 4)
	Then("Contains finds a stored name", oZ.Contains($cFxRel + "/pm/f3.txt"), 1)
	Then("and not a name that is not stored", oZ.Contains($cFxRel + "/pm/none.txt"), 0)
	Then("IsEmpty is false", oZ.IsEmpty(), 0)
	Then("Size is the real byte size", oZ.Size(), len(read(cArc)))
	Then("Exists is true", oZ.Exists(), 1)
	oZ.ExtractTo($cFx + "/pm/e1")
	Then("ExtractTo restores a file", read($cFx + "/pm/e1/" + $cFxRel + "/pm/f2.txt"), "second")
	Then("and the text entry", read($cFx + "/pm/e1/s.txt"), "text")
	StzDirCreatePath($cFx + "/pm/here")
	Then("CopyTo copies the archive and says it is there", oZ.CopyTo($cFx + "/pm/here/m.zip"), 1)
	Then("byte for byte", ZfSame(read($cFx + "/pm/here/m.zip"), read(cArc)), 1)
	oH = new stzZipFile($cFx + "/pm/here/m.zip")
	Then("ExtractHere returns the folder holding the archive", oH.ExtractHere(), $cFx + "/pm/here")
	Then("and unpacks beside it", read($cFx + "/pm/here/s.txt"), "text")
	Then("ExtractToNewFolder returns a folder named like the archive", oH.ExtractToNewFolder(), $cFx + "/pm/here/m")
	Then("and unpacks into it", read($cFx + "/pm/here/m/s.txt"), "text")
	Then("MoveTo moves the archive and reports the copy", oH.MoveTo($cFx + "/pm/moved.zip"), 1)
	Then("the object points at the new path", oH.FileName(), $cFx + "/pm/moved.zip")
	Then("the old path is gone", StzFileExists($cFx + "/pm/here/m.zip"), 0)
	Then("the moved archive is intact", ZfSame(read($cFx + "/pm/moved.zip"), read(cArc)), 1)
	oH.Delete()
	Then("Delete removes the archive", oH.Exists(), 0)
	oH.Delete()
	Then("and deleting again is not an error (this line ran)", oH.Exists(), 0)
	Then("Q variants return the object: CreateFromQ", classname(oZ.CreateFromQ([$cFxRel + "/pm/f1.txt"])), "stzzipfile")
	Then("CreateFromSingleFileQ", classname(oZ.CreateFromSingleFileQ($cFxRel + "/pm/f1.txt")), "stzzipfile")
	Then("CreateFromDirectoryQ", classname(oZ.CreateFromDirectoryQ($cFx + "/pm/e1")), "stzzipfile")
	Then("AddFileQ", classname(oZ.AddFileQ($cFxRel + "/pm/f2.txt")), "stzzipfile")
	Then("AddFilesQ", classname(oZ.AddFilesQ([$cFxRel + "/pm/f3.txt"])), "stzzipfile")
	Then("AddStringQ", classname(oZ.AddStringQ("q.txt", "q")), "stzzipfile")
	Then("ListContentsQ", classname(oZ.ListContentsQ()), "stzzipfile")
	Then("ExtractToQ", classname(oZ.ExtractToQ($cFx + "/pm/e2")), "stzzipfile")
	Then("CopyToQ", classname(oZ.CopyToQ($cFx + "/pm/copyq.zip")), "stzzipfile")
	oQ = new stzZipFile($cFx + "/pm/copyq.zip")
	Then("DeleteQ", classname(oQ.DeleteQ()), "stzzipfile")
	Then("(and it removed the copy)", StzFileExists($cFx + "/pm/copyq.zip"), 0)
	oZ.CopyTo($cFx + "/pm/cp2.zip")
	oC = new stzZipFile($cFx + "/pm/cp2.zip")
	Then("MoveToQ", classname(oC.MoveToQ($cFx + "/pm/y.zip")), "stzzipfile")
	Then("(and it moved the copy)", StzFileExists($cFx + "/pm/y.zip") + StzFileExists($cFx + "/pm/cp2.zip") * 10, 1)
EndScenario()

# ---------------------------------------------------------------------------------------------
Scenario("Small helpers: the folder of an archive path")
	Then("a path with a folder gives the folder", _DirOfPath("a/b/c.zip"), "a/b")
	Then("a backslash path is read the same", _DirOfPath("a\b\c.zip"), "a/b")
	Then("a bare name gives .", _DirOfPath("c.zip"), ".")
	Then("an archive at the root gives the root, not an empty text (it was empty)", _DirOfPath("/c.zip"), "/")
	Then("the base name drops the extension", _BaseNameOfPath("a/b/c.zip"), "c")
EndScenario()

Summary()

StzDirDeleteAll($cFx)

# =============================================================== helpers (kept at the end of the file)
# Every local here is prefixed h_ : Ring lets a function see the variables of the main script, so a
# helper that used cOut or nI would overwrite the script's own.

func ZfJoin(h_aList)
	h_cOut = ""
	h_nLen = len(h_aList)
	for h_nQ = 1 to h_nLen
		if h_nQ > 1
			h_cOut += "|"
		ok
		h_cOut += h_aList[h_nQ]
	next
	return h_cOut

# byte-exact equality, safe for NUL: lengths, then every byte, then the engine's CRC32 of both
func ZfSame(h_cA, h_cB)
	if len(h_cA) != len(h_cB)
		return 0
	ok
	h_nLen = len(h_cA)
	for h_nQ = 1 to h_nLen
		if ascii(h_cA[h_nQ]) != ascii(h_cB[h_nQ])
			return 0
		ok
	next
	if StzEngineCompressCrc32(h_cA) != StzEngineCompressCrc32(h_cB)
		return 0
	ok
	return 1

func ZfHas(h_cText, h_cNeedle)
	if not isString(h_cText)
		return 0
	ok
	h_aPos = StzFind(h_cNeedle, h_cText)
	if len(h_aPos) > 0
		return 1
	ok
	return 0

func ZfShow(h_cName)
	h_cOut = ""
	if not isString(h_cName)
		return "(not a text)"
	ok
	h_nMax = len(h_cName)
	if h_nMax > 40
		h_nMax = 40
	ok
	for h_nQ = 1 to h_nMax
		h_nC = ascii(h_cName[h_nQ])
		if h_nC < 32 or h_nC > 126
			h_cOut += "?"
		else
			h_cOut += h_cName[h_nQ]
		ok
	next
	if len(h_cName) > 40
		h_cOut += "..(" + len(h_cName) + " bytes)"
	ok
	return "[" + h_cOut + "]"

func ZfIndexOf(h_aList, h_cName)
	h_nLen = len(h_aList)
	for h_nQ = 1 to h_nLen
		if strcmp(h_aList[h_nQ], h_cName) = 0
			return h_nQ
		ok
	next
	return 0

func ZfCountStarting(h_aList, h_cPrefix)
	h_nCount = 0
	h_nLen = len(h_aList)
	h_nP = len(h_cPrefix)
	for h_nQ = 1 to h_nLen
		if len(h_aList[h_nQ]) >= h_nP
			if strcmp(left(h_aList[h_nQ], h_nP), h_cPrefix) = 0
				h_nCount++
			ok
		ok
	next
	return h_nCount

func ZfCountHaving(h_aList, h_cPart)
	h_nCount = 0
	h_nLen = len(h_aList)
	for h_nQ = 1 to h_nLen
		h_aPos = StzFind(h_cPart, h_aList[h_nQ])
		if len(h_aPos) > 0
			h_nCount++
		ok
	next
	return h_nCount

func ZfAdd(h_oZip, h_cName, h_cContent)
	try
		h_oZip.AddString(h_cName, h_cContent)
	catch
		return "" + cCatchError
	done
	return ""

func ZfCreateDirErr(h_oZip, h_cDir)
	try
		h_oZip.CreateFromDirectory(h_cDir)
	catch
		return "" + cCatchError
	done
	return ""

func ZfExtractErr(h_oZip, h_cDir)
	try
		h_oZip.ExtractTo(h_cDir)
	catch
		return "" + cCatchError
	done
	return ""

func ZfHereErr(h_oZip)
	try
		h_oZip.ExtractHere()
	catch
		return "" + cCatchError
	done
	return ""

func ZfNewFolderErr(h_oZip)
	try
		h_oZip.ExtractToNewFolder()
	catch
		return "" + cCatchError
	done
	return ""

func ZfListErr(h_oZip)
	try
		h_oZip.ListContents()
	catch
		return "" + cCatchError
	done
	return ""

func ZfWalkErr(h_cRoot, h_nDepth, h_nFiles)
	try
		_ZipWalkFolder(h_cRoot, h_nDepth, h_nFiles, 100000)
	catch
		return "" + cCatchError
	done
	return ""

func ZfWalkErrFolders(h_cRoot, h_nFolders)
	try
		_ZipWalkFolder(h_cRoot, 64, 100000, h_nFolders)
	catch
		return "" + cCatchError
	done
	return ""

# builds an archive whose entry names go in unchecked (the library's writer does not look at them)
func ZfBuildHostile(h_cZip, h_aNames)
	remove(h_cZip)
	h_pZip = zip_openfile(h_cZip, "w")
	h_nLen = len(h_aNames)
	for h_nQ = 1 to h_nLen
		zip_entry_open(h_pZip, h_aNames[h_nQ])
		zip_entry_write(h_pZip, "EVIL", 4)
		zip_entry_close(h_pZip)
	next
	zip_close(h_pZip)

# turns each # of a name stored in the archive into a backslash, same length, so the CRC stays valid
func ZfPatchHash(h_cZip, h_cName)
	h_cData = read(h_cZip)
	h_cNew = substr(h_cName, "#", "\")
	h_cData2 = substr(h_cData, h_cName, h_cNew)
	write(h_cZip, h_cData2)

func ZfAddFolderEntry(h_cZip, h_cFolder)
	h_pZip = zip_openfile(h_cZip, "a")
	zip_entry_open(h_pZip, h_cFolder)
	zip_entry_close(h_pZip)
	zip_close(h_pZip)

# counts the files under a folder, iteratively
func ZfFilesUnder(h_cRoot)
	h_aTodo = [ h_cRoot ]
	h_nFiles = 0
	while len(h_aTodo) > 0
		h_cHere = h_aTodo[len(h_aTodo)]
		del(h_aTodo, len(h_aTodo))
		h_aF = StzEngineDirListFiles(h_cHere)
		h_nFiles += len(h_aF)
		h_aD = StzEngineDirListDirs(h_cHere)
		for h_nQ = 1 to len(h_aD)
			if h_aD[h_nQ] != "." and h_aD[h_nQ] != ".."
				h_aTodo + (h_cHere + "/" + h_aD[h_nQ])
			ok
		next
	end
	return h_nFiles

# counts the files called h_cWanted anywhere under a folder
func ZfFilesNamed(h_cRoot, h_cWanted)
	h_aTodo = [ h_cRoot ]
	h_nFound = 0
	while len(h_aTodo) > 0
		h_cHere = h_aTodo[len(h_aTodo)]
		del(h_aTodo, len(h_aTodo))
		h_aF = StzEngineDirListFiles(h_cHere)
		for h_nQ = 1 to len(h_aF)
			if strcmp(h_aF[h_nQ], h_cWanted) = 0
				h_nFound++
			ok
		next
		h_aD = StzEngineDirListDirs(h_cHere)
		for h_nQ = 1 to len(h_aD)
			if h_aD[h_nQ] != "." and h_aD[h_nQ] != ".."
				h_aTodo + (h_cHere + "/" + h_aD[h_nQ])
			ok
		next
	end
	return h_nFound

# reads the CRC32 of an entry from the CENTRAL DIRECTORY of an archive, parsed by hand; -1 when absent
func ZfCentralCrc(h_cZip, h_cName)
	h_cData = read(h_cZip)
	h_nLen = len(h_cData)
	h_nName = len(h_cName)
	for h_nQ = 1 to h_nLen - 46
		if ascii(h_cData[h_nQ]) = 80 and ascii(h_cData[h_nQ + 1]) = 75 and ascii(h_cData[h_nQ + 2]) = 1 and ascii(h_cData[h_nQ + 3]) = 2
			h_nNLen = ZfByte(h_cData, h_nQ + 28) + ZfByte(h_cData, h_nQ + 29) * 256
			if h_nNLen = h_nName
				h_cNm = ""
				for h_nR = 1 to h_nNLen
					h_cNm += h_cData[h_nQ + 45 + h_nR]
				next
				if strcmp(h_cNm, h_cName) = 0
					return ZfByte(h_cData, h_nQ + 16) + ZfByte(h_cData, h_nQ + 17) * 256 + ZfByte(h_cData, h_nQ + 18) * 65536 + ZfByte(h_cData, h_nQ + 19) * 16777216
				ok
			ok
		ok
	next
	return -1

func ZfByte(h_cData, h_nPos)
	h_nV = ascii(h_cData[h_nPos])
	if h_nV < 0
		h_nV += 256
	ok
	return h_nV
