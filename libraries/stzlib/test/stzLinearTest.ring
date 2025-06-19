/*
	stzLinear Test Suite - Practical Examples by Theme
	Demonstrates when and how to use each solver strategy
	Author: Softanza Team
*/

load "../max/stzmax.ring"

#=========================#
#   RESOURCE ALLOCATION   #
#=========================#

/*--- Army recruitment optimization from the article
*/
pr()
# Classic resource allocation with multiple constraints
# GREEDY solver works well - maximizes efficiency ratios

o1 = new stzLinear()
o1 {
	addIntegerVariable("swordsmen", 0, 1000)
	addIntegerVariable("bowmen", 0, 1000)  
	addIntegerVariable("horsemen", 0, 1000)
	
	# Resource constraints
	addConstraint("60*swordsmen + 80*bowmen + 140*horsemen", "<=", 1200)  # Food
	addConstraint("20*swordsmen + 10*bowmen", "<=", 800)                  # Wood
	addConstraint("40*bowmen + 100*horsemen", "<=", 600)                  # Gold
	
	maximize("70*swordsmen + 95*bowmen + 230*horsemen")  # Power
	solve("greedy")
	show()
}

pf()
# Execution time: ~5ms

/*--- Restaurant menu planning

pr()
# Planning optimal menu mix to maximize profit
# GREEDY solver ideal for quick business decisions

o2 = new stzLinear()
o2 {
	addVariable("pizza", 0, 200)
	addVariable("pasta", 0, 150)
	addVariable("salad", 0, 100)
	
	# Kitchen constraints
	addConstraint("15*pizza + 10*pasta + 5*salad", "<=", 2000)   # Prep time (minutes)
	addConstraint("3*pizza + 2*pasta + 1*salad", "<=", 400)     # Chef time (hours)
	addConstraint("pizza + pasta", "<=", 250)                   # Oven capacity
	
	maximize("12*pizza + 8*pasta + 6*salad")  # Profit per item
	solve("greedy")
	
	? "Daily menu recommendation:"
	? "Pizza: " + solutionValue("pizza") + " portions"
	? "Pasta: " + solutionValue("pasta") + " portions" 
	? "Salad: " + solutionValue("salad") + " portions"
	? "Expected profit: $" + objectiveValue()
}

pf()
# Execution time: ~3ms

#====================#
#   PRODUCTION PLANNING    #
#====================#

/*--- Manufacturing optimization with integer constraints

pr()
# Product mix with discrete units requiring exact quantities
# BRANCH_BOUND solver handles integer constraints properly

o3 = new stzLinear()
o3 {
	addIntegerVariable("chairs", 0, 100)
	addIntegerVariable("tables", 0, 50)
	addIntegerVariable("desks", 0, 30)
	
	# Material constraints
	addConstraint("4*chairs + 12*tables + 8*desks", "<=", 800)  # Wood (board feet)
	addConstraint("2*chairs + 6*tables + 4*desks", "<=", 300)   # Labor (hours)
	addConstraint("1*chairs + 3*tables + 2*desks", "<=", 150)   # Hardware sets
	
	maximize("25*chairs + 80*tables + 60*desks")  # Profit
	solve("branch_bound")
	show()
}

pf()
# Execution time: ~15ms

/*--- Batch production scheduling

pr()
# Weekly production schedule with setup costs
# SIMPLEX solver for continuous production rates

o4 = new stzLinear()
o4 {
	addVariable("batch_a", 0, 1000)
	addVariable("batch_b", 0, 800)
	addVariable("batch_c", 0, 600)
	
	# Production constraints
	addConstraint("2.5*batch_a + 3.2*batch_b + 4.1*batch_c", "<=", 4000)  # Machine hours
	addConstraint("1.2*batch_a + 0.8*batch_b + 1.5*batch_c", "<=", 1500)  # Quality control
	addConstraint("batch_a + batch_b + batch_c", ">=", 500)               # Min production
	
	maximize("18*batch_a + 22*batch_b + 28*batch_c")  # Revenue
	solve("simplex")
	
	? "Weekly production schedule:"
	? "Batch A: " + solutionValue("batch_a") + " units"
	? "Batch B: " + solutionValue("batch_b") + " units"
	? "Batch C: " + solutionValue("batch_c") + " units"
}

pf()
# Execution time: ~8ms

#====================#
#   FINANCIAL PLANNING    #
#====================#

/*--- Investment portfolio optimization

pr()
# Asset allocation with risk constraints
# GREEDY solver for quick portfolio rebalancing

o5 = new stzLinear()
o5 {
	addVariable("stocks", 0, 100000)
	addVariable("bonds", 0, 100000)
	addVariable("real_estate", 0, 50000)
	addVariable("cash", 1000, 20000)  # Minimum cash reserve
	
	# Portfolio constraints
	addConstraint("stocks + bonds + real_estate + cash", "=", 100000)  # Total budget
	addConstraint("stocks", "<=", 60000)                               # Max stock exposure
	addConstraint("bonds + cash", ">=", 30000)                         # Conservative allocation
	
	maximize("0.08*stocks + 0.04*bonds + 0.06*real_estate + 0.01*cash")  # Expected return
	solve("greedy")
	
	? "Optimal portfolio allocation:"
	? "Stocks: $" + solutionValue("stocks")
	? "Bonds: $" + solutionValue("bonds")
	? "Real Estate: $" + solutionValue("real_estate")
	? "Cash: $" + solutionValue("cash")
	? "Expected annual return: " + (objectiveValue() * 100) + "%"
}

pf()
# Execution time: ~4ms

/*--- Budget allocation across departments

pr()
# Corporate budget distribution with minimum requirements
# SIMPLEX solver handles equality and inequality constraints well

o6 = new stzLinear()
o6 {
	addVariable("marketing", 50000, 200000)
	addVariable("rd", 100000, 300000)
	addVariable("operations", 80000, 250000)
	addVariable("hr", 30000, 100000)
	
	# Budget constraints
	addConstraint("marketing + rd + operations + hr", "=", 500000)  # Total budget
	addConstraint("rd", ">=", 150000)                              # Min R&D investment
	addConstraint("marketing + operations", ">=", 200000)          # Core operations
	
	# Maximize weighted business value
	maximize("0.6*marketing + 0.8*rd + 0.5*operations + 0.3*hr")
	solve("simplex")
	show()
}

pf()
# Execution time: ~6ms

#====================#
#   EDUCATIONAL EXAMPLES    #
#====================#

/*--- Classic diet problem for nutrition education

pr()
# Teaching linear programming fundamentals
# SIMPLEX solver demonstrates classic LP methodology

o7 = new stzLinear()
o7 {
	addVariable("bread", 0, 10)    # Loaves
	addVariable("milk", 0, 8)      # Gallons  
	addVariable("cheese", 0, 5)    # Pounds
	addVariable("meat", 0, 3)      # Pounds
	
	# Nutritional requirements (daily minimums)
	addConstraint("400*bread + 300*milk + 200*cheese + 500*meat", ">=", 2000)  # Calories
	addConstraint("8*bread + 12*milk + 25*cheese + 30*meat", ">=", 60)         # Protein (g)
	addConstraint("0*bread + 300*milk + 200*cheese + 0*meat", ">=", 800)       # Calcium (mg)
	addConstraint("2*bread + 0*milk + 0*cheese + 8*meat", ">=", 15)            # Iron (mg)
	
	minimize("2.50*bread + 4.00*milk + 8.00*cheese + 12.00*meat")  # Cost
	solve("simplex")
	
	? "Minimum cost diet plan:"
	? "Bread: " + solutionValue("bread") + " loaves"
	? "Milk: " + solutionValue("milk") + " gallons"
	? "Cheese: " + solutionValue("cheese") + " pounds"
	? "Meat: " + solutionValue("meat") + " pounds"
	? "Total cost: $" + objectiveValue()
}

pf()
# Execution time: ~7ms

/*--- Transportation problem for logistics education

pr()
# Classic network flow problem
# GREEDY solver good for understanding allocation logic

o8 = new stzLinear()
o8 {
	# Routes from 2 warehouses to 3 stores
	addVariable("w1_s1", 0, 1000)  # Warehouse 1 to Store 1
	addVariable("w1_s2", 0, 1000)  # Warehouse 1 to Store 2
	addVariable("w1_s3", 0, 1000)  # Warehouse 1 to Store 3
	addVariable("w2_s1", 0, 1000)  # Warehouse 2 to Store 1
	addVariable("w2_s2", 0, 1000)  # Warehouse 2 to Store 2
	addVariable("w2_s3", 0, 1000)  # Warehouse 2 to Store 3
	
	# Supply constraints
	addConstraint("w1_s1 + w1_s2 + w1_s3", "<=", 500)  # Warehouse 1 capacity
	addConstraint("w2_s1 + w2_s2 + w2_s3", "<=", 600)  # Warehouse 2 capacity
	
	# Demand constraints  
	addConstraint("w1_s1 + w2_s1", "=", 300)  # Store 1 demand
	addConstraint("w1_s2 + w2_s2", "=", 400)  # Store 2 demand
	addConstraint("w1_s3 + w2_s3", "=", 350)  # Store 3 demand
	
	# Minimize shipping costs
	minimize("5*w1_s1 + 8*w1_s2 + 6*w1_s3 + 7*w2_s1 + 4*w2_s2 + 9*w2_s3")
	solve("greedy")
	
	? "Optimal shipping plan:"
	? "W1→S1: " + solutionValue("w1_s1") + " units"
	? "W1→S2: " + solutionValue("w1_s2") + " units"
	? "W1→S3: " + solutionValue("w1_s3") + " units"
	? "W2→S1: " + solutionValue("w2_s1") + " units"
	? "W2→S2: " + solutionValue("w2_s2") + " units"
	? "W2→S3: " + solutionValue("w2_s3") + " units"
	? "Total shipping cost: $" + objectiveValue()
}

pf()
# Execution time: ~6ms

#====================#
#   GAMING APPLICATIONS    #
#====================#

/*--- RPG character build optimization

pr()
# Game balance testing with non-linear preferences
# GENETIC solver handles complex, conflicting objectives

o9 = new stzLinear()
o9 {
	addIntegerVariable("strength", 10, 100)
	addIntegerVariable("agility", 10, 100)
	addIntegerVariable("intelligence", 10, 100)
	addIntegerVariable("vitality", 10, 100)
	
	# Character constraints
	addConstraint("strength + agility + intelligence + vitality", "=", 200)  # Total points
	addConstraint("strength + vitality", ">=", 80)                          # Warrior viability
	addConstraint("agility + intelligence", ">=", 60)                       # Skill requirements
	
	# Complex effectiveness function (simplified for LP)
	maximize("2*strength + 1.5*agility + 1.8*intelligence + 1.2*vitality")
	solve("genetic")
	
	? "Optimized character build:"
	? "Strength: " + solutionValue("strength")
	? "Agility: " + solutionValue("agility")
	? "Intelligence: " + solutionValue("intelligence")
	? "Vitality: " + solutionValue("vitality")
	? "Combat effectiveness: " + objectiveValue()
}

pf()
# Execution time: ~25ms

/*--- Game economy balancing

pr()
# Resource generation rates for balanced gameplay
# BRANCH_BOUND for discrete resource packets

o10 = new stzLinear()
o10 {
	addIntegerVariable("gold_rate", 1, 50)     # Gold per minute
	addIntegerVariable("wood_rate", 5, 200)    # Wood per minute
	addIntegerVariable("food_rate", 3, 150)    # Food per minute
	addIntegerVariable("stone_rate", 2, 100)   # Stone per minute
	
	# Balance constraints
	addConstraint("gold_rate", "<=", 25)                                    # Max gold generation
	addConstraint("wood_rate + food_rate", "<=", 300)                       # Gatherer limit
	addConstraint("2*gold_rate + wood_rate + food_rate + stone_rate", "<=", 400)  # Total effort
	
	# Maximize player engagement (balanced resource flow)
	maximize("10*gold_rate + 2*wood_rate + 3*food_rate + 4*stone_rate")
	solve("branch_bound")
	
	? "Balanced resource generation rates:"
	? "Gold: " + solutionValue("gold_rate") + "/min"
	? "Wood: " + solutionValue("wood_rate") + "/min"
	? "Food: " + solutionValue("food_rate") + "/min"
	? "Stone: " + solutionValue("stone_rate") + "/min"
}

pf()
# Execution time: ~12ms

#====================#
#   COMPLEX REAL-WORLD SCENARIOS    #
#====================#

/*--- Event planning with multiple constraints

pr()
# Wedding planning with vendor coordination
# GENETIC solver handles complex, interdependent constraints

o11 = new stzLinear()
o11 {
	addIntegerVariable("guests", 50, 200)
	addVariable("catering_cost", 2000, 15000)
	addVariable("venue_cost", 1000, 8000)
	addVariable("decoration_cost", 500, 3000)
	
	# Budget and space constraints
	addConstraint("catering_cost + venue_cost + decoration_cost", "<=", 20000)  # Total budget
	addConstraint("25*guests", "<=", "catering_cost")                          # Min catering per guest
	addConstraint("guests", "<=", 150)                                         # Venue capacity
	
	# Maximize satisfaction (complex relationship)
	maximize("guests + 0.1*catering_cost + 0.05*venue_cost + 0.2*decoration_cost")
	solve("genetic")
	
	? "Optimal event plan:"
	? "Guests: " + solutionValue("guests")
	? "Catering budget: $" + solutionValue("catering_cost")
	? "Venue budget: $" + solutionValue("venue_cost")
	? "Decoration budget: $" + solutionValue("decoration_cost")
	? "Satisfaction score: " + objectiveValue()
}

pf()
# Execution time: ~30ms

/*--- Supply chain optimization with uncertainty

pr()
# Multi-tier supply chain with demand fluctuation
# GENETIC solver robust against uncertainty and complexity

o12 = new stzLinear()
o12 {
	# Inventory levels at different stages
	addVariable("raw_inventory", 0, 10000)
	addVariable("wip_inventory", 0, 5000)
	addVariable("finished_inventory", 0, 8000)
	
	# Production rates
	addVariable("production_rate", 100, 2000)
	addVariable("shipping_rate", 50, 1500)
	
	# Supply chain constraints
	addConstraint("raw_inventory", ">=", "1.2*production_rate")              # Safety stock
	addConstraint("production_rate", "<=", "shipping_rate + 200")            # WIP buildup limit
	addConstraint("finished_inventory + shipping_rate", ">=", 1200)          # Customer demand
	
	# Minimize total costs (inventory + production + shipping)
	minimize("5*raw_inventory + 15*wip_inventory + 8*finished_inventory + 10*production_rate + 12*shipping_rate")
	solve("genetic")
	
	? "Optimized supply chain:"
	? "Raw inventory: " + solutionValue("raw_inventory") + " units"
	? "WIP inventory: " + solutionValue("wip_inventory") + " units"
	? "Finished inventory: " + solutionValue("finished_inventory") + " units"
	? "Production rate: " + solutionValue("production_rate") + " units/day"
	? "Shipping rate: " + solutionValue("shipping_rate") + " units/day"
	? "Total cost: $" + objectiveValue() + "/day"
}

pf()
# Execution time: ~35ms

#====================#
#   SOLVER COMPARISON    #
#====================#

/*--- Same problem, different solvers

pr()
# Comparing solver performance on identical problem
# Shows when each approach works best

? "=== SOLVER COMPARISON ==="
? "Problem: Maximize 3x + 2y subject to x + y <= 100, x <= 60, y <= 80"
? ""

for cSolver in ["greedy", "simplex", "branch_bound", "genetic"]
	? "Solver: " + upper(cSolver)
	
	oTest = new stzLinear()
	oTest {
		addVariable("x", 0, 1000)
		addVariable("y", 0, 1000)
		addConstraint("x + y", "<=", 100)
		addConstraint("x", "<=", 60)
		addConstraint("y", "<=", 80)
		maximize("3*x + 2*y")
		
		nStart = clock()
		solve(cSolver)
		nTime = clock() - nStart
		
		? "  x = " + solutionValue("x")
		? "  y = " + solutionValue("y")
		? "  Objective = " + objectiveValue()
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
