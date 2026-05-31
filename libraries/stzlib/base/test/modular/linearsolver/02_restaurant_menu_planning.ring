# Narrative
# --------
# Restaurant menu planning"
#
# Extracted from stzlinearsolvertest.ring, block #2.

load "../../../stzBase.ring"

pr()

# Planning optimal menu mix to maximize profit
# Using a GREEDY solver for fast decision-making in a restaurant context

o1 = new stzLinearSolver()
o1 {
    # Define variables: number of portions for each dish (with min and max bounds)
    AddVariable("pizza", 0, 200)   # Up to 200 pizzas can be served
    AddVariable("pasta", 0, 150)   # Up to 150 pastas
    AddVariable("salad", 0, 100)   # Up to 100 salads

    # Add kitchen constraints (resource limits)

    # Constraint on total preparation time (in minutes)
    # Pizza takes 15 min, pasta 10 min, salad 5 min — max 2000 min total
    AddConstraint("15*pizza + 10*pasta + 5*salad", "<=", 2000)

    # Constraint on chef time (in hours converted to units)
    # Pizza = 3 units, pasta = 2, salad = 1 — max 400 units (i.e. 400 chef-hours)
    AddConstraint("3*pizza + 2*pasta + 1*salad", "<=", 400)

    # Constraint on oven capacity (total dishes that require baking)
    # Only pizza and pasta use oven — limit to 250 total portions
    AddConstraint("pizza + pasta", "<=", 250)

    # Objective: maximize total profit
    # Pizza = $12, pasta = $8, salad = $6 profit per portion
    Maximize("12*pizza + 8*pasta + 6*salad")

    # Solve the problem using the greedy algorithm (fast, good-enough solution)
    Solve("greedy")
    Show()

}

#-->
'
╭─────────╮
│ Problem │
╰─────────╯
• Variables:
 ─ pizza ∈ [0, 200] (continuous)
 ─ pasta ∈ [0, 150] (continuous)
 ─ salad ∈ [0, 100] (continuous)

• Constraints:
 ─ 15*pizza + 10*pasta + 5*salad <= 2000
 ─ 3*pizza + 2*pasta + 1*salad <= 400
 ─ pizza + pasta <= 250

• Objective:
  MAXIMIZE 12*pizza + 8*pasta + 6*salad

╭──────────╮
│ Solution │
╰──────────╯
• Status: optimal
• Solved in 0.4540 second(s)
• Iterations: 3

• Variable Values:
 ─ pizza = 100
 ─ pasta = 0
 ─ salad = 100

• Objective Value: 1800
'

pf()
# Executed in 0.06 second(s) in Ring 1.22

#=======================#
#  PRODUCTION PLANNING  #
#=======================#
