# Narrative
# --------
# Batch production scheduling
#
# Extracted from stzlinearsolvertest.ring, block #4.

load "../../stzBase.ring"


pr()

# Weekly production schedule with setup costs
# SIMPLEX solver -- REAL since R4 step 5 (2026-07-14): exact LP optimum

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
	Solve("simplex")
	
	? "Weekly production schedule:"
	? "Batch A: " + SolutionValue("batch_a") + " units"
	? "Batch B: " + SolutionValue("batch_b") + " units"
	? "Batch C: " + SolutionValue("batch_c") + " units"
}

#-->
'
Weekly production schedule:
Batch A: 869.57 units
Batch B: 570.65 units
Batch C: 0 units
'
# The REAL simplex mixes batches at the binding vertex of the machine
# and quality constraints -- the exact revenue optimum.

pf()
# Executed in 0.06 second(s) in Ring 1.22

#=========================#
#   FINANCIAL PLANNING    #
#=========================#
