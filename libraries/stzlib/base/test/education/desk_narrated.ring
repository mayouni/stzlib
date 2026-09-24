# THE LEARNER'S DESK -- the two tools a learner and a teacher run, each a
# program judged by running it, from the command line, as they would.
#
#   1. learn.ring: status, submit (refused, then passed -- both real runs),
#      status again, ask (the tutor with the course laid on, in two
#      languages), a project folder judged by its guard; wrong calls are
#      refused with exit 1 and the usage (negative siblings)
#   2. build_reader.ring: a scoped build runs the chapters and the world
#      page side by side, writes one page, and PRINTS what it skipped by
#      name; a language with no edition is red (law 7), not English
#
# The tools load ../../stzBase.ring from their own folder; this folder
# sits at the same depth, so the guard runs them from here unchanged.
#
# Run from this folder: ring desk_narrated.ring

load "../../stzBase.ring"
load "../_narrated.ring"

t0 = clock()
cProg = "../../education/program"
cLearner = "t_edu_desk/amina"
cCommon = " --program " + cProg
EduDeskClean()
StzEngineDirCreatePath("t_edu_desk")

#---------------------------------------------------------------------------
Scenario("1. learn.ring: where you are, what you submit, what the tutor says")
t1 = clock()
aR = EduDeskLearn(cLearner + " status" + cCommon)
? "    " + StzReplace(ring_trim(aR[1]), char(10), char(10) + "    ")
Then("a fresh learner: exit 0", aR[2], 0)
Then("...on chapter 1, nothing passed", StzFindFirst("ON chapter 1: find-then-apply", aR[1]) > 0 and StzFindFirst("PASSED 0 of 23 exercises", aR[1]) > 0, 1)
Then("...and the next level named with what it needs", StzFindFirst("LEVEL s0: missing 5 -- ex-01-01", aR[1]) > 0, 1)

oEx1 = StzProgramQ(cProg).CourseQ("elementary-introduction").ExerciseQ("ex-01-01")
write("t_edu_desk/wrong.ring", read(oEx1.WrongAnswers()[1]))
write("t_edu_desk/right.ring", read(oEx1.RightAnswers()[1]))
When("the learner submits a wrong answer to exercise 1.1")
aR = EduDeskLearn(cLearner + " submit ex-01-01 t_edu_desk/wrong.ring" + cCommon)
? "    " + ring_trim(aR[1])
Then("refused: exit 2, and the checker says why", aR[2] = 2 and StzLeft(ring_trim(aR[1]), 17) = "REFUSED ex-01-01:", 1)
When("the learner submits a right answer")
aR = EduDeskLearn(cLearner + " submit ex-01-01 t_edu_desk/right.ring" + cCommon)
? "    " + ring_trim(aR[1])
Then("passed: exit 0, the checker ran it", aR[2] = 0 and StzLeft(ring_trim(aR[1]), 16) = "PASSED ex-01-01:", 1)
aR = EduDeskLearn(cLearner + " status" + cCommon)
Then("status moved: on chapter 2, one exercise passed", StzFindFirst("ON chapter 2: a-first-sentence", aR[1]) > 0 and
	StzFindFirst("PASSED 1 of 23 exercises: ex-01-01", aR[1]) > 0, 1)
Then("...and the next level needs one thing fewer", StzFindFirst("LEVEL s0: missing 4 -- ex-02-01", aR[1]) > 0, 1)

When("the learner asks the tutor about a later chapter, in English and in French")
aR = EduDeskLearn(cLearner + ' ask ex-02-01 "How do I use KnowRelation to teach a world?"' + cCommon)
? "    tutor: " + ring_trim(aR[1])
Then("the tutor has the course: rule 2 names chapter 12 and explains nothing",
	ring_trim(aR[1]), _EduSay("en", "ahead", [ 12, "Teach a world", 2 ]))
aR = EduDeskLearn(cLearner + ' ask ex-02-01 "Comment enseigner un monde ?" --lang fr' + cCommon)
? "    tuteur: " + ring_trim(aR[1])
Then("...in French when asked in French", ring_trim(aR[1]), _EduSay("fr", "ahead", [ 12, "Enseigner un monde", 2 ]))

When("the learner hands in a project folder (a right sample of project-s0, copied as their own)")
oPr = StzProgramQ(cProg).ProjectQ("project-s0")
StzEduCopyTree(oPr.RightSamples()[1], cLearner + "/projects/project-s0")
aR = EduDeskLearn(cLearner + " project project-s0" + cCommon)
? "    " + ring_trim(aR[1])
Then("the guard ran the folder and passed it: exit 0", aR[2] = 0 and StzLeft(ring_trim(aR[1]), 18) = "PASSED project-s0:", 1)
aR = EduDeskLearn(cLearner + " status" + cCommon)
Then("status: level s0 no longer waits on the project, only on exercises", StzFindFirst("LEVEL s0: missing 3 -- ex-02-01, ex-03-01, ex-04-01", aR[1]) > 0, 1)

Given("wrong calls (negative siblings)")
aR = EduDeskLearn("")
Then("no argument: the usage, exit 1", aR[2] = 1 and StzFindFirst("usage:", aR[1]) > 0, 1)
aR = EduDeskLearn(cLearner + " dance" + cCommon)
Then("an unknown verb: the usage, exit 1", aR[2] = 1 and StzFindFirst("usage:", aR[1]) > 0, 1)
aR = EduDeskLearn(cLearner + " submit ex-99-99 t_edu_desk/right.ring" + cCommon)
Then("an exercise that does not exist: ERROR, exit 1", aR[2] = 1 and StzFindFirst("ERROR:", aR[1]) > 0, 1)
aR = EduDeskLearn(cLearner + " submit ex-01-01 t_edu_desk/nothing.ring" + cCommon)
Then("a file that does not exist: ERROR, exit 1", aR[2] = 1 and StzFindFirst("ERROR: no such file", aR[1]) > 0, 1)
aR = EduDeskLearn(cLearner + " status --world mars" + cCommon)
Then("a world that is not shipped: ERROR naming the ones that are, exit 1", aR[2] = 1 and StzFindFirst("cooperative", aR[1]) > 0, 1)
EndScenario()
? "  [time] learn.ring, eleven calls: " + ((clock() - t1) / clockspersecond()) + " s"

#---------------------------------------------------------------------------
t2 = clock()
Scenario("2. build_reader.ring: the page is built by a tool, and a scoped build says what it skipped")
aR = EduDeskBuild("t_edu_desk/page.html --chapters 1-2 --langs en,fr --worlds school" + cCommon)
? "    " + StzReplace(ring_trim(aR[1]), char(10), char(10) + "    ")
Then("exit 0 and the file exists", aR[2] = 0 and fexists("t_edu_desk/page.html"), 1)
cHtml = read("t_edu_desk/page.html")
Then("the page holds both chapters, in both languages", StzFindFirst(">1 · Find, then apply<", cHtml) > 0 and
	StzFindFirst(">1 · Trouver, puis agir<", cHtml) > 0 and StzFindFirst(">2 · ", cHtml) > 0, 1)
Then("...and the school's page under World / Monde", StzFindFirst(">World · The school<", cHtml) > 0 and StzFindFirst(">Monde · ", cHtml) > 0, 1)
Then("...with no output stored: every English cell shows the fixed sentence", len(StzFind(_EduSay("en", "cell-no-output", ""), cHtml)) > 0 and
	StzFindFirst("```", cHtml) = 0, 1)
Then("it printed what ran", StzFindFirst("chapter 1 find-then-apply: en fr", aR[1]) > 0 and StzFindFirst("world school: en fr", aR[1]) > 0, 1)
Then("it printed what it skipped, by name", StzFindFirst("SKIPPED chapters: read-the-name-as-a-sentence", aR[1]) > 0 and
	StzFindFirst("SKIPPED worlds: cooperative, workplace", aR[1]) > 0, 1)

Given("wrong calls (negative siblings)")
aR = EduDeskBuild("")
Then("no argument: the usage, exit 1", aR[2] = 1 and StzFindFirst("usage:", aR[1]) > 0, 1)
aR = EduDeskBuild("t_edu_desk/tr.html --chapters 1 --langs tr --worlds none" + cCommon)
Then("a language the course does not teach in: ERROR, exit 1, never English instead (law 7)",
	aR[2] = 1 and StzFindFirst("ERROR:", aR[1]) > 0 and StzFindFirst("'tr'", aR[1]) > 0, 1)
EndScenario()
? "  [time] build_reader.ring, three calls: " + ((clock() - t2) / clockspersecond()) + " s"

EduDeskClean()
? ""
? "  [time] whole guard: " + ((clock() - t0) / clockspersecond()) + " s"
Summary()

#===========================================================================
func EduDeskClean()
	StzEduRemoveTree("t_edu_desk")

# Runs a tool as a learner would: a fresh process. [ stdout, exit code, stderr ].
func EduDeskLearn(pcArgs)
	_aR_ = StzEngineSystemRunXT(StzEduRingExe() + " ../../education/tools/learn.ring " + pcArgs)
	return [ "" + _aR_[1], 0 + _aR_[2], "" + _aR_[3] ]

func EduDeskBuild(pcArgs)
	_aR_ = StzEngineSystemRunXT(StzEduRingExe() + " ../../education/tools/build_reader.ring " + pcArgs)
	return [ "" + _aR_[1], 0 + _aR_[2], "" + _aR_[3] ]
