# A PAGE PER WORLD -- each teaching world, questioned, in four languages.
#
#   1. every world with a page has one in every language the program
#      teaches in; the four editions run green over their world, store no
#      output, and make the same promises cell for cell; each edition has
#      its own title (it is not English under another name)
#   2. the promises are the world's own: the cooperative's page run over
#      the school fails them (negative sibling); a page missing in a
#      language is a red fact, never a fallback
#   3. the reader shows a world page in a language's menu under "World",
#      after the chapters
#   4. the overlay court judges an institution's world page the way it
#      judges a chapter: every spoken language, no stored output, green
#      when run over the institution's world
#
# Run from this folder: ring world_pages_narrated.ring

load "../../stzBase.ring"
load "../_narrated.ring"

t0 = clock()
cProg = "../../education/program"
cOverlays = "../../education/overlays"
oP = StzProgramQ(cProg)
acLangs = oP.Languages()
EduPagesClean()

#---------------------------------------------------------------------------
Scenario("1. Every world has a page, in every language, and it runs")
Then("the three worlds have pages", @@(oP.WorldsWithPages()), @@([ "cooperative", "school", "workplace" ]))
Then("the program teaches in four languages", len(acLangs), 4)
acW = oP.WorldsWithPages()
aKeep = []
for w = 1 to len(acW)
	t1 = clock()
	aCh = oP.RunWorldPageInQ(acW[w], acLangs)
	if w = 1
		aKeep = aCh
	ok
	for i = 1 to len(acLangs)
		oCh = aCh[i]
		acBroken = []
		for j = 1 to oCh.NumberOfCells()
			if NOT oCh.CellRan(j)
				acBroken + ("cell " + j + " raised: " + StzLeft(oCh.CellError(j), 70))
			but oCh.CellKept(j) = 0
				acBroken + ("cell " + j + " diverged, printed: " + StzLeft(StzReplace(ring_trim(oCh.CellOutput(j)), char(10), " / "), 70))
			ok
		next
		Then(acW[w] + " " + acLangs[i] + ": " + oCh.NumberOfCells() + " cells ran and " + oCh.NumberOfPromises() +
			" promises kept over the " + acW[w], @@(acBroken), "[ ]")
		Then(acW[w] + " " + acLangs[i] + ": no stored output", oCh.HasStoredOutput(), 0)
	next
	acDrift = []
	acSameTitle = []
	for i = 2 to len(acLangs)
		if aCh[i].NumberOfCells() != aCh[1].NumberOfCells()
			acDrift + (acLangs[i] + ": " + aCh[i].NumberOfCells() + " cells against " + aCh[1].NumberOfCells())
		else
			for j = 1 to aCh[1].NumberOfCells()
				if @@(aCh[i].CellPromises(j)) != @@(aCh[1].CellPromises(j))
					acDrift + (acLangs[i] + ": cell " + j + " promises differ from en")
				ok
			next
		ok
		if aCh[i].Title() = aCh[1].Title()
			acSameTitle + acLangs[i]
		ok
	next
	Then(acW[w] + ": the four editions make the same promises, cell for cell", @@(acDrift), "[ ]")
	Then(acW[w] + ": every edition has its own title, not the English one", @@(acSameTitle), "[ ]")
	? "  [time] " + acW[w] + ", four editions side by side: " + ((clock() - t1) / clockspersecond()) + " s"
next
EndScenario()

#---------------------------------------------------------------------------
t2 = clock()
Scenario("2. The promises are the world's own (negative siblings)")
oX = oP.WorldPageQ("cooperative", "en")
oX.Run(oP.FileFor("worlds/school.zknw"))
Then("the cooperative's page, run over the school, ran every cell", oX.AllCellsRan(), 1)
Then("...and did NOT keep its promises: they are about the cooperative", oX.AllPromisesKept(), 0)
Then("...the first cell printed the school's name instead", StzFindFirst("lycee-de-niamey", oX.CellOutput(1)) > 0, 1)
bRed = 0
try
	oP.WorldPageQ("cooperative", "tr")
catch
	bRed = 1
done
Then("a page missing in a language is refused, never English instead (law 7)", bRed, 1)
EndScenario()
? "  [time] scenario 2: " + ((clock() - t2) / clockspersecond()) + " s"

#---------------------------------------------------------------------------
t3 = clock()
Scenario("3. The reader lists a world page under 'World', after the chapters")
oC = oP.CourseQ("elementary-introduction")
oCh1 = oC.RunChapterQ("find-then-apply", "en")
oRd = new stzEduReader(oC)
oRd.AddChapter(oCh1)
oRd.AddWorldPage(aKeep[1])
oRd.AddWorldPage(aKeep[3])
cHtml = oRd.Html()
Then("two world pages entered the reader", oRd.NumberOfWorldPages(), 2)
Then("the English menu shows the chapter by number and the world by name",
	StzFindFirst(">1 · Find, then apply<", cHtml) > 0 and StzFindFirst(">World · The cooperative<", cHtml) > 0, 1)
Then("the Arabic menu says it in Arabic", StzFindFirst(">عالم · التعاونية<", cHtml) > 0, 1)
Then("the page stores no output: every English cell shows the fixed sentence instead (" +
	(oCh1.NumberOfCells() + aKeep[1].NumberOfCells()) + " cells)",
	len(StzFind(_EduSay("en", "cell-no-output", ""), cHtml)), oCh1.NumberOfCells() + aKeep[1].NumberOfCells())
EndScenario()
? "  [time] scenario 3: " + ((clock() - t3) / clockspersecond()) + " s"

#---------------------------------------------------------------------------
t4 = clock()
Scenario("4. The court judges an institution's world page like a chapter")
oOv = StzOverlayFromTemplate(cOverlays + "/_template", "t_edu_pages/ministry", [
	[ "{{NAME}}", "ministry" ], [ "{{INSTITUTION-SLUG}}", "ministry-of-education" ],
	[ "{{WORLD-NAME}}", "ministry-of-education" ], [ "{{WORLD-TYPE}}", "ministry" ],
	[ "{{THING-1}}", "transcript" ], [ "{{THING-2}}", "posting" ] ])
acSpoken = oOv.Languages()
Then("from the template, with no page, it passes the court", @@(oOv.Check(oP)), "[ ]")

When("the institution copies the cooperative's English page as its own, in English only")
write("t_edu_pages/ministry/worlds/workplace.en.md", read(cProg + "/worlds/cooperative.en.md"))
aF = StzOverlayQ("t_edu_pages/ministry").Check(oP)
nMissing = 0
nNotKept = 0
for i = 1 to len(aF)
	if aF[i][:rule] = "overlay-world-page"
		if StzFindFirst("missing", aF[i][:message]) > 0
			nMissing++
		but StzFindFirst("not kept", aF[i][:message]) > 0
			nNotKept++
		ok
	ok
next
Then("the court names every other spoken language as missing (" + (len(acSpoken) - 1) + ")", nMissing, len(acSpoken) - 1)
Then("...and, run over the ministry, the copied page keeps no promise of the cooperative", nNotKept, 1)

When("the institution writes its own page, in every language it speaks")
for i = 1 to len(acSpoken)
	write("t_edu_pages/ministry/worlds/workplace." + acSpoken[i] + ".md", "# The ministry (" + acSpoken[i] + ")" + char(10) + char(10) +
		"Its name, and what was requested." + char(10) + char(10) +
		"```ring" + char(10) + "? EduWorldName()" + char(10) + "#--> ministry-of-education (ministry)" + char(10) +
		"? len( EduWorldObjects('requested') )" + char(10) + "#--> 3" + char(10) + "```" + char(10))
next
Then("now the court passes it", @@(StzOverlayQ("t_edu_pages/ministry").Check(oP)), "[ ]")
oPM = StzProgramQ(cProg).WithOverlayQ("t_edu_pages/ministry")
Then("...and the program reads the institution's page for the workplace", StzFindFirst("ministry", oPM.WorldPageQ("workplace", acSpoken[1]).Title()) > 0, 1)
EndScenario()
? "  [time] scenario 4: " + ((clock() - t4) / clockspersecond()) + " s"

EduPagesClean()
? ""
? "  [time] whole guard: " + ((clock() - t0) / clockspersecond()) + " s"
Summary()

#===========================================================================
func EduPagesClean()
	StzEduRemoveTree("t_edu_pages")
