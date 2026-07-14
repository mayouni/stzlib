# Narrative
# --------
# Batch production scheduling
#
# Extracted from stzlinearsolvertest.ring, block #4.

load "../../stzBase.ring"


pr()

# Weekly production schedule with setup costs
# GREEDY solver (approximate); simplex refuses honestly until the
# real implementation lands (roadmap R4)

o1 = new stzLinearSolver()
o1 {
	AddVariable("batch_a", 0, 1000)
	AddVariable("batch_b", 0, 800)
	AddVariable("batch_c", 0, 600)
	
	# Production constraints
	AddConstraint("2.5*batch_a + 3.2*batch_b + 4.1*batch_c", "<=", 4000)  # Machine hours
	AddConstraint("1.2*batch_a + 0.8*batch_b + 1.5*batch_c", "<=", 1500)  # Quality control
	AddConstraint("batch_a + batch_b + batch_c", ">=", 500)               # Min production
	
	Maximize("18*batch_a + 22*batch_b + 28*batch_c")  # Revenue
	Solve("greedy")
	
	? "Weekly production schedule:"
	? "Batch A: " + SolutionValue("batch_a") + " units"
	? "Batch B: " + SolutionValue("batch_b") + " units"
	? "Batch C: " + SolutionValue("batch_c") + " units"
}

#-->
'
Weekly production schedule:
Batch A: 0 units
Batch B: 0 units
Batch C: 500 units
'
# NOTE: greedy approximation (it meets the min-production constraint
# with the highest-ratio batch only); the richer mixed schedule shown
# in older narrations needs the real simplex (roadmap R4).

pf()
# Executed in 0.06 second(s) in Ring 1.22

#=========================#
#   FINANCIAL PLANNING    #
#=========================#
