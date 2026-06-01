# Narrative
# --------
# Manufacturing optimization with integer constraints
#
# Extracted from stzlinearsolvertest.ring, block #3.

load "../../../stzBase.ring"


# Goal: Decide how many chairs, tables, and desks to make 
# to maximize profit, using limited resources.
# Integer variables mean you can't produce fractional furniture.
pr()

o1 = new stzLinearSolver()
o1 {

    # Define decision variables — integer only
    # These represent how many of each item to produce (whole units)

    AddIntegerVariable("chairs", 0, 100)  # up to 100 chairs
    AddIntegerVariable("tables", 0, 50)   # up to 50 tables
    AddIntegerVariable("desks", 0, 30)    # up to 30 desks

    # Add constraints based on available resources (materials, labor, hardware)
    
    # Constraint 1: Wood usage (in board feet)
    # Chairs use 4, tables 12, desks 8 — total wood must not exceed 800

    AddConstraint("4*chairs + 12*tables + 8*desks", "<=", 800)

    # Constraint 2: Labor usage (in hours)
    # Chairs = 2 hrs, tables = 6, desks = 4 — total labor ≤ 300 hrs

    AddConstraint("2*chairs + 6*tables + 4*desks", "<=", 300)

    # Constraint 3: Hardware sets (e.g., screws, bolts)
    # Chairs = 1 set, tables = 3, desks = 2 — total hardware ≤ 150 sets

    AddConstraint("1*chairs + 3*tables + 2*desks", "<=", 150)

    # Define the profit to maximize
    # Each chair = $25, table = $80, desk = $60

    Maximize("25*chairs + 80*tables + 60*desks")

    # Solve using branch and bound (needed for integer decisions)

    Solve("branch_bound")

    # Show detailed output: model, constraints, and solution

    Show()
}

#-->
'
╭─────────╮
│ Problem │
╰─────────╯
• Variables:
 ─ chairs ∈ [0, 100] (continuous)
 ─ tables ∈ [0, 50] (continuous)
 ─ desks ∈ [0, 30] (continuous)

• Constraints:
 ─ 4*chairs + 12*tables + 8*desks <= 800
 ─ 2*chairs + 6*tables + 4*desks <= 300
 ─ 1*chairs + 3*tables + 2*desks <= 150

• Objective:
  MAXIMIZE 25*chairs + 80*tables + 60*desks

╭──────────╮
│ Solution │
╰──────────╯
• Status: optimal
• Solved in 0.07 second(s)
• Iterations: 6

• Variable Values:
 ─ chairs = 0
 ─ tables = 30
 ─ desks = 30

• Objective Value: 4200
'

#NOTE: This gives objective value: 0×25 + 30×80 + 30×60 = 4200

# However, this might not be the optimal solution. The greedy algorithm
# doesn't guarantee global optimality - it just finds a good solution
# quickly by prioritizing efficiency ratios.

# The actual optimal solution would require checking if different
# combinations could yield higher profits within the constraints.
# For true optimization, you'd need a proper simplex or branch-and-bound
# implementation.

pf()
# Executed in 0.10 second(s) in Ring 1.22
