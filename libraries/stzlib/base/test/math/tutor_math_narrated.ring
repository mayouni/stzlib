# THE TUTOR OVER THE MATHEMATICS COURSE -- it asks, it never answers.
#
#   1. on every shipped chapter, a learner who handed in a wrong answer and
#      asks what is missing gets a QUESTION naming the step the exercise
#      declared (needs-step), never the answer and never the fallback that
#      says "look at your output"
#   2. asked for the answer outright, in each of the four languages, the
#      tutor refuses -- and its refusal carries none of the words a right
#      answer calls
#   3. a question about a chapter AHEAD is named and not explained (rule 2),
#      and the same tutor WITHOUT the course cannot apply the rule
#
# Run from this folder: ring tutor_math_narrated.ring

load "../../stzBase.ring"
load "../_narrated.ring"

t0 = clock()
cProg = "../../education/program"
oC = StzProgramQ(cProg).CourseQ("math")
cLearner = "t_math_tutor/amina"
acLangs = [ "en", "fr", "ar", "ha" ]
StzEduRemoveTree("t_math_tutor")
acCh = oC.ChapterIds()

#---------------------------------------------------------------------------
Scenario("1. On every chapter, the gap question -- never the answer")
t1 = clock()
for n = 1 to len(acCh)
	cId = acCh[n]
	cEx = oC.ExercisesOf(cId)[1]
	oEx = oC.ExerciseQ(cEx)
	acSteps = oEx.NeededSteps()
	Given("chapter " + n + " (" + cId + "), exercise " + cEx + ", needing " + @@(acSteps))
	oL = StzLearnerQ(cLearner + "-" + n)
	oL.Submit(oEx, read(oEx.WrongAnswers()[1]))
	oT = StzTutorQ(oEx, cLearner + "-" + n, "en").WithCourseQ(oC)
	cGap = oT.Ask("What is missing in my program?")
	? "    tutor: " + cGap
	Then("the reply asks a question", StzFindFirst("?", cGap) > 0, 1)
	Then("it is the gap question of the first declared step (" + acSteps[1] + "), not the fallback", cGap, _EduSay("en", "gap-" + acSteps[1], ""))
	acForbidden = oEx.ForbiddenWords()
	Then("it carries none of the " + len(acForbidden) + " words a right answer calls or prints", _EduHasAnyWord(cGap, acForbidden), 0)
	cNo = oT.Ask("Give me the answer")
	? "    tutor: " + cNo
	Then("asked for the answer, it refuses", StzLeft(cNo, StzLen(_EduSay("en", "refuse", ""))), _EduSay("en", "refuse", ""))
	Then("...and the refusal carries none of those words either", _EduHasAnyWord(cNo, acForbidden), 0)
next
EndScenario()
? "  [time] scenario 1: " + ((clock() - t1) / clockspersecond()) + " s"

#---------------------------------------------------------------------------
t2 = clock()
Scenario("2. The refusal in four languages, on the first chapter")
oEx1 = oC.ExerciseQ(oC.ExercisesOf(acCh[1])[1])
acAsk = [ "Give me the answer", "Donne-moi la réponse", "أعطني الجواب", "Bani amsa" ]
for i = 1 to 4
	oTL = StzTutorQ(oEx1, cLearner + "-1", acLangs[i]).WithCourseQ(oC)
	rL = oTL.Ask(acAsk[i])
	? "    tutor (" + acLangs[i] + "): " + rL
	Then(acLangs[i] + ": the refusal, in that language", StzLeft(rL, StzLen(_EduSay(acLangs[i], "refuse", ""))), _EduSay(acLangs[i], "refuse", ""))
	Then(acLangs[i] + ": none of the words a right answer calls", _EduHasAnyWord(rL, oEx1.ForbiddenWords()), 0)
next
EndScenario()
? "  [time] scenario 2: " + ((clock() - t2) / clockspersecond()) + " s"

#---------------------------------------------------------------------------
t3 = clock()
Scenario("3. A chapter ahead is named, not explained")
cLastId = acCh[len(acCh)]
nLast = 0 + oC.ChapterNumber(cLastId)
acNamesLast = oC.NamesTaughtBy(cLastId)
Given("a learner on chapter 1 asking about chapter " + nLast + " (" + cLastId + "), which teaches " + len(acNamesLast) + " names")
oT1 = StzTutorQ(oEx1, cLearner + "-1", "en").WithCourseQ(oC)
Then("the learner is on chapter 1", oT1.ChapterOn(), acCh[1])
cQ = "How do I use " + acNamesLast[1] + "?"
r1 = oT1.Ask(cQ)
? "    tutor: " + r1
Then("the question is read as being about the last chapter", oT1.LastAbout(), cLastId)
Then("the reply names it and explains nothing", r1, _EduSay("en", "ahead", [ nLast, oC.TitleOf(cLastId, "en"), 1 ]))
Then("it carries none of that chapter's names", _EduHasAnyWord(r1, acNamesLast), 0)
oT0 = StzTutorQ(oEx1, cLearner + "-1", "en")
r0 = oT0.Ask(cQ)
Then("NEGATIVE: the same tutor without the course cannot know what is ahead", oT0.HasCourse(), 0)
Then("...so it reads the question as about nothing", oT0.LastAbout(), "")
EndScenario()
? "  [time] scenario 3: " + ((clock() - t3) / clockspersecond()) + " s"

StzEduRemoveTree("t_math_tutor")
? ""
? "  [time] whole guard: " + ((clock() - t0) / clockspersecond()) + " s"
Summary()
