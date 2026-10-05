# HONEST DRAFTS -- a translation says what it is until a native speaker has
# signed it off, and the sign-off is a recorded fact, not a feeling.
#
#   1. the units a reviewer can sign off, counted independently from the
#      files on disk; English (the source) has none
#   2. a review is `<reviewer> | reviewed | <unit>` in reviews/<lang>.zknw,
#      merged between the core and an overlay; a unit nobody has signed is
#      not reviewed; a typo'd unit counts for nothing and is reported
#   3. the reader page: a draft notice on every unreviewed translation, the
#      reviewers' names on a reviewed one, nothing on English; in the
#      article's own language and direction
#   4. review_sheet.ring, run as a reviewer's helper would: every unit of a
#      language in one file, headings demoted so the sheet's outline holds,
#      the line to record the sign-off, and wrong calls refused
#
# The shipped state of reviews/ is NEVER asserted (it will change the day a
# reviewer signs): expectations are computed from it, and the scratch
# overlay supplies the reviews the mechanism needs.
#
# Run from this folder: ring review_narrated.ring

load "../../stzBase.ring"
load "../_narrated.ring"

t0 = clock()
cProg = "../../education/program"
cOverlays = "../../education/overlays"
oP = StzProgramQ(cProg)
EduRvClean()
StzEngineDirCreatePath("t_edu_rv")

#---------------------------------------------------------------------------
Scenario("1. The units a reviewer can sign off")
Then("English is the source: nothing to review in it", @@(oP.ReviewUnits("en")), "[ ]")
acLangs = [ "fr", "ar", "ha" ]
for i = 1 to 3
	acU = oP.ReviewUnits(acLangs[i])
	nChap = 0
	nWorld = 0
	for k = 1 to len(acU)
		if StzLeft(acU[k], 8) = "chapter:"
			nChap++
		but StzLeft(acU[k], 6) = "world:"
			nWorld++
		ok
	next
	nChapDisk = EduRvCountEditions(cProg + "/courses", acLangs[i])
	nWorldDisk = EduRvCountFiles(cProg + "/worlds", "." + acLangs[i] + ".md")
	Then(acLangs[i] + ": " + nChap + " chapter units, as many as there are ." + acLangs[i] + ".md chapter files on disk", nChap, nChapDisk)
	Then(acLangs[i] + ": " + nWorld + " world units, as many as world pages on disk", nWorld, nWorldDisk)
	Then(acLangs[i] + ": and the skills and the tutor close the list", acU[len(acU) - 1] = "skills" and acU[len(acU)] = "tutor", 1)
	aCov = oP.ReviewCoverage(acLangs[i])
	? "    " + acLangs[i] + ": " + aCov[1] + " of " + aCov[2] + " units reviewed in the shipped program"
	Then(acLangs[i] + ": coverage is a count of units, never more than there are", aCov[2] = len(acU) and aCov[1] <= aCov[2], 1)
next
Then("a language the program does not teach has only the skills and the tutor (nothing to read)", len(oP.ReviewUnits("tr")), 2)
EndScenario()

#---------------------------------------------------------------------------
t2 = clock()
Scenario("2. A review is a recorded fact, merged between the core and an overlay")
Given("a minimal program with one review of its own, and an overlay with another")
StzEngineDirCreatePath("t_edu_rv/core/reviews")
write("t_edu_rv/core/program.zknw", 'knowledge "p"' + char(10) + char(10) + "facts" + char(10) + "    p | is-a | program" + char(10))
write("t_edu_rv/core/reviews/ha.zknw", 'knowledge "reviews-ha"' + char(10) + char(10) + "facts" + char(10) +
	"    musa | reviewed | tutor" + char(10) + "    musa | is-a | person" + char(10))
StzEngineDirCreatePath("t_edu_rv/ovm/reviews")
write("t_edu_rv/ovm/overlay.zknw", 'knowledge "ovm"' + char(10) + char(10) + "facts" + char(10) + "    ovm | is-a | overlay" + char(10))
write("t_edu_rv/ovm/reviews/ha.zknw", 'knowledge "reviews-ha"' + char(10) + char(10) + "facts" + char(10) +
	"    zainab | reviewed | tutor" + char(10))
oM = StzProgramQ("t_edu_rv/core")
Then("alone, the core's review is the only one, and `is-a` is not a review", @@(oM.ReviewersOf("ha", "tutor")), @@([ "musa" ]))
oM.WithOverlay("t_edu_rv/ovm")
Then("with the overlay, both reviewers are named: the overlay never hides the core's", @@(oM.ReviewersOf("ha", "tutor")), @@([ "musa", "zainab" ]))
Then("the overlay report says the two review files MERGE (it never calls it a shadow)", @@(oM.OverlayReport()), @@([ [ "reviews/ha.zknw", "merges" ] ]))
Then("the unit name is compared without regard to case", @@(oM.ReviewersOf("ha", "TUTOR")), @@([ "musa", "zainab" ]))
Then("another language is untouched by the Hausa file (negative sibling)", @@(oM.ReviewersOf("fr", "tutor")), "[ ]")

Given("the real program laid under a scratch overlay that signs three units and names one that does not exist")
oOv = StzOverlayFromTemplate(cOverlays + "/_template", "t_edu_rv/ov", [
	[ "{{NAME}}", "ov" ], [ "{{INSTITUTION-SLUG}}", "ov-institution" ], [ "{{WORLD-NAME}}", "ov-world" ],
	[ "{{WORLD-TYPE}}", "shop" ], [ "{{THING-1}}", "tea" ], [ "{{THING-2}}", "rice" ] ])
StzEngineDirCreatePath("t_edu_rv/ov/reviews")
write("t_edu_rv/ov/reviews/ha.zknw", 'knowledge "reviews-ha"' + char(10) + char(10) + "facts" + char(10) +
	"    aminu | reviewed | chapter:elementary-introduction.find-then-apply" + char(10) +
	"    zainab | reviewed | chapter:elementary-introduction.find-then-apply" + char(10) +
	"    aminu | reviewed | world:school" + char(10) +
	"    zainab | reviewed | tutor" + char(10) +
	"    aminu | reviewed | chapter:no-such.nothing" + char(10))
write("t_edu_rv/ov/reviews/ar.zknw", 'knowledge "reviews-ar"' + char(10) + char(10) + "facts" + char(10) +
	"    fatima | reviewed | chapter:elementary-introduction.find-then-apply" + char(10))
oPO = StzProgramQ(cProg).WithOverlayQ("t_edu_rv/ov")
cU1 = "chapter:elementary-introduction.find-then-apply"
Then("chapter 1 in Hausa has two reviewers", @@(oPO.ReviewersOf("ha", cU1)), @@([ "aminu", "zainab" ]))
Then("...and so counts as reviewed", oPO.IsReviewed("ha", cU1), 1)
Then("a unit the overlay does not sign is exactly as reviewed as in the core (world:cooperative)",
	oPO.IsReviewed("ha", "world:cooperative"), oP.IsReviewed("ha", "world:cooperative"))
nWillGrow = (1 - oP.IsReviewed("ha", cU1)) + (1 - oP.IsReviewed("ha", "world:school")) + (1 - oP.IsReviewed("ha", "tutor"))
Then("the coverage grows by exactly the real units the overlay signs that the core had not (" + nWillGrow + " of 3)",
	oPO.ReviewCoverage("ha")[1] - oP.ReviewCoverage("ha")[1], nWillGrow)
Then("the typo'd unit counts for nothing and is reported by name", @@(oPO.UnknownReviews("ha")), @@([ "chapter:no-such.nothing" ]))
Then("the shipped program, without the overlay, does not carry the overlay's typo", len(oP.UnknownReviews("ha")), 0)
EndScenario()
? "  [time] scenario 2: " + ((clock() - t2) / clockspersecond()) + " s"

#---------------------------------------------------------------------------
t3 = clock()
Scenario("3. The page says what a translation is")
oCO = oPO.CourseQ("elementary-introduction")
aCh = oCO.RunChapterInQ("find-then-apply", [ "en", "fr", "ar", "ha" ])
aWp = oPO.RunWorldPageInQ("school", [ "fr", "ha" ])
oRd = new stzEduReader(oCO)
for i = 1 to 4
	oRd.AddChapter(aCh[i])
next
oRd.AddWorldPage(aWp[1])
oRd.AddWorldPage(aWp[2])
cHtml = oRd.Html()
nNotes = len(StzFind('role="note"', cHtml))
Then("one note per translated article (3 chapters + 2 world pages), none on English", nNotes, 5)
Then("the English article carries no note", StzFindFirst('role="note"', EduRvArticle(cHtml, "en", 1)), 0)
Then("Hausa chapter 1 names its reviewers, in a bdi so the names keep their direction",
	StzFindFirst("<bdi>aminu, zainab</bdi>", EduRvArticle(cHtml, "ha", 1)) > 0 and StzFindFirst('class="reviewed"', EduRvArticle(cHtml, "ha", 1)) > 0, 1)
cTplHa = _EduSay("ha", "reviewed-note", "{ids}")
Then("...and says it in Hausa: the template's words come before the names",
	StzFindFirst(_EduEsc(StzLeft(cTplHa, StzFindFirst("{ids}", cTplHa) - 1)) + "<bdi>", EduRvArticle(cHtml, "ha", 1)) > 0, 1)
Then("Arabic chapter 1 is reviewed by fatima, in Arabic, in a right-to-left article",
	StzFindFirst("<bdi>fatima</bdi>", EduRvArticle(cHtml, "ar", 1)) > 0 and StzFindFirst('dir="rtl"', EduRvArticle(cHtml, "ar", 1)) > 0, 1)
Then("French chapter 1 follows the program: a draft unless someone signed it",
	StzFindFirst('class="draft"', EduRvArticle(cHtml, "fr", 1)) > 0, oPO.IsReviewed("fr", cU1) = 0)
Then("...and its draft text is the French one when it is a draft",
	StzFindFirst(_EduEsc(_EduSay("fr", "draft-note", "")), EduRvArticle(cHtml, "fr", 1)) > 0, oPO.IsReviewed("fr", cU1) = 0)
Then("the Hausa world page of the school, signed by aminu, says so", StzFindFirst("<bdi>aminu</bdi>", EduRvArticle(cHtml, "ha", 2)) > 0, 1)
Then("the French world page follows the program", StzFindFirst('class="draft"', EduRvArticle(cHtml, "fr", 2)) > 0, oPO.IsReviewed("fr", "world:school") = 0)
EndScenario()
? "  [time] scenario 3: " + ((clock() - t3) / clockspersecond()) + " s"

#---------------------------------------------------------------------------
t4 = clock()
Scenario("4. The reviewer's sheet")
aR = EduRvSheet("t_edu_rv/fr.md --lang fr --program " + cProg)
? "    " + StzReplace(ring_trim(aR[1]), char(10), char(10) + "    ")
Then("exit 0, and it prints the coverage and what it wrote", aR[2] = 0 and StzFindFirst("REVIEW SHEET fr:", aR[1]) > 0 and StzFindFirst("WROTE t_edu_rv/fr.md", aR[1]) > 0, 1)
cSheet = read("t_edu_rv/fr.md")
Then("it says what the reviewer is asked to do, and how a sign-off is recorded",
	StzFindFirst("## What you are asked to do", cSheet) > 0 and StzFindFirst("<your-name-or-handle> | reviewed | <unit>", cSheet) > 0 and
	StzFindFirst("program/reviews/fr.zknw", cSheet) > 0, 1)
oCE = oP.CourseQ("elementary-introduction")
acIds = oCE.ChapterIds()
nHeads = 0
nTitles = 0
for i = 1 to len(acIds)
	if StzFindFirst(char(10) + "## chapter:elementary-introduction." + acIds[i] + " ", cSheet) > 0
		nHeads++
	ok
	cT = oCE.TitleOf(acIds[i], "fr")
	if StzFindFirst(char(10) + "### " + cT + char(10), cSheet) > 0
		nTitles++
	ok
next
Then("every chapter of the course is a unit of the sheet (" + len(acIds) + ")", nHeads, len(acIds))
Then("...with its French title, demoted one outline level (a chapter's # is the sheet's ###)", nTitles, len(acIds))
Then("...so a chapter's own title is never left at the top level", StzFindFirst(char(10) + "# " + oCE.TitleOf(acIds[1], "fr") + char(10), cSheet), 0)
Then("the code cells and their promises are kept as they are", StzFindFirst("```ring", cSheet) > 0 and StzFindFirst("#--> ", cSheet) > 0, 1)
Then("the exercise tasks come with their chapter", StzFindFirst("### Exercise ex-01-01", cSheet) > 0, 1)
Then("the world pages, the skills and the tutor are units too", StzFindFirst(char(10) + "## world:school ", cSheet) > 0 and
	StzFindFirst(char(10) + "## skills ", cSheet) > 0 and StzFindFirst(char(10) + "## tutor ", cSheet) > 0, 1)
Then("the tutor's French text sits beside its English original",
	StzFindFirst("- original (en): " + _EduSay("en", "refuse", ""), cSheet) > 0 and StzFindFirst("- fr: " + _EduSay("fr", "refuse", ""), cSheet) > 0, 1)
Then("the twenty-five skills are there", StzFindFirst("### kn-01 - ", cSheet) > 0 and StzFindFirst("### cr-03 - ", cSheet) > 0, 1)

When("the sheet is made for Hausa under the scratch overlay that signs three units and names one that does not exist")
aR = EduRvSheet("t_edu_rv/ha.md --lang ha --program " + cProg + " --overlay t_edu_rv/ov")
Then("a signed unit shows who signed it", StzFindFirst("## chapter:elementary-introduction.find-then-apply [reviewed by aminu, zainab]", read("t_edu_rv/ha.md")) > 0, 1)
Then("an unsigned one is still open (unless the core has signed it)",
	StzFindFirst("## chapter:elementary-introduction.a-first-sentence [ ]", read("t_edu_rv/ha.md")) > 0,
	oPO.IsReviewed("ha", "chapter:elementary-introduction.a-first-sentence") = 0)
Then("the typo'd unit is reported, not ignored", StzFindFirst("WARNING: review facts naming no unit", aR[1]) > 0 and StzFindFirst("chapter:no-such.nothing", aR[1]) > 0, 1)

Given("wrong calls (negative siblings)")
aR = EduRvSheet("")
Then("no argument: the usage, exit 1", aR[2] = 1 and StzFindFirst("usage:", aR[1]) > 0, 1)
aR = EduRvSheet("t_edu_rv/en.md --lang en --program " + cProg)
Then("the source edition is refused: nothing to review in it", aR[2] = 1 and StzFindFirst("source edition", aR[1]) > 0 and NOT fexists("t_edu_rv/en.md"), 1)
aR = EduRvSheet("t_edu_rv/tr.md --lang tr --program " + cProg)
Then("a language with no edition is refused, naming the ones the program speaks", aR[2] = 1 and StzFindFirst("no edition in 'tr'", aR[1]) > 0 and StzFindFirst("ha", aR[1]) > 0, 1)
aR = EduRvSheet("t_edu_rv/x.md --program " + cProg)
Then("no --lang: the usage, exit 1", aR[2] = 1 and StzFindFirst("usage:", aR[1]) > 0, 1)
EndScenario()
? "  [time] scenario 4: " + ((clock() - t4) / clockspersecond()) + " s"

EduRvClean()
? ""
? "  [time] whole guard: " + ((clock() - t0) / clockspersecond()) + " s"
Summary()

#===========================================================================
func EduRvClean()
	StzEduRemoveTree("t_edu_rv")

# Runs the sheet tool as a reviewer's helper would: a fresh process.
func EduRvSheet(pcArgs)
	_aR_ = StzEngineSystemRunXT(StzEduRingExe() + " ../../education/tools/review_sheet.ring " + pcArgs)
	return [ "" + _aR_[1], 0 + _aR_[2], "" + _aR_[3] ]

# The files of a folder whose name ends in a suffix.
func EduRvCountFiles(pcDir, pcSuffix)
	_n_ = 0
	_acF_ = StzEngineDirListFiles(pcDir)
	for _i_ = 1 to len(_acF_)
		if StzRight(_acF_[_i_], StzLen(pcSuffix)) = pcSuffix
			_n_++
		ok
	next
	return _n_

# The chapter files in a language, over every course folder -- counted from
# the disk, not from the module under test.
func EduRvCountEditions(pcCoursesDir, pcLang)
	_n_ = 0
	_acD_ = StzEngineDirListDirs(pcCoursesDir)
	for _i_ = 1 to len(_acD_)
		if StzEngineDirExists(pcCoursesDir + "/" + _acD_[_i_] + "/chapters")
			_n_ += EduRvCountFiles(pcCoursesDir + "/" + _acD_[_i_] + "/chapters", "." + pcLang + ".md")
		ok
	next
	return _n_

# One article of the page: from its opening tag to the next one.
func EduRvArticle(pcHtml, pcLang, pnIndex)
	_nStart_ = StzFindFirst('<article id="' + pcLang + "-" + pnIndex + '"', pcHtml)
	if _nStart_ = 0
		return ""
	ok
	_cRest_ = StzRight(pcHtml, StzLen(pcHtml) - _nStart_ + 1)
	_nEnd_ = StzFindFirst("</article>", _cRest_)
	return StzLeft(_cRest_, _nEnd_ - 1)
