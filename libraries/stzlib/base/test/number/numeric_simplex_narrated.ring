load "../../stzBase.ring"
load "../_narrated.ring"

# Phase 5 of the numeric foundation, second slice: THE LINEAR SOLVER.
#
# The plan says: "Simplex -> engine. stzLinearSolver's 1170 Ring lines become a
# revised dual simplex over resident buffers. Same public surface; the narration and
# tests stay valid."
#
# I DID EXACTLY THAT, AND IT CHANGED NOTHING -- 2.620s became 2.603s on a
# 40-variable model. Then I measured properly instead of assuming, and the real cost
# was somewhere else entirely.
#
#     extractCoefficient x 1200 calls : 2.474s
#     the whole Solve("simplex")      : 2.592s
#
# NINETY-FIVE PERCENT OF THE TIME WAS RE-PARSING STRINGS. `extractCoefficient` is
# called once per (constraint, variable) pair, and each call re-parsed the ENTIRE
# constraint expression from scratch -- lowercase it, rewrite the minus signs, split
# on "+", walk every term -- to pull out ONE coefficient. Parsing a 40-term
# expression once per variable does forty times the necessary work, so the cost grew
# as constraints x variables x terms: cubic in the model, for a parse that is linear.
#
# The fix is to parse each expression ONCE into [ [name, coefficient], ... ] and
# cache it by its own text. All seven call sites keep their exact signatures.
#
#     vars x cons     solve before    solve after
#     10 x 8          0.051s          0.009s
#     20 x 15         0.353s          0.024s
#     30 x 25         1.303s          0.052s
#     40 x 30         2.620s          0.091s      29x
#
# and on the whole Solve() call at 40 variables, 2.592s -> 0.063s, FORTY-ONE times.
#
# SAME SHAPE AS TWO FINDINGS ALREADY IN THIS LIBRARY: the CSV module losing 3.1s per
# 2000 rows to a regex recompiled per cell, and the graph module's O(E^2) rebuild.
# The lesson keeps being the same one -- PROFILE BEFORE OPTIMISING, because the
# expensive line is rarely the one the plan names.

Scenario("the textbook LPs, whose optima every course states")
	# Wyndor Glass: max 3x + 5y s.t. x <= 4 ; 2y <= 12 ; 3x + 2y <= 18
	oW = new stzLinearSolver()
	oW {
		AddVariable("x", 0, 1000)
		AddVariable("y", 0, 1000)
		AddConstraint("1*x", "<=", 4)
		AddConstraint("2*y", "<=", 12)
		AddConstraint("3*x + 2*y", "<=", 18)
		Maximize("3*x + 5*y")
		Solve("simplex")
	}
	Then("x = 2", Rnd6(GetVal(oW, "x")), 2)
	Then("y = 6", Rnd6(GetVal(oW, "y")), 6)
	Then("the objective is 36", Rnd6(oW.ObjectiveValue()), 36)
	Then("and it says so", oW.Status(), "optimal")

	# max 5x + 4y s.t. 6x + 4y <= 24 ; x + 2y <= 6  ->  x = 3, y = 1.5, obj 21
	oS = new stzLinearSolver()
	oS {
		AddVariable("x", 0, 1000)
		AddVariable("y", 0, 1000)
		AddConstraint("6*x + 4*y", "<=", 24)
		AddConstraint("1*x + 2*y", "<=", 6)
		Maximize("5*x + 4*y")
		Solve("simplex")
	}
	Then("a fractional optimum is found exactly", Rnd6(GetVal(oS, "y")), 1.5)
	Then("...and the objective", Rnd6(oS.ObjectiveValue()), 21)

	# a MINIMISATION with >= rows, which exercises the Big-M artificial path
	oM = new stzLinearSolver()
	oM {
		AddVariable("x", 0, 1000)
		AddVariable("y", 0, 1000)
		AddConstraint("1*x + 1*y", ">=", 10)
		AddConstraint("1*x", ">=", 2)
		AddConstraint("1*y", ">=", 3)
		Minimize("2*x + 3*y")
		Solve("simplex")
	}
	Then("minimisation loads the cheaper variable: x = 7", Rnd6(GetVal(oM, "x")), 7)
	Then("...y sits at its floor of 3", Rnd6(GetVal(oM, "y")), 3)
	Then("...for a cost of 23", Rnd6(oM.ObjectiveValue()), 23)
EndScenario()

Scenario("the coefficient parser gives the same answers, cached or not")
	# The cache must not change a single reading. These are the shapes the parser
	# understands: 'k*var', 'var*k', a bare 'var', negatives, and repeated terms.
	o = new stzLinearSolver()
	o.AddVariable("alpha", 0, 100)
	o.AddVariable("beta", 0, 100)

	Then("k*var", o.extractCoefficient("3*alpha + 2*beta", "alpha"), 3)
	Then("...the other one", o.extractCoefficient("3*alpha + 2*beta", "beta"), 2)
	Then("var*k reads the same", o.extractCoefficient("alpha*4", "alpha"), 4)
	Then("a bare variable is 1", o.extractCoefficient("alpha + 5*beta", "alpha"), 1)
	Then("a negative term keeps its sign",
	     o.extractCoefficient("5*alpha - 2*beta", "beta"), -2)
	Then("a fractional coefficient survives -- the R4 repair this parser exists for",
	     o.extractCoefficient("0.6*alpha", "alpha"), 0.6)
	Then("a variable that is absent is 0",
	     o.extractCoefficient("3*alpha", "beta"), 0)
	Then("repeated terms ACCUMULATE",
	     o.extractCoefficient("2*alpha + 3*alpha", "alpha"), 5)

	# EXACT TOKEN MATCHING: 'rd' must never match inside 'yard'. That was a real
	# defect once, and the cache must not reintroduce it.
	o2 = new stzLinearSolver()
	o2.AddVariable("rd", 0, 100)
	o2.AddVariable("yard", 0, 100)
	Then("a short name does not match inside a longer one",
	     o2.extractCoefficient("7*yard", "rd"), 0)
	Then("...and the longer one reads correctly",
	     o2.extractCoefficient("7*yard", "yard"), 7)

	# asking the SAME expression twice must give the same answer -- the second time
	# comes from the cache
	Then("a second reading of a cached expression agrees",
	     o.extractCoefficient("3*alpha + 2*beta", "alpha"),
	     o.extractCoefficient("3*alpha + 2*beta", "alpha"))
EndScenario()

Scenario("the model is solved, not merely returned")
	# A solution is only worth having if it satisfies the constraints. Checked here
	# rather than trusted, on a model with several interacting limits.
	aA = [ [15, 10, 5], [3, 2, 1], [1, 1, 0] ]
	aRhs = [ 2000, 400, 250 ]
	o = new stzLinearSolver()
	o {
		AddVariable("pizza", 0, 200)
		AddVariable("pasta", 0, 150)
		AddVariable("salad", 0, 100)
		AddConstraint("15*pizza + 10*pasta + 5*salad", "<=", 2000)
		AddConstraint("3*pizza + 2*pasta + 1*salad", "<=", 400)
		AddConstraint("pizza + pasta", "<=", 250)
		Maximize("12*pizza + 8*pasta + 6*salad")
		Solve("simplex")
	}
	nP = GetVal(o, "pizza")
	nT = GetVal(o, "pasta")
	nS = GetVal(o, "salad")

	Then("every variable is within its declared bounds",
	     nP >= 0 and nP <= 200 and nT >= 0 and nT <= 150 and nS >= 0 and nS <= 100, TRUE)
	Then("the preparation-time constraint holds",
	     15*nP + 10*nT + 5*nS <= 2000.000001, TRUE)
	Then("...the chef-time constraint", 3*nP + 2*nT + 1*nS <= 400.000001, TRUE)
	Then("...and the oven constraint", nP + nT <= 250.000001, TRUE)
	Then("the reported objective matches the solution it reports",
	     Rnd4(o.ObjectiveValue()), Rnd4(12*nP + 8*nT + 6*nS))
EndScenario()

Scenario("the speed this slice was actually about")
	# 40 variables and 30 constraints took 2.6 SECONDS before, and the plan's
	# proposed fix -- moving the pivot loop to the engine -- accounted for 0.017s of
	# it. Parsing once instead of once per variable accounted for the rest.
	nV = 40
	nC = 30
	o = new stzLinearSolver()
	for j = 1 to nV
		o.AddVariable("x" + j, 0, 100)
	next
	for i = 1 to nC
		cExpr = ""
		for j = 1 to nV
			if j > 1
				cExpr += " + "
			ok
			cExpr += ("" + (((i * j) % 7) + 1) + "*x" + j)
		next
		o.AddConstraint(cExpr, "<=", 100 * nV)
	next
	cObj = ""
	for j = 1 to nV
		if j > 1
			cObj += " + "
		ok
		cObj += ("" + (((j * 3) % 5) + 1) + "*x" + j)
	next
	o.Maximize(cObj)

	nT0 = clock()
	o.Solve("simplex")
	nT1 = clock()
	nElapsed = (nT1 - nT0) / clockspersecond()

	Then("a 40x30 model now solves in well under half a second", nElapsed < 0.5, TRUE)
	Then("...and it is optimal, not merely fast", o.Status(), "optimal")
	# if this ever fails, look for a re-parse before looking at the pivoting.
EndScenario()

Summary()

func GetVal(o, cName)
	aSol = o.Solution()
	nLen = len(aSol)
	for i = 1 to nLen
		if aSol[i][1] = cName
			return aSol[i][2]
		ok
	next
	return 0

func Rnd4(n)
	return ceil(n * 10000 - 0.5) / 10000
func Rnd6(n)
	return ceil(n * 1000000 - 0.5) / 1000000
