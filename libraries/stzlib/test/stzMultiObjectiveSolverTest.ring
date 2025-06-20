/*
	stzMultiObjectiveSolver Test Suite - Practical Examples by Theme
	Demonstrates multi-objective optimization in real-world scenarios
	Author: Softanza Team
*/

load "../max/stzmax.ring"

/*---

pr()

o1 = new stzMultiObjectiveSolver()
o1 {
    AddVariable("x", 0, 10)
    AddVariable("y", 0, 10)
    
    # Simple constraints
    AddConstraint("x + y", "<=", 15)
    
    # Simple objectives  
    Maximize("x")
    Minimize("y")
    
    SetNSGAParameters(10, 20, 0.1, 0.8)  # Very small for testing
    Solve("nsga_ii")
    show()
}

pf()

#============================#
#   PORTFOLIO OPTIMIZATION   #
#============================#

/*--- Investment portfolio balancing profit vs risk
# Scenario: Choose stock/bond mix to maximize profit while minimizing risk
# Method: NSGA-II — handles competing objectives well

pr()

o1 = new stzMultiObjectiveSolver()
o1 {
    # Decision variables: percentage allocation
    AddVariable("stocks", 0, 100)
    AddVariable("bonds", 0, 100)
    AddVariable("cash", 0, 100)

    # Must allocate 100% of portfolio
    AddConstraint("stocks + bonds + cash", "=", 100)
    
    # Risk diversification: stocks shouldn't exceed 70%
    AddConstraint("stocks", "<=", 70)
    
    # Minimum liquidity: keep at least 10% in cash
    AddConstraint("cash", ">=", 10)

    # Objective 1: Maximize expected return (%)
    # Returns: stocks=8%, bonds=4%, cash=1%
    Maximize("0.08*stocks + 0.04*bonds + 0.01*cash")
    
    # Objective 2: Minimize risk (volatility)
    # Risk scores: stocks=12, bonds=3, cash=0
    Minimize("0.12*stocks + 0.03*bonds + 0.00*cash")

    # Use NSGA-II for multi-objective optimization
    SetNSGAParameters(30, 50, 0.1, 0.8)  # smaller population for demo
    Solve("nsga_ii")
    show()
}

#-->
# Shows Pareto front of solutions trading off return vs risk
# Best compromise typically around 40-50% stocks, 40-50% bonds, 10% cash
#-->
'
╭─────────────────────────╮
│ Multi-Objective Problem │
╰─────────────────────────╯

• Variables:
  stocks ∈ [0, 100] (continuous)
  bonds ∈ [0, 100] (continuous)
  cash ∈ [0, 100] (continuous)

• Constraints:
  stocks + bonds + cash = 100
  stocks <= 70
  cash >= 10

• Objectives:
  MAXIMIZE 0.08*stocks + 0.04*bonds + 0.01*cash
  MINIMIZE 0.12*stocks + 0.03*bonds + 0.00*cash

╭───────────╮
│ Solutions │
╰───────────╯
• Status: optimal
• Solved in 24.26 second(s)
• Iterations: 50
• Pareto Solutions Found: 0
'
pf()
# Executed in 24.29 second(s) in Ring 1.22

#=================================#
#   SUPPLY CHAIN LOGISTICS       #
#=================================#

/*--- Delivery optimization balancing cost and speed
# Scenario: Choose shipping methods to minimize cost while minimizing delivery time
# Method: Epsilon-constraint — systematic exploration of trade-offs

pr()

o1 = new stzMultiObjectiveSolver()
o1 {
    # Decision variables: shipments by method
    AddIntegerVariable("truck", 0, 50)      # Truck shipments
    AddIntegerVariable("air", 0, 20)        # Air shipments  
    AddIntegerVariable("rail", 0, 30)       # Rail shipments

    # Must fulfill total demand of 40 units
    AddConstraint("truck + air + rail", ">=", 35)
    AddConstraint("truck + air + rail", "<=", 45)

    # Capacity constraints
    AddConstraint("truck", "<=", 25)        # Limited truck capacity
    AddConstraint("air", "<=", 15)          # Limited air capacity
    
    # Budget constraint: total cost ≤ $8000
    AddConstraint("150*truck + 500*air + 100*rail", "<=", 8000)

    # Objective 1: Minimize total cost ($)
    # Costs: truck=$150, air=$500, rail=$100 per unit
    Minimize("150*truck + 500*air + 100*rail")
    
    # Objective 2: Minimize average delivery time (days)  
    # Times: truck=3 days, air=1 day, rail=5 days
    Minimize("3*truck + 1*air + 5*rail")

    # Use epsilon-constraint method
    Solve("epsilon_constraint")
    show()
}

#-->
# Shows trade-off solutions from cheap/slow to expensive/fast
# Business can choose based on priority: cost-sensitive vs time-critical
#-->
'
╭─────────────────────────╮
│ Multi-Objective Problem │
╰─────────────────────────╯

• Variables:
 ─ truck ∈ [0, 50] (integer)
 ─ air ∈ [0, 20] (integer)
 ─ rail ∈ [0, 30] (integer)

• Constraints:
 ─ truck + air + rail = 40
 ─ truck <= 25
 ─ air <= 15
 ─ 150*truck + 500*air + 100*rail <= 8000

• Objectives:
 ─ MINIMIZE 150*truck + 500*air + 100*rail
 ─ MINIMIZE 3*truck + 1*air + 5*rail

╭───────────╮
│ Solutions │
╰───────────╯
• Status: optimal
• Solved in 0.60 second(s)
• Iterations: 20

• Pareto Solutions Found: 11
• Best Compromise Solution:
 ─ truck = 0
 ─ air = 0
 ─ rail = 0

• Objective Values:
 ─ 150*truck + 500*air + 100*rail = 0
 ─ 3*truck + 1*air + 5*rail = 0
'

pf()
# Executed in 0.62 second(s) in Ring 1.22

#============================#
#   MANUFACTURING PLANNING   #
#============================#

/*--- Production scheduling balancing efficiency and quality
# Scenario: Allocate production time across methods to maximize output and quality
# Method: NSGA-II — balances multiple production objectives
*/
pr()

o3 = new stzMultiObjectiveSolver()
o3 {
    # Decision variables: hours allocated to each production method
    AddVariable("manual", 0, 40)           # Manual production hours
    AddVariable("semi_auto", 0, 60)        # Semi-automated hours
    AddVariable("full_auto", 0, 80)        # Fully automated hours

    # Total available production time: 100 hours/week
    AddConstraint("manual + semi_auto + full_auto", "<=", 100)
    
    # Labor constraint: manual and semi-auto need workers
    AddConstraint("2*manual + 1*semi_auto", "<=", 80)  # 80 worker-hours available
    
    # Equipment constraint: automated methods share equipment
    AddConstraint("semi_auto + full_auto", "<=", 70)   # 70 machine-hours available
    
    # Minimum manual production for flexibility
    AddConstraint("manual", ">=", 10)

    # Objective 1: Maximize total output (units)
    # Output rates: manual=2, semi-auto=5, full-auto=8 units/hour
    Maximize("2*manual + 5*semi_auto + 8*full_auto")
    
    # Objective 2: Maximize quality score
    # Quality scores: manual=9, semi-auto=7, full-auto=6 (manual has highest quality)
    Maximize("9*manual + 7*semi_auto + 6*full_auto")

    SetNSGAParameters(40, 60, 0.15, 0.85)
    Solve("nsga_ii")
    show()
}

#-->
# Shows trade-off between high-volume/low-quality vs low-volume/high-quality
# Managers can choose strategy based on market positioning
#-->
'
╭─────────────────────────╮
│ Multi-Objective Problem │
╰─────────────────────────╯

• Variables:
 ─ manual ∈ [0, 40] (continuous)
 ─ semi_auto ∈ [0, 60] (continuous)
 ─ full_auto ∈ [0, 80] (continuous)

• Constraints:
 ─ manual + semi_auto + full_auto <= 100
 ─ 2*manual + 1*semi_auto <= 80
 ─ semi_auto + full_auto <= 70
 ─ manual >= 10

• Objectives:
 ─ MAXIMIZE 2*manual + 5*semi_auto + 8*full_auto
 ─ MAXIMIZE 9*manual + 7*semi_auto + 6*full_auto

╭───────────╮
│ Solutions │
╰───────────╯
• Status: optimal
• Solved in 41.61 second(s)
• Iterations: 60

• Pareto Solutions Found: 0
'
pf()
# Executed in 41.63 second(s) in Ring 1.22

#==========================#
#   RESOURCE ALLOCATIO     #
#==========================#

/*--- IT project staffing balancing speed and expertise
# Scenario: Assign developers to maximize project completion while maintaining code quality
# Method: Epsilon-constraint — explores speed vs quality systematically

pr()

o4 = new stzMultiObjectiveSolver()
o4 {
    # Decision variables: developer assignments
    AddIntegerVariable("junior", 0, 10)     # Junior developers
    AddIntegerVariable("senior", 0, 8)      # Senior developers  
    AddIntegerVariable("architect", 0, 3)   # Solution architects

    # Total team size constraint
    AddConstraint("junior + senior + architect", "<=", 15)
    
    # Budget constraint: total salary ≤ $50k/month
    AddConstraint("5*junior + 8*senior + 12*architect", "<=", 50)
    
    # Knowledge transfer: need at least 1 senior per 3 juniors
 //   AddConstraint("3*senior + 3*architect", ">=", "junior")
    
    # Architecture oversight: complex projects need architects
    AddConstraint("architect", ">=", 1)

    # Objective 1: Maximize development speed (story points/sprint)
    # Productivity: junior=3, senior=5, architect=4 points/sprint
    Maximize("3*junior + 5*senior + 4*architect")
    
    # Objective 2: Maximize code quality score
    # Quality impact: junior=2, senior=8, architect=10
    Maximize("2*junior + 8*senior + 10*architect")

    Solve("epsilon_constraint")
    show()
}

#-->
# Shows solutions from fast/lower-quality to slower/higher-quality
# Project managers choose based on deadline vs maintenance requirements
#-->
'
╭─────────────────────────╮
│ Multi-Objective Problem │
╰─────────────────────────╯

• Variables:
 ─ junior ∈ [0, 10] (integer)
 ─ senior ∈ [0, 8] (integer)
 ─ architect ∈ [0, 3] (integer)

• Constraints:
 ─ junior + senior + architect <= 15
 ─ 5*junior + 8*senior + 12*architect <= 50
 ─ architect >= 1

• Objectives:
 ─ MAXIMIZE 3*junior + 5*senior + 4*architect
 ─ MAXIMIZE 2*junior + 8*senior + 10*architect

╭───────────╮
│ Solutions │
╰───────────╯
• Status: optimal
• Solved in 0.57 second(s)
• Iterations: 20

• Pareto Solutions Found: 11
• Best Compromise Solution:
 ─ junior = 10
 ─ senior = 0
 ─ architect = 0

• Objective Values:
 ─ 3*junior + 5*senior + 4*architect = 30
 ─ 2*junior + 8*senior + 10*architect = 20
'

pf()
# Executed in 4.21 second(s) in Ring 1.22

#=========================#
#   MARKETING CAMPAIGN    #
#=========================#

/*--- Ad spend optimization balancing reach and conversion
# Scenario: Allocate marketing budget across channels for maximum reach and ROI
# Method: NSGA-II — finds optimal marketing mix

pr()

o5 = new stzMultiObjectiveSolver()
o5 {
    # Decision variables: budget allocation ($000s)
    AddVariable("social_media", 0, 50)      # Social media ads
    AddVariable("search_ads", 0, 40)        # Search engine ads
    AddVariable("display", 0, 30)           # Display advertising
    AddVariable("email", 0, 20)             # Email campaigns

    # Total marketing budget: $80k
    AddConstraint("social_media + search_ads + display + email", "<=", 80)
    
    # Platform minimums for campaign effectiveness
    AddConstraint("social_media", ">=", 10)
    AddConstraint("search_ads", ">=", 15)
    
    # Cross-channel synergy: display + email should be balanced
    AddConstraint("display - email", "<=", 10)
    AddConstraint("email - display", "<=", 5)

    # Objective 1: Maximize reach (thousands of people)
    # Reach per $1k: social=2.5k, search=1.8k, display=3.2k, email=1.5k
    Maximize("2.5*social_media + 1.8*search_ads + 3.2*display + 1.5*email")
    
    # Objective 2: Maximize conversions (sales)
    # Conversion rates: social=0.8, search=2.2, display=0.6, email=1.9 per $1k
    Maximize("0.8*social_media + 2.2*search_ads + 0.6*display + 1.9*email")

    SetNSGAParameters(35, 45, 0.12, 0.88)
    Solve("nsga_ii")
    show()
}

#-->
# Shows Pareto front balancing brand awareness (reach) vs direct sales (conversion)
# Marketing teams choose strategy based on campaign goals
#-->
'
╭─────────────────────────╮
│ Multi-Objective Problem │
╰─────────────────────────╯

• Variables:
 ─ social_media ∈ [0, 50] (continuous)
 ─ search_ads ∈ [0, 40] (continuous)
 ─ display ∈ [0, 30] (continuous)
 ─ email ∈ [0, 20] (continuous)

• Constraints:
 ─ social_media + search_ads + display + email <= 80
 ─ social_media >= 10
 ─ search_ads >= 15
 ─ display - email <= 10
 ─ email - display <= 5

• Objectives:
 ─ MAXIMIZE 2.5*social_media + 1.8*search_ads + 3.2*display + 1.5*email
 ─ MAXIMIZE 0.8*social_media + 2.2*search_ads + 0.6*display + 1.9*email

╭───────────╮
│ Solutions │
╰───────────╯
• Status: optimal
• Solved in 34.56 second(s)
• Iterations: 45

• Pareto Solutions Found: 0
'

pf()
# Executed in 34.58 second(s) in Ring 1.22

#============================#
#   EDUCATIONAL PLANNING     #
#============================#

/*--- Course scheduling balancing student satisfaction and resource efficiency
# Scenario: Schedule classes to maximize enrollment while minimizing facility costs
# Method: Epsilon-constraint — systematic exploration of education trade-offs

pr()

o6 = new stzMultiObjectiveSolver()
o6 {
    # Decision variables: class sections to offer
    AddIntegerVariable("morning", 0, 8)     # Morning sections
    AddIntegerVariable("afternoon", 0, 10)  # Afternoon sections
    AddIntegerVariable("evening", 0, 6)     # Evening sections

    # Minimum course offerings for program requirements
    AddConstraint("morning + afternoon + evening", ">=", 12)
    
    # Faculty availability constraints
    AddConstraint("morning + afternoon", "<=", 12)  # Day faculty limit
    AddConstraint("evening", "<=", 4)               # Evening faculty limit
    
    # Classroom capacity constraint
    AddConstraint("morning + afternoon + evening", "<=", 18)

    # Objective 1: Maximize student enrollment
    # Demand: morning=25, afternoon=30, evening=20 students per section
    Maximize("25*morning + 30*afternoon + 20*evening")
    
    # Objective 2: Minimize facility costs ($)
    # Costs: morning=$200, afternoon=$250, evening=$400 per section
    Minimize("200*morning + 250*afternoon + 400*evening")

    Solve("epsilon_constraint")
    show()
}

#-->
# Shows solutions from cost-efficient to enrollment-maximizing
# Academic planners choose based on budget constraints vs accessibility goals
#-->
'
╭─────────────────────────╮
│ Multi-Objective Problem │
╰─────────────────────────╯

• Variables:
 ─ morning ∈ [0, 8] (integer)
 ─ afternoon ∈ [0, 10] (integer)
 ─ evening ∈ [0, 6] (integer)

• Constraints:
 ─ morning + afternoon + evening >= 12
 ─ morning + afternoon <= 12
 ─ evening <= 4
 ─ morning + afternoon + evening <= 18

• Objectives:
 ─ MAXIMIZE 25*morning + 30*afternoon + 20*evening
 ─ MINIMIZE 200*morning + 250*afternoon + 400*evening

╭───────────╮
│ Solutions │
╰───────────╯
• Status: optimal
• Solved in 0.49 second(s)
• Iterations: 20

• Pareto Solutions Found: 11
• Best Compromise Solution:
 ─ morning = 0
 ─ afternoon = 0
 ─ evening = 0

• Objective Values:
 ─ 25*morning + 30*afternoon + 20*evening = 0
 ─ 200*morning + 250*afternoon + 400*evening = 0
'

pf()

#===============================#
#   SUSTAINABILITY PLANNING     #
#===============================#

/*--- Energy mix optimization balancing cost and environmental impact
# Scenario: Choose energy sources to minimize cost while maximizing sustainability
# Method: NSGA-II — balances economic and environmental objectives
*/
pr()

o7 = new stzMultiObjectiveSolver()
o7 {
    # Decision variables: energy capacity (MW)
    AddVariable("solar", 0, 100)            # Solar capacity
    AddVariable("wind", 0, 80)              # Wind capacity  
    AddVariable("natural_gas", 0, 120)      # Natural gas capacity
    AddVariable("coal", 0, 60)              # Coal capacity

    # Must meet minimum energy demand: 150 MW
    AddConstraint("solar + wind + natural_gas + coal", ">=", 150)
    
    # Renewable energy mandate: ≥30% from renewables
 //   AddConstraint("solar + wind", ">=", "0.3*(solar + wind + natural_gas + coal)")
    
    # Grid stability: need some dispatchable power
    AddConstraint("natural_gas + coal", ">=", 40)
    
    # Infrastructure constraint: total capacity ≤200 MW
    AddConstraint("solar + wind + natural_gas + coal", "<=", 200)

    # Objective 1: Minimize cost ($/MWh)
    # Costs: solar=$60, wind=$55, gas=$45, coal=$35 per MWh
    Minimize("60*solar + 55*wind + 45*natural_gas + 35*coal")
    
    # Objective 2: Minimize CO2 emissions (tons/year)
    # Emissions: solar=0, wind=0, gas=0.4, coal=0.9 tons CO2/MWh
    Minimize("0*solar + 0*wind + 0.4*natural_gas + 0.9*coal")

    SetNSGAParameters(50, 70, 0.08, 0.92)
    Solve("nsga_ii")
    show()
}

#-->
# Shows Pareto front from cheap/dirty to expensive/clean energy mixes
# Policy makers choose based on environmental vs economic priorities
#-->
'
╭─────────────────────────╮
│ Multi-Objective Problem │
╰─────────────────────────╯

• Variables:
 ─ solar ∈ [0, 100] (continuous)
 ─ wind ∈ [0, 80] (continuous)
 ─ natural_gas ∈ [0, 120] (continuous)
 ─ coal ∈ [0, 60] (continuous)

• Constraints:
 ─ solar + wind + natural_gas + coal >= 150
 ─ natural_gas + coal >= 40
 ─ solar + wind + natural_gas + coal <= 200

• Objectives:
 ─ MINIMIZE 60*solar + 55*wind + 45*natural_gas + 35*coal
 ─ MINIMIZE 0*solar + 0*wind + 0.4*natural_gas + 0.9*coal

╭───────────╮
│ Solutions │
╰───────────╯
• Status: optimal
• Solved in 80.31 second(s)
• Iterations: 70

• Pareto Solutions Found: 0
'
pf()

