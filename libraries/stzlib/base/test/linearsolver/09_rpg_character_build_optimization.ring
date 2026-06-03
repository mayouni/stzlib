# Narrative
# --------
# RPG Character Build Optimization
#
# Extracted from stzlinearsolvertest.ring, block #9.

load "../../stzBase.ring"

#    Goal: Allocate character attribute points to maximize combat effectiveness
#    under certain balance constraints using a genetic solver for complex preferences
pr()

o1 = new stzLinearSolver()
o1 {
    # Decision variables: character attributes, integer values between 10 and 100
    AddIntegerVariable("strength", 10, 100)       # Physical power
    AddIntegerVariable("agility", 10, 100)        # Speed and reflexes
    AddIntegerVariable("intelligence", 10, 100)   # Magical/mental power
    AddIntegerVariable("vitality", 10, 100)       # Health and stamina

    # Total attribute points must sum exactly to 200 (build budget)
    AddConstraint("strength + agility + intelligence + vitality", "=", 200)

    # Warrior viability: Strength + Vitality must be at least 80
    AddConstraint("strength + vitality", ">=", 80)

    # Skill requirements: Agility + Intelligence must be at least 60
    AddConstraint("agility + intelligence", ">=", 60)

    # Objective function (linear approximation of combat effectiveness)
    # Weights reflect relative contribution of each attribute to combat power
    Maximize("2*strength + 1.5*agility + 1.8*intelligence + 1.2*vitality")

    # Solve using a genetic algorithm to handle complex trade-offs (nonlinearities)
    Solve("genetic")

    # Output the optimized attribute distribution and the resulting effectiveness
    ? "Optimized character build:"
    ? "─ Strength: " + SolutionValue("strength")
    ? "─ Agility: " + SolutionValue("agility")
    ? "─ Intelligence: " + SolutionValue("intelligence")
    ? "─ Vitality: " + SolutionValue("vitality")
    ? "─ Combat effectiveness: " + ObjectiveValue()
}
#-->
'
Optimized character build:
─ Strength: 100
─ Agility: 10
─ Intelligence: 80
─ Vitality: 10
─ Combat effectiveness: 371
'

pf()
# Executed in 0.05 second(s) in Ring 1.22
