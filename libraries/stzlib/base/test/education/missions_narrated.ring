# THE ZINDARA MISSIONS -- the children's track, proved by running.
#
# Three missions of three steps, set in the village of Zindara. Every step
# is an exercise a child answers with a program, checked by running it,
# in any of the four languages. This gate proves:
#   - the course declares 3 missions x 3 steps, every step an exercise that exists
#   - every step has a task in en/fr/ar/ha
#   - every step refuses its wrong answers and accepts its right ones
#   - at least one right answer is written in Hausa (the track's promise)
#
# Run from this folder: ring missions_narrated.ring

load "../../stzBase.ring"
load "../_narrated.ring"

t0 = clock()
aLangs = [ "en", "fr", "ar", "ha" ]
cProg = "../../education/program"
oP = StzProgramQ(cProg)
oC = oP.CourseQ("zindara-missions")
aFacts = _EduFactsOf(cProg + "/courses/zindara-missions/course.zknw")

Scenario("Three missions of three steps")
acMissions = []
for i = 1 to 3
	acM = _EduObjects(aFacts, "zindara-missions", "has-mission-" + i)
	if len(acM) = 1
		acMissions + acM[1]
	ok
next
Then("the course declares three missions", @@(acMissions), @@([ "who-lives-in-zindara", "what-happens-each-day", "what-are-the-rules" ]))
acSteps = []
acBadSteps = []
for m = 1 to len(acMissions)
	for s = 1 to 3
		acS = _EduObjects(aFacts, acMissions[m], "has-step-" + s)
		if len(acS) = 1 and oP.FolderFor("courses/zindara-missions/exercises/" + acS[1]) != ""
			acSteps + acS[1]
		else
			acBadSteps + (acMissions[m] + " step " + s)
		ok
	next
next
Then("every mission has three steps, each an exercise that exists", @@(acBadSteps), "[ ]")
Then("nine steps in all", len(acSteps), 9)
Then("the course lists the same nine as its exercises", len(oC.ExercisesOf("zindara-missions")), 9)
EndScenario()

nHausa = 0
for m = 1 to len(acMissions)
	t1 = clock()
	Scenario("Mission " + m + " · " + acMissions[m])
	for s = 1 to 3
		cId = acSteps[(m - 1) * 3 + s]
		oEx = oC.ExerciseQ(cId)
		acNoTask = []
		for i = 1 to len(aLangs)
			if NOT oEx.HasTaskIn(aLangs[i])
				acNoTask + aLangs[i]
			ok
		next
		Then(cId + ": task in all four languages", @@(acNoTask), "[ ]")
		aPr = oEx.ProveItself()
		Then(cId + ": at least two wrong and two right answers", aPr[:wrong] >= 2 and aPr[:right] >= 2, 1)
		Then(cId + ": every wrong answer refused, every right one accepted (" + aPr[:wrongrefused] + "/" +
			aPr[:wrong] + ", " + aPr[:rightaccepted] + "/" + aPr[:right] + ")", @@(aPr[:failures]), "[ ]")
		acR = oEx.RightAnswers()
		for r = 1 to len(acR)
			if StzFindFirst('NaturallyIn("ha"', read(acR[r])) > 0
				nHausa++
			ok
		next
	next
	EndScenario()
	? "  [time] mission " + m + ": " + ((clock() - t1) / clockspersecond()) + " s"
next

Scenario("A child may answer in Hausa")
Then("at least one right answer of the track is written in Hausa", nHausa >= 1, 1)
EndScenario()

? ""
? "  [time] whole guard: " + ((clock() - t0) / clockspersecond()) + " s"
Summary()
