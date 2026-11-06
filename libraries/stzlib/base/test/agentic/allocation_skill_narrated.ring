# A RESOURCE-ALLOCATION SKILL -- R5's OPTIMIZATION leg, rung 2, narrated
#
# The capstone's maitre-d seated tables with an if/but chain: first
# match wins, nothing is optimized. stzAllocationSkill is a stzAgentSkill
# whose does: builds a stzOptimModel from the agent's memory, solves it,
# and writes the allocation back -- governed, verified, and through the
# safe world when the agent holds a workbench.
#
#   Scene 1  the skill solves the memory and writes facts, verified
#   Scene 2  it is GOVERNED: refused without permission, run with it,
#            and it reaches a fixpoint instead of firing forever
#   Scene 3  an INFEASIBLE allocation is a fact another skill acts on
#   Scene 4  the safe world: the plan file lands in the workbench, the
#            disk does not move
#   Scene 5  a party streams in: the next cycle seats it, and nobody
#            already seated is moved
#
# Deterministic, offline, seconds. THE HELPERS LIVE AFTER pf().

load "../../stzBase.ring"

$nPass = 0
$nFail = 0
$nSec = clock()

cFx = StzReplace(WorkingDirectory(), "\", "/") + "/_allocskill-fixture"
if StzDirExists(cFx)
	StzDirDeleteAll(cFx)
ok
StzDirCreatePath(cFx)

pr()

#=====================================================================#
? "-- Scene 1: the skill solves the memory and writes the answer --"
#=====================================================================#
# Three tables (2, 4, 8 seats), four parties (2, 4, 5, 3), one party per
# table, most covers: p3 -> t3, p2 -> t2, p1 -> t1, p4 waits. The first-
# match chain would have put p1 (the first party) at the first table
# that fits and lost covers; the model cannot.

oSk = new stzAllocationSkill("seat", Seating())
oMem = new stzAgentMemory("maitre-d")
Hall(oMem)
aR = oSk.Apply(oMem)

chk("the skill ran and VERIFIED", aR[:ran] = 1 and aR[:verified] = 1)
chk("...p3 is seated at t3, the only table that fits", oMem.Fact("p3", "seated-at", "t3") = 1)
chk("...p2 at t2, p1 at t1", oMem.Fact("p2", "seated-at", "t2") = 1 and
	oMem.Fact("p1", "seated-at", "t1") = 1)
chk("...p4 is recorded as waiting", oMem.Fact("p4", "seated-at", "waiting") = 1)
chk("...the verdict is a fact in memory", oMem.Fact("seating", "verdict", "allocated") = 1)
chk("...and the why names the engine that decided",
	StzFindFirst("engine floor (Zig simplex", aR[:why]) > 0)
chk("solved once, the precondition no longer holds", oSk.PreconditionHolds(oMem) = 0)

sec("scene 1")

#=====================================================================#
? "-- Scene 2: governed, and it reaches a fixpoint --"
#=====================================================================#
# The skill is added with AddGovernedSkill, so stzPIAgent.Cycle() asks
# MayProceed before it runs -- the gate is the one every skill passes.

oAg = new stzPIAgent("maitre-d")
Hall(oAg.MemoryQ())
oAg.AddGovernedSkill(new stzAllocationSkill("seat", Seating()), "seat-table")
oAg.Cycle()
chk("without a declared risk and a grant, the gate refuses it",
	oAg.Trace()[1][:decision] = "refused" and oAg.MemoryQ().Fact("p3", "seated-at", "t3") = 0)

oAg = new stzPIAgent("maitre-d")
Hall(oAg.MemoryQ())
oAg.GovernanceQ().DeclareRisk("seat-table", 1)
oAg.GovernanceQ().GrantPermission("maitre-d", "seat-table")
oAg.GovernanceQ().SetAuthority("maitre-d", :Delegated)
oAg.AddGovernedSkill(new stzAllocationSkill("seat", Seating()), "seat-table")
nActed = oAg.Pursue()

chk("granted, the agent allocates", oAg.MemoryQ().Fact("p3", "seated-at", "t3") = 1)
chk("...exactly once: the fixpoint, not twenty rounds", nActed = 1)
chk("...the decision is in the governed lineage", len(oAg.DecisionLog()) = 1)
chk("...and the trace carries the engine's name",
	StzFindFirst("engine floor", oAg.DecisionLog()[1][:why]) > 0)

sec("scene 2")

#=====================================================================#
? "-- Scene 3: an infeasible allocation is a fact to act on --"
#=====================================================================#
# Every party MUST be seated tonight, one per table: four parties,
# three tables -- infeasible. The seat skill does not crash and does
# not seat three and pretend: it records the verdict. A second skill
# reacts to that FACT -- it opens the terrace table and re-arms the
# allocation -- and the next cycle seats everyone.

oAg = new stzPIAgent("maitre-d")
Hall(oAg.MemoryQ())
oAg.AddSkill(new stzAllocationSkill("seat", Seating().PlaceEvery()))
oTerrace = new stzAgentSkill("open-terrace")
oTerrace.SetWhen(func oM { return oM.Fact("seating", "verdict", "infeasible") })
oTerrace.SetDoes(func oM {
	oM.Learn("terrace", "is-a", "table")
	oM.Learn("terrace", "seats", "4")
	StzAllocationReopen(oM, "seating")
	return 1
})
oTerrace.SetVerifiedBy(func oM { return oM.Fact("terrace", "is-a", "table") })
oAg.AddSkill(oTerrace)

oAg.Cycle()
chk("first cycle: the seat skill ran and could not allocate",
	oAg.Trace()[1][:decision] = "ran" and oAg.Trace()[1][:verified] = 0)
chk("...its why says INFEASIBLE and names the engine",
	StzFindFirst("INFEASIBLE", oAg.Trace()[1][:why]) > 0 and
	StzFindFirst("engine floor", oAg.Trace()[1][:why]) > 0)
chk("...nobody was half-seated", oAg.MemoryQ().Fact("p3", "seated-at", "t3") = 0)
chk("...the terrace skill acted on the verdict in the same cycle",
	oAg.MemoryQ().Fact("terrace", "is-a", "table") = 1)

oAg.Pursue()
# p2 and p4 may trade t2 and the terrace (both 4 seats, same covers), so
# the check is that every party holds a real seat, not which one
chk("the next cycle seats every party",
	oAg.MemoryQ().Fact("seating", "verdict", "allocated") = 1 and
	AllSeated(oAg.MemoryQ(), [ "p1", "p2", "p3", "p4" ]))

sec("scene 3")

#=====================================================================#
? "-- Scene 4: the safe world --"
#=====================================================================#
# The skill files a seating plan. Inside a workbench-holding agent's
# cycle the write lands in the twin and the disk does not move: the
# tick's only export toward reality is the update plan. Outside one,
# the same skill writes the disk -- the door stzAgentRoster uses.

cPlan = cFx + "/seating.txt"
oAg = new stzPIAgent("maitre-d")
Hall(oAg.MemoryQ())
oAg.GiveWorkbench()
oAg.AddSkill(new stzAllocationSkill("seat", Seating()).FileTo(cPlan))
oAg.Pursue()

chk("the agent allocated", oAg.MemoryQ().Fact("p3", "seated-at", "t3") = 1)
chk("...the plan file is NOT on disk", StzFileExists(cPlan) = 0)
chk("...it is in the workbench, rehearsed",
	StzFindFirst("p3 seated-at t3", oAg.WorkbenchQ().ContentOf(cPlan)) > 0)
chk("...one rehearsed operation, exported only as a plan",
	oAg.WorkbenchQ().NumberOfOperations() = 1)

oMem = new stzAgentMemory("maitre-d")
Hall(oMem)
new stzAllocationSkill("seat", Seating()).FileTo(cPlan).Apply(oMem)
chk("outside a workbench the same skill writes the disk", StzFileExists(cPlan) = 1)

sec("scene 4")

#=====================================================================#
? "-- Scene 5: a party streams in --"
#=====================================================================#
# After the first allocation, a party of 2 arrives and a 2-seat table
# frees up. The new demand alone re-arms the skill; the next cycle seats
# it and keeps everyone already seated where they are.

oAg = new stzPIAgent("maitre-d")
Hall(oAg.MemoryQ())
oAg.AddSkill(new stzAllocationSkill("seat", Seating()))
oAg.Pursue()
oAg.MemoryQ().Learn("p5", "is-a", "party").Learn("p5", "size", "2")
oAg.MemoryQ().Learn("t5", "is-a", "table").Learn("t5", "seats", "2")
nActed = oAg.Pursue()

chk("the new party is seated", oAg.MemoryQ().Fact("p5", "seated-at", "t5") = 1)
chk("...in one more firing", nActed = 1)
chk("...nobody seated before was moved",
	oAg.MemoryQ().Fact("p3", "seated-at", "t3") = 1 and
	oAg.MemoryQ().Fact("p2", "seated-at", "t2") = 1 and
	oAg.MemoryQ().Fact("p1", "seated-at", "t1") = 1)

sec("scene 5")

StzDirDeleteAll(cFx)

? ""
? "=========================================="
? "TOTAL: " + ($nPass + $nFail) + " assertions, " + $nPass + " pass, " + $nFail + " fail"
? "=========================================="

pfq()
shutdown($nFail)

func Seating()
	oA = new stzAllocation("seating")
	oA.Assign("party").To("table").SizedBy("size").Within("seats").OnePerResource()
	oA.WriteAs("seated-at").UnplacedAs("waiting")
	return oA

func Hall(oM)
	oM.Learn("t1", "is-a", "table").Learn("t1", "seats", "2")
	oM.Learn("t2", "is-a", "table").Learn("t2", "seats", "4")
	oM.Learn("t3", "is-a", "table").Learn("t3", "seats", "8")
	oM.Learn("p1", "is-a", "party").Learn("p1", "size", "2")
	oM.Learn("p2", "is-a", "party").Learn("p2", "size", "4")
	oM.Learn("p3", "is-a", "party").Learn("p3", "size", "5")
	oM.Learn("p4", "is-a", "party").Learn("p4", "size", "3")

func AllSeated(oM, acParties)
	n = len(acParties)
	for i = 1 to n
		acAt = oM.Recall(acParties[i], "seated-at")
		if len(acAt) != 1
			return 0
		ok
		if acAt[1] = "waiting"
			return 0
		ok
	next
	return 1

func chk(cWhat, bCond)
	if bCond = 1
		$nPass++
		? "  [OK] " + cWhat
	else
		$nFail++
		? "  [FAIL] " + cWhat
	ok

func sec(cName)
	? "    ~ " + cName + ": " + ((clock() - $nSec) / clockspersecond()) + "s"
	? ""
	$nSec = clock()
