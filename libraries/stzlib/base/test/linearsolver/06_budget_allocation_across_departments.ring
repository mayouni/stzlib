# Narrative
# --------
# Budget allocation across departments
#
# Extracted from stzlinearsolvertest.ring, block #6.

load "../../stzBase.ring"


pr()

# Corporate budget distribution with minimum requirements
# SIMPLEX solver -- REAL since R4 step 5 (2026-07-14): exact LP optimum

o1 = new stzLinearSolver()
o1 {
	AddVariable("marketing", 50_000, 200_000)
	AddVariable("rd", 100_000, 300_000)
	AddVariable("operations", 80_000, 250_000)
	AddVariable("hr", 30_000, 100_000)

	# Budget constraints
	AddConstraint("marketing + rd + operations + hr", "=", 500_000) # Total budget
	AddConstraint("rd", ">=", 150_000) # Min R&D investment
	AddConstraint("marketing + operations", ">=", 200_000) # Core operations

	# Maximize weighted business value
	Maximize("0.6*marketing + 0.8*rd + 0.5*operations + 0.3*hr")
	Solve("simplex")
	Show()
}
#-->
'
╭─────────╮
│ Problem │
╰─────────╯
• Variables:
 ─ marketing ∈ [50000, 200000] (continuous)
 ─ rd ∈ [100000, 300000] (continuous)
 ─ operations ∈ [80000, 250000] (continuous)
 ─ hr ∈ [30000, 100000] (continuous)

• Constraints:
 ─ marketing + rd + operations + hr = 500000
 ─ rd >= 150000
 ─ marketing + operations >= 200000

• Objective:
  MAXIMIZE 0.6*marketing + 0.8*rd + 0.5*operations + 0.3*hr

╭──────────╮
│ Solution │
╰──────────╯
• Status: optimal
• Solved in 0.04 second(s)
• Iterations: 4

• Variable Values:
 ─ marketing = 120000
 ─ rd = 270000
 ─ operations = 80000
 ─ hr = 30000

• Objective Value: 337000
'
# TRUE OPTIMUM: 337000. (The pre-2026 narration claimed 343000 with
# rd=300000 -- that point is INFEASIBLE: it violates
# marketing+operations >= 200000. Verified independently in Python.)

pf()
# Executed in 0.08 second(s) in Ring 1.22

#===========================#
#   EDUCATIONAL EXAMPLES    #
#===========================#
