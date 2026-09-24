# THE INSTITUTION KIT -- overlays, the guide, cohorts and their reports, proved by running.
#
#   1. the two reference overlays (a bank, a university) pass the overlay court;
#      the same chapter reasons over each world; an overlay's exercise appears
#      on the chapter's page and is judged like any other
#   2. OVERLAY_GUIDE.md executed literally: the template copied and its
#      placeholders filled, and the result is a valid overlay; three broken
#      overlays are refused with the finding named (negative siblings)
#   3. a cohort is a folder: learners added, one passes an exercise, the
#      progress report is generated as a NARRATION whose figures are promises;
#      after another learner passes, the old report reports its own staleness
#      and the regenerated one holds
#
# Run from this folder: ring institution_narrated.ring

load "../../stzBase.ring"
load "../_narrated.ring"

t0 = clock()
cProg = "../../education/program"
cOverlays = "../../education/overlays"
oP = StzProgramQ(cProg)
EduKitClean()

#---------------------------------------------------------------------------
Scenario("1. Two reference overlays: a bank and a university")
acRef = [ "bank", "university" ]
acWorld = [ "sahel-savings", "sahel-university" ]
acExtra = [ "bank-01", "uni-01" ]
acChapter = [ "declare-what-not-how", "teach-a-world" ]
for i = 1 to 2
	t1 = clock()
	oOv = StzOverlayQ(cOverlays + "/" + acRef[i])
	Then(acRef[i] + ": has a manifest and extends the core program", oOv.HasManifest() and oOv.Extends()[1] = oP.Id(), 1)
	Then(acRef[i] + ": passes the overlay court", @@(oOv.Check(oP)), "[ ]")
	oPB = StzProgramQ(cProg).WithOverlayQ(cOverlays + "/" + acRef[i])
	aR = oPB.OverlayReport()
	nShadow = 0
	for k = 1 to len(aR)
		if aR[k][2] = "shadows"
			nShadow++
		ok
	next
	Then(acRef[i] + ": shadows exactly one core file, its world", nShadow, 1)
	oC = oPB.CourseQ("elementary-introduction")
	oCh = oC.RunChapterQ("find-then-apply", "en")
	nW = oCh.WorldDependentCells()[1]
	Then(acRef[i] + ": chapter 1 reasons over the overlay's world", StzFindFirst(acWorld[i], oCh.CellOutput(nW)) > 0, 1)
	Then(acRef[i] + ": every promise of chapter 1 still holds", oCh.AllPromisesKept(), 1)
	Then(acRef[i] + ": its exercise is attached to the chapter through the merged course facts",
		StzFindFirst(acExtra[i], oC.ExercisesOf(acChapter[i])) > 0, 1)
	oEx = oC.ExerciseQ(acExtra[i])
	aPr = oEx.ProveItself()
	Then(acRef[i] + ": the exercise proves itself (" + aPr[:wrongrefused] + "/" + aPr[:wrong] + ", " + aPr[:rightaccepted] + "/" + aPr[:right] + ")", @@(aPr[:failures]), "[ ]")
	oChX = oC.RunChapterQ(acChapter[i], "fr")
	oRd = new stzEduReader(oC)
	oRd.AddChapter(oChX)
	cTitleFr = StzReplace(StzSplit(oEx.Task("fr"), char(10))[1], "### ", "")
	Then(acRef[i] + ": the overlay's exercise appears on the chapter's page, in French",
		StzFindFirst('class="exercise overlay"', oRd.Html()) > 0 and StzFindFirst(_EduEsc(cTitleFr), oRd.Html()) > 0, 1)
	? "  [time] " + acRef[i] + ": " + ((clock() - t1) / clockspersecond()) + " s"
next
Given("the core, without any overlay (negative sibling)")
oC0 = StzProgramQ(cProg).CourseQ("elementary-introduction")
Then("chapter 7 has no bank exercise without the overlay", StzFindFirst("bank-01", oC0.ExercisesOf("declare-what-not-how")), 0)
EndScenario()

#---------------------------------------------------------------------------
t2 = clock()
Scenario("2. The guide, executed literally")
Given("step 1 and 2 of OVERLAY_GUIDE.md: copy the template, fill the placeholders")
oNew = StzOverlayFromTemplate(cOverlays + "/_template", "t_edu_kit/ministry", [
	[ "{{NAME}}", "ministry" ], [ "{{INSTITUTION-SLUG}}", "ministry-of-education" ],
	[ "{{WORLD-NAME}}", "ministry-of-education" ], [ "{{WORLD-TYPE}}", "ministry" ],
	[ "{{THING-1}}", "transcript" ], [ "{{THING-2}}", "posting" ] ])
Then("the result names itself", oNew.Name(), "ministry")
Then("no placeholder is left in any file", EduKitLeftovers("t_edu_kit/ministry"), 0)
Then("the result passes the overlay court with no finding", @@(oNew.Check(oP)), "[ ]")
oPM = StzProgramQ(cProg).WithOverlayQ("t_edu_kit/ministry")
oChM = oPM.CourseQ("elementary-introduction").RunChapterQ("find-then-apply", "ha")
Then("chapter 1, in Hausa, now reasons over the ministry",
	StzFindFirst("ministry-of-education", oChM.CellOutput(oChM.WorldDependentCells()[1])) > 0, 1)

Given("three overlays that break a rule (negative siblings)")
StzEduCopyTree("t_edu_kit/ministry", "t_edu_kit/no-manifest")
remove("t_edu_kit/no-manifest/overlay.zknw")
Then("no manifest -> overlay-manifest", StzOverlayQ("t_edu_kit/no-manifest").Check(oP)[1][:rule], "overlay-manifest")
StzEduCopyTree("t_edu_kit/ministry", "t_edu_kit/broken-world")
write("t_edu_kit/broken-world/worlds/workplace.zknw", 'knowledge "workplace"' + char(10) + char(10) + "facts" + char(10) + "    ministry of education | is-a | ministry" + char(10))
Then("a world with a space in a word -> overlay-world", StzOverlayQ("t_edu_kit/broken-world").Check(oP)[1][:rule], "overlay-world")
StzEduCopyTree("t_edu_kit/ministry", "t_edu_kit/fork")
StzEngineDirCreatePath("t_edu_kit/fork/courses/elementary-introduction/chapters")
write("t_edu_kit/fork/courses/elementary-introduction/chapters/01-find-then-apply.en.md", "# Mine now" + char(10))
Then("a file that would replace a core chapter -> overlay-no-fork", StzOverlayQ("t_edu_kit/fork").Check(oP)[1][:rule], "overlay-no-fork")
Then("...and the finding says which file, and why", StzFindFirst("law 5", StzOverlayQ("t_edu_kit/fork").CiteFindings(oP)) > 0, 1)
EndScenario()
? "  [time] the guide: " + ((clock() - t2) / clockspersecond()) + " s"

#---------------------------------------------------------------------------
t3 = clock()
Scenario("3. A cohort is a folder, and its report is a narration")
StzEngineDirCreatePath("t_edu_kit/cohorts/espa-2026")
write("t_edu_kit/cohorts/espa-2026/cohort.zknw", 'knowledge "espa-2026"' + char(10) + char(10) + "facts" + char(10) +
	"    espa-2026 | is-a | cohort" + char(10) + "    espa-2026 | follows | elementary-introduction" + char(10) +
	"    espa-2026 | under | bank" + char(10))
oCo = StzCohortQ("t_edu_kit/cohorts/espa-2026")
oCo.AddLearner("amina")
oCo.AddLearner("moussa")
Then("two learners, each a folder", @@(oCo.LearnerIds()), @@([ "amina", "moussa" ]))
Then("...that exist on disk", StzEngineDirExists("t_edu_kit/cohorts/espa-2026/amina/work") and StzEngineDirExists("t_edu_kit/cohorts/espa-2026/moussa/work"), 1)
Then("the cohort is read back from its file", @@(StzCohortQ("t_edu_kit/cohorts/espa-2026").LearnerIds()), @@([ "amina", "moussa" ]))
oPC = oCo.ProgramQ(cProg)
Then("the cohort's program carries its overlay", oPC.HasOverlay(), 1)
Then("...so the bank's exercise counts among the cohort's " + len(oCo.ExerciseIds(oPC)),
	StzFindFirst("bank-01", oCo.ExerciseIds(oPC)) > 0, 1)

When("Amina passes the first exercise")
oEx1 = oPC.CourseQ("elementary-introduction").ExerciseQ("ex-01-01")
oCo.LearnerQ("amina").Submit(oEx1, read(oEx1.RightAnswers()[1]))
cRep = oCo.WriteReport(cProg, "")
Then("the report is written under the cohort", cRep, "t_edu_kit/cohorts/espa-2026/reports/progress.en.md")
cText = read(cRep)
Then("it shows Amina's one pass and Moussa's none", StzFindFirst("| amina | 1 of", cText) > 0 and StzFindFirst("| moussa | 0 of", cText) > 0, 1)
Then("every figure is a promise beside the cell that computes it", len(StzFind("#--> ", cText)), 4)
Then("run as a narration, the report holds", oCo.IsReportCurrent(cRep), 1)

When("Moussa passes the same exercise after the report was written")
oCo.LearnerQ("moussa").Submit(oEx1, read(oEx1.RightAnswers()[2]))
Then("the OLD report, run again, reports its own staleness", oCo.IsReportCurrent(cRep), 0)
cRep2 = oCo.WriteReport(cProg, "")
Then("the regenerated report holds", oCo.IsReportCurrent(cRep2), 1)
Then("...and now shows both", StzFindFirst("| moussa | 1 of", read(cRep2)) > 0, 1)
Then("no level is earned by one exercise", @@(oCo.LevelsEarnedBy("amina", oPC)), "[ ]")

Given("a folder that is not a cohort (negative sibling)")
bRed = 0
try
	StzCohortQ("t_edu_kit")
catch
	bRed = 1
done
Then("it is refused, not guessed", bRed, 1)
EndScenario()
? "  [time] the cohort: " + ((clock() - t3) / clockspersecond()) + " s"

EduKitClean()
? ""
? "  [time] whole guard: " + ((clock() - t0) / clockspersecond()) + " s"
Summary()

#===========================================================================
func EduKitClean()
	StzEduRemoveTree("t_edu_kit")

# how many "{{" remain in the text files of a folder
func EduKitLeftovers(pcFolder)
	_ek_acF_ = _EduFilesUnder(pcFolder, "")
	_ek_n_ = 0
	for _ek_i_ = 1 to len(_ek_acF_)
		_ek_n_ += len(StzFind("{{", read(pcFolder + "/" + _ek_acF_[_ek_i_])))
	next
	return _ek_n_
