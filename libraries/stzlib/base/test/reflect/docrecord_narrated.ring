load "../../stzBase.ring"
load "../_narrated.ring"

# DOCREFORM -- the reference record (base/meta/stzDocRecord.ring + stzDocExport.ring).
# The block above a def is read, what the code can say is derived, and the record
# says WHICH it is, field by field. Everything here runs on a small fixture library
# (docrecord_fixture/), so it takes seconds, not the minute the whole library takes.

cFxBase = currentdir() + "/docrecord_fixture"
cFxFile = cFxBase + "/fx/stzDocFx.ring"

Scenario("The block: brief, detail, fields, continuation lines")
	aRun = [ " Returns the positions of every occurrence of pcSubStr.", "",
	         " A detail line.", "", "   pcSubStr   the text to look for",
	         "   returns    a list of numbers;", "              [ ] when absent",
	         '   example    ? @@( Q("banana").Find("an") )', "              #--> [ 2, 4 ]",
	         "   see        FindFirst, FindNth" ]
	aP = _StzDocParseRun(aRun, [ "pcSubStr" ])
	Then("the brief is the text before the first bare #",
		aP[1], "Returns the positions of every occurrence of pcSubStr.")
	Then("the detail is the paragraph after it", aP[2], "A detail line.")
	Then("a run with a separator or a field is not legacy", aP[4], 0)
	Then("there are four fields", len(aP[3]), 4)
	Then("a field named after a parameter of the def is a parameter field",
		aP[3][1][1] + ":" + aP[3][1][2], "param:pcSubStr")
	Then("an indented line continues the field above",
		aP[3][2][3], "a list of numbers; [ ] when absent")
	Then("an example keeps its lines, and its #--> promise sits inline",
		aP[3][3][3], '? @@( Q("banana").Find("an") )' + char(10) + "#--> [ 2, 4 ]")
	Then("the same run with a def that has no such parameter has one field fewer",
		len(_StzDocParseRun(aRun, [])[3]), 3)
	aP2 = _StzDocParseRun([ " A legacy comment." ], [])
	Then("a one-line comment is a valid brief", aP2[1], "A legacy comment.")
	Then("and is marked legacy", aP2[4], 1)
	aP3 = _StzDocParseRun([ " Returns x.", "   see the manual" ], [])
	Then("a key followed by ONE space is prose, not a field", len(aP3[3]), 0)
EndScenario()

Scenario("The scan: class extents, methods, forwards")
	aCls = _StzDocScanLibrary(cFxBase)
	Then("three classes are found (a class inside /* */ is not)", len(aCls), 3)
	nI = 0
	for i = 1 to len(aCls)
		if aCls[i][1] = "stzDocFx" nI = i ok
	next
	aL = _StzDocLines(cFxFile)
	aR = _StzDocScanRange(aL, aCls[nI][4] + 1, aCls[nI][5])
	cNames = ""
	for i = 1 to len(aR)
		cNames += aR[i][:name] + " "
	next
	Then("a func inside a class is a method: the class does NOT end there",
		StzFindFirst("AfterFunc", cNames) > 0, TRUE)
	Then("MidClassMethod is read as a method", StzFindFirst("MidClassMethod", cNames) > 0, TRUE)
	Then("a global func StzXxx after the class is not a method",
		StzFindFirst("StzDocFxQ", cNames), 0)
	nF = 0
	nS = 0
	nLo = 0
	for i = 1 to len(aR)
		if aR[i][:name] = "Find" nF = i ok
		if aR[i][:name] = "Search" nS = i ok
		if aR[i][:name] = "Locate" nLo = i ok
	next
	Then("Find forwards to FindCS with its own arguments only, so it is a PURE forward",
		aR[nF][:fwd] + ":" + aR[nF][:fwdpure], "FindCS:0")
	Then("Locate is a pure forward to Find", aR[nLo][:fwd] + ":" + aR[nLo][:fwdpure], "Find:1")
	Then("the doc of Find is read: brief", aR[nF][:brief],
		"Returns the positions of every occurrence of pcSubStr, as a list of numbers.")
	Then("the section Find sits in is recorded", aR[nF][:section], "finding")
EndScenario()

Scenario("The harvest the library already had still answers the same way")
	aH = _StzHarvestClass(cFxFile, "stzDocFx")
	nF = 0
	nC = 0
	nD = 0
	for i = 1 to len(aH)
		if aH[i][1] = "Find" nF = i ok
		if aH[i][1] = "Contains" nC = i ok
		if aH[i][1] = "pvtHelper" nD = i ok
	next
	Then("a method's description is its BRIEF, not the design paragraph under it",
		aH[nF][2], "Returns the positions of every occurrence of pcSubStr, as a list of numbers.")
	Then("the detail paragraph is not the description",
		StzFindFirst("Case-sensitive by default", aH[nF][2]), 0)
	Then("the base form of the brief's opening verb is folded into the retrieval-only field (Returns -> return)",
		StzFindFirst("return", aH[nF][3]) > 0, TRUE)
	Then("the detail paragraph is NOT folded in (old maintainer talk once made an unrelated method win an Ask)",
		StzFindFirst("Case-sensitive by default", aH[nF][3]), 0)
	Then("a legacy one-line comment is still the description", aH[nC][2], "a legacy one-line comment")
	Then("a section title is NEVER a description", aH[nD][2], "")
	Then("but it is still kept for retrieval", StzFindFirst("internals", aH[nD][3]) > 0, TRUE)
	Then("a field line is never a description", StzFindFirst("pcSubStr   the text", aH[nF][2]), 0)
EndScenario()

Scenario("The export: one deterministic JSON, valid, with the derived parts")
	cOut1 = cFxBase + "/out1.json"
	cOut2 = cFxBase + "/out2.json"
	r = StzReferenceExport(cFxBase, cOut1, "fixture", "2026-10-05")
	r2 = StzReferenceExport(cFxBase, cOut2, "fixture", "2026-10-05")
	cJ1 = read(cOut1)
	cJ2 = read(cOut2)
	Then("the file is valid JSON", StzJsonIsValid(cJ1), TRUE)
	Then("two exports of the same tree are byte-identical", cJ1 = cJ2, TRUE)
	Then("the schema is 1", StzFindFirst('"schema":1', cJ1) > 0, TRUE)
	Then("Find carries its extensions: FindCS, FindQ and FindXT are Find, not three methods",
		StzFindFirst('"extensions":[{"name":"FindCS"', cJ1) > 0 and
		StzFindFirst('"name":"FindQ"', cJ1) > 0 and StzFindFirst('"name":"FindXT"', cJ1) > 0, TRUE)
	Then("Locate is listed as another name of Find", StzFindFirst('"aliases":["Locate"]', cJ1) > 0, TRUE)
	Then("an empty subclass is another name of its parent class",
		StzFindFirst('"alias_of":"stzDocFx"', cJ1) > 0, TRUE)
	Then("the class block is read: receiver", StzFindFirst('"receiver":"o1 = new stzDocFx(', cJ1) > 0, TRUE)
	Then("a method with no doc of its own gets NO brief from its section",
		StzFindFirst('"name":"Describe","line":', cJ1) > 0 and
		StzFindFirst('"key":"stzdocfx.describe","name":"Describe","line":' , cJ1) > 0, TRUE)
	Then("a predicate gets a derived brief, labelled derived",
		StzFindFirst('"brief":"TRUE if the object is empty."', cJ1) > 0 and
		StzFindFirst('"origin":{"brief":"derived"', cJ1) > 0, TRUE)
	Then("a pvt name is marked internal, derived", StzFindFirst('"status":"internal"', cJ1) > 0, TRUE)
	Then("a private method is not in the record", StzFindFirst('"name":"_private"', cJ1), 0)
	Then("the summary counts the roots", r[:roots] >= 9, TRUE)
	remove(cOut1)
	remove(cOut2)
EndScenario()

Scenario("The findings: dead forwards, internals shown, typos")
	aF = StzDocFindings(cFxBase)
	cFound = ""
	for i = 1 to len(aF)
		cFound += aF[i][:rule] + ":" + aF[i][:subject] + " "
	next
	Then("a public name forwarding to a method nobody defines is a finding",
		StzFindFirst("doc-dead-forward:stzDocFx.Search", cFound) > 0, TRUE)
	Then("a forward to a method that exists is not", StzFindFirst("doc-dead-forward:stzDocFx.Locate", cFound), 0)
	Then("a pvt name not marked internal is a finding",
		StzFindFirst("doc-internal-shown:stzDocFx.pvtHelper", cFound) > 0, TRUE)
	Then("one edit apart (a transposition) is detected", _StzDocDam1("shwo", "show"), 1)
	Then("a substitution", _StzDocDam1("colmun", "column"), 1)
	Then("an insertion", _StzDocDam1("positon", "position"), 1)
	Then("two edits are not", _StzDocDam1("neighther", "neither"), 0)
	Then("an inflection is not a typo", _StzDocInflection("item", "items"), 1)
	Then("a different word is", _StzDocInflection("befor", "before"), 0)
EndScenario()

Scenario("The score: the brief checks")
	Then("a good brief passes the form check",
		_StzDocBriefForm("Returns the positions of every occurrence of pcSubStr."), 1)
	Then("a comma after the first word is punctuation: Returns, for each ...",
		_StzDocBriefForm("Returns, for each occurrence, the items on both sides."), 1)
	Then("TRUE if is a valid opening",
		_StzDocBriefForm("TRUE if the text is made of letters only."), 1)
	Then("a lowercase start fails", _StzDocBriefForm("returns the positions of every occurrence."), 0)
	Then("no final period fails", _StzDocBriefForm("Returns the positions of every occurrence"), 0)
	Then("under 20 characters fails", _StzDocBriefForm("Finds it."), 0)
	Then("over 140 characters fails", _StzDocBriefForm("Returns " + copy("a very long description ", 8) + "."), 0)
	Then("a noun phrase fails (no verb)", _StzDocBriefForm("The positions of every occurrence of the text."), 0)
	Then("a brief that only restates the name fails check 2",
		_StzDocBriefRestates("Returns the number of chars.", "NumberOfChars"), 1)
	Then("a brief that adds something passes check 2",
		_StzDocBriefRestates("Returns how many characters the text holds, counting spaces.", "NumberOfChars"), 0)
	Then("a brief that repeats the signature fails check 2",
		_StzDocBriefRestates("Calls Find(pcSubStr) and returns the list.", "Find"), 1)
EndScenario()

Scenario("ExplainMethod and RecordOf show what the author WROTE")
	o = StzSelfDocQ(cFxFile)
	cE = o.ExplainMethod("Find")
	Then("the brief opens the explanation",
		StzFindFirst("Returns the positions of every occurrence", cE) > 0, TRUE)
	Then("the parameter role is shown", StzFindFirst("pcSubStr -- the text to look for", cE) > 0, TRUE)
	Then("the returns line is shown", StzFindFirst("returns: a list of numbers", cE) > 0, TRUE)
	Then("the example is shown with its inline promise", StzFindFirst("#--> [ 2, 4 ]", cE) > 0, TRUE)
	Then("a method with no doc block shows no invented sections",
		StzFindFirst("returns:", o.ExplainMethod("Describe")), 0)
	Then("RecordOf answers the written fields", o.RecordOf("Find")[:returns], "a list of numbers; [ ] when pcSubStr is absent")
	Then("RecordOf of an unknown method is empty", len(o.RecordOf("NoSuch")), 0)
EndScenario()

Summary()
