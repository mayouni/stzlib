load "../../stzBase.ring"
load "../_narrated.ring"

# L-BFGS: FINDING THE BOTTOM OF A FUNCTION (numeric phase 6, slice 2).
#
# Slice 1 built the tape. This is what the plan said it unlocks, and the claim held:
# once gradients are free, the optimiser is a few hundred lines.
#
# WHY LIMITED MEMORY. Newton's method needs the matrix of second derivatives -- n^2
# numbers and a linear solve every step. BFGS approximates its inverse from
# successive gradients, still n^2. L-BFGS never forms the matrix at all: it keeps the
# last few (step, gradient-change) pairs and reconstructs what the matrix would have
# DONE to a vector, by a two-loop recursion. Storage falls from n^2 to about 7n --
# megabytes to kilobytes at a thousand variables.
#
# THE LINE SEARCH IS THE PART THAT IS EASY TO GET WRONG, and it is why the Rosenbrock
# scenario below is here rather than a second quadratic. A plain backtracking search
# that only insists the value goes DOWN (the Armijo condition) is much shorter, and
# it quietly breaks L-BFGS: the curvature condition is what guarantees s'y > 0, and
# s'y > 0 is what keeps the implicit inverse Hessian positive definite. Without it,
# pairs have to be discarded, the approximation degrades toward plain gradient
# descent, and nothing reports that it happened. So this is the full bracket-and-zoom
# search for the strong Wolfe conditions.
#
# THE OPTIMISER TAKES A FUNCTION POINTER, NOT A TAPE. The obvious thing was to hand
# it an autodiff Program, since that is its only caller today -- but an optimiser
# that can only minimise parsed expressions could never minimise a logistic loss over
# a resident dataset, and the whole argument for building autodiff was that gradients
# unlock optimisation GENERALLY. The tape is one implementation of the objective
# interface, not the interface.
#
# THE ANSWER IS A RECORD, for the reason the hypothesis tests return one: a bare
# point cannot tell you it did not converge. :status, :iterations, :evaluations and a
# :why in words, so a caller can tell "found it" from "gave up".

Scenario("a bowl, which should take almost no work at all")
	oO = new stzObjective("(x-1)^2 + (y-2)^2", [ "x", "y" ])
	aR = oO.MinimizeFrom([ -5, 8 ])

	Then("it lands on the minimum", Rnd6(aR[:point][1]), 1)
	Then("...in both coordinates", Rnd6(aR[:point][2]), 2)
	Then("the value there is zero", Rnd6(aR[:value]), 0)
	Then("it says it converged", aR[:status], :converged)
	# a quadratic is exactly what a quasi-Newton method is built for: the very first
	# curvature pair describes it completely
	Then("...and it took one iteration", aR[:iterations] <= 2, TRUE)
	Then("the reason is in words", StzFindFirst("gradient", aR[:why]) > 0, TRUE)
EndScenario()

Scenario("Rosenbrock, which a weak line search cannot solve")
	# The classic test: a banana-shaped valley whose floor curves, so every straight
	# step leaves it. Gradient descent needs tens of thousands of iterations and
	# usually stalls; a quasi-Newton method with a proper Wolfe line search walks it.
	oB = new stzObjective("(1-x)^2 + 100*(y - x^2)^2", [ "x", "y" ])
	aR = oB.MinimizeFrom([ -1.2, 1 ])

	Then("it finds the valley floor at x=1", Rnd4(aR[:point][1]), 1)
	Then("...and y=1", Rnd4(aR[:point][2]), 1)
	Then("the value is essentially zero", aR[:value] < 0.00000001, TRUE)
	Then("...in well under a hundred iterations", aR[:iterations] < 100, TRUE)
	# evaluations exceed iterations because the line search evaluates repeatedly --
	# reporting only iterations would understate the cost, which is why both are here
	Then("the cost is reported honestly", aR[:evaluations] > aR[:iterations], TRUE)
EndScenario()

Scenario("ill conditioning, which is what quasi-Newton is FOR")
	# Curvature a million times greater in one direction than the other. Gradient
	# descent zig-zags down the walls of a ravine like this for thousands of steps
	# because the steepest direction points almost across the valley, not along it.
	oI = new stzObjective("x^2 + 1000000*y^2", [ "x", "y" ])
	aR = oI.MinimizeFrom([ 1, 1 ])

	Then("it reaches the bottom", aR[:value] < 0.0000001, TRUE)
	Then("...in a handful of iterations, not thousands", aR[:iterations] < 50, TRUE)
	Then("x went to zero", fabs(aR[:point][1]) < 0.001, TRUE)
	Then("...and so did y", fabs(aR[:point][2]) < 0.001, TRUE)
EndScenario()

Scenario("starting at the answer is recognised, not stepped away from")
	oO = new stzObjective("(x-1)^2 + (y-2)^2", [ "x", "y" ])
	aR = oO.MinimizeFrom([ 1, 2 ])
	Then("no iterations were needed", aR[:iterations], 0)
	Then("the point did not move", aR[:point][1], 1)
	Then("...at all", aR[:point][2], 2)
	Then("and it still says converged", aR[:status], :converged)
EndScenario()

Scenario("it is deterministic, which for an optimiser is not a given")
	# Many optimisers use randomised restarts or a randomised initial step. This one
	# does not: same start, same answer, same iteration count, same evaluation count.
	# Two runs that disagree would make every result unreproducible.
	oB = new stzObjective("(1-x)^2 + 100*(y - x^2)^2", [ "x", "y" ])
	a1 = oB.MinimizeFrom([ -1.2, 1 ])
	a2 = oB.MinimizeFrom([ -1.2, 1 ])
	Then("the same point", a1[:point][1], a2[:point][1])
	Then("...to the last bit", a1[:point][2], a2[:point][2])
	Then("the same iteration count", a1[:iterations], a2[:iterations])
	Then("the same evaluation count", a1[:evaluations], a2[:evaluations])
EndScenario()

Scenario("maximising, without making you negate the expression yourself")
	# -f has the same maximiser as f has minimiser, but the VALUE comes back negated,
	# and forgetting to flip it is the obvious way to get this wrong. So it is done
	# here rather than in the docstring.
	oM = new stzObjective("-(x-3)^2 + 7", [ "x" ])
	aR = oM.MaximizeFrom([ 0 ])
	Then("the maximiser is x = 3", Rnd6(aR[:point][1]), 3)
	Then("the value is +7, not -7", Rnd6(aR[:value]), 7)

	# and a two-variable one, to be sure the flip is not a one-off
	oN = new stzObjective("10 - (x-2)^2 - (y+1)^2", [ "x", "y" ])
	aN = oN.MaximizeFrom([ 0, 0 ])
	Then("x = 2", Rnd6(aN[:point][1]), 2)
	Then("y = -1", Rnd6(aN[:point][2]), -1)
	Then("...and the peak is 10", Rnd6(aN[:value]), 10)
EndScenario()

Scenario("the objective and its gradient are the SAME function it minimises")
	# stzObjective holds a stzMathFunction rather than re-parsing the expression, so
	# the value you can ask for and the value being minimised cannot drift apart.
	# This is the one-definition rule the numeric phases keep paying for.
	oO = new stzObjective("(x-1)^2 + (y-2)^2", [ "x", "y" ])
	aR = oO.MinimizeFrom([ -5, 8 ])
	Then("evaluating at the answer reproduces the reported value",
	     Rnd6(oO.ValueAt(aR[:point])), Rnd6(aR[:value]))
	Then("...and the gradient there is flat", fabs(oO.GradientAt(aR[:point])[1]) < 0.0001, TRUE)
	Then("...in both directions", fabs(oO.GradientAt(aR[:point])[2]) < 0.0001, TRUE)
	Then("the expression is still readable back", oO.Expression(), "(x-1)^2 + (y-2)^2")
	Then("...and the variables", @@(oO.Variables()), '[ "x", "y" ]')
EndScenario()

Scenario("what it refuses")
	oO = new stzObjective("(x-1)^2 + (y-2)^2", [ "x", "y" ])
	Then("a starting point of the wrong size", RaisesMin(oO, [ 1 ]), TRUE)
	Then("...saying how many were wanted",
	     StzFindFirst("2 variable(s)", WhyMin(oO, [1])) > 0, TRUE)
	Then("a bad expression never becomes an objective",
	     RaisesObj("x + nope", ["x"]), TRUE)

	# A function with no minimum. It must not claim to have found one: the value
	# falls forever, so the search either exhausts its iterations or fails to find a
	# step -- both are honest, and neither is :converged.
	oD = new stzObjective("x", [ "x" ])
	aD = oD.MinimizeFrom([ 0 ])
	Then("an unbounded function does NOT report convergence",
	     aD[:status] != :converged, TRUE)
EndScenario()

Summary()

func Rnd6(n)
	return ceil(n * 1000000 - 0.5) / 1000000

func Rnd4(n)
	return ceil(n * 10000 - 0.5) / 10000

func RaisesMin(o, aP)
	b = FALSE
	try
		v = o.MinimizeFrom(aP)
	catch
		b = TRUE
	done
	return b

func WhyMin(o, aP)
	s = ""
	try
		v = o.MinimizeFrom(aP)
	catch
		s = cCatchError
	done
	return s

func RaisesObj(c, ac)
	b = FALSE
	try
		o = new stzObjective(c, ac)
	catch
		b = TRUE
	done
	return b
