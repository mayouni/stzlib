# THREE TEACHING WORLDS (COMPASS-CT-WORLDS-01) -- a restaurant, a cooperative,
# a school -- and the contract a world keeps so the chapters can reason over it.
#
#   1. the core ships three worlds, each keeping the teaching world's
#      contract (a name, requests with a repeat); two broken worlds are
#      refused with the reason named (negative siblings)
#   2. a learner chooses a world without any overlay, and every chapter
#      that reasons over the world keeps all its promises over each of
#      the two new worlds, run for real; a world not shipped is refused
#   3. inside an institution's overlay, the institution's world IS the
#      workplace, whatever the learner chose; and the overlay court now
#      holds an overlay's world to the same contract
#
# Run from this folder: ring worlds_narrated.ring

load "../../stzBase.ring"
load "../_narrated.ring"

t0 = clock()
cProg = "../../education/program"
cOverlays = "../../education/overlays"
oP = StzProgramQ(cProg)
EduWorldsClean()

#---------------------------------------------------------------------------
Scenario("1. Three teaching worlds, one contract")
t1 = clock()
Then("the core ships three worlds", @@(oP.WorldIds()), @@([ "cooperative", "school", "workplace" ]))
acW = oP.WorldIds()
for i = 1 to 3
	Then(acW[i] + " keeps the contract (a name, requests with a repeat)",
		@@(StzEduWorldFindings(cProg + "/worlds/" + acW[i] + ".zknw")), "[ ]")
next
Then("the default world is the restaurant, and it is not a chosen one", oP.HasWorld(), 0)

Given("two worlds that break the contract (negative siblings)")
StzEngineDirCreatePath("t_edu_worlds")
write("t_edu_worlds/no-name.zknw", 'knowledge "workplace"' + char(10) + char(10) + "facts" + char(10) +
	"    r-1 | requested | tea" + char(10) + "    r-2 | requested | tea" + char(10))
aF1 = StzEduWorldFindings("t_edu_worlds/no-name.zknw")
Then("a world with no is-a fact: one finding, naming is-a", len(aF1) = 1 and StzFindFirst("is-a", aF1[1]) > 0, 1)
write("t_edu_worlds/no-repeat.zknw", 'knowledge "workplace"' + char(10) + char(10) + "facts" + char(10) +
	"    shop | is-a | shop" + char(10) + "    r-1 | requested | tea" + char(10) + "    r-2 | requested | rice" + char(10))
aF2 = StzEduWorldFindings("t_edu_worlds/no-repeat.zknw")
Then("a world whose requests never repeat: one finding, naming chapter 1", len(aF2) = 1 and StzFindFirst("chapter 1", aF2[1]) > 0, 1)
EndScenario()
? "  [time] scenario 1: " + ((clock() - t1) / clockspersecond()) + " s"

#---------------------------------------------------------------------------
t2 = clock()
Scenario("2. A learner chooses a world, and every world chapter holds over it")
acNew = [ "cooperative", "school" ]
acName = [ "tillaberi-cooperative (cooperative)", "lycee-de-niamey (school)" ]
acCh = [ "find-then-apply", "a-first-sentence", "one-object-any-structure", "teach-a-world" ]
for i = 1 to 2
	t3 = clock()
	oPW = StzProgramQ(cProg).WithWorldQ(acNew[i])
	Then(acNew[i] + ": chosen", oPW.World(), acNew[i])
	Then(acNew[i] + ": the workplace role now resolves to that file",
		StzRight(oPW.WorldFile("workplace"), StzLen("worlds/" + acNew[i] + ".zknw")), "worlds/" + acNew[i] + ".zknw")
	oCW = oPW.CourseQ("elementary-introduction")
	nKept = 0
	nRan = 0
	for k = 1 to 4
		oCh = oCW.RunChapterQ(acCh[k], "en")
		if oCh.AllPromisesKept()
			nKept++
		ok
		if oCh.AllCellsRan()
			nRan++
		ok
		if k = 1
			Then(acNew[i] + ": chapter 1 prints the world's name", oCh.CellOutput(oCh.WorldDependentCells()[1]) != "" and
				StzFindFirst(acName[i], oCh.CellOutput(oCh.WorldDependentCells()[1])) > 0, 1)
		ok
	next
	Then(acNew[i] + ": all four world chapters ran every cell", nRan, 4)
	Then(acNew[i] + ": ...and kept every promise", nKept, 4)
	? "  [time] " + acNew[i] + ", four chapters: " + ((clock() - t3) / clockspersecond()) + " s"
next

Given("a world that is not shipped (negative sibling)")
bRed = 0
cWhy = ""
try
	StzProgramQ(cProg).WithWorld("mars")
catch
	bRed = 1
	cWhy = cCatchError
done
Then("it is refused, not quietly the default", bRed, 1)
Then("...and the refusal names the worlds that exist", StzFindFirst("cooperative", cWhy) > 0, 1)
EndScenario()
? "  [time] scenario 2: " + ((clock() - t2) / clockspersecond()) + " s"

#---------------------------------------------------------------------------
t4 = clock()
Scenario("3. Inside an institution, the institution's world is the workplace")
oPB = StzProgramQ(cProg).WithOverlayQ(cOverlays + "/bank").WithWorldQ("school")
Then("the learner chose the school", oPB.World(), "school")
Then("...but the bank's world wins the workplace role",
	StzRight(oPB.WorldFile("workplace"), StzLen("bank/worlds/workplace.zknw")), "bank/worlds/workplace.zknw")
oChB = oPB.CourseQ("elementary-introduction").RunChapterQ("find-then-apply", "en")
Then("chapter 1 reasons over the bank", StzFindFirst("sahel-savings", oChB.CellOutput(oChB.WorldDependentCells()[1])) > 0, 1)
Then("the overlay's own worlds are listed beside the core's", @@(oPB.WorldIds()), @@([ "cooperative", "school", "workplace" ]))

Given("an overlay whose world breaks the contract (negative sibling)")
oNew = StzOverlayFromTemplate(cOverlays + "/_template", "t_edu_worlds/flat", [
	[ "{{NAME}}", "flat" ], [ "{{INSTITUTION-SLUG}}", "flat-shop" ], [ "{{WORLD-NAME}}", "flat-shop" ],
	[ "{{WORLD-TYPE}}", "shop" ], [ "{{THING-1}}", "tea" ], [ "{{THING-2}}", "rice" ] ])
Then("from the template it passes the court", @@(oNew.Check(oP)), "[ ]")
write("t_edu_worlds/flat/worlds/workplace.zknw", 'knowledge "workplace"' + char(10) + char(10) + "facts" + char(10) +
	"    flat-shop | is-a | shop" + char(10) + "    r-1 | requested | tea" + char(10) + "    r-2 | requested | rice" + char(10))
aF3 = StzOverlayQ("t_edu_worlds/flat").Check(oP)
Then("with no repeated request the court refuses it, under overlay-world", aF3[1][:rule], "overlay-world")
Then("...and says why", StzFindFirst("repeated", aF3[1][:message]) > 0, 1)
EndScenario()
? "  [time] scenario 3: " + ((clock() - t4) / clockspersecond()) + " s"

EduWorldsClean()
? ""
? "  [time] whole guard: " + ((clock() - t0) / clockspersecond()) + " s"
Summary()

#===========================================================================
func EduWorldsClean()
	StzEduRemoveTree("t_edu_worlds")
