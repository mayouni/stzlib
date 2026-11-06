# THE SUB-SOLVER SEAM -- R5's OPTIMIZATION leg, rung 1, narrated
#
# SOFTANZA_INTELLIGENCE_ARCHITECTURE.md section 6, R5: "OPTIMIZATION =
# stzOptimModel (R4 step 5) called by the planner as a sub-solver for
# resource-allocation skills". The planner searches ROUTES; the
# optimizer allocates QUANTITIES. stzAllocation is the seam between
# them: it reads an allocation FROM the knowledge, builds the
# stzOptimModel, solves it, and answers with a verdict whose Why()
# names the engine that ran.
#
#   Scene 1  an allocation built from facts, with no per-domain code
#   Scene 2  entity names the expression compiler would refuse
#   Scene 3  one per resource, or shared capacity: two answers
#   Scene 4  INFEASIBLE IS AN ANSWER -- and the model's own
#            IsFeasibleAnswer() cannot see it (measured, 2026-11-01)
#   Scene 5  incomplete knowledge: no solver runs, and it says so
#   Scene 6  the effect: written as facts, kept on the next solve
#   Scene 7  the choose shape: quantities under a budget
#   Scene 8  the planner hands off at an allocation step, and only there
#
# PER PX: one process, seconds, per-section wall time; nothing is
# skipped. THE HELPERS LIVE AFTER pf().

load "../../stzBase.ring"

$nPass = 0
$nFail = 0
nT0 = clock()
$nSec = clock()

pr()

#=====================================================================#
? "-- Scene 1: an allocation built from facts --"
#=====================================================================#
# The declaration names a SHAPE and the PROPERTIES the knowledge
# already holds; every number comes from a triple. One party per
# table, most covers: p3 (5) can only sit at t3, p2 (4) beats p4 (3)
# for t2, p1 takes t1 -- 11 covers, p4 waits. Checkable by hand.

oK = Hall()
oA = new stzAllocation("seating")
oA.Assign("party").To("table").SizedBy("size").Within("seats").OnePerResource()
oA.SolveOn(oK)

chk("the verdict is allocated", oA.Verdict() = "allocated")
chk("...11 covers, the hand-computed optimum", oA.Objective() = 11)
chk("...p3 at t3, p2 at t2, p1 at t1",
	Has(oA.Placements(), [ "p3", "t3" ]) and Has(oA.Placements(), [ "p2", "t2" ]) and
	Has(oA.Placements(), [ "p1", "t1" ]))
chk("...and p4 is left waiting", Same(oA.Unplaced(), [ "p4" ]))
chk("the model was built from the facts: 4 parties x 3 tables = 12 variables",
	oA.NumberOfVars() = 12 and oA.Model().NumberOfVars() = 12)
chk("Why() survives the seam: it names the engine that ran",
	StzFindFirst("engine floor (Zig simplex", oA.Why()) > 0)
chk("...and the model's answer checks itself", oA.Model().IsFeasibleAnswer() = 1)

sec("scene 1")

#=====================================================================#
? "-- Scene 2: entity names that are not variable names --"
#=====================================================================#
# Measured: the expression compiler refuses "a-b" and "p1.t1" -- and
# knowledge is full of hyphens. The variables are synthetic and the map
# back is the seam's job, so the caller never sanitises a name.

oK2 = new stzKnowledgeGraph("terrace")
oK2.Know("big-table", "table").KnowRelation("big-table", "seats", "6")
oK2.Know("the-smiths", "party").KnowRelation("the-smiths", "size", "5")
oA2 = new stzAllocation("terrace-seating")
oA2.Assign("party").To("table").SizedBy("size").Within("seats")
oA2.SolveOn(oK2)

chk("hyphenated entities are allocated", Same(oA2.Placements(), [ [ "the-smiths", "big-table" ] ]))
chk("...through a synthetic variable", Same(oA2.Model().VarNames(), [ "a1_1" ]))

sec("scene 2")

#=====================================================================#
? "-- Scene 3: one per resource, or shared capacity --"
#=====================================================================#
# Without OnePerResource a table is a capacity, not a slot: t3's 8
# seats take p3 (5) AND p4 (3), and all 14 covers sit. Same facts, a
# different declaration, a different and still hand-checkable answer.

oK = Hall()
oA = new stzAllocation("seating")
oA.Assign("party").To("table").SizedBy("size").Within("seats")
oA.SolveOn(oK)

chk("shared capacity seats all 14 covers", oA.Objective() = 14)
chk("...nobody waits", len(oA.Unplaced()) = 0)
chk("...t3 holds p3 and p4", Has(oA.Placements(), [ "p3", "t3" ]) and
	Has(oA.Placements(), [ "p4", "t3" ]))

sec("scene 3")

#=====================================================================#
? "-- Scene 4: INFEASIBLE IS AN ANSWER --"
#=====================================================================#
# Four parties, three tables, one party per table, and every party
# must be placed: impossible. The verdict says so, the solver that
# found it is named -- and the model's own IsFeasibleAnswer() still
# answers 1, because it re-checks a POINT and there is none. That is
# why the verdict reads the solver status and never the violations.

oK = Hall()
oA = new stzAllocation("seating")
oA.Assign("party").To("table").SizedBy("size").Within("seats").OnePerResource().PlaceEvery()
oA.SolveOn(oK)

chk("the verdict is infeasible, not a crash", oA.Verdict() = "infeasible")
chk("...nothing is offered as placed", len(oA.Placements()) = 0)
chk("...Why() names the engine that found it",
	StzFindFirst("INFEASIBLE", oA.Why()) > 0 and
	StzFindFirst("engine floor", oA.Why()) > 0)
chk("...the model status is infeasible", oA.Model().StatusWord() = "infeasible")
chk("THE TRAP, pinned: IsFeasibleAnswer() is 1 on an infeasible model",
	oA.Model().IsFeasibleAnswer() = 1 and len(oA.Model().Violations()) = 0)
chk("an infeasible allocation writes nothing", oA.WriteAs("seated-at").WriteTo(oK) = 0)

sec("scene 4")

#=====================================================================#
? "-- Scene 5: incomplete knowledge --"
#=====================================================================#
# A party with no size is a gap in the knowledge, not a zero. No solver
# runs on a guess; the verdict names the missing fact.

oK = Hall()
oK.Know("p5", "party")
oK.KnowRelation("t2", "seats", "four")
oA = new stzAllocation("seating")
oA.Assign("party").To("table").SizedBy("size").Within("seats")
oA.SolveOn(oK)

chk("the verdict is incomplete", oA.Verdict() = "incomplete")
chk("...the missing size is named", Has(oA.Missing(), "p5 has no size"))
chk("...the first value read for t2 is still the number", len(oA.Missing()) = 1)
chk("...Why() says no solver ran", StzFindFirst("did not run the solver", oA.Why()) > 0)

oK3 = new stzKnowledgeGraph("odd")
oK3.Know("t9", "table").KnowRelation("t9", "seats", "four")
oK3.Know("p9", "party").KnowRelation("p9", "size", "2")
oA3 = new stzAllocation("odd")
oA3.Assign("party").To("table").SizedBy("size").Within("seats")
oA3.SolveOn(oK3)
chk("a value that is not a number is a gap too",
	Same(oA3.Missing(), [ "t9's seats is not a number ('four')" ]))

sec("scene 5")

#=====================================================================#
? "-- Scene 6: the effect, and the next solve keeps it --"
#=====================================================================#
# WriteTo is the effect: each placement becomes a fact. A party that
# already has a place keeps it on the next solve and uses up that
# capacity -- guests are not moved to make room for a new arrival.

oK = Hall()
oA = new stzAllocation("seating")
oA.Assign("party").To("table").SizedBy("size").Within("seats").OnePerResource()
oA.WriteAs("seated-at").UnplacedAs("waiting")
oA.SolveOn(oK)
nW = oA.WriteTo(oK)

chk("four facts written: three placements and one wait", nW = 4)
chk("...p3 seated-at t3 is now knowledge", Same(oK.Query([ "p3", "seated-at", "?t" ]), [ "t3" ]))
chk("...p4 is recorded as waiting", Same(oK.Query([ "p4", "seated-at", "?t" ]), [ "waiting" ]))

oK.Know("t4", "table").KnowRelation("t4", "seats", "3")
oA.SolveOn(oK)
chk("a table frees up: the next solve keeps the three seated",
	len(oA.Kept()) = 3)
chk("...and seats only the waiting party", Same(oA.Placements(), [ [ "p4", "t4" ] ]))
oA.WriteTo(oK)
chk("...whose wait is replaced, not added to",
	Same(oK.Query([ "p4", "seated-at", "?t" ]), [ "t4" ]))

sec("scene 6")

#=====================================================================#
? "-- Scene 7: the choose shape --"
#=====================================================================#
# A workshop picks how many chairs and stools to make: margin 30 and 25,
# 2 and 1 machine hours each, 10 hours available, at most 4 chairs and
# 5 stools wanted. The relaxation would say 2.5 chairs; the integer
# optimum is 3 chairs and 4 stools = 190. Checkable by enumeration.

oK = new stzKnowledgeGraph("workshop")
oK.Know("chair", "product").KnowRelation("chair", "margin", "30").
	KnowRelation("chair", "hours", "2").KnowRelation("chair", "wanted", "4")
oK.Know("stool", "product").KnowRelation("stool", "margin", "25").
	KnowRelation("stool", "hours", "1").KnowRelation("stool", "wanted", "5")
oK.KnowRelation("shop", "hours", "10")

oA = new stzAllocation("production")
oA.Choose("product").Maximize("margin").AtMost("wanted").Spending("hours", "shop", "hours")
oA.WriteAs("make").CountedIn("units")
oA.SolveOn(oK)

chk("the verdict is allocated", oA.Verdict() = "allocated")
chk("...3 chairs and 4 stools, margin 190",
	Same(oA.Placements(), [ [ "chair", 3 ], [ "stool", 4 ] ]) and oA.Objective() = 190)
chk("...the budget is named in the model", oA.Model().ConstraintAt(1)[1] = "budget:shop.hours")
oA.WriteTo(oK)
chk("...written as quantities WITH their unit", Same(oK.Query([ "chair", "make", "?n" ]), [ "3-units" ]))

# WHY THE UNIT, pinned: stzGraph stores one edge per node pair and a
# number is a node, so a subject cannot hold two properties of the same
# value. A bare "2" here would collide with the bench's own wanted 2.
oT = new stzKnowledgeGraph("trap")
oT.KnowRelation("x", "a", "5")
bRaised = 0
try
	oT.KnowRelation("x", "b", "5")
catch
	bRaised = 1
done
chk("THE TRAP, pinned: a second property with the same value is refused", bRaised = 1)

oK.Know("bench", "garden-item").KnowRelation("bench", "margin", "10").
	KnowRelation("bench", "hours", "1").KnowRelation("bench", "wanted", "2")
oK.KnowRelation("yard", "hours", "5")
oB = new stzAllocation("benches")
oB.Choose("garden-item").Maximize("margin").AtMost("wanted").Spending("hours", "yard", "hours")
oB.WriteAs("built")
oB.SolveOn(oK)
oB.WriteTo(oK)
chk("...so a quantity equal to another property still writes: 2 benches beside wanted 2",
	Same(oK.Query([ "bench", "built", "?n" ]), [ "2-built" ]) and
	Same(oK.Query([ "bench", "wanted", "?n" ]), [ "2" ]))

sec("scene 7")

#=====================================================================#
? "-- Scene 8: the planner hands off, and only at an allocation step --"
#=====================================================================#
# A service plan: open -> seat -> serve, or open -> walk-ins -> serve.
# Only the edge open->seat carries :allocate = "seating". The cheapest
# route goes through it, so Execute hands that ONE step to the
# sub-solver; the other steps are route choices and hand nothing off.

oPlan = new stzGraph("service")
oPlan.AddNodeXTT("open", "Open", [ :x = 0 ])
oPlan.AddNodeXTT("seat", "Seat", [ :x = 1 ])
oPlan.AddNodeXTT("walkins", "Walk-ins", [ :x = 1 ])
oPlan.AddNodeXTT("serve", "Serve", [ :x = 2 ])
oPlan.AddEdgeXTT("open", "seat", "seat parties", [ :cost = 1, :allocate = "seating" ])
oPlan.AddEdgeXTT("seat", "serve", "serve", [ :cost = 1 ])
oPlan.AddEdgeXTT("open", "walkins", "take walk-ins", [ :cost = 5 ])
oPlan.AddEdgeXTT("walkins", "serve", "serve", [ :cost = 1 ])

oSeating = new stzAllocation("seating")
oSeating.Assign("party").To("table").SizedBy("size").Within("seats").OnePerResource()

oP = new stzGraphPlanner(oPlan)
oP.UseKnowledge(Hall())
oP.AddAllocation(oSeating)
oP.AddPlan("saturday")
oP.Walk("open", "serve")
oP.Minimize("cost")
oP.Execute()

aRows = oP.Allocations()
chk("the route goes through the allocation step", Same(oP.Route(), [ "open", "seat", "serve" ]))
chk("...ONE step of two handed off", len(aRows) = 1 and len(oP.Actions()) = 2)
chk("...it is the open -> seat step", aRows[1][:step] = "open -> seat")
chk("...the sub-solver allocated it: 11 covers' worth of placements",
	aRows[1][:verdict] = "allocated" and len(aRows[1][:placements]) = 3)
chk("...and the row's why names the engine", StzFindFirst("engine floor", aRows[1][:why]) > 0)
chk("every allocation step holds", oP.AllocationsHold() = 1)

oP2 = new stzGraphPlanner(oPlan)
oP2.UseKnowledge(Hall())
oP2.AddPlan("no-allocation")
oP2.Walk("walkins", "serve")
oP2.Minimize("cost")
oP2.Execute()
chk("a route with no allocation step hands nothing off", len(oP2.Allocations()) = 0)

oP3 = new stzGraphPlanner(oPlan)
oP3.UseKnowledge(Hall())
oP3.AddPlan("unstaffed")
oP3.Walk("open", "serve")
oP3.Minimize("cost")
oP3.Execute()
chk("an allocation step with no sub-solver says so, it does not guess",
	oP3.Allocations()[1][:verdict] = "unregistered")
chk("...and the plan does not hold", oP3.AllocationsHold() = 0)

oStrict = new stzAllocation("seating")
oStrict.Assign("party").To("table").SizedBy("size").Within("seats").OnePerResource().PlaceEvery()
oP4 = new stzGraphPlanner(oPlan)
oP4.UseKnowledge(Hall())
oP4.AddAllocation(oStrict)
oP4.AddPlan("everyone")
oP4.Walk("open", "serve")
oP4.Minimize("cost")
oP4.Execute()
chk("an infeasible step is reported, and the route still stands",
	oP4.Allocations()[1][:verdict] = "infeasible" and Same(oP4.Route(), [ "open", "seat", "serve" ]))

sec("scene 8")

? ""
? "=========================================="
? "TOTAL: " + ($nPass + $nFail) + " assertions, " + $nPass + " pass, " + $nFail + " fail"
? "=========================================="

pfq()
shutdown($nFail)

# the hall every scene starts from: three tables, four parties
func Hall()
	oK = new stzKnowledgeGraph("hall")
	oK.Know("t1", "table").KnowRelation("t1", "seats", "2")
	oK.Know("t2", "table").KnowRelation("t2", "seats", "4")
	oK.Know("t3", "table").KnowRelation("t3", "seats", "8")
	oK.Know("p1", "party").KnowRelation("p1", "size", "2")
	oK.Know("p2", "party").KnowRelation("p2", "size", "4")
	oK.Know("p3", "party").KnowRelation("p3", "size", "5")
	oK.Know("p4", "party").KnowRelation("p4", "size", "3")
	return oK

func chk(cWhat, bCond)
	if bCond = 1
		$nPass++
		? "  [OK] " + cWhat
	else
		$nFail++
		? "  [FAIL] " + cWhat
	ok

func Has(aList, xItem)
	n = len(aList)
	for i = 1 to n
		if Same(aList[i], xItem)
			return 1
		ok
	next
	return 0

func Same(a, b)
	if isList(a) and isList(b)
		return @@(a) = @@(b)
	ok
	if isList(a) or isList(b)
		return 0
	ok
	return a = b

func sec(cName)
	? "    ~ " + cName + ": " + ((clock() - $nSec) / clockspersecond()) + "s"
	? ""
	$nSec = clock()
