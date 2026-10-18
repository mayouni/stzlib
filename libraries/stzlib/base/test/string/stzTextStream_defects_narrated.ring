load "guilib.ring"
load "../../stzBase.ring"
load "../_narrated.ring"

# stzTextStream -- the six rows of the register (DEFECTS.md) and the neighbours found under them.
#
# Before: SetFromFile raised R20 (it built an stzFile with two parameters), SetEncoding raised
# Bad parameter type! for every name, IsSetFromFile and IsSetFromSocket never became TRUE (the
# setter wrote _bSetFromFile_, the getter read _bIsSetFromFile_), IsSetFromProcess raised R24
# (a misspelled return) and Flush raised R14 (a call to flash). Run from inside test/string.
#
# The class needs RingQt, loaded here before stzlib. No real socket is opened and no process is
# started: the socket and process flags are driven with an in-memory QBuffer, which the class accepts
# as any open device. A file is a scratch file next to this guard, removed at the end. Hebrew, Arabic
# and emoji texts are built from char codes and never printed.

cTsA = "_tsd_a.txt"
cTsB = "_tsd_b.txt"
cTsU = "_tsd_u.txt"
cTsC = "_tsd_c.txt"
cTsMissing = "_tsd_missing_never_created.txt"

remove(cTsA)
remove(cTsB)
remove(cTsU)
remove(cTsC)

# alef-free sample: shin lamed vav final-mem, meem, a smiling face (4 bytes)
cTsHeb = char(215) + char(169) + char(215) + char(156) + char(215) + char(149) + char(215) + char(157)
cTsAr = char(217) + char(133)
cTsEmo = char(240) + char(159) + char(152) + char(128)
cTsMulti = cTsHeb + char(10) + cTsAr + char(10) + cTsEmo

write(cTsA, "alpha" + char(10) + "beta" + char(10) + "gamma")
write(cTsB, "one" + char(10) + "two")
write(cTsU, cTsMulti)
write(cTsC, "held")

Scenario("A new stream has no source, and every flag is a number")
	o = new stzTextStream()
	Then("the source is an empty text", o.SourceOfStream(), "")
	Then("IsSetFromFile is 0, not NULL", o.IsSetFromFile(), 0)
	Then("IsSetFromSocket is 0", o.IsSetFromSocket(), 0)
	Then("IsSetFromProcess answers 0 (it raised R24)", o.IsSetFromProcess(), 0)
	Then("the flags are numbers", isNumber(o.IsSetFromFile()) and isNumber(o.IsSetFromSocket()) and isNumber(o.IsSetFromProcess()), 1)
	Then("the status is ok", o.Status(), "ok")
	Then("no encoding was applied", o.Encoding(), "")
	Then("unicode detection is on", o.IsUnicodeAutoDetected(), 1)
	Then("ReadAll with no device is an empty text", TsSame(o.ReadAll(), ""), 1)
EndScenario()

Scenario("SetFromFile attaches a file (it raised R20)")
	o = new stzTextStream()
	r = o.SetFromFile(cTsA)
	Then("it answers 1", r, 1)
	Then("IsSetFromFile is TRUE after the attach (was 0 before)", o.IsSetFromFile(), 1)
	Then("the source is file (it stayed empty)", o.SourceOfStream(), "file")
	Then("it is not a socket", o.IsSetFromSocket(), 0)
	Then("it is not a process", o.IsSetFromProcess(), 0)
	cWhole = o.ReadAll()
	Then("ReadAll returns the whole file, exact", TsSame(cWhole, "alpha" + char(10) + "beta" + char(10) + "gamma"), 1)
	Then("a second ReadAll finds nothing left", TsSame(o.ReadAll(), ""), 1)
	Then("the status is ok after reading to the end", o.Status(), "ok")

	o = new stzTextStream()
	o.SetFromFile(cTsA)
	aL = o.Lines()
	Then("Lines gives three lines", len(aL), 3)
	Then("the second is beta", TsSame(aL[2], "beta"), 1)

	o = new stzTextStream()
	o.SetFromFile(cTsA)
	cLine = o.ReadLine(3)
	Then("ReadLine(3) gives gamma", TsSame(cLine, "gamma"), 1)
EndScenario()

Scenario("A file that cannot be attached sets nothing")
	o = new stzTextStream()
	Then("a missing file answers 0", o.SetFromFile(cTsMissing), 0)
	Then("so IsSetFromFile stays FALSE", o.IsSetFromFile(), 0)
	Then("and the source stays empty", o.SourceOfStream(), "")
	Then("a folder answers 0", o.SetFromFile("."), 0)
	Then("so the flag is still FALSE", o.IsSetFromFile(), 0)
	Then("an empty path answers 0", o.SetFromFile(""), 0)
	Then("a number answers 0, not an error", o.SetFromFile(42), 0)
	Then("a list answers 0, not an error", o.SetFromFile([ 1 ]), 0)
	Then("still no source", o.SourceOfStream(), "")

	o = new stzTextStream()
	o.SetFromFile(cTsA)
	Then("a failure after a success answers 0", o.SetFromFile(cTsMissing), 0)
	Then("the file stays attached", o.SourceOfStream(), "file")
	Then("the flag stays TRUE", o.IsSetFromFile(), 1)
	cKept = o.ReadAll()
	Then("and it still reads the first file", TsSame(StzLeft(cKept, 5), "alpha"), 1)
EndScenario()

Scenario("A second source replaces the first, and only its flag is TRUE")
	o = new stzTextStream()
	o.SetFromFile(cTsA)
	r = o.SetFromFile(cTsB)
	Then("the second file attaches", r, 1)
	cB = o.ReadAll()
	Then("it reads the second file", TsSame(cB, "one" + char(10) + "two"), 1)
	Then("still a file", o.IsSetFromFile(), 1)

	o = new stzTextStream()
	o.SetFromFile(cTsC)
	Then("while attached, the file is held open and cannot be removed", TsRemoveOk(cTsC), 0)
	o.SetFromProcess(TsBuffer("x"))
	Then("a later source closes the file it replaced", TsRemoveOk(cTsC), 1)

	o = new stzTextStream()
	o.SetFromFile(cTsA)
	o.SetFromFile(cTsB)
	Then("a second file closes the first one", TsRemoveOk(cTsA), 1)
	write(cTsA, "alpha" + char(10) + "beta" + char(10) + "gamma")

	oBuf = TsBuffer("from memory")
	r = o.SetFromProcess(oBuf)
	Then("a process device replaces the file", r, 1)
	Then("IsSetFromProcess is TRUE (it raised R24)", o.IsSetFromProcess(), 1)
	Then("the file flag fell to FALSE", o.IsSetFromFile(), 0)
	Then("the source is process", o.SourceOfStream(), "process")
	Then("it reads the buffer", TsSame(o.ReadAll(), "from memory"), 1)

	oBuf2 = TsBuffer("sock")
	r = o.SetFromSocket(oBuf2)
	Then("a socket stand-in replaces the process, answering 1", r, 1)
	Then("IsSetFromSocket is TRUE", o.IsSetFromSocket(), 1)
	Then("the process flag fell to FALSE", o.IsSetFromProcess(), 0)
	Then("the source is socket", o.SourceOfStream(), "socket")
	Then("the file flag is still FALSE", o.IsSetFromFile(), 0)
EndScenario()

Scenario("IsSetFromSocket and the misspelled setter (it stayed 0)")
	o = new stzTextStream()
	Then("0 before any attach", o.IsSetFromSocket(), 0)
	oBuf = TsBuffer("abc")
	r = o.SetFromScocket(oBuf)
	Then("the old misspelled name still works and answers 1", r, 1)
	Then("IsSetFromSocket is TRUE after it", o.IsSetFromSocket(), 1)
	Then("SourceOfStream agrees", o.SourceOfStream(), "socket")
	Then("it reads the device", TsSame(o.ReadAll(), "abc"), 1)

	o = new stzTextStream()
	oBuf = TsBuffer("xyz")
	r = o.SetFromSocket(oBuf)
	Then("the correct spelling answers 1", r, 1)
	Then("and sets the same flag", o.IsSetFromSocket(), 1)
	Then("and the same source", o.SourceOfStream(), "socket")
	Then("IsSetFromProcess stays FALSE", o.IsSetFromProcess(), 0)

	o = new stzTextStream()
	Then("the misspelled name refuses a number", o.SetFromScocket(5), 0)
	Then("the right name refuses a text", o.SetFromSocket("not a socket"), 0)
	Then("a refused call sets no flag", o.IsSetFromSocket(), 0)
	Then("nor a source", o.SourceOfStream(), "")
EndScenario()

Scenario("IsSetFromProcess after SetFromProcess")
	o = new stzTextStream()
	oBuf = TsBuffer("p1" + char(10) + "p2")
	Then("FALSE before", o.IsSetFromProcess(), 0)
	r = o.SetFromProcess(oBuf)
	Then("SetFromProcess answers 1", r, 1)
	Then("TRUE after", o.IsSetFromProcess(), 1)
	Then("the file flag is FALSE", o.IsSetFromFile(), 0)
	Then("the socket flag is FALSE", o.IsSetFromSocket(), 0)
	aL = o.Lines()
	Then("the lines are read", TsSame(aL[1] + "|" + aL[2], "p1|p2"), 1)

	o = new stzTextStream()
	Then("a number is refused", o.SetFromProcess(7), 0)
	Then("and sets no flag", o.IsSetFromProcess(), 0)
EndScenario()

Scenario("SetEncoding applies a codec (it raised Bad parameter type!)")
	o = new stzTextStream()
	o.SetFromFile(cTsU)
	Then("the default codec garbles the Hebrew, Arabic and emoji lines",
		TsSame(TsReadWith("", cTsU), cTsMulti), 0)
	Then("UTF-8 reads them exact", TsSame(TsReadWith("UTF-8", cTsU), cTsMulti), 1)
	Then("utf8 does too (letter case does not matter)", TsSame(TsReadWith("utf8", cTsU), cTsMulti), 1)
	Then("ISO-8859-1 garbles them again, so it was applied and is not the UTF-8 one",
		TsSame(TsReadWith("ISO-8859-1", cTsU), cTsMulti), 0)
	Then("UTF-16LE garbles them differently from UTF-8", TsSame(TsReadWith("UTF-16LE", cTsU), cTsMulti), 0)

	o = new stzTextStream()
	r = o.SetEncoding("UTF-8")
	Then("SetEncoding before any source answers 1", r, 1)
	Then("Encoding answers the name applied", o.Encoding(), "UTF-8")
	o.SetFromFile(cTsU)
	cWhole = o.ReadAll()
	Then("and it holds after a file is attached", TsSame(cWhole, cTsMulti), 1)

	o = new stzTextStream()
	o.SetFromFile(cTsU)
	o.SetEncoding("UTF-8")
	cWhole = o.ReadAll()
	Then("applied after the attach it also holds", TsSame(cWhole, cTsMulti), 1)

	o = new stzTextStream()
	o.SetFromFile(cTsU)
	o.SetEncoding("UTF-8")
	aL = o.Lines()
	Then("Lines are three", len(aL), 3)
	Then("the first is the Hebrew word", TsSame(aL[1], cTsHeb), 1)
	Then("the third is the emoji", TsSame(aL[3], cTsEmo), 1)

	o = new stzTextStream()
	o.SetEncoding("UTF-8")
	o.SetEncoding("latin1")
	Then("a later name replaces the earlier one", o.Encoding(), "latin1")
EndScenario()

Scenario("The names SetEncoding accepts, and the ones it refuses")
	o = new stzTextStream()
	Then("UTF-8", o.SetEncoding("UTF-8"), 1)
	Then("utf8", o.SetEncoding("utf8"), 1)
	Then("ISO-8859-1", o.SetEncoding("ISO-8859-1"), 1)
	Then("latin1", o.SetEncoding("Latin1"), 1)
	Then("UTF-16", o.SetEncoding("UTF-16"), 1)
	Then("UTF-16LE", o.SetEncoding("UTF-16LE"), 1)
	Then("UTF-16BE", o.SetEncoding("utf-16be"), 1)
	Then("UTF-32", o.SetEncoding("UTF-32"), 1)
	Then("UTF-32LE", o.SetEncoding("UTF-32LE"), 1)
	Then("UTF-32BE", o.SetEncoding("UTF-32BE"), 1)
	o.SetEncoding("UTF-8")
	Then("an unknown name is refused", o.SetEncoding("NOPE-9"), 0)
	Then("UTF-7 is outside the list", o.SetEncoding("UTF-7"), 0)
	Then("windows-1252 is outside the list", o.SetEncoding("windows-1252"), 0)
	Then("an empty text is refused", o.SetEncoding(""), 0)
	Then("a number is refused", o.SetEncoding(8), 0)
	Then("a name with a space is refused", o.SetEncoding("UTF-8 UTF-16"), 0)
	Then("a refusal leaves the earlier name", o.Encoding(), "UTF-8")
	o.SetFromFile(cTsU)
	cWhole = o.ReadAll()
	Then("and the earlier codec still decodes", TsSame(cWhole, cTsMulti), 1)
EndScenario()

Scenario("The wide codecs decode their own bytes")
	cLe = "A" + char(0) + "B" + char(0)
	cBe = char(0) + "A" + char(0) + "B"
	cLe32 = "A" + char(0) + char(0) + char(0) + "B" + char(0) + char(0) + char(0)
	Then("UTF-16LE reads A B", TsSame(TsBytes(cLe, "UTF-16LE"), "AB"), 1)
	Then("UTF-16BE reads A B", TsSame(TsBytes(cBe, "UTF-16BE"), "AB"), 1)
	Then("UTF-32LE reads A B", TsSame(TsBytes(cLe32, "UTF-32LE"), "AB"), 1)
	Then("UTF-16BE does not read the little-endian bytes as A B", TsSame(TsBytes(cLe, "UTF-16BE"), "AB"), 0)
	Then("UTF-8 does not read UTF-16LE bytes as A B", TsSame(TsBytes(cLe, "UTF-8"), "AB"), 0)
EndScenario()

Scenario("Flush (it raised R14, a call to flash)")
	o = new stzTextStream()
	cErr = TsCatch(o, "Flush")
	Then("with no device it does not raise", cErr, "")
	Then("and answers 1", o.Flush(), 1)

	o = new stzTextStream()
	o.SetFromFile(cTsA)
	Then("with a file attached it answers 1", o.Flush(), 1)
	cWhole = o.ReadAll()
	Then("the stream still reads everything", TsSame(StzLeft(cWhole, 5), "alpha"), 1)
	Then("after reading to the end it still answers 1", o.Flush(), 1)
	Then("the status stays ok", o.Status(), "ok")

	o = new stzTextStream()
	oBuf = TsBuffer("zz")
	o.SetFromProcess(oBuf)
	Then("with a buffer attached it answers 1", o.Flush(), 1)
	Then("and the buffer is still readable", TsSame(o.ReadAll(), "zz"), 1)
EndScenario()

Scenario("SetStatus sets the status (it answered 1 and changed nothing)")
	o = new stzTextStream()
	Then("it answers 1", o.SetStatus(:ReadPastEnd), 1)
	Then("Status reads readpastend", o.Status(), "readpastend")
	Then("a later problem does not replace the first (Qt keeps the first)", TsStatusAfter(o, :WriteFailed), "readpastend")
	o.ResetStatus()
	Then("ResetStatus brings ok back", o.Status(), "ok")
	o.SetStatus(:ReadCorruptData)
	Then("ReadCorruptData", o.Status(), "readcorruptdata")
	o.ResetStatus()
	o.SetStatus(:WriteFailed)
	Then("WriteFailed", o.Status(), "writefailed")
	o.ResetStatus()
	o.SetStatus(:Ok)
	Then("Ok keeps it ok", o.Status(), "ok")
	cErr = TsCatch2(o, "SetStatus", "Nonsense")
	Then("an unknown name raises", len(cErr) > 0, 1)
	Then("the message names the status", StzFindFirst("Nonsense", cErr) > 0, 1)
	Then("and the status is untouched", o.Status(), "ok")
EndScenario()

Scenario("SetLocale (it ended the Ring process)")
	o = new stzTextStream()
	Then("a locale name answers 1", o.SetLocale("de_DE"), 1)
	cName = o.Locale().name()
	Then("Locale reads it back", cName, "de_DE")
	Then("the text C answers 1", o.SetLocale("C"), 1)
	cName = o.Locale().name()
	Then("and Locale reads C", cName, "C")
	oLoc = new QLocale("fr_FR")
	Then("a QLocale object answers 1", o.SetLocale(oLoc), 1)
	cName = o.Locale().name()
	Then("and is applied", cName, "fr_FR")
	Then("a number is refused, the process lives", o.SetLocale(1), 0)
	cName = o.Locale().name()
	Then("and the locale stays", cName, "fr_FR")
EndScenario()

Scenario("Delete frees the stream and closes the file it opened")
	o = new stzTextStream()
	o.SetFromFile(cTsB)
	cRead = o.ReadAll()
	Then("the file reads before", TsSame(StzLeft(cRead, 3), "one"), 1)
	Then("while the stream is alive the file is held open", TsRemoveOk(cTsB), 0)
	o.Delete()
	Then("after Delete the scratch file can be removed", TsRemoveOk(cTsB), 1)
EndScenario()

remove(cTsA)
remove(cTsB)
remove(cTsU)
remove(cTsC)

Summary()

# case-sensitive text equality as 1/0 (= on texts folds case)
func TsSame(cA1, cB1)
	if strcmp(cA1, cB1) = 0
		return 1
	ok
	return 0

# an open in-memory device holding the text
func TsBuffer(cText)
	oBA = new QByteArray()
	oBA.append(cText)
	oBuf = new QBuffer(NULL)
	oBuf.setData(oBA)
	oBuf.open(1)
	return oBuf

# what a file reads back as under an encoding name ("" = none applied)
func TsReadWith(cEncoding, cFile)
	o = new stzTextStream()
	o.SetFromFile(cFile)
	if len(cEncoding) > 0
		o.SetEncoding(cEncoding)
	ok
	cR = o.ReadAll()
	o.Delete()
	return cR

# what the raw bytes read back as under an encoding name
func TsBytes(cBytes, cEncoding)
	cF = "_tsd_bytes.tmp"
	write(cF, cBytes)
	cR = TsReadWith(cEncoding, cF)
	remove(cF)
	return cR

# the error text of calling a method with no argument, "" when it did not raise
func TsCatch(o, cMethod)
	cE = ""
	try
		if strcmp(cMethod, "Flush") = 0
			o.Flush()
		ok
	catch
		cE = cCatchError
	done
	return cE

# the error text of calling a one-argument setter, "" when it did not raise
func TsCatch2(o, cMethod, xArg)
	cE = ""
	try
		if strcmp(cMethod, "SetStatus") = 0
			o.SetStatus(xArg)
		ok
	catch
		cE = cCatchError
	done
	return cE

func TsStatusAfter(o, cNext)
	o.SetStatus(cNext)
	return o.Status()

# 1 when the file could be removed (a file still open by the stream would refuse on Windows)
func TsRemoveOk(cFile)
	remove(cFile)
	if fexists(cFile)
		return 0
	ok
	return 1
