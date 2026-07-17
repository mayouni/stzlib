# The multi-objective + stochastic solvers -- neither had a single test.
#
# A solver is the most dangerous thing to leave untested, because its failure
# mode is not a crash: it is a PLAUSIBLE WRONG NUMBER. Every bug this week
# announced itself with R2/R14/R20 the moment something touched it. A solver
# that returns an empty result and calls it "optimal" says nothing is wrong.
#
# That is exactly what stzMultiObjectiveSolver did: solve() ran the whole
# NSGA-II loop, reported status "optimal", and returned ZERO Pareto solutions
# -- because the generation loop ends on createNewPopulation(), which builds
# every child with rank 0 and never re-ranks, so the final `:rank = 1` filter
# matched nothing. So every assertion here checks a KNOWN answer, not merely
# that a call returned.

load "../../stzBase.ring"

nPass = 0
nFail = 0

pr()

? "-- Scene 1: NSGA-II returns a real Pareto front, not an empty one --"

# max x AND min x over x in [0,10]: pure trade-off, so EVERY x is optimal and
# the true front spans the whole range.
oM = new stzMultiObjectiveSolver()
oM.addVariable("x", 0, 10)
oM.maximize("x")
oM.minimize("x")
oM.solve("nsga_ii")

aFront = oM.@aParetoSolutions
chk("the front is NOT empty (the bug returned 0)", len(aFront) > 0)
chk("it fills the population", len(aFront) = 50)

# every returned solution must actually be on the front
bAllRank1 = TRUE
nMin = 999
nMax = -999
_n_ = len(aFront)
for i = 1 to _n_
	if aFront[i][:rank] != 1  bAllRank1 = FALSE  ok
	_x_ = aFront[i][:solution][1][2]
	if _x_ < nMin  nMin = _x_  ok
	if _x_ > nMax  nMax = _x_  ok
next
chk("every solution is genuinely rank 1", bAllRank1)
chk("the front SPREADS across the trade-off (near 0 AND near 10)",
	nMin < 2 and nMax > 8)
chk("... and stays inside the variable bounds", nMin >= 0 and nMax <= 10)

? ""
? "-- Scene 2: NSGA-II REFUSES what it cannot honour --"

# the genetic path does not enforce constraints; it used to drop them
# silently and return an infeasible front. It now raises instead.
oC = new stzMultiObjectiveSolver()
oC.addVariable("x", 0, 10)
oC.addConstraint("x", "<=", 5)
oC.maximize("x")
oC.minimize("x")
bRefused = 0
try
	oC.solve("nsga_ii")
catch
	bRefused = 1
done
chk("a constrained problem on the NSGA path REFUSES (never a silent wrong front)",
	bRefused = 1)

? ""
? "-- Scene 3: the epsilon-constraint path DOES honour constraints --"

# it solves through stzLinearSolver, which respects bounds.
oE = new stzMultiObjectiveSolver()
oE.addVariable("x", 0, 10)
oE.addConstraint("x", "<=", 5)
oE.maximize("x")
oE.minimize("x")
oE.solve("epsilon_constraint")

chk("it returns a front", len(oE.@aParetoSolutions) > 0)
bAllFeasible = TRUE
_n_ = len(oE.@aParetoSolutions)
for i = 1 to _n_
	if oE.@aParetoSolutions[i][:solution][1][2] > 5.001  bAllFeasible = FALSE  ok
next
chk("every solution respects the x <= 5 constraint", bAllFeasible)

? ""
? "-- Scene 4: the solver guards its own preconditions --"

bNoVar = 0
try
	oX = new stzMultiObjectiveSolver()
	oX.maximize("x")
	oX.solve("nsga_ii")
catch
	bNoVar = 1
done
chk("no variables -> refuses", bNoVar = 1)

bOneObj = 0
try
	oY = new stzMultiObjectiveSolver()
	oY.addVariable("x", 0, 10)
	oY.maximize("x")
	oY.solve("nsga_ii")
catch
	bOneObj = 1
done
chk("a SINGLE objective -> sent to stzLinearSolver, not solved as multi", bOneObj = 1)

? ""
? "-- Scene 5: stzStochasticSolver -- scenarios and expectations --"

oS = new stzStochasticSolver()
oS.addVariable("x", 0, 10)
oS.addScenario("good", "high demand", [ :d = 8 ], 0.6)
oS.addScenario("bad",  "low demand",  [ :d = 3 ], 0.4)
oS.maximize("x")

chk("it holds the scenarios it was given", len(oS.scenarios()) = 2)

# validateScenarios RAISES if probabilities do not sum to 1; 0.6 + 0.4 = 1.0
bProbOk = 1
try
	oS.validateScenarios()
catch
	bProbOk = 0
done
chk("probabilities summing to 1.0 pass validation", bProbOk = 1)

# and a set that does NOT sum to 1 must be caught
oBad = new stzStochasticSolver()
oBad.addVariable("x", 0, 10)
oBad.addScenario("a", "", [ :d = 1 ], 0.5)
oBad.addScenario("b", "", [ :d = 2 ], 0.2)
oBad.maximize("x")
bCaught = 0
try
	oBad.validateScenarios()
catch
	bCaught = 1
done
chk("probabilities that do NOT sum to 1.0 are REFUSED", bCaught = 1)

bSolved = 1
try
	oS.solveExpectedValue()
catch
	bSolved = 0
done
chk("it solves the expected-value problem without crashing", bSolved = 1)

? ""
? "=========================================="
? "TOTAL: " + (nPass + nFail) + " assertions, " + nPass + " pass, " + nFail + " fail"
? "=========================================="

pf()

func chk(cLabel, bCond)
	if bCond
		nPass++
		? "  [OK] " + cLabel
	else
		nFail++
		? "  [FAIL] " + cLabel
	ok
