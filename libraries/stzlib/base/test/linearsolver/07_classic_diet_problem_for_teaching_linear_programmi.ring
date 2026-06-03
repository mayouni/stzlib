# Narrative
# --------
# Classic Diet Problem for Teaching Linear Programming
#
# Extracted from stzlinearsolvertest.ring, block #7.

load "../../stzBase.ring"

#    Goal: Minimize cost while satisfying basic nutritional needs

pr()

# Create a new linear solver instance
o1 = new stzLinearSolver()
o1 {

    # Decision variables: quantities of food items to include in the diet
    # The units here are intuitive: loaves, gallons, pounds
    AddVariable("bread", 0, 10)     # Up to 10 loaves of bread
    AddVariable("milk", 0, 8)       # Up to 8 gallons of milk
    AddVariable("cheese", 0, 5)     # Up to 5 pounds of cheese
    AddVariable("meat", 0, 3)       # Up to 3 pounds of meat

    # Nutritional constraints — daily minimums required for a balanced diet

    # Calories constraint (must meet or exceed 2000 kcal)
    AddConstraint("400*bread + 300*milk + 200*cheese + 500*meat", ">=", 2000)

    # Protein constraint (at least 60 grams)
    AddConstraint("8*bread + 12*milk + 25*cheese + 30*meat", ">=", 60)

    # Calcium constraint (at least 800 mg, mostly from milk and cheese)
    AddConstraint("0*bread + 300*milk + 200*cheese + 0*meat", ">=", 800)

    # Iron constraint (at least 15 mg, mostly from bread and meat)
    AddConstraint("2*bread + 0*milk + 0*cheese + 8*meat", ">=", 15)

    # Objective function: minimize the total cost of the diet
    # Prices per unit: Bread $2.50, Milk $4.00, Cheese $8.00, Meat $12.00
    minimize("2.50*bread + 4.00*milk + 8.00*cheese + 12.00*meat")

    # Solve the problem using the simplex method (exact for LP)
    Solve("simplex")

    # Display the optimal diet plan and its cost
    ? "Minimum cost diet plan:"
    ? "─ Bread: " + SolutionValue("bread") + " loaves"
    ? "─ Milk: " + SolutionValue("milk") + " gallons"
    ? "─ Cheese: " + SolutionValue("cheese") + " pounds"
    ? "─ Meat: " + SolutionValue("meat") + " pounds"
    ? "─ Total cost: $" + ObjectiveValue()
}
#-->
'
Minimum cost diet plan:
─ Bread: 10 loaves
─ Milk: 8 gallons
─ Cheese: 5 pounds
─ Meat: 3 pounds
─ Total cost: $133
'

pf()
# Executed in 0.12 second(s) in Ring 1.22
