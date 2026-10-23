load "../../stzBase.ring"
load "../_narrated.ring"

# stzLinearSolver -- the three register rows (solveWithBranchAndBound, CalculateFitness, CalculatePenalty)
# and what the class's own sweep found around them.
#
#  * CalculatePenalty read a variable that does not exist ahead of the correct line, so it raised as soon
#    as the problem had one constraint; CalculateFitness and the genetic solver died with it. The numbers
#    below are computed by hand: 1000 times the total violation.
#  * solveWithBranchAndBound was an honesty guard over scaffolding that never branched (it edited a
#    solution, not a problem). It is now a real branch and bound over the class's own simplex, proved here
#    against a brute-force enumeration written in this file, on random problems with a fixed seed.
#  * extractCoefficient read the text term by term and dropped what it could not read: 5*(-2*x + 8) - 3
#    gave -2 for x where the answer is -10, and 67 of 200 random expressions were answered wrongly without
#    a word. It reads the plain shapes as before and hands any other text to stzCoeffExtractor, which
#    judges and evaluates it.
#  * the objective value and evaluateExpression pasted values into the objective and ran it (rule R17:
#    text is judged, never run); x was replaced inside xx on the way. A harmless canary, a global that
#    injected text would set, must stay 0.
#  * round() with one argument answers nonsense, so isIntegerSolution and FindFractionalVariable called a
#    whole number fractional; the genetic solver kept the WORST candidate when minimizing.
#
# Run from inside its folder: cd base/test/stats

canary = 0
$lsShown = "" + 0.123456789   # how Ring shows a number before any extractor was built
$lsSeed = 1   # the seed of the random cross-checks, a global so the generator can advance it

Scenario("A control: the canary does detect code that runs")
	canary = 0
	oProbe = new CanaryProbe
	oProbe.Run("LsCanary()")
	Then("a function call evaluated in a class method sets the canary", canary, 1)
	canary = 0
	Then("and a fresh canary reads 0", canary, 0)
EndScenario()

Scenario("CalculatePenalty: 1000 times the total violation, hand-computed on 15 candidates")
	# x + y <= 4
	oA = LsTwo()
	oA.addConstraint("x + y", "<=", 4)
	cMsg = RaiseOf("oA.CalculatePenalty([ [ 'x', 3 ], [ 'y', 2 ] ])")
	Then("with one constraint it no longer raises (it raised R5 on oConst)", cMsg, "")
	Then("<= : (2, 2) is on the limit, nothing is broken: 0", oA.CalculatePenalty([ [ "x", 2 ], [ "y", 2 ] ]), 0)
	Then("<= : (3, 2) exceeds the limit by 1: 1000", oA.CalculatePenalty([ [ "x", 3 ], [ "y", 2 ] ]), 1000)
	Then("<= : (3.5, 2) exceeds it by 1.5: 1500", oA.CalculatePenalty([ [ "x", 3.5 ], [ "y", 2 ] ]), 1500)
	Then("<= : (0, 0) is well inside: 0", oA.CalculatePenalty([ [ "x", 0 ], [ "y", 0 ] ]), 0)
	Then("<= : a violation is not 0 (the wrong neighbour of the line above)", oA.CalculatePenalty([ [ "x", 3 ], [ "y", 2 ] ]) = 0, 0)

	# x + y >= 4
	oB = LsTwo()
	oB.addConstraint("x + y", ">=", 4)
	Then(">= : (1, 1) falls short by 2: 2000", oB.CalculatePenalty([ [ "x", 1 ], [ "y", 1 ] ]), 2000)
	Then(">= : (3, 2) is above the floor: 0", oB.CalculatePenalty([ [ "x", 3 ], [ "y", 2 ] ]), 0)
	Then(">= : (2, 2) is on the floor: 0", oB.CalculatePenalty([ [ "x", 2 ], [ "y", 2 ] ]), 0)

	# x - y = 1
	oC = LsTwo()
	oC.addConstraint("x - y", "=", 1)
	Then("= : (3, 2) gives exactly 1: 0", oC.CalculatePenalty([ [ "x", 3 ], [ "y", 2 ] ]), 0)
	Then("= : (5, 2) gives 3, 2 above: 2000", oC.CalculatePenalty([ [ "x", 5 ], [ "y", 2 ] ]), 2000)
	Then("= : (0, 2) gives -2, 3 below: 3000 (above and below count alike)", oC.CalculatePenalty([ [ "x", 0 ], [ "y", 2 ] ]), 3000)

	# negative and zero coefficients
	oD = LsTwo()
	oD.addConstraint("-2*x + y", "<=", 1)
	Then("negative coefficient: (0, 3) gives 3, 2 above 1: 2000", oD.CalculatePenalty([ [ "x", 0 ], [ "y", 3 ] ]), 2000)
	Then("negative coefficient: (2, 1) gives -3: 0", oD.CalculatePenalty([ [ "x", 2 ], [ "y", 1 ] ]), 0)
	oD0 = LsTwo()
	oD0.addConstraint("0*x + y", "<=", 1)
	Then("zero coefficient: x does not count, (9, 2) gives 2, 1 above: 1000", oD0.CalculatePenalty([ [ "x", 9 ], [ "y", 2 ] ]), 1000)
	Then("zero coefficient: (9, 1) is on the limit: 0", oD0.CalculatePenalty([ [ "x", 9 ], [ "y", 1 ] ]), 0)

	# two constraints
	oE = LsTwo()
	oE.addConstraint("x + y", "<=", 4).addConstraint("x - y", ">=", 1)
	Then("two broken: (1, 5) is 2 above the first and 5 short of the second: 7000", oE.CalculatePenalty([ [ "x", 1 ], [ "y", 5 ] ]), 7000)
	Then("one broken: (4, 1) is 1 above the first, the second holds (3 >= 1): 1000", oE.CalculatePenalty([ [ "x", 4 ], [ "y", 1 ] ]), 1000)
	Then("none broken: (3, 1) gives 4 and 2: 0", oE.CalculatePenalty([ [ "x", 3 ], [ "y", 1 ] ]), 0)
	cMsg = RaiseOf("oE.CalculatePenalty([ [ 'x', 1 ], [ 'y', 5 ] ])")
	Then("two constraints raise nothing either", cMsg, "")

	# a constraint over a subset of the variables
	oF = new stzLinearSolver()
	oF.addVariable("x", 0, 10).addVariable("y", 0, 10).addVariable("z", 0, 10)
	oF.addConstraint("z", "<=", 2)
	Then("a constraint on z only: (9, 9, 3) is 1 above: 1000", oF.CalculatePenalty([ [ "x", 9 ], [ "y", 9 ], [ "z", 3 ] ]), 1000)
	Then("a constraint on z only: (0, 0, 2) holds: 0", oF.CalculatePenalty([ [ "x", 0 ], [ "y", 0 ], [ "z", 2 ] ]), 0)

	# no constraint
	oG = LsTwo()
	Then("a problem without constraint has no penalty, whatever the candidate", oG.CalculatePenalty([ [ "x", 9 ], [ "y", 9 ] ]), 0)
EndScenario()

Scenario("CalculateFitness: objective less the penalty, negated objective when minimizing (hand-computed)")
	oF1 = LsTwo()
	oF1.addConstraint("x + y", "<=", 4)
	oF1.maximize("3*x + 2*y")
	cMsg = RaiseOf("oF1.CalculateFitness([ [ 'x', 3 ], [ 'y', 2 ] ])")
	Then("with a constraint it no longer raises", cMsg, "")
	Then("maximize 3x + 2y, x + y <= 4: (3, 2) is 13 less 1000 = -987", oF1.CalculateFitness([ [ "x", 3 ], [ "y", 2 ] ]), -987)
	Then("(2, 2) is feasible: 10", oF1.CalculateFitness([ [ "x", 2 ], [ "y", 2 ] ]), 10)
	Then("(0, 0) is feasible: 0", oF1.CalculateFitness([ [ "x", 0 ], [ "y", 0 ] ]), 0)
	Then("the violating candidate scores below the feasible one", oF1.CalculateFitness([ [ "x", 3 ], [ "y", 2 ] ]) < oF1.CalculateFitness([ [ "x", 2 ], [ "y", 2 ] ]), 1)
	Then("and the raw objective, 13, is not the score", oF1.CalculateFitness([ [ "x", 3 ], [ "y", 2 ] ]) = 13, 0)

	oF2 = LsTwo()
	oF2.addConstraint("x + y", ">=", 4)
	oF2.minimize("3*x + 2*y")
	Then("minimize 3x + 2y, x + y >= 4: (1, 1) costs 5 and falls short by 2: -5 - 2000 = -2005", oF2.CalculateFitness([ [ "x", 1 ], [ "y", 1 ] ]), -2005)
	Then("(2, 2) costs 10, feasible: -10", oF2.CalculateFitness([ [ "x", 2 ], [ "y", 2 ] ]), -10)
	Then("(0, 4) costs 8, feasible: -8, the best of the three", oF2.CalculateFitness([ [ "x", 0 ], [ "y", 4 ] ]), -8)
	Then("a cheaper feasible candidate scores higher: -8 above -10", oF2.CalculateFitness([ [ "x", 0 ], [ "y", 4 ] ]) > oF2.CalculateFitness([ [ "x", 2 ], [ "y", 2 ] ]), 1)

	oF3 = LsTwo()
	oF3.maximize("x + y")
	Then("with no constraint, maximizing returns the objective: x + y at (2, 3) is 5", oF3.CalculateFitness([ [ "x", 2 ], [ "y", 3 ] ]), 5)
	oF4 = LsTwo()
	oF4.minimize("x + y")
	Then("with no constraint, minimizing returns it negated: -5", oF4.CalculateFitness([ [ "x", 2 ], [ "y", 3 ] ]), -5)

	oF5 = LsTwo()
	oF5.addConstraint("x + y", "<=", 4).addConstraint("x", "<=", 2)
	oF5.maximize("3*x + 2*y")
	Then("two constraints, both broken at (3, 2): 13 - 2000 = -1987", oF5.CalculateFitness([ [ "x", 3 ], [ "y", 2 ] ]), -1987)
	Then("(2, 2) breaks neither: 10", oF5.CalculateFitness([ [ "x", 2 ], [ "y", 2 ] ]), 10)
EndScenario()

Scenario("The genetic solver runs with constraints, and keeps the BEST candidate for both goals")
	# The search is random: only what any run must satisfy is asserted, with a wide margin.
	oG1 = LsTwo()
	oG1.addConstraint("x + y", "<=", 4).addConstraint("x", "<=", 2)
	oG1.maximize("3*x + 2*y")
	cMsg = RaiseOf("oG1.solve('genetic')")
	Then("maximize with two constraints no longer raises R5", cMsg, "")
	Then("the status is optimal", oG1.status(), "optimal")
	Then("it counted its 100 generations", oG1.iterations(), 100)
	aS = oG1.Solution()
	Then("the answer is feasible", oG1.IsFeasible(aS), 1)
	nV = oG1.EvaluateSolution(aS)
	Then("and good: value 6 or more, where the optimum is 10 and a feasible point cannot beat it", nV >= 6 and nV <= 10, 1)

	oG2 = new stzLinearSolver()
	oG2.addVariable("x", 0, 5).addVariable("y", 0, 5)
	oG2.addConstraint("x + y", ">=", 4)
	oG2.minimize("x + y")
	cMsg = RaiseOf("oG2.solve('genetic')")
	Then("minimize with a constraint no longer raises", cMsg, "")
	aS = oG2.Solution()
	nSum = LsGet(aS, "x") + LsGet(aS, "y")
	Then("the answer is feasible: x + y >= 4", nSum >= 4, 1)
	Then("and it is the best kind, at most 6 where 10 is the worst feasible (it kept the worst before)", nSum <= 6, 1)
	Then("and not the maximum, 10", nSum = 10, 0)
EndScenario()

Scenario("The simplex agrees with eight hand-solved problems (the relaxation branch and bound rides on)")
	# L1: maximize 3x + 2y, x + y <= 4, x <= 2 -> (2, 2), 10
	o1 = LsTwo()
	o1.addConstraint("x + y", "<=", 4).addConstraint("x", "<=", 2).maximize("3*x + 2*y")
	o1.solve("simplex")
	Then("L1 optimal", o1.status(), "optimal")
	Then("L1 x = 2", LsNear(o1.solutionValue("x"), 2), 1)
	Then("L1 y = 2", LsNear(o1.solutionValue("y"), 2), 1)
	Then("L1 value 10", LsNear(o1.objectiveValue(), 10), 1)
	Then("L1 value is not the greedy 8", LsNear(o1.objectiveValue(), 8), 0)

	# L2: minimize x + 2y, x + y >= 3, x - y = -1, x in 0..2, y in 0..5 -> (1, 2), 5
	o2 = new stzLinearSolver()
	o2.addVariable("x", 0, 2).addVariable("y", 0, 5)
	o2.addConstraint("x + y", ">=", 3).addConstraint("x - y", "=", -1).minimize("x + 2*y")
	o2.solve("simplex")
	Then("L2 optimal", o2.status(), "optimal")
	Then("L2 x = 1", LsNear(o2.solutionValue("x"), 1), 1)
	Then("L2 y = 2", LsNear(o2.solutionValue("y"), 2), 1)
	Then("L2 value 5", LsNear(o2.objectiveValue(), 5), 1)

	# L3: maximize 5x + 4y, 6x + 4y <= 24, x + 2y <= 6 -> (3, 1.5), 21
	o3 = LsBig()
	o3.addConstraint("6*x + 4*y", "<=", 24).addConstraint("x + 2*y", "<=", 6).maximize("5*x + 4*y")
	o3.solve("simplex")
	Then("L3 x = 3", LsNear(o3.solutionValue("x"), 3), 1)
	Then("L3 y = 1.5", LsNear(o3.solutionValue("y"), 1.5), 1)
	Then("L3 value 21", LsNear(o3.objectiveValue(), 21), 1)

	# L4: minimize 2x + 3y, x + y >= 4, x + 3y >= 6 -> (3, 1), 9
	o4 = LsBig()
	o4.addConstraint("x + y", ">=", 4).addConstraint("x + 3*y", ">=", 6).minimize("2*x + 3*y")
	o4.solve("simplex")
	Then("L4 x = 3", LsNear(o4.solutionValue("x"), 3), 1)
	Then("L4 y = 1", LsNear(o4.solutionValue("y"), 1), 1)
	Then("L4 value 9", LsNear(o4.objectiveValue(), 9), 1)

	# L5: maximize x + y, 2x + y <= 10, x + 3y <= 15 -> (3, 4), 7
	o5 = LsBig()
	o5.addConstraint("2*x + y", "<=", 10).addConstraint("x + 3*y", "<=", 15).maximize("x + y")
	o5.solve("simplex")
	Then("L5 x = 3", LsNear(o5.solutionValue("x"), 3), 1)
	Then("L5 y = 4", LsNear(o5.solutionValue("y"), 4), 1)
	Then("L5 value 7", LsNear(o5.objectiveValue(), 7), 1)

	# L6: lower bounds: maximize 2x + y, x + y <= 7, x in 2..6, y in 3..4 -> (4, 3), 11
	o6 = new stzLinearSolver()
	o6.addVariable("x", 2, 6).addVariable("y", 3, 4)
	o6.addConstraint("x + y", "<=", 7).maximize("2*x + y")
	o6.solve("simplex")
	Then("L6 x = 4", LsNear(o6.solutionValue("x"), 4), 1)
	Then("L6 y = 3", LsNear(o6.solutionValue("y"), 3), 1)
	Then("L6 value 11", LsNear(o6.objectiveValue(), 11), 1)

	# L7: infeasible
	o7 = new stzLinearSolver()
	o7.addVariable("x", 0, 2).addVariable("y", 0, 2)
	o7.addConstraint("x + y", ">=", 10).maximize("x + y")
	o7.solve("simplex")
	Then("L7 is infeasible: x + y >= 10 with both at most 2", o7.status(), "infeasible")
	Then("and the sibling with x + y >= 4 is optimal", LsStatus("x + y", ">=", 4), "optimal")

	# L8: unbounded
	o8 = new stzLinearSolver()
	o8.addVariable("x", 0, 1000000000000).addVariable("y", 0, 1000000000000)
	o8.addConstraint("x - y", "<=", 1).maximize("x + y")
	o8.solve("simplex")
	Then("L8 is unbounded", o8.status(), "unbounded")
EndScenario()

Scenario("Branch and bound, hand-solved: the guard is lifted and the answers are whole")
	# maximize x + y, 2x + 2y <= 7, integers 0..5: the simplex alone says 3.5, the whole answer is 3
	oB1 = new stzLinearSolver()
	oB1.addIntegerVariable("x", 0, 5).addIntegerVariable("y", 0, 5)
	oB1.addConstraint("2*x + 2*y", "<=", 7).maximize("x + y")
	cMsg = RaiseOf("oB1.solve('branch_bound')")
	Then("solve('branch_bound') no longer raises", cMsg, "")
	Then("the status is optimal, not unimplemented", oB1.status(), "optimal")
	Then("the value is 3", oB1.EvaluateSolution(oB1.Solution()), 3)
	Then("x is whole", LsWhole(oB1.solutionValue("x")), 1)
	Then("y is whole", LsWhole(oB1.solutionValue("y")), 1)
	Then("x + y = 3", oB1.solutionValue("x") + oB1.solutionValue("y"), 3)
	Then("it took more than the root node", oB1.iterations() > 1, 1)
	oB1.solve("simplex")
	Then("while the simplex alone gives the fractional 3.5 (the marks are not enforced there)", LsNear(oB1.EvaluateSolution(oB1.Solution()), 3.5), 1)

	# binary knapsack: 6a + 5b + 4c, 3a + 2b + 2c <= 5 -> a = 1, b = 1, c = 0, 11
	oB2 = new stzLinearSolver()
	oB2.addBinaryVariable("a").addBinaryVariable("b").addBinaryVariable("c")
	oB2.addConstraint("3*a + 2*b + 2*c", "<=", 5).maximize("6*a + 5*b + 4*c")
	oB2.solve("branch_bound")
	Then("knapsack: value 11", oB2.EvaluateSolution(oB2.Solution()), 11)
	Then("knapsack: a = 1", oB2.solutionValue("a"), 1)
	Then("knapsack: b = 1", oB2.solutionValue("b"), 1)
	Then("knapsack: c = 0", oB2.solutionValue("c"), 0)
	Then("knapsack: not b + c, worth only 9", oB2.EvaluateSolution(oB2.Solution()) = 9, 0)

	# mixed: x integer in 0..2.5, y continuous; maximize 3x + 2y, x + y <= 4.5 -> x = 2, y = 2.5, 11
	oB3 = new stzLinearSolver()
	oB3.addIntegerVariable("x", 0, 2.5).addVariable("y", 0, 10)
	oB3.addConstraint("x + y", "<=", 4.5).maximize("3*x + 2*y")
	oB3.solve("branch_bound")
	Then("mixed: x is the whole 2", oB3.solutionValue("x"), 2)
	Then("mixed: y stays continuous, 2.5", LsNear(oB3.solutionValue("y"), 2.5), 1)
	Then("mixed: value 11", LsNear(oB3.EvaluateSolution(oB3.Solution()), 11), 1)
	Then("mixed: the relaxation's 11.5 is beaten by the whole answer 11", LsNear(oB3.EvaluateSolution(oB3.Solution()), 11.5), 0)

	# infeasible in integers, feasible in reals: 2x = 1
	oB4 = new stzLinearSolver()
	oB4.addIntegerVariable("x", 0, 5)
	oB4.addConstraint("2*x", "=", 1).maximize("x")
	oB4.solve("branch_bound")
	Then("2x = 1 has no whole solution: infeasible", oB4.status(), "infeasible")
	oB5 = new stzLinearSolver()
	oB5.addIntegerVariable("x", 0, 5)
	oB5.addConstraint("2*x", "=", 4).maximize("x")
	oB5.solve("branch_bound")
	Then("while 2x = 4 is optimal", oB5.status(), "optimal")
	Then("with x = 2", oB5.solutionValue("x"), 2)

	# unbounded relaxation
	oB6 = new stzLinearSolver()
	oB6.addIntegerVariable("x", 0, 1000000000000).addIntegerVariable("y", 0, 1000000000000)
	oB6.addConstraint("x - y", "<=", 1).maximize("x + y")
	oB6.solve("branch_bound")
	Then("an unbounded relaxation is reported unbounded", oB6.status(), "unbounded")

	# minimize: x + y >= 2.5, integers 0..5 -> 3
	oB7 = new stzLinearSolver()
	oB7.addIntegerVariable("x", 0, 5).addIntegerVariable("y", 0, 5)
	oB7.addConstraint("x + y", ">=", 2.5).minimize("x + y")
	oB7.solve("branch_bound")
	Then("minimize: the value is 3", oB7.EvaluateSolution(oB7.Solution()), 3)
	Then("minimize: not 2, which breaks the constraint", oB7.EvaluateSolution(oB7.Solution()) = 2, 0)

	# no integer variable: one node, the simplex
	oB8 = new stzLinearSolver()
	oB8.addVariable("x", 0, 10).addVariable("y", 0, 10)
	oB8.addConstraint("x + y", "<=", 4).addConstraint("x", "<=", 2).maximize("3*x + 2*y")
	oB8.solve("branch_bound")
	Then("without integer variable it solves one node", oB8.iterations(), 1)
	Then("and gives the simplex value 10", LsNear(oB8.EvaluateSolution(oB8.Solution()), 10), 1)

	# the marks, as the documentation states them: 2n <= 5 with n integer, and 2b <= 1 with b binary
	oB10 = new stzLinearSolver()
	oB10.addIntegerVariable("n", 0, 10)
	oB10.addConstraint("2*n", "<=", 5).maximize("n")
	oB10.solve("simplex")
	Then("maximize n with 2n <= 5: the simplex ignores the mark and answers 2.5", LsNear(oB10.solutionValue("n"), 2.5), 1)
	oB10.solve("branch_bound")
	Then("branch and bound enforces it and answers 2", oB10.solutionValue("n"), 2)
	oB11 = new stzLinearSolver()
	oB11.addBinaryVariable("b")
	oB11.addConstraint("2*b", "<=", 1).maximize("b")
	oB11.solve("simplex")
	Then("maximize b with 2b <= 1: the simplex answers 0.5", LsNear(oB11.solutionValue("b"), 0.5), 1)
	oB11.solve("branch_bound")
	Then("branch and bound answers 0", oB11.solutionValue("b"), 0)

	# the branch and bound entered through the method itself
	oB9 = new stzLinearSolver()
	oB9.addIntegerVariable("x", 0, 5).addIntegerVariable("y", 0, 5)
	oB9.addConstraint("2*x + 2*y", "<=", 7).maximize("x + y")
	aSol = oB9.solveWithBranchAndBound()
	Then("called directly it returns the whole answer: x + y = 3", LsGet(aSol, "x") + LsGet(aSol, "y"), 3)
EndScenario()

Scenario("Branch and bound stops with a clear message beyond its node limit")
	# 2*a + 2*b + ... + 2*h = 9 is feasible in reals (the sum is 4.5) and in no whole numbers: the tree has to be
	# walked to the leaves. The limit is a field; a subclass lowers it so the test is quick.
	oL = new LsLimited
	oL.addBinaryVariable("a").addBinaryVariable("b").addBinaryVariable("c").addBinaryVariable("d")
	oL.addBinaryVariable("e").addBinaryVariable("f").addBinaryVariable("g").addBinaryVariable("h")
	oL.addConstraint("2*a + 2*b + 2*c + 2*d + 2*e + 2*f + 2*g + 2*h", "=", 9).maximize("a + b + c + d + e + f + g + h")
	cMsg = RaiseOf("oL.solve('branch_bound')")
	Then("the message says branch and bound stopped", Has(cMsg, "branch and bound stopped after 20 nodes"), 1)
	Then("it carries the class name", Has(cMsg, "stzLinearSolver:"), 1)
	Then("the status is node_limit", oL.status(), "node_limit")
	oL2 = new LsLimited
	oL2.addBinaryVariable("a").addBinaryVariable("b").addBinaryVariable("c").addBinaryVariable("d")
	oL2.addBinaryVariable("e").addBinaryVariable("f").addBinaryVariable("g").addBinaryVariable("h")
	oL2.addConstraint("2*a + 2*b + 2*c + 2*d + 2*e + 2*f + 2*g + 2*h", "=", 8).maximize("a + b + c + d + e + f + g + h")
	cMsg = RaiseOf("oL2.solve('branch_bound')")
	Then("while the same problem with a reachable sum (= 8) raises nothing", cMsg, "")
	Then("and gives the value 4", LsNear(oL2.EvaluateSolution(oL2.Solution()), 4), 1)
	Then("under the limit the status is optimal", oL2.status(), "optimal")
EndScenario()

Scenario("Branch and bound against a brute-force enumeration: 40 random problems, fixed seed")
	# Each problem has 2 to 4 integer variables in 0..5 and 1 to 3 constraints; the optimum is found by trying all
	# 6^n points, with coefficients written here (never read back from the class). Every 5th problem is written
	# through parentheses, which reads through stzCoeffExtractor. The expected status is optimal when some point
	# is feasible and infeasible otherwise.
	$lsSeed = 20261023
	nProblems = 40
	nOptimalSeen = 0
	nInfeasibleSeen = 0
	nStatusOk = 0
	nValueOk = 0
	nPointOk = 0
	nBranched = 0
	nWrapped = 0
	for iP = 1 to nProblems
		aProb = LsGenProblem(iP)
		aBrute = LsBrute(aProb)
		oBB = LsBuild(aProb)
		cRaised = RaiseOf("oBB.solve('branch_bound')")
		cWantStatus = "infeasible"
		if aBrute[1] > 0
			cWantStatus = "optimal"
			nOptimalSeen++
		else
			nInfeasibleSeen++
		ok
		nStat = 0
		if cRaised = "" and oBB.status() = cWantStatus
			nStat = 1
		ok
		nStatusOk += nStat
		if oBB.iterations() > 1
			nBranched++
		ok
		Then("problem " + iP + " [" + LsDescribe(aProb) + "]: status " + cWantStatus + " (brute force: " + aBrute[1] + " feasible points)", nStat, 1)
		if aBrute[1] > 0
			aGot = oBB.Solution()
			nGotVal = 0
			nPoint = 1
			nVars = len(aProb[:names])
			for k = 1 to nVars
				nCell = LsGet(aGot, aProb[:names][k])
				nGotVal += aProb[:obj][k] * nCell
				if NOT LsWhole(nCell) or nCell < 0 or nCell > 5
					nPoint = 0
				ok
			next
			# the returned point is checked against the coefficients written here, not by the class
			if LsFeasiblePoint(aProb, aGot) = 0
				nPoint = 0
			ok
			nPointOk += nPoint
			nVal = LsNear(nGotVal, aBrute[2])
			nValueOk += nVal
			Then("problem " + iP + ": value " + aBrute[2] + " (brute force)", nVal, 1)
			Then("problem " + iP + ": the point is whole, in 0..5 and satisfies every constraint", nPoint, 1)
		ok
	next
	Then("the corpus is not vacuous: at least 20 problems have a whole optimum", nOptimalSeen >= 20, 1)
	Then("and some are infeasible in integers, to test that status too", nInfeasibleSeen >= 2, 1)
	Then("and at least 8 needed real branching (more than the root node), so the search itself is tested", nBranched >= 8, 1)
	Then("all 40 statuses agree with the oracle", nStatusOk, nProblems)
	Then("every optimum value agrees with the oracle", nValueOk, nOptimalSeen)
	Then("every returned point is whole, bounded and feasible", nPointOk, nOptimalSeen)
EndScenario()

Scenario("extractCoefficient: hand-computed, with the old silent wrong answer as the negative sibling")
	oX = new stzLinearSolver()
	oX.addVariable("x", 0, 10).addVariable("xx", 0, 10).addVariable("y", 0, 10).addVariable("z", 0, 10)
	aCases = [
		[ "3*x + 2*y", "x", 3 ],
		[ "3*x + 2*y", "y", 2 ],
		[ "3*x + 2*y", "z", 0 ],
		[ "x + 2*x", "x", 3 ],
		[ "x*2 + y - x", "x", 1 ],
		[ "-x", "x", -1 ],
		[ "5*xx + 2*x", "x", 2 ],
		[ "5*xx + 2*x", "xx", 5 ],
		[ "X + 2*x", "x", 3 ],
		[ "7", "x", 0 ],
		[ "", "x", 0 ],
		[ "x + y + 7", "y", 1 ],
		[ "0.5*x - 1.5*x", "x", -1 ],
		[ "2*(x + 1)", "x", 2 ],
		[ "(x + y)*2 + z", "x", 2 ],
		[ "(x + y)*2 + z", "z", 1 ],
		[ "5*(-2*x + 8) - 3", "x", -10 ],
		[ "(3*x + 4) * 5 + 4", "x", 15 ],
		[ "(3*x + 2*xx) * 2", "xx", 4 ],
		[ "x/2 + y", "x", 0.5 ],
		[ "2*3*x", "x", 6 ],
		[ "x - -y", "y", 1 ],
		[ "x - -y", "x", 1 ],
		[ "pow(x, 1) + y", "x", 1 ]
	]
	nCases = len(aCases)
	for i = 1 to nCases
		nGot = oX.extractCoefficient(aCases[i][1], aCases[i][2])
		Then("[" + aCases[i][1] + "] for " + aCases[i][2] + " is " + aCases[i][3], LsNear(nGot, aCases[i][3]), 1)
	next
	Then("5*(-2*x + 8) - 3 is not the old answer -2", LsNear(oX.extractCoefficient("5*(-2*x + 8) - 3", "x"), -2), 0)
	Then("x/2 + y is not the old 0 for x", LsNear(oX.extractCoefficient("x/2 + y", "x"), 0), 0)
	Then("2*3*x is not the old 0", LsNear(oX.extractCoefficient("2*3*x", "x"), 0), 0)
	Then("x - -y is not the old -1 for y", LsNear(oX.extractCoefficient("x - -y", "y"), -1), 0)
	Then("a second reading of an exact answer agrees with the first", oX.extractCoefficient("2*(x + 1)", "x"), oX.extractCoefficient("2*(x + 1)", "x"))
	Then("the display precision was not left at 4 decimals by the extractor", LsPrecisionKept(), 1)

	cMsg = RaiseOf("oX.extractCoefficient('x*y', 'x')")
	Then("x*y is not linear in x: refused with that sentence", Has(cMsg, "is not linear in the variable x"), 1)
	cMsg = RaiseOf("oX.extractCoefficient('pow(x, 2)', 'x')")
	Then("pow(x, 2) is not linear either", Has(cMsg, "is not linear"), 1)
	cMsg = RaiseOf("oX.extractCoefficient('2x + y', 'y')")
	Then("a name glued to a digit is refused, not read as the variable '2x'", Has(cMsg, "refused"), 1)
	canary = 0
	cMsg = RaiseOf("oX.extractCoefficient('x + LsCanary()', 'x')")
	Then("a call is refused", Has(cMsg, "refused"), 1)
	Then("and nothing ran", canary, 0)
	cMsg = RaiseOf("oX.extractCoefficient('x + 1; canary = 1', 'x')")
	Then("a statement is refused", Has(cMsg, "refused"), 1)
	Then("and nothing ran either", canary, 0)
	cMsg = RaiseOf("oX.extractCoefficient('2*(x + 1)', 'x')")
	Then("while a parenthesised linear text raises nothing", cMsg, "")
EndScenario()

Scenario("200 random linear expressions in three spellings, every coefficient of x, xx, y, yy read exactly")
	# The same generator as test/stats/stzCoeffExtractor_defects_narrated.ring: it writes each text and computes its
	# true coefficients on the way, independently of the class. Against the old reader 67 of the 200 were answered
	# wrongly and not one raised (measured on 2026-10-23): every one with parentheses.
	aRnd = LsGenCases(200)
	Then("200 expressions were generated", len(aRnd), 200)
	oR4 = new stzLinearSolver()
	aNames4 = [ "x", "xx", "y", "yy" ]
	for v = 1 to 4
		oR4.addVariable(aNames4[v], 0, 10)
	next
	nExact = 0
	nWithParen = 0
	nParenExact = 0
	for i = 1 to 200
		nAll = 1
		for v = 1 to 4
			nGot = oR4.extractCoefficient(aRnd[i][1], aNames4[v])
			nAll *= LsNear(nGot, aRnd[i][2][v])
		next
		nExact += nAll
		if Has(aRnd[i][1], "(")
			nWithParen++
			nParenExact += nAll
		ok
		Then("case " + i + " [" + aRnd[i][1] + "]", nAll, 1)
	next
	Then("all 200 are exact", nExact, 200)
	Then("the corpus is not vacuous: at least 60 are parenthesised", nWithParen >= 60, 1)
	Then("and every parenthesised one is exact", nParenExact, nWithParen)
EndScenario()

Scenario("A solved problem written with parentheses: the objective and the constraints are read exactly")
	oQ = new stzLinearSolver()
	oQ.addVariable("x", 0, 10).addVariable("y", 0, 10)
	oQ.addConstraint("2*(x + y)", "<=", 8).addConstraint("x", "<=", 3)
	oQ.maximize("(3*x + 2*y) * 2")
	oQ.solve("simplex")
	Then("2(x + y) <= 8, x <= 3, maximize 2(3x + 2y): x = 3", LsNear(oQ.solutionValue("x"), 3), 1)
	Then("y = 1", LsNear(oQ.solutionValue("y"), 1), 1)
	Then("the objective is 2 * (9 + 2) = 22", LsNear(oQ.objectiveValue(), 22), 1)
	Then("and not the 11 of the reader that dropped the factor", LsNear(oQ.objectiveValue(), 11), 0)
EndScenario()

Scenario("Text is judged, never run: evaluateExpression and objectiveValue")
	oT = new stzLinearSolver()
	Then("2+3*4 is 14", oT.evaluateExpression("2+3*4"), 14)
	Then("(2+3)*4 is 20", oT.evaluateExpression("(2+3)*4"), 20)
	Then("pow(2, 3) + sqrt(16) is 12", oT.evaluateExpression("pow(2, 3) + sqrt(16)"), 12)
	Then("a text that cannot be evaluated gives 0", oT.evaluateExpression("1 +"), 0)
	Then("10 / 4 is 2.5, not a whole division", oT.evaluateExpression("10 / 4"), 2.5)
	canary = 0
	Then("a call of a function of the program gives 0", oT.evaluateExpression("LsCanary()"), 0)
	Then("and did not run", canary, 0)
	Then("an assignment gives 0", oT.evaluateExpression("canary = 1"), 0)
	Then("and did not run", canary, 0)
	Then("two statements give 0", oT.evaluateExpression("1; canary = 1"), 0)
	Then("and did not run", canary, 0)
	Then("a name that is not a number gives 0", oT.evaluateExpression("canary + 1"), 0)

	# the doc's example: 14
	oV = new stzLinearSolver()
	oV.addVariable("x", 0, 4).addVariable("y", 0, 6)
	oV.addConstraint("x + y", "<=", 5).addConstraint("x + 3*y", "<=", 12)
	oV.maximize("3*x + 2*y")
	Then("before any solve the objective value is 0", oV.objectiveValue(), 0)
	oV.solve("simplex")
	Then("the objective value of x = 4, y = 1 is 14", LsNear(oV.objectiveValue(), 14), 1)
	oV.maximize("3*x + 2*y + 10")
	Then("a constant in the objective counts: 24", LsNear(oV.objectiveValue(), 24), 1)
	oV.maximize("(3*x + 2*y) * 2")
	Then("a parenthesised objective goes through the extractor: 28", LsNear(oV.objectiveValue(), 28), 1)

	# x inside xx
	oW = new stzLinearSolver()
	oW.addVariable("x", 0, 3).addVariable("xx", 0, 5)
	oW.maximize("xx + 2*x")
	oW.solve("simplex")
	Then("xx + 2x at x = 3, xx = 5 is 11", LsNear(oW.objectiveValue(), 11), 1)
	Then("and not the 39 of 'xx' becoming '33'", LsNear(oW.objectiveValue(), 39), 0)

	# hostile objective after a solve
	canary = 0
	oV.maximize("x + LsCanary()")
	cMsg = RaiseOf("oV.objectiveValue()")
	Then("an objective with a call is refused by objectiveValue", Has(cMsg, "refused"), 1)
	Then("and nothing ran", canary, 0)
	cMsg = RaiseOf("oV.solve('simplex')")
	Then("solve refuses it too", Has(cMsg, "refused"), 1)
	Then("and nothing ran", canary, 0)
	oC = new stzLinearSolver()
	oC.addVariable("x", 0, 3)
	oC.addConstraint("x + LsCanary()", "<=", 3).maximize("x")
	cMsg = RaiseOf("oC.solve('simplex')")
	Then("a constraint with a call is refused by solve", Has(cMsg, "refused"), 1)
	Then("and nothing ran", canary, 0)
	oC.clear()
	oC.addVariable("x", 0, 3)
	oC.addConstraint("x", "<=", 2).maximize("x")
	cMsg = RaiseOf("oC.solve('simplex')")
	Then("while the same problem with plain text solves", cMsg, "")
	Then("x = 2", LsNear(oC.solutionValue("x"), 2), 1)
EndScenario()

Scenario("isIntegerSolution and FindFractionalVariable read a whole number as whole")
	oI = LsTwo()
	Then("[ x = 2, y = 3 ] is whole", oI.isIntegerSolution([ [ "x", 2 ], [ "y", 3 ] ]), 1)
	Then("[ x = 2, y = 2.5 ] is not", oI.isIntegerSolution([ [ "x", 2 ], [ "y", 2.5 ] ]), 0)
	Then("[ x = 2.0004, y = 3 ] is whole within 0.001", oI.isIntegerSolution([ [ "x", 2.0004 ], [ "y", 3 ] ]), 1)
	Then("[ x = 2.01, y = 3 ] is not", oI.isIntegerSolution([ [ "x", 2.01 ], [ "y", 3 ] ]), 0)
	Then("[ x = -2, y = 7 ] is whole", oI.isIntegerSolution([ [ "x", -2 ], [ "y", 7 ] ]), 1)
	Then("the first fractional variable of [ x = 2, y = 2.5 ] is y", oI.FindFractionalVariable([ [ "x", 2 ], [ "y", 2.5 ] ]), "y")
	Then("and a whole solution has none", oI.FindFractionalVariable([ [ "x", 2 ], [ "y", 3 ] ]), "")
	Then("[ x = 0.5, y = 3 ] puts x first", oI.FindFractionalVariable([ [ "x", 0.5 ], [ "y", 3 ] ]), "x")
EndScenario()

Scenario("Every public method once, on maximize 3x + 2y with x + y <= 4 and x <= 2 (hand-solved: x = 2, y = 2, value 10)")
	oS = LsTwo()
	oS.addConstraint("x + y", "<=", 4).addConstraint("x", "<=", 2).maximize("3*x + 2*y")
	acNm = oS.variableNames()
	Then("variableNames", acNm[1] + acNm[2], "xy")
	aVr = oS.variables()
	Then("variables holds two entries", len(aVr), 2)
	Then("the first variable's bounds are 0 and 10", "" + aVr[1][:lowerbound] + " " + aVr[1][:upperbound], "0 10")
	aCn = oS.constraints()
	Then("constraints holds two entries", len(aCn), 2)
	cOpFirst = aCn[1][:operator]
	Then("the first constraint's operator", cOpFirst, "<=")
	Then("objective", oS.objective(), "3*x + 2*y")
	Then("objectiveType", oS.objectiveType(), "maximize")
	Then("validateProblem", oS.validateProblem(), 1)
	Then("isValidVariableName of x", oS.isValidVariableName("x"), 1)
	Then("and of q", oS.isValidVariableName("q"), 0)
	anCo = oS.parseObjectiveCoefficients()
	Then("parseObjectiveCoefficients", "" + anCo[1] + " " + anCo[2], "3 2")
	Then("extractCoefficient", oS.extractCoefficient("3*x + 2*y", "y"), 2)
	Then("calculateResourceCost of x: it is in two constraints with coefficient 1 each", oS.calculateResourceCost("x"), 2)
	Then("calculateResourceCost of y: one constraint", oS.calculateResourceCost("y"), 1)
	Then("CalculateMaxPossibleValue of x with y = 0: min(4, 2) = 2", oS.CalculateMaxPossibleValue("x", [ [ "x", 0 ], [ "y", 0 ] ]), 2)
	Then("CalculateMaxPossibleValue of y with x = 2: 4 - 2 = 2", oS.CalculateMaxPossibleValue("y", [ [ "x", 2 ], [ "y", 0 ] ]), 2)
	Then("GetSolutionValue", oS.GetSolutionValue([ [ "x", 4 ], [ "y", 1 ] ], "x"), 4)
	Then("GetSolutionValue of an absent name is 0", oS.GetSolutionValue([ [ "x", 4 ] ], "q"), 0)
	Then("EvaluateSolution of (2, 2) is 10", oS.EvaluateSolution([ [ "x", 2 ], [ "y", 2 ] ]), 10)
	Then("EvaluateConstraintLeft of x + y at (2, 2) is 4", oS.EvaluateConstraintLeft("x + y", [ [ "x", 2 ], [ "y", 2 ] ]), 4)
	Then("IsFeasible (2, 2)", oS.IsFeasible([ [ "x", 2 ], [ "y", 2 ] ]), 1)
	Then("IsFeasible (3, 2) breaks both", oS.IsFeasible([ [ "x", 3 ], [ "y", 2 ] ]), 0)
	Then("isBetter 3 over 2 when maximizing", oS.isBetter(3, 2), 1)
	Then("and 2 over 3 is not", oS.isBetter(2, 3), 0)
	aBr = oS.AddBranchConstraint([ [ "x", 4 ], [ "y", 1 ] ], "x", "<=", 2)
	Then("AddBranchConstraint caps x = 4 at 2", LsGet(aBr, "x"), 2)
	aBr = oS.AddBranchConstraint([ [ "x", 1 ], [ "y", 1 ] ], "x", ">=", 3)
	Then("and raises x = 1 to 3 for >=", LsGet(aBr, "x"), 3)
	Then("CreateRelaxedProblem keeps two variables", len(oS.CreateRelaxedProblem().variableNames()), 2)
	Then("and its two constraints", len(oS.CreateRelaxedProblem().constraints()), 2)

	aPop = oS.InitializePopulation(5)
	Then("InitializePopulation draws 5 candidates", len(aPop), 5)
	nInBounds = 1
	for i = 1 to 5
		for k = 1 to 2
			if aPop[i][k][2] < 0 or aPop[i][k][2] > 10 or NOT LsWhole(aPop[i][k][2])
				nInBounds = 0
			ok
		next
	next
	Then("every drawn value is a whole number within 0..10", nInBounds, 1)
	aPick = oS.TournamentSelection([ [ [ "x", 1 ], [ "y", 1 ] ], [ [ "x", 9 ], [ "y", 9 ] ] ], [ 1, 2 ])
	Then("TournamentSelection returns one of the two candidates", aPick[1][2] = 1 or aPick[1][2] = 9, 1)
	aKid = oS.Crossover([ [ "x", 1 ], [ "y", 1 ] ], [ [ "x", 9 ], [ "y", 9 ] ])
	Then("Crossover keeps each variable from one parent", (aKid[1][2] = 1 or aKid[1][2] = 9) and (aKid[2][2] = 1 or aKid[2][2] = 9), 1)
	aMut = oS.Mutate([ [ "x", 1 ], [ "y", 1 ] ])
	Then("Mutate keeps the names", aMut[1][1] + aMut[2][1], "xy")
	Then("and the values within the bounds", aMut[1][2] >= 0 and aMut[1][2] <= 10 and aMut[2][2] >= 0 and aMut[2][2] <= 10, 1)

	Then("BuildSimplexTableau is the documented constant placeholder", len(oS.BuildSimplexTableau()), 2)
	Then("HasNegativeCoefficient is the documented 0", oS.HasNegativeCoefficient([ [ 1, -2 ] ]), 0)
	Then("FindPivotColumn is the documented 1", oS.FindPivotColumn([]), 1)
	Then("FindPivotRow is the documented 1", oS.FindPivotRow([], 3), 1)
	Then("PivotTableau answers its argument", len(oS.PivotTableau([ [ 1 ], [ 2 ] ], 1, 1)), 2)
	Then("ExtractSimplexSolution answers a zero per variable", len(oS.ExtractSimplexSolution([])), 2)

	oS.solve("simplex")
	Then("solve('simplex'): optimal", oS.status(), "optimal")
	Then("x = 2", LsNear(oS.solutionValue("x"), 2), 1)
	Then("y = 2", LsNear(oS.solutionValue("y"), 2), 1)
	Then("objectiveValue 10", LsNear(oS.objectiveValue(), 10), 1)
	Then("Solution has two pairs", len(oS.Solution()), 2)
	Then("iterations is a count, not 0", oS.iterations() > 0, 1)
	Then("solveTime is not negative", oS.solveTime() >= 0, 1)
	oS.solve("")
	Then("solve('') is the greedy solver; the heuristic answers y = 4, value 8 (x + y <= 4 first)", LsNear(oS.objectiveValue(), 8), 1)
	Then("which is not the optimum 10", LsNear(oS.objectiveValue(), 10), 0)
	cMsg = RaiseOf("oS.solve('nonsense')")
	Then("an unknown solver name raises", Has(cMsg, "Unknown solver"), 1)

	cFile = "ls_defects_tmp.csv"
	oS.solve("simplex")
	oS.exportToCSV(cFile)
	cCsv = read(cFile)
	Then("exportToCSV begins with its header", Has(cCsv, "Variable,Value"), 1)
	Then("and holds x,2", Has(cCsv, "x,2"), 1)
	remove(cFile)
	oS.exportReport(cFile)
	cRep = read(cFile)
	Then("exportReport names the objective", Has(cRep, "Objective: MAXIMIZE 3*x + 2*y"), 1)
	Then("and the value", Has(cRep, "Objective Value: 10"), 1)
	remove(cFile)

	# minimize, infeasible, unbounded
	oM2 = LsTwo()
	oM2.addConstraint("x + y", ">=", 4).minimize("3*x + 2*y")
	oM2.solve("simplex")
	Then("minimize 3x + 2y with x + y >= 4: simplex value 8 (x = 0, y = 4)", LsNear(oM2.objectiveValue(), 8), 1)
	oM2.solve("branch_bound")
	Then("and branch and bound agrees", LsNear(oM2.objectiveValue(), 8), 1)
	oM2.solve("genetic")
	Then("and the genetic search, feasible and at most 20 where the worst feasible costs 50", oM2.IsFeasible(oM2.Solution()) and oM2.objectiveValue() <= 20, 1)
	oI2 = new stzLinearSolver()
	oI2.addVariable("x", 0, 2).addVariable("y", 0, 2)
	oI2.addConstraint("x + y", ">=", 10).maximize("x + y")
	oI2.solve("branch_bound")
	Then("infeasible: branch and bound says infeasible", oI2.status(), "infeasible")
	oI2.solve("greedy")
	Then("infeasible: the greedy heuristic still says optimal (documented)", oI2.status(), "optimal")
EndScenario()

Summary()

# helpers go at the END: top-level code after a func belongs to that func

func LsCanary()
	canary = 1
	return 1

func LsNear(a, b)
	if abs(a - b) <= 0.000001
		return 1
	ok
	return 0

func Has(cText, cNeedle)
	if NOT isString(cText)
		return 0
	ok
	if substr(cText, cNeedle) > 0
		return 1
	ok
	return 0

func RaiseOf(cCode)
	gRaised = ""
	try
		eval("gDummy = " + cCode)
	catch
		gRaised = cCatchError
	done
	return gRaised

# the value of one variable in a list of [ name, value ] pairs, 0 when absent
func LsGet(aPairs, cName)
	nPairs = len(aPairs)
	for i = 1 to nPairs
		if aPairs[i][1] = cName
			return aPairs[i][2]
		ok
	next
	return 0

func LsWhole(n)
	if abs(n - floor(n + 0.5)) < 0.000000001
		return 1
	ok
	return 0

# two variables x and y in 0..10
func LsTwo()
	oMade = new stzLinearSolver()
	oMade.addVariable("x", 0, 10).addVariable("y", 0, 10)
	return oMade

# two variables x and y in 0..100
func LsBig()
	oMade = new stzLinearSolver()
	oMade.addVariable("x", 0, 100).addVariable("y", 0, 100)
	return oMade

# the status of: maximize x + y with one constraint over x and y in 0..2
func LsStatus(cExpr, cOp, nRhs)
	oMade = new stzLinearSolver()
	oMade.addVariable("x", 0, 2).addVariable("y", 0, 2)
	oMade.addConstraint(cExpr, cOp, nRhs).maximize("x + y")
	oMade.solve("simplex")
	return oMade.status()

# building a stzCoeffExtractor sets Ring's display precision to 4 decimals; the solver must put it back at once
func LsPrecisionKept()
	cNow = "" + 0.123456789
	if cNow = $lsShown
		return 1
	ok
	return 0

func LsRand(nMax)
	$lsSeed = ($lsSeed * 16807) % 2147483647
	return $lsSeed % nMax

# a random integer problem: [ :names, :bounds 0..5, :coef (rows), :op, :rhs, :obj, :goal, :wrapped ]
func LsGenProblem(iP)
	nVars = LsRand(3) + 2
	acAll = [ "a", "b", "c", "d" ]
	acNames = []
	for k = 1 to nVars
		acNames + acAll[k]
	next
	nCons = LsRand(3) + 1
	aRows = []
	acOps = []
	anRhs = []
	for r = 1 to nCons
		anRow = []
		nNonZero = 0
		for k = 1 to nVars
			nC = LsRand(7) - 2
			anRow + nC
			if nC != 0
				nNonZero++
			ok
		next
		if nNonZero = 0
			anRow[1] = 1
		ok
		nKind = LsRand(10)
		if nKind < 5
			cOp = "<="
			nRhs = LsRand(13)
		but nKind < 8
			cOp = ">="
			nRhs = LsRand(7)
		else
			cOp = "="
			nRhs = LsRand(9)
		ok
		aRows + anRow
		acOps + cOp
		anRhs + nRhs
	next
	anObj = []
	nObjNonZero = 0
	for k = 1 to nVars
		nC = LsRand(10) - 3
		anObj + nC
		if nC != 0
			nObjNonZero++
		ok
	next
	if nObjNonZero = 0
		anObj[1] = 1
	ok
	cGoal = "maximize"
	if LsRand(2) = 0
		cGoal = "minimize"
	ok
	nWrap = 0
	if iP % 5 = 0
		nWrap = 1
	ok
	return [ :names = acNames, :coef = aRows, :op = acOps, :rhs = anRhs, :obj = anObj, :goal = cGoal, :wrapped = nWrap ]

# the text of a linear expression: 3*a - b + 2*c
func LsText(anCoef, acNames)
	cT = ""
	nLen = len(anCoef)
	for i = 1 to nLen
		nC = anCoef[i]
		if nC != 0
			nAbs = nC
			if nC < 0
				nAbs = -nC
			ok
			cTerm = "" + nAbs + "*" + acNames[i]
			if nAbs = 1
				cTerm = acNames[i]
			ok
			if cT = ""
				if nC < 0
					cT = "-" + cTerm
				else
					cT = cTerm
				ok
			else
				if nC < 0
					cT = cT + " - " + cTerm
				else
					cT = cT + " + " + cTerm
				ok
			ok
		ok
	next
	return cT

func LsDescribe(aProb)
	cD = aProb[:goal] + " " + LsText(aProb[:obj], aProb[:names]) + " |"
	nRows = len(aProb[:coef])
	for r = 1 to nRows
		cD += " " + LsText(aProb[:coef][r], aProb[:names]) + " " + aProb[:op][r] + " " + aProb[:rhs][r] + ";"
	next
	if aProb[:wrapped] = 1
		cD += " wrapped"
	ok
	return cD

# the solver for a problem, with integer variables in 0..5; a wrapped problem writes everything through "( ) * 2"
func LsBuild(aProb)
	oMade = new stzLinearSolver()
	nVars = len(aProb[:names])
	for k = 1 to nVars
		oMade.addIntegerVariable(aProb[:names][k], 0, 5)
	next
	nRows = len(aProb[:coef])
	for r = 1 to nRows
		cE = LsText(aProb[:coef][r], aProb[:names])
		nR = aProb[:rhs][r]
		if aProb[:wrapped] = 1
			cE = "(" + cE + ") * 2"
			nR = nR * 2
		ok
		oMade.addConstraint(cE, aProb[:op][r], nR)
	next
	cObj = LsText(aProb[:obj], aProb[:names])
	if aProb[:wrapped] = 1
		cObj = "(" + cObj + ") * 2"
	ok
	if aProb[:goal] = "maximize"
		oMade.maximize(cObj)
	else
		oMade.minimize(cObj)
	ok
	return oMade

# does a point (a list of [ name, value ]) satisfy every constraint of the problem, by the coefficients written here
func LsFeasiblePoint(aProb, aPoint)
	nRows = len(aProb[:coef])
	nVars = len(aProb[:names])
	for r = 1 to nRows
		nLhs = 0
		for k = 1 to nVars
			nLhs += aProb[:coef][r][k] * LsGet(aPoint, aProb[:names][k])
		next
		cOp = aProb[:op][r]
		nRhs = aProb[:rhs][r]
		if cOp = "<=" and nLhs > nRhs + 0.000001
			return 0
		ok
		if cOp = ">=" and nLhs < nRhs - 0.000001
			return 0
		ok
		if cOp = "=" and abs(nLhs - nRhs) > 0.000001
			return 0
		ok
	next
	return 1

# the oracle: all 6^n points of 0..5; returns [ number of feasible points, best objective value ]
func LsBrute(aProb)
	nVars = len(aProb[:names])
	anPt = []
	for k = 1 to nVars
		anPt + 0
	next
	nTotal = 1
	for k = 1 to nVars
		nTotal *= 6
	next
	nFeasible = 0
	nBest = 0
	for iPt = 0 to nTotal - 1
		nRest = iPt
		for k = 1 to nVars
			anPt[k] = nRest % 6
			nRest = floor(nRest / 6)
		next
		bOk = 1
		nRows = len(aProb[:coef])
		for r = 1 to nRows
			nLhs = 0
			for k = 1 to nVars
				nLhs += aProb[:coef][r][k] * anPt[k]
			next
			cOp = aProb[:op][r]
			nRhs = aProb[:rhs][r]
			if cOp = "<=" and nLhs > nRhs
				bOk = 0
			ok
			if cOp = ">=" and nLhs < nRhs
				bOk = 0
			ok
			if cOp = "=" and nLhs != nRhs
				bOk = 0
			ok
		next
		if bOk = 1
			nVal = 0
			for k = 1 to nVars
				nVal += aProb[:obj][k] * anPt[k]
			next
			if nFeasible = 0
				nBest = nVal
			else
				if aProb[:goal] = "maximize"
					if nVal > nBest
						nBest = nVal
					ok
				else
					if nVal < nBest
						nBest = nVal
					ok
				ok
			ok
			nFeasible++
		ok
	next
	return [ nFeasible, nBest ]

# nCases random linear expressions over x, xx, y, yy, in three spellings; each is [ text, [ c(x), c(xx), c(y), c(yy) ] ],
# the true coefficients being computed here while the text is written, independently of the solver
func LsGenCases(nCases)
	$lsSeed = 20261022
	aNames = [ "x", "xx", "y", "yy" ]
	aOut = []
	for iCase = 1 to nCases
		nStyle = (iCase - 1) % 3 + 1
		nTerms = LsRand(4) + 1
		anCoef = [ 0, 0, 0, 0 ]
		cBody = ""
		iFirstVar = 0
		for iT = 1 to nTerms
			iVar = LsRand(4) + 1
			nA = LsRand(19) - 9
			if iT = 1
				iFirstVar = iVar
			ok
			nSpell = LsRand(3)
			nAbs = nA
			if nA < 0
				nAbs = -nA
			ok
			if nSpell = 0
				cTerm = "" + nAbs + "*" + aNames[iVar]
			but nSpell = 1
				cTerm = aNames[iVar] + "*" + nAbs
			else
				if nAbs = 1
					cTerm = aNames[iVar]
				else
					cTerm = "" + nAbs + "*" + aNames[iVar]
				ok
			ok
			cSep = " "
			if LsRand(2) = 0
				cSep = ""
			ok
			if iT = 1
				if nA < 0
					cBody = "-" + cTerm
				else
					cBody = cTerm
				ok
			else
				if nA < 0
					cBody = cBody + cSep + "-" + cSep + cTerm
				else
					cBody = cBody + cSep + "+" + cSep + cTerm
				ok
			ok
			anCoef[iVar] = anCoef[iVar] + nA
		next
		nConst = LsRand(19) - 9
		if nStyle = 1
			cText = cBody + " + " + nConst
			if nConst < 0
				cText = cBody + " - " + (-nConst)
			ok
		but nStyle = 2
			nK = LsRand(4) + 2
			cInner = "(" + cBody + " + " + nConst + ")"
			if nConst < 0
				cInner = "(" + cBody + " - " + (-nConst) + ")"
			ok
			if LsRand(2) = 0
				cText = cInner + " * " + nK + " + 4"
			else
				cText = "" + nK + "*" + cInner + " - 3"
			ok
			for i = 1 to 4
				anCoef[i] = anCoef[i] * nK
			next
		else
			nC = LsRand(9) + 1
			cText = cBody + " + " + nC + "*" + aNames[iFirstVar] + " + " + nConst
			if nConst < 0
				cText = cBody + " + " + nC + "*" + aNames[iFirstVar] + " - " + (-nConst)
			ok
			anCoef[iFirstVar] = anCoef[iFirstVar] + nC
		ok
		aOut + [ cText, anCoef ]
	next
	return aOut

# classes go last of all: a func written after a class would belong to it

class CanaryProbe
	def Run(cCode)
		eval(cCode)

# a solver whose branch and bound gives up after 20 nodes
class LsLimited from stzLinearSolver
	@nMaxNodes = 20
