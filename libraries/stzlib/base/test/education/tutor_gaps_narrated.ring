# THE TUTOR, AS ANOTHER COURSE USES IT -- two findings of the mathematics
# plane, which ran the tutor over a corpus it was not written on.
#
#   1. MATH-FINDING-EDU-TUTOR-01: a question is read as being about a
#      chapter only by words that DISTINGUISH that chapter; a title that
#      repeats "the" cannot claim "Give me the answer". Proved on titles
#      alone (a pure function), then on the real courses
#   2. MATH-TUTOR-NUMBERS-01: the gap question is the EXERCISE'S, not
#      chapter 1's. An exercise declares the words that show a step
#      (`<step> | seen-by | <word>`) and the question for it per language
#      (gaps.<lang>.md); the three chapter-1 steps keep their defaults. A
#      step with no question in a language is red, never another language
#
# Run from this folder: ring tutor_gaps_narrated.ring

load "../../stzBase.ring"
load "../_narrated.ring"

t0 = clock()
cProg = "../../education/program"
EduGapsClean()

#---------------------------------------------------------------------------
Scenario("1. A title word may reach a chapter only if it distinguishes it")
t1 = clock()
acTitles = [ "The number line", "The fraction", "The derivative that checks the formula", "Limits and continuity" ]
Given("a course whose third title repeats 'the' and shares it with two other titles")
Then("'Give me the answer' is about no chapter", _EduChapterByTitle(acTitles, [ "give", "me", "the", "answer" ]), 0)
Then("'the question that I have' neither (two common words in one title)", _EduChapterByTitle(acTitles, [ "the", "question", "that", "have" ]), 0)
Then("the distinguishing words still reach it: derivative + formula", _EduChapterByTitle(acTitles, [ "derivative", "formula" ]), 3)
Then("one distinguishing word of a three-word title is not enough", _EduChapterByTitle(acTitles, [ "formula" ]), 0)
Then("'the number line': 'number' and 'line' distinguish chapter 1, 'the' does not", _EduChapterByTitle(acTitles, [ "the", "number", "line" ]), 1)
Then("a title with a single distinguishing word is reached by it ('Limits and continuity' has two; 'fraction' is alone)",
	_EduChapterByTitle(acTitles, [ "fraction" ]), 2)

Given("the same repetition where NO other title uses 'the' (the old matcher counted it twice)")
acAlone = [ "The derivative that checks the formula", "Limits and continuity" ]
Then("'Give me the answer' is still about no chapter: 'the' counts once, and once is not two",
	_EduChapterByTitle(acAlone, [ "give", "me", "the", "answer" ]), 0)

Given("the real courses, in the learner's language")
oP = StzProgramQ(cProg)
oC = oP.CourseQ("elementary-introduction")
oEx = oC.ExerciseQ("ex-01-01")
oT = StzTutorQ(oEx, "t_edu_gaps/nobody", "en").WithCourseQ(oC)
Then("elementary-introduction: 'Give me the answer' is about no chapter", oT.ChapterAskedAbout("Give me the answer"), "")
Then("...and 'how do I teach a world?' still is about chapter 12", oT.ChapterAskedAbout("how do I teach a world?"), "teach-a-world")
if len(oP.Courses()) > 0 and StzFindFirst("math", oP.Courses()) > 0
	oM = oP.CourseQ("math")
	oTm = StzTutorQ(oM.ExerciseQ(oM.ExercisesOf(oM.ChapterIds()[1])[1]), "t_edu_gaps/nobody", "en").WithCourseQ(oM)
	Then("math: 'Give me the answer' is about no chapter", oTm.ChapterAskedAbout("Give me the answer"), "")
	Then("math: 'the question that I have' neither", oTm.ChapterAskedAbout("the question that I have"), "")
else
	? "  SKIPPED: the math course is not in this program (nothing to run it over)"
ok
EndScenario()
? "  [time] scenario 1: " + ((clock() - t1) / clockspersecond()) + " s"

#---------------------------------------------------------------------------
t2 = clock()
Scenario("2. The gap question is the exercise's own")
Given("the built-in exercise, unchanged (chapter 1's three steps keep their defaults)")
Then("finds is seen by 'find'", @@(oEx.StepWords("finds")), @@([ "find" ]))
Then("asks is seen by contains / numberof / count", @@(oEx.StepWords("asks")), @@([ "contains", "numberof", "count" ]))
Then("a step nobody described is seen by nothing", @@(oEx.StepWords("reduces")), "[ ]")
Then("its question is still the built-in one", oEx.GapText("finds", "en"), _EduSay("en", "gap-finds", ""))

Given("an exercise of another subject: it declares its own steps, words and questions")
EduGapsWriteFraction("t_edu_gaps/ex-fraction")
oF = StzExerciseQ("t_edu_gaps/ex-fraction")
Then("it needs two steps, in order", @@(oF.NeededSteps()), @@([ "reduces", "compares" ]))
Then("'reduces' is seen by gcd (declared, not built in)", @@(oF.StepWords("reduces")), @@([ "gcd" ]))
Then("...and asks its own question", oF.GapText("reduces", "en"), "Did you reduce the fraction first? Which common divisor did you look for?")

oL = StzLearnerQ("t_edu_gaps/amina")
oTf = StzTutorQ(oF, "t_edu_gaps/amina", "en")
When("the learner submits a wrong answer that shows neither step")
oCk = oL.Submit(oF, '? "6/8"')
Then("the checker refused it (it ran)", oCk.Passed(), 0)
r1 = oTf.Ask("what is missing in my program?")
? "    tutor: " + r1
Then("the first missing step is the exercise's own: reduces", oTf.LastGap(), "reduces")
Then("the reply is that exercise's question, nothing about lists",
	r1, "Did you reduce the fraction first? Which common divisor did you look for?")
Then("...it never speaks of the chapter-1 vocabulary", StzFindFirst("list", StzLower(r1)) = 0 and StzFindFirst("duplicate", StzLower(r1)) = 0, 1)

When("the learner's next attempt shows the first step (the word gcd is in the code) and still diverges")
oL.Submit(oF, '? "gcd 6/8"')
r2 = oTf.Ask("and now?")
Then("the next missing step is named: compares", oTf.LastGap(), "compares")
Then("...with its own question", r2, "Once both are in lowest terms, which is greater, and how did your program decide?")

When("the attempt shows both steps and still diverges")
oL.Submit(oF, '? "gcd greater 6/8"')
r3 = oTf.Ask("and now?")
Then("no step is missing: the tutor sends the learner to the output", r3, _EduSay("en", "look-output", ""))
Then("...and no reply ever needed the filter", oTf.FilteredCount(), 0)

Given("the same exercise in French, Arabic and Hausa")
oL2 = StzLearnerQ("t_edu_gaps/moussa")
oL2.Submit(oF, '? "6/8"')
acLang = [ "fr", "ar", "ha" ]
acWant = [ "Avez-vous d'abord réduit la fraction ? Quel diviseur commun avez-vous cherché ?",
	"هل بسّطت الكسر أولًا؟ أيّ قاسم مشترك بحثت عنه؟",
	"Ka rage ɓangaren lamba tukuna? Wane mai raba su ɗaya ka nema?" ]
for i = 1 to 3
	oTL = StzTutorQ(oF, "t_edu_gaps/moussa", acLang[i])
	rL = oTL.Ask("?")
	? "    tutor (" + acLang[i] + "): " + rL
	Then(acLang[i] + ": the question of step 'reduces', in " + acLang[i], rL, acWant[i])
next

Given("a step with no question in a language (negative sibling): Hausa has only 'reduces'")
oL2.Submit(oF, '? "gcd 6/8"')
bRed = 0
cWhy = ""
try
	StzTutorQ(oF, "t_edu_gaps/moussa", "ha").Ask("?")
catch
	bRed = 1
	cWhy = cCatchError
done
Then("it is red, never another language", bRed, 1)
Then("...and names the step and the file to write", StzFindFirst("compares", cWhy) > 0 and StzFindFirst("gaps.ha.md", cWhy) > 0, 1)
EndScenario()
? "  [time] scenario 2: " + ((clock() - t2) / clockspersecond()) + " s"

EduGapsClean()
? ""
? "  [time] whole guard: " + ((clock() - t0) / clockspersecond()) + " s"
Summary()

#===========================================================================
func EduGapsClean()
	StzEduRemoveTree("t_edu_gaps")

# A scratch exercise of another subject: reduce 6/8, then compare. The right
# answer prints 3/4; the wrong one prints 6/8. The tutor's vocabulary is
# declared HERE (seen-by, gaps.<lang>.md), not built into the tutor.
func EduGapsWriteFraction(pcFolder)
	StzEngineDirCreatePath(pcFolder + "/right")
	StzEngineDirCreatePath(pcFolder + "/wrong")
	write(pcFolder + "/exercise.zknw", 'knowledge "ex-fraction"' + char(10) + char(10) + "facts" + char(10) +
		"    ex-fraction | is-a | exercise" + char(10) +
		"    ex-fraction | needs-step | reduces" + char(10) +
		"    ex-fraction | needs-step | compares" + char(10) +
		"    reduces | seen-by | gcd" + char(10) +
		"    compares | seen-by | greater" + char(10))
	write(pcFolder + "/promise.ring", "#--> 3/4" + char(10))
	write(pcFolder + "/right/01-reduced.ring", '? "3/4"' + char(10))
	write(pcFolder + "/wrong/01-unreduced.ring", '? "6/8"' + char(10))
	write(pcFolder + "/gaps.en.md", "reduces: Did you reduce the fraction first? Which common divisor did you look for?" + char(10) +
		"compares: Once both are in lowest terms, which is greater, and how did your program decide?" + char(10))
	write(pcFolder + "/gaps.fr.md", "reduces: Avez-vous d'abord réduit la fraction ? Quel diviseur commun avez-vous cherché ?" + char(10) +
		"compares: Une fois les deux en termes irréductibles, laquelle est la plus grande, et comment votre programme a-t-il décidé ?" + char(10))
	write(pcFolder + "/gaps.ar.md", "reduces: هل بسّطت الكسر أولًا؟ أيّ قاسم مشترك بحثت عنه؟" + char(10) +
		"compares: بعد أن صار الاثنان في أبسط صورة، أيّهما أكبر، وكيف قرّر برنامجك ذلك؟" + char(10))
	write(pcFolder + "/gaps.ha.md", "reduces: Ka rage ɓangaren lamba tukuna? Wane mai raba su ɗaya ka nema?" + char(10))
