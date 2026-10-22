load "../../stzBase.ring"
load "../_narrated.ring"

# RX2 -- twin-coverage: the court between the three projections of a .panel
# document (its HTML, its text, its accessibility JSON).
#
# WHAT IS JUDGED. Every named box that holds a text must be carried by each
# twin. A twin that drops a box is an ERROR. An exception is taken only with a
# written reason; a bare one is refused; a stale one is reported; the court
# never writes one. The report prints its limits: a comparison proves
# sameness, never rightness.
#
# HOW A TWIN "DROPS" A BOX HERE. The rule takes the three projections as
# inputs (StzTwinCoverageXT), so this guard can hand it a doctored twin and
# watch the error appear -- the positive and its negative sibling are both
# real. The plain form (StzTwinCoverage) produces the projections itself and
# is shown green on an honest document.
#
# THE EXCEPTION THAT EXISTS IN THE LIBRARY TODAY. A TEXT box with a LABEL is
# named by its label in the accessibility tree, not by its content: the
# accessibility twin carries the label and drops the content. That is a true
# divergence, and the shape this rule takes an exception for -- with a reason.

RxMain()

func RxPanel()
	return 'DEFINE PANEL screen (' + char(10) +
	       '  SIZE [400, 240],' + char(10) +
	       '  DIRECTION column,' + char(10) +
	       '  FONT "app",' + char(10) +
	       '  CHILDREN [brand, note, tab]' + char(10) +
	       ') RATIONALE "The RX2 probe panel: three boxes, one of them labelled."' + char(10) + char(10) +
	       'DEFINE TEXT brand (' + char(10) +
	       '  CONTENT "Softanza",' + char(10) +
	       '  SIZE 20' + char(10) +
	       ') RATIONALE "The brand."' + char(10) + char(10) +
	       'DEFINE TEXT note (' + char(10) +
	       '  CONTENT "fish & chips <today>",' + char(10) +
	       '  SIZE 14' + char(10) +
	       ') RATIONALE "A note with characters the HTML twin must escape."' + char(10) + char(10) +
	       'DEFINE TEXT tab (' + char(10) +
	       '  CONTENT "Graphics tab",' + char(10) +
	       '  LABEL "Graphics",' + char(10) +
	       '  SIZE 16' + char(10) +
	       ') RATIONALE "A box whose accessible name is its label, by design."' + char(10)

func RxErrorsOf(paF)
	_a_ = []
	for _i_ = 1 to len(paF)
		if "" + paF[_i_][:severity] = "error"
			_a_ + paF[_i_]
		ok
	next
	return _a_

func RxCount(paF, pcSeverity, pcSubject, pcWhere)
	_n_ = 0
	for _i_ = 1 to len(paF)
		_f_ = paF[_i_]
		if "" + _f_[:severity] = pcSeverity and
		   (pcSubject = "*" or strcmp("" + _f_[:subject], pcSubject) = 0) and
		   (pcWhere = "*" or strcmp("" + _f_[:where], pcWhere) = 0)
			_n_++
		ok
	next
	return _n_

func RxSays(paF, pcSubject, pcText)
	for _i_ = 1 to len(paF)
		if strcmp("" + paF[_i_][:subject], pcSubject) = 0 and
		   StzFindFirst(pcText, "" + paF[_i_][:message]) > 0
			return 1
		ok
	next
	return 0

func RxMain()

Scenario("1. An honest document, judged on its own three projections")
	Given("the three-box panel, clean")
	oD = new stzUiDocument(RxPanel())
	Then("the panel is clean", oD.IsClean(), 1)
	When("the rule produces the projections itself and judges them, excepting the labelled box with a reason")
	aEx = [ [ "tab", "the accessible name of a labelled box is its label, by design (G4b)" ] ]
	aF = StzTwinCoverage(oD, aEx)
	Then("no error", len(RxErrorsOf(aF)), 0)
	Then("brand and note are carried by every twin (no finding about them)", RxCount(aF, "*", "brand", "*") + RxCount(aF, "*", "note", "*"), 0)
	Then("the labelled box is noted as excepted, at info, on the accessibility twin", RxCount(aF, "info", "tab", "accessibility"), 1)
	Then("...with its reason in the message", RxSays(aF, "tab", "by design (G4b)"), 1)
	Then("the limits are printed, as an info finding on the document", RxCount(aF, "info", "document", "limits"), 1)
	Then("...and they say what is not certified", RxSays(aF, "document", "does not certify equivalent meaning, order, cardinality, or accessibility"), 1)
	Then("the exceptions list was not written to by the court", len(aEx) = 1 and len(aEx[1]) = 2, 1)
	Given("the same, through the one report")
	oRep = StzTwinCoverageReportQ(oD, aEx)
	Then("the report is sound", oRep.IsSound(), 1)
	Then("its name is the rule's", oRep.Name(), "twin-coverage")
	cExp = ""
	for cLine in oRep.Explain()
		cExp += cLine + char(10)
	next
	Then("and its explanation carries the limits", StzFindFirst("sameness, never rightness", cExp) > 0, 1)
EndScenario()

Scenario("2. The same document WITHOUT the exception: the labelled box is an error, with the twin named")
	Given("the three-box panel and no exception")
	oD = new stzUiDocument(RxPanel())
	aF = StzTwinCoverage(oD, [])
	Then("exactly one error", len(RxErrorsOf(aF)), 1)
	Then("on the labelled box, on the accessibility twin", RxCount(aF, "error", "tab", "accessibility"), 1)
	Then("the message asks for a repair or a reasoned exception", RxSays(aF, "tab", "except the box WITH a reason"), 1)
EndScenario()

Scenario("3. A twin that drops a box is an error, twin by twin")
	Given("the honest projections of the panel")
	oD = new stzUiDocument(RxPanel())
	cH = oD.ToHtml()
	cT = oD.ToText()
	cJ = StzAccessibilityTreeQ(oD, NULL).ToJSON()
	aEx = [ [ "tab", "label by design" ] ]
	Then("they pass as they are", len(RxErrorsOf(StzTwinCoverageXT(oD, cH, cT, cJ, aEx))), 0)
	When("the HTML twin loses the note's element")
	cH2 = StzReplace(cH, '<div id="note">fish &amp; chips &lt;today&gt;</div>', "")
	Then("the doctoring took (the page changed)", strcmp(cH2, cH) != 0, 1)
	aF = StzTwinCoverageXT(oD, cH2, cT, cJ, aEx)
	Then("one error, on note, on the html twin", RxCount(aF, "error", "note", "html"), 1)
	Then("and no other error", len(RxErrorsOf(aF)), 1)
	When("the HTML twin keeps the words but in another element (the oracle reads the element, not the page)")
	cH3 = StzReplace(cH, '<div id="note">fish &amp; chips &lt;today&gt;</div>', '<div id="note"></div>')
	cH3 = StzReplace(cH3, '<div id="brand">Softanza</div>', '<div id="brand">Softanza fish &amp; chips &lt;today&gt;</div>')
	aF = StzTwinCoverageXT(oD, cH3, cT, cJ, aEx)
	Then("note is dropped by the html twin", RxCount(aF, "error", "note", "html"), 1)
	Then("and brand too, since its text is no longer its content", RxCount(aF, "error", "brand", "html"), 1)
	When("the text twin loses the note's declaration")
	nP = StzFindFirst("DEFINE TEXT note (", cT)
	nQ = StzFindFirst("DEFINE TEXT tab (", cT)
	cT2 = StzLeft(cT, nP - 1) + StzMidToEnd(cT, nQ)
	aF = StzTwinCoverageXT(oD, cH, cT2, cJ, aEx)
	Then("one error, on note, on the text twin", RxCount(aF, "error", "note", "text"), 1)
	When("the accessibility twin renames the note's node")
	cJ2 = StzReplace(cJ, '"id": "note"', '"id": "note_2"')
	aF = StzTwinCoverageXT(oD, cH, cT, cJ2, aEx)
	Then("one error, on note, on the accessibility twin", RxCount(aF, "error", "note", "accessibility"), 1)
	When("the accessibility twin is not even JSON")
	aF = StzTwinCoverageXT(oD, cH, cT, "{ not json", aEx)
	Then("every box is dropped by that twin: two errors and the excepted one at info", RxCount(aF, "error", "*", "accessibility"), 2)
EndScenario()

Scenario("4. Exceptions: a bare one is refused, a stale one is reported, and the court writes none")
	Given("the panel and a bare exception")
	oD = new stzUiDocument(RxPanel())
	aF = StzTwinCoverageXT(oD, oD.ToHtml(), oD.ToText(), StzAccessibilityTreeQ(oD, NULL).ToJSON(), [ [ "tab" ] ])
	Then("the bare exception is an error, under exceptions", RxCount(aF, "error", "tab", "exceptions"), 1)
	Then("...saying it needs a written reason", RxSays(aF, "tab", "written reason"), 1)
	Then("and the box it failed to except is still an error on its twin", RxCount(aF, "error", "tab", "accessibility"), 1)
	Given("an exception whose reason is blank")
	aF = StzTwinCoverage(oD, [ [ "tab", "   " ] ])
	Then("it is refused the same way", RxCount(aF, "error", "tab", "exceptions"), 1)
	Given("a stale exception on a box every twin carries, and one on a box that does not exist")
	aEx = [ [ "tab", "label by design" ], [ "brand", "once dropped, no longer" ], [ "ghost", "never was" ] ]
	aF = StzTwinCoverage(oD, aEx)
	Then("no error", len(RxErrorsOf(aF)), 0)
	Then("brand's exception is a warning: every twin carries it", RxCount(aF, "warning", "brand", "exceptions"), 1)
	Then("...and the message says so", RxSays(aF, "brand", "every twin carries the box"), 1)
	Then("ghost's exception is a warning: no such box", RxCount(aF, "warning", "ghost", "exceptions"), 1)
	Then("...and the message says so", RxSays(aF, "ghost", "names nothing"), 1)
	Then("the used exception is not warned about", RxCount(aF, "warning", "tab", "*"), 0)
	Then("the court wrote no exception: the list is as given", len(aEx), 3)
	oFresh = new stzUiDocument(RxPanel())
	cFresh = oFresh.ToText()
	Then("and the document is as given", strcmp(oD.ToText(), cFresh), 0)
	Given("the report of a document with a stale exception")
	oRep = StzTwinCoverageReportQ(oD, aEx)
	Then("it is sound (a warning is not an error) and has the two warnings", oRep.IsSound() = 1 and len(oRep.Warnings()) = 2, 1)
EndScenario()

Scenario("5. A document with no text box at all")
	Given("a panel holding one empty container")
	cSrc = 'DEFINE PANEL screen (' + char(10) + '  SIZE [100, 100],' + char(10) +
	       '  DIRECTION column,' + char(10) + '  CHILDREN [area]' + char(10) +
	       ') RATIONALE "Empty."' + char(10) + char(10) +
	       'DEFINE BOX area (' + char(10) + '  HEIGHT 50' + char(10) + ') RATIONALE "An area."' + char(10)
	oE = new stzUiDocument(cSrc)
	Then("it is clean", oE.IsClean(), 1)
	aF = StzTwinCoverage(oE, [])
	Then("the only finding is the limits line, which counts zero boxes", len(aF) = 1 and RxSays(aF, "document", "0 named box"), 1)
EndScenario()

Summary()
