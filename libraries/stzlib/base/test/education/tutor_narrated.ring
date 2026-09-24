# THE TUTOR'S RULE 2 -- it never explains ahead of where the learner is.
#
#   1. the course knows what each chapter teaches (the names its cells
#      call, its title in four languages, its recap) and the learner's
#      progress says where the learner is
#   2. a question about a chapter AHEAD is named and not explained, in
#      en/fr/ar/ha, and the reply carries none of that chapter's names;
#      the same tutor WITHOUT the course cannot apply the rule (negative
#      sibling), and a question about nothing gets the gap conversation
#   3. the same question as the learner moves through the course: ahead,
#      then current (the gap conversation), then behind (recalled in the
#      chapter's own recap words) -- every pass a real run of a right answer
#
# Run from this folder: ring tutor_narrated.ring

load "../../stzBase.ring"
load "../_narrated.ring"

t0 = clock()
cProg = "../../education/program"
oC = StzProgramQ(cProg).CourseQ("elementary-introduction")
cLearner = "t_edu_tutor/amina"
EduTutorClean()

#---------------------------------------------------------------------------
Scenario("1. What each chapter teaches, and where the learner is")
t1 = clock()
Given("the course's teaching index, read from the chapters' own cells")
Then("KnowRelation is first called by chapter 12", oC.TeachesWhere("KnowRelation"), "teach-a-world")
Then("...case does not matter", oC.TeachesWhere("knowrelation"), "teach-a-world")
Then("DuplicatesRemoved is first called by chapter 1", oC.TeachesWhere("DuplicatesRemoved"), "find-then-apply")
Then("a name no chapter calls belongs nowhere", oC.TeachesWhere("Zorglub"), "")
? "  [time] the index of 15 chapters: " + ((clock() - t1) / clockspersecond()) + " s"
acNames12 = oC.NamesTaughtBy("teach-a-world")
Then("chapter 12 teaches " + len(acNames12) + " names, KnowRelation among them", StzFindFirst("KnowRelation", acNames12) > 0, 1)
acLangs = [ "en", "fr", "ar", "ha" ]
nRecaps = 0
for i = 1 to 4
	if oC.ChapterQ("teach-a-world", acLangs[i]).RecapAchieved() != ""
		nRecaps++
	ok
next
Then("chapter 12 has a recap first bullet in all four languages", nRecaps, 4)
Then("...and the English one is the chapter's own words, without its label",
	StzLeft(oC.ChapterQ("teach-a-world", "en").RecapAchieved(), 16), "you stated facts")
Then("the title in Arabic comes from the Arabic edition", oC.TitleOf("teach-a-world", "ar"), "علّم عالمًا")

Given("a learner who has done nothing yet")
oL = StzLearnerQ(cLearner)
Then("the learner is on chapter 1", oL.ChapterOn(oC), "find-then-apply")
When("the learner submits a wrong answer to chapter 1's exercise (negative sibling)")
oEx1 = oC.ExerciseQ("ex-01-01")
oL.Submit(oEx1, read(oEx1.WrongAnswers()[1]))
Then("a try that did not pass does not move the learner", oL.ChapterOn(oC), "find-then-apply")
When("the learner submits a right answer, and the checker runs it")
Then("the checker accepted it", oL.Submit(oEx1, read(oEx1.RightAnswers()[1])).Passed(), 1)
Then("now the learner is on chapter 2", oL.ChapterOn(oC), "a-first-sentence")
EndScenario()
? "  [time] scenario 1: " + ((clock() - t1) / clockspersecond()) + " s"

#---------------------------------------------------------------------------
t2 = clock()
Scenario("2. A question about a chapter ahead is named, not explained")
oEx2 = oC.ExerciseQ("ex-02-01")
oT = StzTutorQ(oEx2, cLearner, "en").WithCourseQ(oC)
Given("the tutor on chapter 2's exercise, with the course laid on")
Then("the tutor knows where the learner is", oT.ChapterOn(), "a-first-sentence")

cQ = "How do I use KnowRelation to teach a world?"
r1 = oT.Ask(cQ)
? "    tutor: " + r1
Then("the question is read as being about chapter 12", oT.LastAbout(), "teach-a-world")
Then("the reply names the chapter and the learner's own, and explains nothing",
	r1, _EduSay("en", "ahead", [ 12, "Teach a world", 2 ]))
Then("the reply carries none of the " + len(acNames12) + " names chapter 12 teaches", _EduHasAnyWord(r1, acNames12), 0)
Then("...and ends on a question", StzRight(r1, 1), "?")
Then("no filter was needed: the template carries no code", oT.FilteredCount(), 0)

r2 = oT.Ask("how do I teach a world?")
Then("a question in the chapter's title words, with no name, is read the same way", oT.LastAbout(), "teach-a-world")
Then("...and answered the same way", r2, r1)

r3 = oT.Ask("Give me the code for KnowRelation")
? "    tutor: " + r3
Then("asked for the code of a later chapter: refuses (rule 1), then names the chapter (rule 2)",
	r3, _EduSay("en", "refuse", "") + " " + _EduSay("en", "ahead", [ 12, "Teach a world", 2 ]))

acNames14 = oC.NamesTaughtBy("an-agent-that-cannot-hurt")
r4 = oT.Ask("What does " + acNames14[1] + " do?")
Then("a name from chapter 14 (" + acNames14[1] + ") points at chapter 14", oT.LastAbout(), "an-agent-that-cannot-hurt")
Then("...and is not explained either", StzFindFirst("chapter 14,", r4) > 0 and _EduHasAnyWord(r4, acNames14) = 0, 1)

Given("the same question in French, Arabic and Hausa, each in its edition's title words")
acQ = [ "Comment enseigner un monde ?", "ماذا يعني علّم عالمًا؟", "Yaya zan koyar da duniya?" ]
acL = [ "fr", "ar", "ha" ]
for i = 1 to 3
	oTL = StzTutorQ(oEx2, cLearner, acL[i]).WithCourseQ(oC)
	rL = oTL.Ask(acQ[i])
	? "    tutor (" + acL[i] + "): " + rL
	Then(acL[i] + ": read as chapter 12", oTL.LastAbout(), "teach-a-world")
	Then(acL[i] + ": the ahead reply in that language, with that edition's title",
		rL, _EduSay(acL[i], "ahead", [ 12, oC.TitleOf("teach-a-world", acL[i]), 2 ]))
	Then(acL[i] + ": none of chapter 12's names", _EduHasAnyWord(rL, acNames12), 0)
next

Given("negative siblings")
r5 = oT.Ask("What is missing in my program?")
Then("a question about no chapter is not about any", oT.LastAbout(), "")
Then("...and gets the ordinary conversation (not tried yet: try first)", r5, _EduSay("en", "try-first", ""))
oT0 = StzTutorQ(oEx2, cLearner, "en")
r6 = oT0.Ask(cQ)
Then("the same tutor WITHOUT the course cannot know what is ahead", oT0.HasCourse(), 0)
Then("...so rule 2 cannot bite there: it falls to the ordinary conversation", r6, _EduSay("en", "try-first", ""))
Then("...and reads the question as about nothing", oT0.LastAbout(), "")
EndScenario()
? "  [time] scenario 2: " + ((clock() - t2) / clockspersecond()) + " s"

#---------------------------------------------------------------------------
t3 = clock()
Scenario("3. The same question as the learner moves: ahead, current, behind")
acCh = oC.ChapterIds()
When("the learner passes every exercise of chapters 2 to 11, each a real run")
nRuns = EduTutorPass(oL, oC, 2, 11)
? "    " + nRuns + " right answers run and accepted in " + ((clock() - t3) / clockspersecond()) + " s"
Then("the learner is now on chapter 12", oL.ChapterOn(oC), "teach-a-world")
oEx12 = oC.ExerciseQ("ex-12-01")
oT12 = StzTutorQ(oEx12, cLearner, "en").WithCourseQ(oC)
r7 = oT12.Ask(cQ)
? "    tutor: " + r7
Then("the question is still about chapter 12", oT12.LastAbout(), "teach-a-world")
Then("...but chapter 12 is now the current one: the gap conversation, not a refusal",
	r7, _EduSay("en", "try-first", ""))

When("the learner passes chapter 12's exercises")
nRuns2 = EduTutorPass(oL, oC, 12, 12)
Then("the learner is on chapter 13", oL.ChapterOn(oC), "the-gap-question")
oEx13 = oC.ExerciseQ("ex-13-01")
oT13 = StzTutorQ(oEx13, cLearner, "en").WithCourseQ(oC)
r8 = oT13.Ask(cQ)
? "    tutor: " + r8
Then("chapter 12 is behind now: recalled in the chapter's own recap words",
	r8, _EduSay("en", "recap", [ 12, "Teach a world", oC.ChapterQ("teach-a-world", "en").RecapAchieved() ]))
oT13ar = StzTutorQ(oEx13, cLearner, "ar").WithCourseQ(oC)
r9 = oT13ar.Ask("ماذا يعني علّم عالمًا؟")
? "    tutor (ar): " + r9
Then("...in Arabic, from the Arabic edition's recap",
	r9, _EduSay("ar", "recap", [ 12, oC.TitleOf("teach-a-world", "ar"), oC.ChapterQ("teach-a-world", "ar").RecapAchieved() ]))
r10 = oT13.Ask("What did DuplicatesRemoved do, back in the first chapter?")
Then("chapter 1 is behind too: its recap, built from chapter 1's own first bullet",
	r10, _EduSay("en", "recap", [ 1, "Find, then apply", oC.ChapterQ("find-then-apply", "en").RecapAchieved() ]))
r11 = oT13.Ask("What does " + acNames14[1] + " do?")
Then("and chapter 14 is still ahead", r11, _EduSay("en", "ahead", [ 14, oC.TitleOf("an-agent-that-cannot-hurt", "en"), 13 ]))
EndScenario()
? "  [time] scenario 3: " + ((clock() - t3) / clockspersecond()) + " s"

EduTutorClean()
? ""
? "  [time] whole guard: " + ((clock() - t0) / clockspersecond()) + " s"
Summary()

#===========================================================================
func EduTutorClean()
	StzEduRemoveTree("t_edu_tutor")

# Submits the first right answer of every exercise of chapters nFrom..nTo,
# in course order, and raises if the checker refuses one: a pass here is
# a real run, never a fact typed into progress.
func EduTutorPass(poL, poC, nFrom, nTo)
	_acCh_ = poC.ChapterIds()
	_n_ = 0
	for _i_ = nFrom to nTo
		_acEx_ = poC.ExercisesOf(_acCh_[_i_])
		for _j_ = 1 to len(_acEx_)
			_oEx_ = poC.ExerciseQ(_acEx_[_j_])
			_oCk_ = poL.Submit(_oEx_, read(_oEx_.RightAnswers()[1]))
			if NOT _oCk_.Passed()
				StzRaise("The checker refused the right answer of " + _acEx_[_j_] + ": " + _oCk_.Why())
			ok
			_n_++
		next
	next
	return _n_
