# LEVELS ARE EARNED BY PROJECTS -- the five project guards, and one learner who earns S0.
#
#   1. every project has a brief in four languages, a guard, a promise, and
#      sample folders that MUST fail and MUST pass; each guard proves itself
#   2. a learner earns S0 only when every exercise of chapters 1-4 has passed
#      AND the S0 project has passed, each with evidence that still matches;
#      MissingFor() names what is missing by name; a changed project folder
#      loses the level; a level cannot be typed into the progress file
#
# Section 1 runs 5 guards on 12 sample folders; section 2 submits 4 right
# answers and one project. Per-section wall times are printed.
#
# Run from this folder: ring levels_narrated.ring

load "../../stzBase.ring"
load "../_narrated.ring"

t0 = clock()
aLangs = [ "en", "fr", "ar", "ha" ]
cProg = "../../education/program"
oP = StzProgramQ(cProg)
oC = oP.CourseQ("elementary-introduction")
StzEduRemoveTree("t_edu_levels")

#---------------------------------------------------------------------------
Scenario("1. Five project guards, each proved against wrong and right samples")
acProjects = oP.ProjectIds()
Then("five projects are declared", len(acProjects), 5)
for i = 1 to len(acProjects)
	t1 = clock()
	oPr = oP.ProjectQ(acProjects[i])
	acNoBrief = []
	for j = 1 to len(aLangs)
		if NOT oPr.HasBriefIn(aLangs[j])
			acNoBrief + aLangs[j]
		ok
	next
	Then(acProjects[i] + ": brief in all four languages", @@(acNoBrief), "[ ]")
	Then(acProjects[i] + ": has a guard and a promise", oPr.HasGuard(), 1)
	aPr = oPr.ProveItself()
	Then(acProjects[i] + ": at least one right and two wrong samples", aPr[:right] >= 1 and aPr[:wrong] >= 2, 1)
	Then(acProjects[i] + ": every wrong sample refused, every right one accepted (" + aPr[:wrongrefused] + "/" +
		aPr[:wrong] + ", " + aPr[:rightaccepted] + "/" + aPr[:right] + ")", @@(aPr[:failures]), "[ ]")
	? "  [time] " + acProjects[i] + ": " + ((clock() - t1) / clockspersecond()) + " s"
next
EndScenario()

#---------------------------------------------------------------------------
t2 = clock()
Scenario("2. A learner earns S0 by passing chapters 1-4 and the S0 project")
cL = "t_edu_levels/zara"
oL = StzLearnerQ(cL)
acCh = oP.ChaptersForLevel(oC, "s0")
Then("S0 needs the first four chapters", @@(acCh), @@([ "find-then-apply", "a-first-sentence", "read-the-name-as-a-sentence", "say-it-in-your-language" ]))
Then("nothing is earned yet", oL.HasEarned(oP, oC, "s0"), 0)
acMissing = oL.MissingFor(oP, oC, "s0")
Then("what is missing is named: four exercises and the project", @@(acMissing),
	@@([ "ex-01-01", "ex-02-01", "ex-03-01", "ex-04-01", "project-s0" ]))

Given("Zara submits a right answer to each of the four exercises")
for i = 1 to len(acCh)
	acEx = oC.ExercisesOf(acCh[i])
	for e = 1 to len(acEx)
		oEx = oC.ExerciseQ(acEx[e])
		oL.Submit(oEx, read(oEx.RightAnswers()[1]))
	next
next
Then("the four exercises are passed", len(oL.MissingFor(oP, oC, "s0")), 1)
Then("...but the level is not earned without the project", oL.HasEarned(oP, oC, "s0"), 0)

Given("Zara writes her S0 project: a five-cell narration over her own list")
oPr0 = oP.ProjectQ("project-s0")
StzEduCopyTree(oPr0.RightSamples()[1], oL.ProjectFolder("project-s0"))
oK = oL.SubmitProject(oPr0)
Then("the project guard passes it, by running it", oK.Passed(), 1)
Then("S0 is earned", oL.HasEarned(oP, oC, "s0"), 1)
Then("nothing is missing for S0", @@(oL.MissingFor(oP, oC, "s0")), "[ ]")
Then("S1 is not earned: it needs chapters 5-7 too", oL.HasEarned(oP, oC, "s1"), 0)
Then("...and what is missing for S1 starts with chapter 5's exercise", oL.MissingFor(oP, oC, "s1")[1], "ex-05-01")

When("her project folder changes after the pass")
write(oL.ProjectFolder("project-s0") + "/narration.en.md", "# changed" + char(10))
Then("the pass no longer counts: the evidence does not match the folder", StzLearnerQ(cL).HasPassedProject("project-s0"), 0)
Then("and S0 is no longer earned", StzLearnerQ(cL).HasEarned(oP, oC, "s0"), 0)

When("a second learner types the verdicts into progress.zknw by hand")
StzEngineDirCreatePath("t_edu_levels/bob/work")
StzEngineDirCreatePath("t_edu_levels/bob/projects/project-s0")
write("t_edu_levels/bob/progress.zknw", 'knowledge "bob"' + char(10) + char(10) + "facts" + char(10) +
	"    bob | worked-on | ex-01-01" + char(10) + "    ex-01-01-by-bob | verdict | passed" + char(10) +
	"    bob | worked-on | project-s0" + char(10) + "    project-s0-by-bob | verdict | passed" + char(10))
Then("verdicts without evidence earn nothing", StzLearnerQ("t_edu_levels/bob").HasEarned(oP, oC, "s0"), 0)

Given("a scratch project with no guard (negative sibling)")
StzEngineDirCreatePath("t_edu_levels/project-zz")
write("t_edu_levels/project-zz/brief.en.md", "# zz" + char(10))
bRed = 0
try
	StzProjectQ("t_edu_levels/project-zz").Check("t_edu_levels/zara")
catch
	bRed = 1
done
Then("a project with no guard cannot judge anything, and says so", bRed, 1)
EndScenario()
? "  [time] the learner: " + ((clock() - t2) / clockspersecond()) + " s"

StzEduRemoveTree("t_edu_levels")
? ""
? "  [time] whole guard: " + ((clock() - t0) / clockspersecond()) + " s"
Summary()
