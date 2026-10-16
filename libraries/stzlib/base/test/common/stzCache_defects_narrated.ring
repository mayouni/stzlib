load "../../stzBase.ring"
load "../_narrated.ring"

# stzCache and stzCacheStorage -- the cache of function results kept in a file.
# Register rows (all "Raises ... today" before this guard): stzCache init, StorageType, CacheOpen,
# CacheFileHandler, CacheFindEntry, CacheGetCachedResult, CacheGetResultInLineNumber, CacheFileLines,
# CacheFileLineNumber, CacheFileNumberOfLines, AddLine, CacheFileColse, ComposeLine; stzCacheStorage
# init, FileHandler, FileName, CompleteFileName, StorageType.
#
# SAFETY: the cache writes files ("cache/<name>.txt" under the current folder). This guard moves into
# a fresh fixture folder under test/common, works only there, and removes it at the end. Every
# destructive call goes through CacheGuardOk, which refuses a relative path, "..", a drive root and
# anything outside the fixture. Run from inside test/common.

$cCacheOrigin = StzNormalizeSlashes(currentdir())
$cCacheFx = $cCacheOrigin + "/_fixture_cache"

# a Hebrew word built from its UTF-8 bytes, so the source stays ASCII
$cHeb = char(215) + char(169) + char(215) + char(156) + char(215) + char(149) + char(215) + char(157)
$cLastError = ""

Scenario("The path guard itself: it refuses everything outside the fixture")
	Then("a relative path is refused", CacheGuardOk("cache/sums.txt"), 0)
	Then("a path with two dots is refused", CacheGuardOk($cCacheFx + "/../x"), 0)
	Then("a drive root is refused", CacheGuardOk("C:/"), 0)
	Then("the folder that holds the fixture is refused", CacheGuardOk($cCacheOrigin), 0)
	Then("a sibling that only shares the prefix is refused", CacheGuardOk($cCacheFx + "_other/x.txt"), 0)
	Then("a number is refused", CacheGuardOk(5), 0)
	Then("the fixture folder itself is accepted", CacheGuardOk($cCacheFx), 1)
	Then("a file inside the fixture is accepted", CacheGuardOk($cCacheFx + "/cache/sums.txt"), 1)
EndScenario()

# start from an empty fixture, then work inside it
CacheCleanFixture()
StzDirCreatePath($cCacheFx)
chdir($cCacheFx)

Scenario("Building a cache with parentheses: the folder and the file appear, nothing is activated")
	Given("no cache folder in the fixture")
	Then("there is no cache folder yet", StzDirExists($cCacheFx + "/cache"), 0)
	When("new stzCache('sums', :InFile) is built")
	oCache = new stzCache("sums", :InFile)
	Then("the cache folder now exists", StzDirExists($cCacheFx + "/cache"), 1)
	Then("the cache file now exists", StzFileExists($cCacheFx + "/cache/sums.txt"), 1)
	Then("the storage type is the one given, in lower case", oCache.StorageType(), "infile")
	Then("the handle of the file is its path", oCache.CacheFileHandler(), "cache/sums.txt")
	Then("a new cache is not activated", oCache.IsActivated(), 0)
	Then("a new cache file holds no line", oCache.CacheFileNumberOfLines(), 0)
	Then("the cache lines are an empty list", len(oCache.CacheFileLines()), 0)
	Then("the cached content is the text NULL, nothing sets it", oCache.Content(), "NULL")
	Then("opening the cache returns the same handle", oCache.CacheOpen(), "cache/sums.txt")
EndScenario()

Scenario("Bad names and types are refused before anything is written")
	Then("an empty name raises", Raises("new stzCache('', :InFile)"), 1)
	Then("a name with a slash raises", Raises("new stzCache('a/b', :InFile)"), 1)
	Then("a name with a backslash raises", Raises("new stzCache('a' + char(92) + 'b', :InFile)"), 1)
	Then("a name that climbs out of the folder raises", Raises("new stzCache('..x', :InFile)"), 1)
	Then("a name with a drive colon raises", Raises("new stzCache('C:x', :InFile)"), 1)
	Then("a name that is not text raises", Raises("new stzCache(5, :InFile)"), 1)
	Then("an unknown storage type raises", Raises("new stzCache('bad', :OnTheMoon)"), 1)
	Then("the message names the class", StzFindFirst("stzCacheStorage", $cLastError) > 0, 1)
	Then("no file was created for the refused ones", CacheListCount(), 1)
EndScenario()

Scenario("ComposeLine joins the parts with a bar and keeps each part intact")
	Then("three plain parts are joined with bars", oCache.ComposeLine([ "Add", "2,3", "5" ]), "Add|2,3|5")
	Then("a number part is written as text", oCache.ComposeLine([ "Add", 2, 5 ]), "Add|2|5")
	Then("a list part is joined with commas", oCache.ComposeLine([ "Add", [ 2, 3 ], "5" ]), "Add|2,3|5")
	Then("a bar inside a part is escaped, so the line has still two bars",
		CountChar(oCache.ComposeLine([ "f", "a|b", "c" ]), "|"), 2)
	Then("a line feed inside a part never reaches the line",
		StzFindFirst(char(10), oCache.ComposeLine([ "f", "a" + char(10) + "b", "c" ])), 0)
	Then("a part that is not a list raises (negative)", Raises("oCache.ComposeLine('abc')"), 1)
	Then("an object part raises (negative)", Raises("oCache.ComposeLine([ 'a', new stzCache('sums', :InFile), 'c' ])"), 1)
EndScenario()

Scenario("A first call is a miss, the same call after storing is a hit with the same result")
	Given("an activated cache with no entry")
	oCache.Activate()
	Then("the cache is activated", oCache.IsActivated(), 1)
	Then("the first call is a miss: no line number", oCache.CacheFindEntry("Add", "2,3"), 0)
	Then("the first call has no cached result: it raises", Raises("oCache.CacheGetCachedResult('Add', '2,3')"), 1)
	Then("the message names the missing call", StzFindFirst("no cached entry", $cLastError) > 0, 1)
	When("the result of Add(2,3) is stored")
	Then("storing a line answers 1", oCache.AddLine( oCache.ComposeLine([ "Add", "2,3", "5" ]) ), 1)
	Then("the file now holds one line", oCache.CacheFileNumberOfLines(), 1)
	Then("the same call is a hit on line 1", oCache.CacheFindEntry("Add", "2,3"), 1)
	Then("the hit returns the stored result", oCache.CacheGetCachedResult("Add", "2,3"), "5")
	Then("a different argument is a miss", oCache.CacheFindEntry("Add", "2,4"), 0)
	Then("a prefix of the arguments is a miss", oCache.CacheFindEntry("Add", "2"), 0)
	Then("an argument that merely starts with the stored one is a miss", oCache.CacheFindEntry("Add", "2,35"), 0)
	Then("a different function with the same arguments is a miss", oCache.CacheFindEntry("Sub", "2,3"), 0)
	Then("the function name is case sensitive: add is a miss", oCache.CacheFindEntry("add", "2,3"), 0)
	Then("a different argument has no cached result: it raises", Raises("oCache.CacheGetCachedResult('Add', '2,4')"), 1)
	When("a second call is stored")
	oCache.AddLine( oCache.ComposeLine([ "Add", "2,4", "6" ]) )
	Then("the second call is on line 2", oCache.CacheFindEntry("Add", "2,4"), 2)
	Then("and returns its own result", oCache.CacheGetCachedResult("Add", "2,4"), "6")
	Then("the first call still returns its result", oCache.CacheGetCachedResult("Add", "2,3"), "5")
	Then("the result is read by line number too", oCache.CacheGetResultInLineNumber(2), "6")
EndScenario()

Scenario("The cache file survives closing and reopening")
	Then("closing the file answers 1", oCache.CacheFileClose(), 1)
	Then("the misspelt old name still works and answers 1", oCache.CacheFileColse(), 1)
	Then("the file is still there after closing", StzFileExists($cCacheFx + "/cache/sums.txt"), 1)
	Then("and still holds its two lines", oCache.CacheFileNumberOfLines(), 2)
	oCache = NULL
	oReopen = new stzCache("sums", :InFile)
	Then("a reopened cache keeps the two lines (the file was not emptied)", oReopen.CacheFileNumberOfLines(), 2)
	Then("a reopened cache is not activated by itself", oReopen.IsActivated(), 0)
	oReopen.Activate()
	Then("a reopened cache answers the stored call", oReopen.CacheGetCachedResult("Add", "2,3"), "5")
	Then("and the other stored call", oReopen.CacheGetCachedResult("Add", "2,4"), "6")
	Then("and still misses the unstored one", oReopen.CacheFindEntry("Add", "9,9"), 0)
	oOther = new stzCache("other", :InFile)
	oOther.Activate()
	Then("a cache of another name has its own file and no entry", oOther.CacheFindEntry("Add", "2,3"), 0)
	Then("so two cache files exist now", CacheListCount(), 2)
EndScenario()

Scenario("An inactive cache answers nothing, the file keeps what it holds")
	oReopen.Deactivate()
	Then("the cache is not activated", oReopen.IsActivated(), 0)
	Then("a stored call is not found", oReopen.CacheFindEntry("Add", "2,3"), 0)
	Then("its result is the empty text and nothing raises", oReopen.CacheGetCachedResult("Add", "2,3"), "")
	Then("the lines are still in the file", oReopen.CacheFileNumberOfLines(), 2)
	Then("reading a line by number still works", oReopen.CacheGetResultInLineNumber(1), "5")
	oReopen.Activate()
	Then("activated again, the same call is a hit", oReopen.CacheFindEntry("Add", "2,3"), 1)
	Then("and returns its result", oReopen.CacheGetCachedResult("Add", "2,3"), "5")
EndScenario()

Scenario("A result with the separator, a backslash, a line break or Hebrew round-trips")
	cBar = "left|right"
	cBack = "C:" + char(92) + "dir" + char(92) + "p"
	cLines = "one" + char(10) + "two" + char(13) + char(10) + "three"
	cEsc = "looks" + char(92) + "like" + char(92) + "escapes" + char(92) + "p" + char(92) + "n" + char(92) + "r"
	oReopen.AddLine( oReopen.ComposeLine([ "Join", "a|b", cBar ]) )
	oReopen.AddLine( oReopen.ComposeLine([ "Path", cBack, cBack ]) )
	oReopen.AddLine( oReopen.ComposeLine([ "Lines", "x", cLines ]) )
	oReopen.AddLine( oReopen.ComposeLine([ "Esc", "y", cEsc ]) )
	oReopen.AddLine( oReopen.ComposeLine([ "Heb", $cHeb, $cHeb + " " + $cHeb ]) )
	oReopen.AddLine( oReopen.ComposeLine([ "Empty", "z", "" ]) )
	oReopen.AddLine( oReopen.ComposeLine([ "Num", 7, 42 ]) )
	Then("each entry is one line of the file: 2 + 7 lines", oReopen.CacheFileNumberOfLines(), 9)
	Then("a result holding the separator comes back intact",
		Same(oReopen.CacheGetCachedResult("Join", "a|b"), cBar), 1)
	Then("a backslash path comes back intact", Same(oReopen.CacheGetCachedResult("Path", cBack), cBack), 1)
	Then("a result with line feed and carriage return comes back intact",
		Same(oReopen.CacheGetCachedResult("Lines", "x"), cLines), 1)
	Then("a result that spells the escapes comes back as spelt",
		Same(oReopen.CacheGetCachedResult("Esc", "y"), cEsc), 1)
	Then("a Hebrew argument finds its entry", oReopen.CacheFindEntry("Heb", $cHeb), 7)
	Then("a Hebrew result comes back byte for byte",
		Same(oReopen.CacheGetCachedResult("Heb", $cHeb), $cHeb + " " + $cHeb), 1)
	Then("an empty result comes back empty and is a hit", oReopen.CacheFindEntry("Empty", "z"), 8)
	Then("the empty result is the empty text", Same(oReopen.CacheGetCachedResult("Empty", "z"), ""), 1)
	Then("a number result comes back as its text", oReopen.CacheGetCachedResult("Num", "7"), "42")
	Then("the bar inside the argument does not match the part before it",
		oReopen.CacheFindEntry("Join", "a"), 0)
	Then("a Hebrew lookup with a different word is a miss", oReopen.CacheFindEntry("Heb", $cHeb + "x"), 0)
EndScenario()

Scenario("Reading the file by lines")
	Then("line 1 is the stored line as written", oReopen.CacheFileLineNumber(1), "Add|2,3|5")
	Then("line 2 is the second", oReopen.CacheFileLineNumber(2), "Add|2,4|6")
	Then("the lines are a list of the same count", len(oReopen.CacheFileLines()), oReopen.CacheFileNumberOfLines())
	Then("line 0 does not exist: it raises (negative)", Raises("oReopen.CacheFileLineNumber(0)"), 1)
	Then("a line past the end does not exist: it raises (negative)", Raises("oReopen.CacheFileLineNumber(99)"), 1)
	Then("a text for a line number raises (negative)", Raises("oReopen.CacheFileLineNumber('x')"), 1)
	Then("a result by an absent line number raises (negative)", Raises("oReopen.CacheGetResultInLineNumber(99)"), 1)
	oReopen.AddLine("not an entry")
	Then("a line that is not an entry of three parts has no result: it raises",
		Raises("oReopen.CacheGetResultInLineNumber(10)"), 1)
	Then("and is never a hit for a lookup", oReopen.CacheFindEntry("not an entry", ""), 0)
	Then("a line holding a line feed is refused by AddLine (negative)",
		Raises("oReopen.AddLine('a' + char(10) + 'b')"), 1)
	Then("a number is not a line (negative)", Raises("oReopen.AddLine(5)"), 1)
	Then("the refused ones left the file at 10 lines", oReopen.CacheFileNumberOfLines(), 10)
	StzFileWrite($cCacheFx + "/cache/crlf.txt", "f|1|one" + char(13) + char(10) + "f|2|two" + char(13) + char(10))
	oCrlf = new stzCache("crlf", :InFile)
	oCrlf.Activate()
	Then("a file saved with carriage returns reads without them", oCrlf.CacheFileLineNumber(1), "f|1|one")
	Then("and has two lines, not three", oCrlf.CacheFileNumberOfLines(), 2)
	Then("and answers from them", oCrlf.CacheGetCachedResult("f", "2"), "two")
EndScenario()

Scenario("stzCacheStorage on its own, and the storage types that keep nothing")
	oSto = new stzCacheStorage("disk", "cache", :InFile)
	Then("the file name is the cache name with .txt", oSto.FileName(), "disk.txt")
	Then("the complete name adds the folder", oSto.CompleteFileName(), "cache/disk.txt")
	Then("the handle is the path", oSto.FileHandler(), "cache/disk.txt")
	Then("the storage type is the one given", oSto.StorageType(), "infile")
	Then("the file was created", StzFileExists($cCacheFx + "/cache/disk.txt"), 1)
	oMemSto = new stzCacheStorage("mem", "cache", :InMemory)
	Then("an in-memory storage has no file handle", oMemSto.FileHandler(), "")
	Then("and creates no file", StzFileExists($cCacheFx + "/cache/mem.txt"), 0)
	Then("it still names its type", oMemSto.StorageType(), "inmemory")
	Then("a storage with a path that climbs out raises (negative)",
		Raises("new stzCacheStorage('x', '../outside', :InFile)"), 1)
	Then("a storage with an empty path raises (negative)", Raises("new stzCacheStorage('x', '', :InFile)"), 1)
	oMem = new stzCache("mem", :InMemory)
	oMem.Activate()
	Then("an in-memory cache can be built", oMem.StorageType(), "inmemory")
	Then("but keeps nothing: AddLine raises", Raises("oMem.AddLine('f|1|2')"), 1)
	Then("and has no file to open: CacheOpen raises", Raises("oMem.CacheOpen()"), 1)
	Then("and no file lines", oMem.CacheFileNumberOfLines(), 0)
	Then("and nothing is a hit", oMem.CacheFindEntry("f", "1"), 0)
	Then("the in-memory cache created no file", StzFileExists($cCacheFx + "/cache/mem.txt"), 0)
EndScenario()

Scenario("The fixture is removed, and nothing outside it was touched")
	chdir($cCacheOrigin)
	oCache = NULL
	oReopen = NULL
	oOther = NULL
	oCrlf = NULL
	CacheCleanFixture()
	Then("the fixture folder is gone", StzDirExists($cCacheFx), 0)
	Then("the test folder holds no cache folder of its own", StzDirExists($cCacheOrigin + "/cache"), 0)
EndScenario()

Summary()

func StzNormalizeSlashes(cPath)
	cOut = ""
	nLen = len(cPath)
	for i = 1 to nLen
		if cPath[i] = char(92)
			cOut += "/"
		else
			cOut += cPath[i]
		ok
	next
	return cOut

# 1 only when the path is the fixture folder or lies under it: absolute, no "..", not a drive root.
func CacheGuardOk(cPath)
	if NOT isString(cPath)
		return 0
	ok
	c = lower(StzNormalizeSlashes(cPath))
	cRoot = lower($cCacheFx)
	if c = "" or StzFindFirst("..", c) > 0
		return 0
	ok
	# the fixture root itself must be a folder named _fixture_cache, never a drive root
	if right(cRoot, 15) != "/_fixture_cache"
		return 0
	ok
	bAbsolute = 0
	if len(c) > 2 and c[2] = ":" and c[3] = "/"
		bAbsolute = 1
	but c[1] = "/"
		bAbsolute = 1
	ok
	if bAbsolute = 0
		return 0
	ok
	if c = cRoot
		return 1
	ok
	if len(c) > len(cRoot) + 1 and left(c, len(cRoot) + 1) = cRoot + "/"
		return 1
	ok
	return 0

func CacheGuardedDeleteFile(cPath)
	if CacheGuardOk(cPath) = 0
		raise("CacheGuardedDeleteFile: refused " + cPath + char(10))
	ok
	return StzFileDelete(cPath)

func CacheGuardedDeleteDir(cPath)
	if CacheGuardOk(cPath) = 0
		raise("CacheGuardedDeleteDir: refused " + cPath + char(10))
	ok
	return StzDirDelete(cPath)

# removes the fixture: the files of its cache folder, that folder, then the fixture folder
func CacheCleanFixture()
	if StzDirExists($cCacheFx) = 0
		return 1
	ok
	cDir = $cCacheFx + "/cache"
	if StzDirExists(cDir)
		aFiles = StzEngineDirListFiles(cDir)
		nFiles = len(aFiles)
		for i = 1 to nFiles
			CacheGuardedDeleteFile(cDir + "/" + aFiles[i])
		next
		CacheGuardedDeleteDir(cDir)
	ok
	aLeft = StzEngineDirListFiles($cCacheFx)
	nLeft = len(aLeft)
	for i = 1 to nLeft
		CacheGuardedDeleteFile($cCacheFx + "/" + aLeft[i])
	next
	return CacheGuardedDeleteDir($cCacheFx)

func CacheListCount()
	if StzDirExists($cCacheFx + "/cache") = 0
		return 0
	ok
	return len(StzEngineDirListFiles($cCacheFx + "/cache"))

# 1 when the code raised an error; the message is kept in $cLastError
func Raises(cCode)
	$cLastError = ""
	try
		eval(cCode)
	catch
		$cLastError = cCatchError
		return 1
	done
	return 0

func Same(cA, cB)
	if NOT ( isString(cA) and isString(cB) )
		return 0
	ok
	return strcmp(cA, cB) = 0

func CountChar(cText, cChar)
	nCount = 0
	nLen = len(cText)
	for i = 1 to nLen
		if cText[i] = cChar
			nCount++
		ok
	next
	return nCount
