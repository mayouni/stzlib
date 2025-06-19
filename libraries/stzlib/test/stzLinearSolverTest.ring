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
# GREEDY solver works well - Maximizes efficiency ratios

o1 = new stzLinearSolver()
o1 {
	AddIntegerVariable("swordsmen", 0, 1000)
	AddIntegerVariable("bowmen", 0, 1000)  
	AddIntegerVariable("horsemen", 0, 1000)

	# Resource constraints
	AddConstraint("60*swordsmen + 80*bowmen + 140*horsemen", "<=", 1200)  # Food
	AddConstraint("20*swordsmen + 10*bowmen", "<=", 800)                  # Wood
	AddConstraint("40*bowmen + 100*horsemen", "<=", 600)                  # Gold
	
	Maximize("70*swordsmen + 95*bowmen + 230*horsemen")  # Power
	Solve("greedy")

	show()
}
#TODO See why objective value = 0
#-->
'
╭────────────────────────────╮
│ Linear Programming Problem │
╰────────────────────────────╯
• Variables:
  swordsmen ∈ [0, 1000] (continuous)
  bowmen ∈ [0, 1000] (continuous)
  horsemen ∈ [0, 1000] (continuous)

• Constraints:
  60*swordsmen + 80*bowmen + 140*horsemen <= 1200
  20*swordsmen + 10*bowmen <= 800
  40*bowmen + 100*horsemen <= 600

• Objective:
  Maximize 70*swordsmen + 95*bowmen + 230*horsemen

╭──────────╮
│ Solution │
╰──────────╯
• Status: optimal
• Solved in 0.06 second(s)
• Iterations: 6

• Variable Values:
  swordsmen = 600
  bowmen = 0
  horsemen = 600

• Objective Value: 0
'

pf()
# Executed in 0.09 second(s) in Ring 1.22

/*--- Restaurant menu planning

pr()
# Planning optimal menu mix to Maximize profit
# GREEDY solver ideal for quick business decisions

o2 = new stzLinearSolver()
o2 {
	AddVariable("pizza", 0, 200)
	AddVariable("pasta", 0, 150)
	AddVariable("salad", 0, 100)
	
	# Kitchen constraints
	AddConstraint("15*pizza + 10*pasta + 5*salad", "<=", 2000)   # Prep time (minutes)
	AddConstraint("3*pizza + 2*pasta + 1*salad", "<=", 400)      # Chef time (hours)
	AddConstraint("pizza + pasta", "<=", 250)                    # Oven capacity
	
	Maximize("12*pizza + 8*pasta + 6*salad")  # Profit per item
	Solve("greedy")
	
	? "Daily menu recommendation:"
	? "• Pizza: " + SolutionValue("pizza") + " portions"
	? "• Pasta: " + SolutionValue("pasta") + " portions" 
	? "• Salad: " + SolutionValue("salad") + " portions"
	? "• Expected profit: $" + ObjectiveValue()
}

#-->
'
Daily menu recommendation:
• Pizza: 200 portions
• Pasta: 50 portions
• Salad: 100 portions
• Expected profit: $3400
'

pf()
# Executed in 0.07 second(s) in Ring 1.22

#=======================#
#  PRODUCTION PLANNING  #
#=======================#

/*--- Manufacturing optimization with integer constraints

pr()
# Product mix with discrete units requiring exact quantities
# BRANCH_BOUND solver handles integer constraints properly

o1 = new stzLinearSolver()
o1 {
	AddIntegerVariable("chairs", 0, 100)
	AddIntegerVariable("tables", 0, 50)
	AddIntegerVariable("desks", 0, 30)
	
	# Material constraints
	AddConstraint("4*chairs + 12*tables + 8*desks", "<=", 800)  # Wood (board feet)
	AddConstraint("2*chairs + 6*tables + 4*desks", "<=", 300)   # Labor (hours)
	AddConstraint("1*chairs + 3*tables + 2*desks", "<=", 150)   # Hardware sets
	
	Maximize("25*chairs + 80*tables + 60*desks")  # Profit
	Solve("branch_bound")
	Show()
}

#TODO See why ObjectiveValue = 0
#-->
'
╭────────────────────────────╮
│ Linear Programming Problem │
╰────────────────────────────╯
• Variables:
  chairs ∈ [0, 100] (continuous)
  tables ∈ [0, 50] (continuous)
  desks ∈ [0, 30] (continuous)

• Constraints:
  4*chairs + 12*tables + 8*desks <= 800
  2*chairs + 6*tables + 4*desks <= 300
  1*chairs + 3*tables + 2*desks <= 150

• Objective:
  Maximize 25*chairs + 80*tables + 60*desks

╭──────────╮
│ Solution │
╰──────────╯
• Status: optimal
• Solved in 0.00 second(s)
• Iterations: 0

• Variable Values:
  chairs = 0
  tables = 0
  desks = 0

• Objective Value: 0
'

pf()
# Executed in 0.04 second(s) in Ring 1.22

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

#TODO: see why values are all zeros!
#-->
'
Weekly production schedule:
Batch A: 0 units
Batch B: 0 units
Batch C: 0 units
'

pf()
# Executed in almost 0 second(s) in Ring 1.22

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
	AddConstraint("stocks + bonds + real_estate + cash", "=", 100_000)  # Total budget
	AddConstraint("stocks", "<=", 60_000)                               # Max stock exposure
	AddConstraint("bonds + cash", ">=", 30_000)                         # Conservative allocation
	
	Maximize("0.08*stocks + 0.04*bonds + 0.06*real_estate + 0.01*cash")  # Expected return
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
# Executed in 0.06 second(s) in Ring 1.22

/*--- Budget allocation across departments

pr()

# Corporate budget distribution with minimum requirements
# SIMPLEX solver handles equality and inequality constraints well

o6 = new stzLinearSolver()
o6 {
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
#TODO: see why results are zeros!
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
  Maximize 0.6*marketing + 0.8*rd + 0.5*operations + 0.3*hr

╭──────────╮
│ Solution │
╰──────────╯
• Status: optimal
• Solved in 0 second(s)
• Iterations: 0

• Variable Values:
 ─ marketing = 0
 ─ rd = 0
 ─ operations = 0
 ─ hr = 0

• Objective Value: 0
'

pf()
# Executed in 0.03 second(s) in Ring 1.22

#===========================#
#   EDUCATIONAL EXAMPLES    #
#===========================#

/*--- Classic diet problem for nutrition education

pr()
# Teaching linear programming fundamentals
# SIMPLEX solver demonstrates classic LP methodology

o1 = new stzLinearSolver()
o1 {
	AddVariable("bread", 0, 10)    # Loaves
	AddVariable("milk", 0, 8)      # Gallons  
	AddVariable("cheese", 0, 5)    # Pounds
	AddVariable("meat", 0, 3)      # Pounds
	
	# Nutritional requirements (daily minimums)
	AddConstraint("400*bread + 300*milk + 200*cheese + 500*meat", ">=", 2000)  # Calories
	AddConstraint("8*bread + 12*milk + 25*cheese + 30*meat", ">=", 60)         # Protein (g)
	AddConstraint("0*bread + 300*milk + 200*cheese + 0*meat", ">=", 800)       # Calcium (mg)
	AddConstraint("2*bread + 0*milk + 0*cheese + 8*meat", ">=", 15)            # Iron (mg)
	
	minimize("2.50*bread + 4.00*milk + 8.00*cheese + 12.00*meat")  # Cost
	Solve("simplex")
	
	? "Minimum cost diet plan:"
	? "─ Bread: " + SolutionValue("bread") + " loaves"
	? "─ Milk: " + SolutionValue("milk") + " gallons"
	? "─ Cheese: " + SolutionValue("cheese") + " pounds"
	? "─ Meat: " + SolutionValue("meat") + " pounds"
	? "─ Total cost: $" + ObjectiveValue()
}
#TODO See why outputs are zeros!
#-->
'
Minimum cost diet plan:
─ Bread: 0 loaves
─ Milk: 0 gallons
─ Cheese: 0 pounds
─ Meat: 0 pounds
─ Total cost: $0
'

pf()
# Executed in 0.01 second(s) in Ring 1.22

/*--- Transportation problem for logistics education

pr()
# Classic network flow problem
# GREEDY solver good for understanding allocation logic

o1 = new stzLinearSolver()
o1 {
	# Routes from 2 warehouses to 3 stores
	AddVariable("w1_s1", 0, 1000)  # Warehouse 1 to Store 1
	AddVariable("w1_s2", 0, 1000)  # Warehouse 1 to Store 2
	AddVariable("w1_s3", 0, 1000)  # Warehouse 1 to Store 3
	AddVariable("w2_s1", 0, 1000)  # Warehouse 2 to Store 1
	AddVariable("w2_s2", 0, 1000)  # Warehouse 2 to Store 2
	AddVariable("w2_s3", 0, 1000)  # Warehouse 2 to Store 3
	
	# Supply constraints
	AddConstraint("w1_s1 + w1_s2 + w1_s3", "<=", 500)  # Warehouse 1 capacity
	AddConstraint("w2_s1 + w2_s2 + w2_s3", "<=", 600)  # Warehouse 2 capacity
	
	# Demand constraints  
	AddConstraint("w1_s1 + w2_s1", "=", 300)  # Store 1 demand
	AddConstraint("w1_s2 + w2_s2", "=", 400)  # Store 2 demand
	AddConstraint("w1_s3 + w2_s3", "=", 350)  # Store 3 demand
	
	# Minimize shipping costs
	minimize("5*w1_s1 + 8*w1_s2 + 6*w1_s3 + 7*w2_s1 + 4*w2_s2 + 9*w2_s3")
	Solve("greedy")
	
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
─ W1→S1: 0 units
─ W1→S2: 100 units
─ W1→S3: 350 units
─ W2→S1: 300 units
─ W2→S2: 300 units
─ W2→S3: 0 units
─ Total shipping cost: $6200
'

pf()
# Executed in 0.08 second(s) in Ring 1.22

#==========================#
#   GAMING APPLICATIONS    #
#==========================#

/*--- RPG character build optimization

pr()

# Game balance testing with non-linear preferences
# GENETIC solver handles complex, conflicting objectives

o1 = new stzLinearSolver()
o1 {
	AddIntegerVariable("strength", 10, 100)
	AddIntegerVariable("agility", 10, 100)
	AddIntegerVariable("intelligence", 10, 100)
	AddIntegerVariable("vitality", 10, 100)
	
	# Character constraints
	AddConstraint("strength + agility + intelligence + vitality", "=", 200)  # Total points
	AddConstraint("strength + vitality", ">=", 80) # Warrior viability
	AddConstraint("agility + intelligence", ">=", 60) # Skill requirements
	
	# Complex effectiveness function (simplified for LP)
	Maximize("2*strength + 1.5*agility + 1.8*intelligence + 1.2*vitality")
	Solve("genetic")
	
	? "Please wait..." + NL

	? "Optimized character build:"
	? "─ Strength: " + SolutionValue("strength")
	? "─ Agility: " + SolutionValue("agility")
	? "─ Intelligence: " + SolutionValue("intelligence")
	? "─ Vitality: " + SolutionValue("vitality")
	? "─ Combat effectiveness: " + ObjectiveValue()

}
#TODO see why Combat effectiveness returns 0
#-->
'
Optimized character build:
─ Strength: 54
─ Agility: 24
─ Intelligence: 77
─ Vitality: 45
─ Combat effectiveness: 0
'

pf()
# Executed in 45.95 second(s) in Ring 1.22

/*--- Game economy balancing

pr()
# Resource generation rates for balanced gameplay
# BRANCH_BOUND for discrete resource packets

o1 = new stzLinearSolver()
o1 {
	AddIntegerVariable("gold_rate", 1, 50)     # Gold per minute
	AddIntegerVariable("wood_rate", 5, 200)    # Wood per minute
	AddIntegerVariable("food_rate", 3, 150)    # Food per minute
	AddIntegerVariable("stone_rate", 2, 100)   # Stone per minute
	
	# Balance constraints
	AddConstraint("gold_rate", "<=", 25)                                    # Max gold generation
	AddConstraint("wood_rate + food_rate", "<=", 300)                       # Gatherer limit
	AddConstraint("2*gold_rate + wood_rate + food_rate + stone_rate", "<=", 400)  # Total effort
	
	# Maximize player engagement (balanced resource flow)
	Maximize("10*gold_rate + 2*wood_rate + 3*food_rate + 4*stone_rate")
	Solve("branch_bound")
	
	? "Balanced resource generation rates:"
	? "─ Gold: " + SolutionValue("gold_rate") + "/min"
	? "─ Wood: " + SolutionValue("wood_rate") + "/min"
	? "─ Food: " + SolutionValue("food_rate") + "/min"
	? "─ Stone: " + SolutionValue("stone_rate") + "/min"
}
#TODO See whi returns are all 0s!
#-->
'
Balanced resource generation rates:
─ Gold: 0/min
─ Wood: 0/min
─ Food: 0/min
─ Stone: 0/min
'

pf()
# Execution time: ~12ms

#===================================#
#   COMPLEX REAL-WORLD SCENARIOS    #
#===================================#

/*--- Event planning with multiple constraints

pr()

# Wedding planning with vendor coordination
# GENETIC solver handles complex, interdependent constraints

o11 = new stzLinearSolver()
o11 {
	AddIntegerVariable("guests", 50, 200)
	AddVariable("catering_cost", 2_000, 15_000)
	AddVariable("venue_cost", 1_000, 8_000)
	AddVariable("decoration_cost", 500, 3_000)
	
	# Budget and space constraints
	AddConstraint("catering_cost + venue_cost + decoration_cost", "<=", 20_000)  # Total budget
	AddConstraint("25*guests", "<=", "catering_cost") # Min catering per guest
	AddConstraint("guests", "<=", 150) # Venue capacity
	
	# Maximize satisfaction (complex relationship)
	Maximize("guests + 0.1*catering_cost + 0.05*venue_cost + 0.2*decoration_cost")
	Solve("genetic")

	? "Optimal event plan:"
	? "─ Guests: " + SolutionValue("guests")
	? "─ Catering budget: $" + SolutionValue("catering_cost")
	? "─ Venue budget: $" + SolutionValue("venue_cost")
	? "─ Decoration budget: $" + SolutionValue("decoration_cost")
	? "─ Satisfaction score: " + ObjectiveValue()
}
#TODO See why Staisfaction score is 0!
#-->
'
Optimal event plan:
─ Guests: 50
─ Catering budget: $11697
─ Venue budget: $7253
─ Decoration budget: $1041
─ Satisfaction score: 0
'

pf()
# Executed in 32.06 second(s) in Ring 1.22

/*--- Supply chain optimization with uncertainty
*/

pr()

# Multi-tier supply chain with demand fluctuation
# GENETIC solver robust against uncertainty and complexity

o1 = new stzLinearSolver()
o1 {
	# Inventory levels at different stages
	AddVariable("raw_inventory", 0, 10000)
	AddVariable("wip_inventory", 0, 5000)
	AddVariable("finished_inventory", 0, 8000)
	
	# Production rates
	AddVariable("production_rate", 100, 2000)
	AddVariable("shipping_rate", 50, 1500)
	
	# Supply chain constraints
	AddConstraint("raw_inventory", ">=", "1.2*production_rate")              # Safety stock
	AddConstraint("production_rate", "<=", "shipping_rate + 200")            # WIP buildup limit
	AddConstraint("finished_inventory + shipping_rate", ">=", 1200)          # Customer demand
	
	# Minimize total costs (inventory + production + shipping)
	minimize("5*raw_inventory + 15*wip_inventory + 8*finished_inventory + 10*production_rate + 12*shipping_rate")
	Solve("genetic")

	? "Optimized supply chain:"
	? "─ Raw inventory: " + SolutionValue("raw_inventory") + " units"
	? "─ WIP inventory: " + SolutionValue("wip_inventory") + " units"
	? "─ Finished inventory: " + SolutionValue("finished_inventory") + " units"
	? "─ Production rate: " + SolutionValue("production_rate") + " units/day"
	? "─ Shipping rate: " + SolutionValue("shipping_rate") + " units/day"
	? "─ Total cost: $" + ObjectiveValue() + "/day"
}
#TODO See why total cost is 0
#-->
'
Optimized supply chain:
─ Raw inventory: 7589 units
─ WIP inventory: 986 units
─ Finished inventory: 398 units
─ Production rate: 1857 units/day
─ Shipping rate: 165 units/day
─ Total cost: $0/day
'

pf()
# Executed in 32.71 second(s) in Ring 1.22

#========================#
#   SOLVER COMPARISON    #
#========================#

/*--- Same problem, different solvers

pr()
# Comparing solver performance on identical problem
# Shows when each approach works best

? "=== SOLVER COMPARISON ==="
? "Problem: Maximize 3x + 2y subject to x + y <= 100, x <= 60, y <= 80"
? ""

for cSolver in ["greedy", "simplex", "branch_bound", "genetic"]
	? "Solver: " + upper(cSolver)
	
	oTest = new stzLinearSolver()
	oTest {
		AddVariable("x", 0, 1000)
		AddVariable("y", 0, 1000)
		AddConstraint("x + y", "<=", 100)
		AddConstraint("x", "<=", 60)
		AddConstraint("y", "<=", 80)
		Maximize("3*x + 2*y")
		
		nStart = clock()
		Solve(cSolver)
		nTime = clock() - nStart
		
		? "  x = " + SolutionValue("x")
		? "  y = " + SolutionValue("y")
		? "  Objective = " + ObjectiveValue()
		? "  Time = " + nTime + "ms"
		? "  Status = " + status()
		? ""
	}
next

pf()

#====================#
#   USAGE GUIDELINES    #
#====================#

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
