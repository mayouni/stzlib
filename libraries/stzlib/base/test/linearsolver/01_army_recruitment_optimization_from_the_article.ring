# Narrative
# --------
# Army recruitment optimization from the article
#
# Extracted from stzlinearsolvertest.ring, block #1.

load "../../stzBase.ring"

# https://towardsdatascience.com/introduction-to-linear-programming-in-python-9261e7eb44b/

pr()

# Classic resource allocation with multiple constraints
# Scenario: Choosing the optimal mix of military units to maximize total army power
# Solver: GREEDY — fast and prioritizes units with the best power-to-resource efficiency

o1 = new stzLinearSolver()
o1 {
    # Decision variables: number of units of each type to recruit
    # Variables are integers: you can’t recruit half a soldier!
    AddIntegerVariable("swordsmen", 0, 1000)
    AddIntegerVariable("bowmen", 0, 1000)  
    AddIntegerVariable("horsemen", 0, 1000)

    # Resource constraints: total available resources are limited

    # FOOD constraint (in arbitrary units):
    # Swordsmen = 60, Bowmen = 80, Horsemen = 140 → max total: 1200
    AddConstraint("60*swordsmen + 80*bowmen + 140*horsemen", "<=", 1200)

    # WOOD constraint:
    # Only Swordsmen and Bowmen use wood → total must not exceed 800
    AddConstraint("20*swordsmen + 10*bowmen", "<=", 800)

    # GOLD constraint:
    # Only Bowmen and Horsemen need gold → total must not exceed 600
    AddConstraint("40*bowmen + 100*horsemen", "<=", 600)

    # Objective: maximize army power
    # Power per unit: Swordsmen = 70, Bowmen = 95, Horsemen = 230
    Maximize("70*swordsmen + 95*bowmen + 230*horsemen")

    # Use a greedy strategy (fast, good heuristic)
    Solve("greedy")

    # Display the result
    show()
}
#-->
'
╭─────────╮
│ Problem │
╰─────────╯
• Variables:
 ─ swordsmen ∈ [0, 1000] (continuous)
 ─ bowmen ∈ [0, 1000] (continuous)
 ─ horsemen ∈ [0, 1000] (continuous)

• Constraints:
 ─ 60*swordsmen + 80*bowmen + 140*horsemen <= 1200
 ─ 20*swordsmen + 10*bowmen <= 800
 ─ 40*bowmen + 100*horsemen <= 600

• Objective:
  MAXIMIZE 70*swordsmen + 95*bowmen + 230*horsemen

╭──────────╮
│ Solution │
╰──────────╯
• Status: optimal
• Solved in 0.06 second(s)
• Iterations: 6

• Variable Values:
 ─ swordsmen = 6
 ─ bowmen = 0
 ─ horsemen = 6

• Objective Value: 1800
'

pf()
# Executed in 0.09 second(s) in Ring 1.22
