/*
	stzLinearSolver Test Suite - Practical Examples by Theme
	Demonstrates when and how to use each solver strategy
	Author: Softanza Team
*/

load "../max/stzmax.ring"

#=========================#
#   RESOURCE ALLOCATION   #
#=========================#

/*--- Army recruitment optimization from the article
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

/*--- Restaurant menu planning"

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

/*--- Manufacturing optimization with integer constraints

# Goal: Decide how many chairs, tables, and desks to make 
# to maximize profit, using limited resources.
# Integer variables mean you can't produce fractional furniture.
*/
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


/*--- Batch production scheduling

pr()

# Weekly production schedule with setup costs
# SIMPLEX solver for continuous production rates

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
Batch A: 0 units
Batch B: 800 units
Batch C: 351.22 units
'

pf()
# Executed in 0.06 second(s) in Ring 1.22

#=========================#
#   FINANCIAL PLANNING    #
#=========================#

/*--- Investment portfolio optimization

pr()

# Asset allocation with risk constraints
# GREEDY solver for quick portfolio rebalancing

o1 = new stzLinearSolver()
o1 {
	AddVariable("stocks", 0, 100_000)
	AddVariable("bonds", 0, 100_000)
	AddVariable("real_estate", 0, 50_000)
	AddVariable("cash", 1_000, 20_000)  # Minimum cash reserve
	
	# Portfolio constraints
	AddConstraint("stocks + bonds + real_estate + cash", "=", 100_000) # Total budget
	AddConstraint("stocks", "<=", 60_000) # Max stock exposure
	AddConstraint("bonds + cash", ">=", 30_000) # Conservative allocation
	
	Maximize("0.08*stocks + 0.04*bonds + 0.06*real_estate + 0.01*cash") # Expected return
	Solve("greedy")
	
	? "Optimal portfolio allocation:"
	? "Stocks: $" + SolutionValue("stocks")
	? "Bonds: $" + SolutionValue("bonds")
	? "Real Estate: $" + SolutionValue("real_estate")
	? "Cash: $" + SolutionValue("cash")
	? "Expected annual return: $" + ObjectiveValue()
}
#-->
'
Optimal portfolio allocation:
Stocks: $49000
Bonds: $0
Real Estate: $50000
Cash: $1000
Expected annual return: $6930
'

pf()
# Executed in 0.04 second(s) in Ring 1.22

/*--- Budget allocation across departments

pr()

# Corporate budget distribution with minimum requirements
# SIMPLEX solver handles equality and inequality constraints well

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
 ─ marketing = 90000
 ─ rd = 300000
 ─ operations = 80000
 ─ hr = 30000

• Objective Value: 343000
'

pf()
# Executed in 0.08 second(s) in Ring 1.22

#===========================#
#   EDUCATIONAL EXAMPLES    #
#===========================#

/*--- Classic Diet Problem for Teaching Linear Programming
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

/*--- Transportation Problem for Logistics Education
#     Goal: Minimize shipping costs while meeting supply & demand constraints

pr()

o1 = new stzLinearSolver()
o1 {
    # Decision variables: shipment quantities along each route
    # From two warehouses (w1, w2) to three stores (s1, s2, s3)
    AddVariable("w1_s1", 0, 1000)  # Units shipped from Warehouse 1 to Store 1
    AddVariable("w1_s2", 0, 1000)  # Warehouse 1 → Store 2
    AddVariable("w1_s3", 0, 1000)  # Warehouse 1 → Store 3
    AddVariable("w2_s1", 0, 1000)  # Warehouse 2 → Store 1
    AddVariable("w2_s2", 0, 1000)  # Warehouse 2 → Store 2
    AddVariable("w2_s3", 0, 1000)  # Warehouse 2 → Store 3

    # Supply constraints: total shipments from each warehouse ≤ its capacity
    AddConstraint("w1_s1 + w1_s2 + w1_s3", "<=", 500)  # Warehouse 1 capacity limit
    AddConstraint("w2_s1 + w2_s2 + w2_s3", "<=", 600)  # Warehouse 2 capacity limit

    # Demand constraints: total shipments to each store = its demand
    AddConstraint("w1_s1 + w2_s1", "=", 300)  # Store 1 demand requirement
    AddConstraint("w1_s2 + w2_s2", "=", 400)  # Store 2 demand requirement
    AddConstraint("w1_s3 + w2_s3", "=", 350)  # Store 3 demand requirement

    # Objective: minimize total shipping cost
    # Costs per unit shipped along each route are given
    minimize("5*w1_s1 + 8*w1_s2 + 6*w1_s3 + 7*w2_s1 + 4*w2_s2 + 9*w2_s3")

    # Solve using a GREEDY heuristic for fast approximate solution
    Solve("greedy")

    # Display the optimal shipping plan and cost
    ? "Optimal shipping plan:"
    ? "─ W1→S1: " + SolutionValue("w1_s1") + " units"
    ? "─ W1→S2: " + SolutionValue("w1_s2") + " units"
    ? "─ W1→S3: " + SolutionValue("w1_s3") + " units"
    ? "─ W2→S1: " + SolutionValue("w2_s1") + " units"
    ? "─ W2→S2: " + SolutionValue("w2_s2") + " units"
    ? "─ W2→S3: " + SolutionValue("w2_s3") + " units"
    ? "─ Total shipping cost: $" + ObjectiveValue()
}

#-->
'
Optimal shipping plan:
─ W1→S1: 300 units
─ W1→S2: 0 units
─ W1→S3: 200 units
─ W2→S1: 0 units
─ W2→S2: 400 units
─ W2→S3: 150 units
─ Total shipping cost: $5650
'

pf()
# Executed in 0.05 second(s) in Ring 1.22

#==========================#
#   GAMING APPLICATIONS    #
#==========================#

/*--- RPG Character Build Optimization
#    Goal: Allocate character attribute points to maximize combat effectiveness
#    under certain balance constraints using a genetic solver for complex preferences
*/
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

/*--- Game economy balancing
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

/*--- Event Planning with Multiple Constraints
#     Optimize wedding event parameters balancing guests and budget

pr()  # Reset solver environment

o1 = new stzLinearSolver()
o1 {
    # Decision variables:
    # Guests is an integer variable within realistic limits for a venue
    AddIntegerVariable("guests", 50, 200)    

    # Budget allocations for key vendors, continuous variables within set ranges
    AddVariable("catering_cost", 2000, 15000)
    AddVariable("venue_cost", 1000, 8000)
    AddVariable("decoration_cost", 500, 3000)

    # Constraints to ensure feasibility and budget adherence

    # Total vendor costs must not exceed overall event budget
    AddConstraint("catering_cost + venue_cost + decoration_cost", "<=", 20000)

    # Ensure minimum catering budget per guest (e.g., $25 per guest)
    AddConstraint("25*guests", "<=", "catering_cost")

    # Guests must not exceed venue capacity limit
    AddConstraint("guests", "<=", 150)

    # Objective function aiming to maximize overall satisfaction score
    # Weighted sum reflecting the impact of guests and budget allocations
    Maximize("guests + 0.1*catering_cost + 0.05*venue_cost + 0.2*decoration_cost")

    # Use genetic solver to handle complex, possibly non-linear tradeoffs
    Solve("genetic")

    # Output the optimized event parameters and satisfaction score
    ? "Optimal event plan:"
    ? "─ Guests: " + SolutionValue("guests")
    ? "─ Catering budget: $" + SolutionValue("catering_cost")
    ? "─ Venue budget: $" + SolutionValue("venue_cost")
    ? "─ Decoration budget: $" + SolutionValue("decoration_cost")
    ? "─ Satisfaction score: " + ObjectiveValue()
}
#-->
'
Optimal event plan:
─ Guests: 50
─ Catering budget: $15000
─ Venue budget: $2000
─ Decoration budget: $3000
─ Satisfaction score: 2250
'

pf()
# Executed in 0.05 second(s) in Ring 1.22

/*--- Supply Chain Optimization with Uncertainty
#     Optimize inventory and production rates under demand fluctuation

pr()  # Reset solver environment

o1 = new stzLinearSolver()
o1 {
    # Variables representing inventory levels at various stages
    AddVariable("raw_inventory", 0, 10000)        # Raw materials stock
    AddVariable("wip_inventory", 0, 5000)         # Work-in-progress inventory
    AddVariable("finished_inventory", 0, 8000)    # Finished goods inventory

    # Variables representing production and shipping rates (units per day)
    AddVariable("production_rate", 100, 2000)     # Production throughput
    AddVariable("shipping_rate", 50, 1500)        # Shipping capacity

    # Constraints modeling supply chain dynamics and safety requirements

    # Safety stock: raw inventory must be at least 1.2 times production rate
    AddConstraint("raw_inventory", ">=", "1.2*production_rate")

    # WIP buildup limit: production rate cannot exceed shipping rate by more than 200 units
    AddConstraint("production_rate", "<=", "shipping_rate + 200")

    # Demand fulfillment: finished inventory plus shipping rate must cover demand of 1200 units
    AddConstraint("finished_inventory + shipping_rate", ">=", 1200)

    # Objective: minimize total daily costs including inventory holding, production, and shipping
    minimize("5*raw_inventory + 15*wip_inventory + 8*finished_inventory + 10*production_rate + 12*shipping_rate")

    # Use genetic solver for handling complexity and uncertainty in constraints
    Solve("genetic")

    # Output optimized supply chain parameters and cost
    ? "Optimized supply chain:"
    ? "─ Raw inventory: " + SolutionValue("raw_inventory") + " units"
    ? "─ WIP inventory: " + SolutionValue("wip_inventory") + " units"
    ? "─ Finished inventory: " + SolutionValue("finished_inventory") + " units"
    ? "─ Production rate: " + SolutionValue("production_rate") + " units/day"
    ? "─ Shipping rate: " + SolutionValue("shipping_rate") + " units/day"
    ? "─ Total cost: $" + ObjectiveValue() + "/day"
}
#-->
'
Optimized supply chain:
─ Raw inventory: 10000 units
─ WIP inventory: 5000 units
─ Finished inventory: 8000 units
─ Production rate: 100 units/day
─ Shipping rate: 1500 units/day
─ Total cost: $208000/day
'

pf()
# Executed in 0.05 second(s) in Ring 1.22

#========================#
#   SOLVER COMPARISON    #
#========================#

/*--- Same problem, different solvers
#     Compare solver performance and results on identical LP

pr()  # Reset solver environment

? BoxRound("SOLVER COMPARISON")
? "Problem: Maximize 3x + 2y subject to x + y <= 100, x <= 60, y <= 80"
? ""

for cSolver in ["greedy", "simplex", "branch_bound", "genetic"]
    ? "• Solver: " + upper(cSolver)

    oTest = new stzLinearSolver()
    oTest {
        # Define continuous variables with wide bounds
        AddVariable("x", 0, 1000)
        AddVariable("y", 0, 1000)

        # Add constraints defining feasible region
        AddConstraint("x + y", "<=", 100)
        AddConstraint("x", "<=", 60)
        AddConstraint("y", "<=", 80)

        # Objective: maximize weighted sum of x and y
        Maximize("3*x + 2*y")

        # Measure solving time for each solver
        nStart = clock()
        Solve(cSolver)
        nTime = clock() - nStart

        # Display results and performance metrics
        ? "─ x = " + SolutionValue("x")
        ? "─ y = " + SolutionValue("y")
        ? "─ Objective = " + ObjectiveValue()
        ? "─ Time = " + nTime + "ms"
        ? "─ Status = " + status()
        ? ""
    }
next

#-->
'
╭───────────────────╮
│ SOLVER COMPARISON │
╰───────────────────╯
Problem: Maximize 3x + 2y subject to x + y <= 100, x <= 60, y <= 80

• Solver: GREEDY
─ x = 60
─ y = 40
─ Objective = 260
─ Time = 29ms
─ Status = optimal

• Solver: SIMPLEX
─ x = 60
─ y = 40
─ Objective = 260
─ Time = 5ms
─ Status = optimal

• Solver: BRANCH_BOUND
─ x = 60
─ y = 40
─ Objective = 260
─ Time = 5ms
─ Status = optimal

• Solver: GENETIC
─ x = 60
─ y = 40
─ Objective = 260
─ Time = 5ms
─ Status = optimal
'

pf()
# Executed in 16.98 second(s) in Ring 1.22

#======================#
#   USAGE GUIDELINES   #
#======================#

/*
WHEN TO USE EACH SOLVER:

GREEDY (Default):
- Quick business decisions
- Resource allocation problems
- When "good enough" solutions are acceptable
- Teaching efficiency concepts
- Time: 1-10ms

SIMPLEX:
- Educational purposes
- Continuous variables only
- Classic LP problems
- When optimality guarantee is needed
- Time: 5-15ms

BRANCH_BOUND:
- Integer/discrete requirements
- Scheduling problems
- Assignment problems
- When exact integer solutions needed
- Time: 10-50ms

GENETIC:
- Complex constraints
- Non-linear relationships
- Large solution spaces
- When other methods fail
- Uncertain/noisy problems
- Time: 20-100ms

PROBLEM SIZE GUIDELINES:
- Small (< 10 variables): Any solver
- Medium (10-50 variables): Greedy or Genetic
- Large (50+ variables): Greedy only

CONSTRAINT COMPLEXITY:
- Simple linear: Greedy or Simplex
- Integer requirements: Branch_Bound
- Complex/non-linear: Genetic
*/
