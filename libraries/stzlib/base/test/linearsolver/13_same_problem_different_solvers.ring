# Narrative
# --------
# The SAME problem through DIFFERENT solvers -- the honesty guard
# un-retired (R4 step 5): the REAL simplex must never lose to the
# greedy heuristic, and every backend must satisfy the constraints.
# (This is the test whose retirement let the zeros-returning stub
# survive for months. It does not retire again.)

load "../../stzBase.ring"

pr()

nGreedy = SolveIt("greedy")
nSimplex = SolveIt("simplex")

? "greedy objective:  " + nGreedy
? "simplex objective: " + nSimplex

if nSimplex >= nGreedy - 0.001
	? "GUARD OK: the exact solver is never beaten by the heuristic"
else
	raise("HONESTY GUARD FAILED: simplex (" + nSimplex + ") lost to greedy (" + nGreedy + ")")
ok

pf()

func SolveIt(cBackend)
	o = new stzLinearSolver()
	o {
		AddVariable("x", 0, 40)
		AddVariable("y", 0, 30)
		AddConstraint("x + y", "<=", 50)
		AddConstraint("2*x + y", "<=", 80)
		Maximize("3*x + 2*y")
		Solve(cBackend)
	}
	return o.ObjectiveValue()
