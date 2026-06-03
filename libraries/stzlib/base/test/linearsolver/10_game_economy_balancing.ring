# Narrative
# --------
# Game economy balancing
#
# Extracted from stzlinearsolvertest.ring, block #10.
#ERR Error (R19) : Calling function with less number of parameters

load "../../stzBase.ring"

#     Optimize resource generation rates for balanced gameplay


pr()  # Reset solver environment

o1 = new stzLinearSolver()
o1 {
    # Define integer variables for resource generation rates (units per minute)
    AddIntegerVariable("gold_rate", 1, 50)     # Gold generation rate: min 1, max 50
    AddIntegerVariable("wood_rate", 5, 200)    # Wood generation rate: min 5, max 200
    AddIntegerVariable("food_rate", 3, 150)    # Food generation rate: min 3, max 150
    AddIntegerVariable("stone_rate", 2, 100)   # Stone generation rate: min 2, max 100

    # Constraints to balance gameplay resources and effort

    AddConstraint("gold_rate", "<=", 25)  # Limit gold generation to max 25 per minute

    # Limit wood + food combined generation to 300 (gatherer capacity)
    AddConstraint("wood_rate + food_rate", "<=", 300)

    # Total player effort constraint combining weighted resource rates
    AddConstraint("2*gold_rate + wood_rate + food_rate + stone_rate", "<=", 400)

    # Objective: maximize overall engagement value based on weighted resource importance
    Maximize("10*gold_rate + 2*wood_rate + 3*food_rate + 4*stone_rate")

    # Use branch and bound solver for integer optimization
    Solve("branch_bound")

    # Output the optimal balanced generation rates for all resources
    ? "Balanced resource generation rates:"
    ? "─ Gold: " + SolutionValue("gold_rate") + "/min"
    ? "─ Wood: " + SolutionValue("wood_rate") + "/min"
    ? "─ Food: " + SolutionValue("food_rate") + "/min"
    ? "─ Stone: " + SolutionValue("stone_rate") + "/min"
}
#-->
'
Balanced resource generation rates:
─ Gold: 25/min
─ Wood: 100/min
─ Food: 150/min
─ Stone: 100/min
'

pf()
# Executed in 0.05 second(s) in Ring 1.22

#===================================#
#   COMPLEX REAL-WORLD SCENARIOS    #
#===================================#
