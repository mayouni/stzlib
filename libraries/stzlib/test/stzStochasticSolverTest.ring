load "../max/stzmax.ring"

#============================#
#   PORTFOLIO OPTIMIZATION   #
#============================#

/*--- Portfolio optimization with expected value
# Scenario: Allocate funds across stocks, bonds, and cash to maximize expected return
# Method: Expected value solver — optimizes based on weighted average of scenarios

pr()

o1 = new stzStochasticSolver()
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

    # Define scenarios with returns under different market conditions
    AddScenario("bull", "High growth", [["stock_return", 0.12], ["bond_return", 0.05], ["cash_return", 0.01]], 0.3)
    AddScenario("bear", "Low growth", [["stock_return", 0.04], ["bond_return", 0.03], ["cash_return", 0.01]], 0.3)
    AddScenario("normal", "Moderate growth", [["stock_return", 0.08], ["bond_return", 0.04], ["cash_return", 0.01]], 0.4)

    # Objective: Maximize expected return
    Maximize("stock_return*stocks + bond_return*bonds + cash_return*cash")

    # Use expected value solver
    SetSolverType("expected")
    Solve()
    Show()
}

#-->
# Displays optimal allocation, expected return, and scenario feasibility
# Typically favors stocks for higher returns, balanced by constraints
#-->
'
╭───────────────────────────────╮
│ Stochastic Programming Problem │
╰───────────────────────────────╯

• Variables:
  stocks ∈ [0, 100] (continuous)
  bonds ∈ [0, 100] (continuous)
  cash ∈ [0, 100] (continuous)

• Objective:  
  MAXIMIZE stock_return*stocks + bond_return*bonds + cash_return*cash

• Scenarios:
  bull: High growth (p=0.3)
    stock_return = 0.12
    bond_return = 0.05
    cash_return = 0.01
  bear: Low growth (p=0.3)
    stock_return = 0.04
    bond_return = 0.03
    cash_return = 0.01
  normal: Moderate growth (p=0.4)
    stock_return = 0.08
    bond_return = 0.04
    cash_return = 0.01

• Constraints:
  stocks + bonds + cash = 100
  stocks <= 70
  cash >= 10
'

# Solution should be:
'
╭─────────╮
│ Solution │
╰─────────╯
• Status: optimal
• Solver: expected
• Variable Values:
  stocks = 70
  bonds = 20
  cash = 10
• Expected Objective Value: ~0.069 (varies slightly by solver implementation)
• Scenario Analysis:
  bull (p=0.3): ~0.094 ✓
  bear (p=0.3): ~0.039 ✓
  normal (p=0.4): ~0.069 ✓
'

# but we got
'
╭──────────╮
│ Solution │
╰──────────╯
• Status: optimal
• Solver: expected
• Solved in 0.26 second(s)

• Variable Values:
 ─ stocks = 100
 ─ bonds = 100
 ─ cash = 100

• Expected Objective Value: 13

• Scenario Analysis:
 ─ bull (p=0.30): 18 ✗
 ─ bear (p=0.30): 8 ✗
 ─ normal (p=0.40): 13 ✗
'

pf()
# Executed in ~0.1 second(s) in Ring 1.22

/*--- Portfolio optimization with robust approach
# Scenario: Minimize risk under worst-case market conditions
# Method: Robust solver — focuses on worst-case scenario performance

pr()

o2 = new stzStochasticSolver()
o2 {
    # Same variables and constraints
    AddVariable("stocks", 0, 100)
    AddVariable("bonds", 0, 100)
    AddVariable("cash", 0, 100)

    AddConstraint("stocks + bonds + cash", "=", 100)
    AddConstraint("stocks", "<=", 70)
    AddConstraint("cash", ">=", 10)

    # Same scenarios with risk parameters
    AddScenario("bull", "High growth", [["stock_risk", 0.15], ["bond_risk", 0.04]], 0.3)
    AddScenario("bear", "Low growth", [["stock_risk", 0.08], ["bond_risk", 0.02]], 0.3)
    AddScenario("normal", "Moderate growth", [["stock_risk", 0.12], ["bond_risk", 0.03]], 0.4)

    # Objective: Minimize risk
    Minimize("stock_risk*stocks + bond_risk*bonds")

    # Use robust solver
    SetSolverType("robust")
    Solve()
    Show()
}

#-->
# Prioritizes low-risk assets (bonds, cash) under worst-case scenario
#-->
'
╭────────────────────────────────╮
│ Stochastic Programming Problem │
╰────────────────────────────────╯
• Variables:
 ─ stocks ∈ [0, 100] (continuous)
 ─ bonds ∈ [0, 100] (continuous)
 ─ cash ∈ [0, 100] (continuous)

• Objective:
╰─> MINIMIZE stock_risk*stocks + bond_risk*bonds

• Scenarios:
 ─ bull: High growth (p=0.30)
 ╰─> stock_risk = 0.15
 ╰─> bond_risk = 0.04

 ─ bear: Low growth (p=0.30)
 ╰─> stock_risk = 0.08
 ╰─> bond_risk = 0.02

 ─ normal: Moderate growth (p=0.40)
 ╰─> stock_risk = 0.12
 ╰─> bond_risk = 0.03

• Constraints:
 ─ stocks + bonds + cash = 100
 ─ stocks <= 70
 ─ cash >= 10

╭──────────╮
│ Solution │
╰──────────╯
• Status: optimal
• Solver: robust
• Solved in 0.20 second(s)

• Variable Values:
 ─ stocks = 100
 ─ bonds = 100
 ─ cash = 100

• Expected Objective Value: 14.70

• Scenario Analysis:
 ─ bull (p=0.30): 19 ✗
 ─ bear (p=0.30): 10 ✗
 ─ normal (p=0.40): 15 ✗
'
pf()

/*--- Portfolio optimization with chance constraints
# Scenario: Maximize return with a high probability of meeting a minimum threshold
# Method: Chance-constrained solver — ensures reliability across scenarios

pr()

o3 = new stzStochasticSolver()
o3 {
    # Same variables and constraints
    AddVariable("stocks", 0, 100)
    AddVariable("bonds", 0, 100)
    AddVariable("cash", 0, 100)

    AddConstraint("stocks + bonds + cash", "=", 100)
    AddConstraint("stocks", "<=", 70)
    AddConstraint("cash", ">=", 10)

    # Same scenarios
    AddScenario("bull", "High growth", [["stock_return", 0.12], ["bond_return", 0.05], ["cash_return", 0.01]], 0.3)
    AddScenario("bear", "Low growth", [["stock_return", 0.04], ["bond_return", 0.03], ["cash_return", 0.01]], 0.3)
    AddScenario("normal", "Moderate growth", [["stock_return", 0.08], ["bond_return", 0.04], ["cash_return", 0.01]], 0.4)

    # Objective: Maximize expected return
    Maximize("stock_return*stocks + bond_return*bonds + cash_return*cash")

    # Chance constraint: Return >= 5% with 90% probability
    AddChanceConstraint("stock_return*stocks + bond_return*bonds + cash_return*cash", ">=", 5, 0.9)

    # Use chance-constrained solver
    SetSolverType("chance")
    Solve()
    Show()
}

#-->
# Balances return and reliability, ensuring 5% return in most scenarios
#-->
'
╭────────────────────────────────╮
│ Stochastic Programming Problem │
╰────────────────────────────────╯
• Variables:
 ─ stocks ∈ [0, 100] (continuous)
 ─ bonds ∈ [0, 100] (continuous)
 ─ cash ∈ [0, 100] (continuous)

• Objective:
╰─> MAXIMIZE stock_return*stocks + bond_return*bonds + cash_return*cash

• Scenarios:
 ─ bull: High growth (p=0.30)
 ╰─> stock_return = 0.12
 ╰─> bond_return = 0.05
 ╰─> cash_return = 0.01

 ─ bear: Low growth (p=0.30)
 ╰─> stock_return = 0.04
 ╰─> bond_return = 0.03
 ╰─> cash_return = 0.01

 ─ normal: Moderate growth (p=0.40)
 ╰─> stock_return = 0.08
 ╰─> bond_return = 0.04
 ╰─> cash_return = 0.01

• Constraints:
 ─ stocks + bonds + cash = 100
 ─ stocks <= 70
 ─ cash >= 10
 ─ stock_return*stocks + bond_return*bonds + cash_return*cash >= 5 (chance=0.90)

╭──────────╮
│ Solution │
╰──────────╯
• Status: optimal
• Solver: chance
• Solved in 0.42 second(s)

• Variable Values:
 ─ stocks = 100
 ─ bonds = 100
 ─ cash = 100

• Expected Objective Value: 13

• Scenario Analysis:
 ─ bull (p=0.30): 18 ✗
 ─ bear (p=0.30): 8 ✗
 ─ normal (p=0.40): 13 ✗
'

pf()
# Executed in 0.56 second(s) in Ring 1.22

#============================#
#   SUPPLY CHAIN MANAGEMENT  #
#============================#

/*--- Inventory management with uncertain demand
# Scenario: Determine order quantities to minimize expected total cost
# Method: Expected value solver — balances ordering, holding, and shortage costs

pr()

o4 = new stzStochasticSolver()
o4 {
    # Decision variables: order quantities for two products
    AddVariable("product1", 0, 1000)
    AddVariable("product2", 0, 1000)

    # Storage capacity constraint
    AddConstraint("2*product1 + 3*product2", "<=", 2000)

    # Budget constraint
    AddConstraint("5*product1 + 10*product2", "<=", 5000)

    # Define scenarios for demand
    AddScenario("low", "Low demand", [["demand1", 200], ["demand2", 150]], 0.2)
    AddScenario("medium", "Medium demand", [["demand1", 300], ["demand2", 250]], 0.5)
    AddScenario("high", "High demand", [["demand1", 400], ["demand2", 350]], 0.3)

    # Objective: Minimize expected total cost
    # Total cost = ordering cost + holding cost + shortage cost
    # For simplicity, assume ordering cost = 2*quantity, holding cost = 1*excess, shortage cost = 3*shortfall
    Minimize("2*product1 + 2*product2 + 
              1*max(product1 - demand1, 0) + 1*max(product2 - demand2, 0) + 
              3*max(demand1 - product1, 0) + 3*max(demand2 - product2, 0)")

    # Use expected value solver
    SetSolverType("expected")
    Solve()
    Show()
}

#-->
# Displays optimal order quantities, expected total cost, and scenario analysis
# Balances ordering, holding, and shortage costs across demand scenarios
#-->
'
╭────────────────────────────────╮
│ Stochastic Programming Problem │
╰────────────────────────────────╯
• Variables:
 ─ product1 ∈ [0, 1000] (continuous)
 ─ product2 ∈ [0, 1000] (continuous)

• Objective:
╰─> MINIMIZE 2*product1 + 2*product2 + 
              1*max(product1 - demand1, 0) + 1*max(product2 - demand2, 0) + 
              3*max(demand1 - product1, 0) + 3*max(demand2 - product2, 0)

• Scenarios:
 ─ low: Low demand (p=0.20)
 ╰─> demand1 = 200
 ╰─> demand2 = 150

 ─ medium: Medium demand (p=0.50)
 ╰─> demand1 = 300
 ╰─> demand2 = 250

 ─ high: High demand (p=0.30)
 ╰─> demand1 = 400
 ╰─> demand2 = 350

• Constraints:
 ─ 2*product1 + 3*product2 <= 2000
 ─ 5*product1 + 10*product2 <= 5000

╭──────────╮
│ Solution │
╰──────────╯
• Status: optimal
• Solver: expected
• Solved in 0.28 second(s)

• Variable Values:
 ─ product1 = 1000
 ─ product2 = 1000

• Expected Objective Value: 4000

• Scenario Analysis:
 ─ low (p=0.20): 4000 ✗
 ─ medium (p=0.50): 4000 ✗
 ─ high (p=0.30): 4000 ✗
'

pf()
# Executed in 0.40 second(s) in Ring 1.22

#============================#
#   ENERGY SYSTEMS           #
#============================#

/*--- Power generation planning with renewable uncertainty
# Scenario: Determine generation levels to minimize expected cost under renewable variability
# Method: Robust solver — ensures feasibility under worst-case renewable output

pr()

o5 = new stzStochasticSolver()
o5 {
    # Decision variables: generation from fossil and renewable sources
    AddVariable("fossil", 0, 1000)
    AddVariable("renewable", 0, 1000)

    # Meet demand constraint (demand = 800 MW)
    AddConstraint("fossil + renewable", ">=", 800)

    # Emission limit constraint
    AddConstraint("0.5*fossil", "<=", 300)

    # Define scenarios for renewable output
    AddScenario("low_renewable", "Low renewable output", [["renewable_output", 200]], 0.3)
    AddScenario("medium_renewable", "Medium renewable output", [["renewable_output", 400]], 0.4)
    AddScenario("high_renewable", "High renewable output", [["renewable_output", 600]], 0.3)

    # Objective: Minimize expected generation cost
    # Cost = fossil cost + renewable cost
    # Fossil cost = 50*fossil, renewable cost = 20*renewable
    Minimize("50*fossil + 20*renewable")

    # Use robust solver to handle worst-case renewable output
    SetSolverType("robust")
    Solve()
    Show()
}

#-->
# Displays optimal generation levels, expected cost, and scenario analysis
# Prioritizes fossil fuel to ensure demand is met even in low renewable scenarios
#-->
'
╭────────────────────────────────╮
│ Stochastic Programming Problem │
╰────────────────────────────────╯
• Variables:
 ─ fossil ∈ [0, 1000] (continuous)
 ─ renewable ∈ [0, 1000] (continuous)

• Objective:
╰─> MINIMIZE 50*fossil + 20*renewable

• Scenarios:
 ─ low_renewable: Low renewable output (p=0.30)
 ╰─> renewable_output = 200

 ─ medium_renewable: Medium renewable output (p=0.40)
 ╰─> renewable_output = 400

 ─ high_renewable: High renewable output (p=0.30)
 ╰─> renewable_output = 600

• Constraints:
 ─ fossil + renewable >= 800
 ─ 0.5*fossil <= 300

╭──────────╮
│ Solution │
╰──────────╯
• Status: optimal
• Solver: robust
• Solved in 0.09 second(s)

• Variable Values:
 ─ fossil = 1000
 ─ renewable = 1000

• Expected Objective Value: 70000

• Scenario Analysis:
 ─ low_renewable (p=0.30): 70000 ✗
 ─ medium_renewable (p=0.40): 70000 ✗
 ─ high_renewable (p=0.30): 70000 ✗
'

pf()

#============================#
#   HEALTHCARE               #
#============================#

/*--- Hospital resource allocation with uncertain patient arrivals
# Scenario: Allocate beds and staff to maximize expected patient satisfaction
# Method: Chance-constrained solver — ensures high probability of meeting patient needs
*/
pr()

o6 = new stzStochasticSolver()
o6 {
    # Decision variables: number of beds and staff in two departments
    AddVariable("beds_dept1", 0, 50)
    AddVariable("beds_dept2", 0, 50)
    AddVariable("staff_dept1", 0, 20)
    AddVariable("staff_dept2", 0, 20)

    # Budget constraint
    AddConstraint("1000*beds_dept1 + 1000*beds_dept2 + 5000*staff_dept1 + 5000*staff_dept2", "<=", 200000)

    # Staffing ratio constraints
    AddConstraint("staff_dept1", ">=", "0.2*beds_dept1")
    AddConstraint("staff_dept2", ">=", "0.2*beds_dept2")

    # Define scenarios for patient arrivals
    AddScenario("low_arrivals", "Low patient arrivals", [["patients_dept1", 20], ["patients_dept2", 15]], 0.2)
    AddScenario("medium_arrivals", "Medium patient arrivals", [["patients_dept1", 30], ["patients_dept2", 25]], 0.5)
    AddScenario("high_arrivals", "High patient arrivals", [["patients_dept1", 40], ["patients_dept2", 35]], 0.3)

    # Objective: Maximize expected patient satisfaction
    # Satisfaction = min(beds / patients, 1) * 100 for each department
    Maximize("min(beds_dept1 / patients_dept1, 1) * 100 + min(beds_dept2 / patients_dept2, 1) * 100")

    # Chance constraint: Satisfaction >= 80 with 90% probability for each department
    AddChanceConstraint("min(beds_dept1 / patients_dept1, 1) * 100", ">=", 80, 0.9)
    AddChanceConstraint("min(beds_dept2 / patients_dept2, 1) * 100", ">=", 80, 0.9)

    # Use chance-constrained solver
    SetSolverType("chance")
    Solve()
    Show()
}

#-->
# Displays optimal resource allocation, expected satisfaction, and scenario analysis
# Ensures high satisfaction levels in most scenarios while respecting budget and staffing constraints
#-->
pf()




/*--------------------------------------------------

pr()

solver = new stzStochasticSolver
solver.addVariable("production", 0, 1000)
      .addScenario("HighDemand", "Strong market", [["demand", 1500]], 0.3)
      .addScenario("LowDemand", "Weak market", [["demand", 800]], 0.7)
      .maximize("50 * production")
      .addConstraint("production", ">=", "demand * 0.9")
      .setSolverType("expected")
      .solve()
	  .show()

#-->
'
╭────────────────────────────────╮
│ Stochastic Programming Problem │
╰────────────────────────────────╯
• Variables:
 ─ production ∈ [0, 1000] (continuous)

• Objective:
╰─> MAXIMIZE 50 * production

• Scenarios:
 ─ HighDemand: Strong market (p=0.30)
 ╰─> demand = 1500

 ─ LowDemand: Weak market (p=0.70)
 ╰─> demand = 800

• Constraints:
 ─ production >= demand * 0.9

╭──────────╮
│ Solution │
╰──────────╯
• Status: optimal
• Solver: expected
• Solved in 0.03 second(s)

• Variable Values:
 ─ production = 1000

• Expected Objective Value: 50000

• Scenario Analysis:
 ─ HighDemand (p=0.30): 50000 ✗
 ─ LowDemand (p=0.70): 50000 ✓
'

pf()
# Executed in 0.06 second(s) in Ring 1.2

/*-----------

#============================#
#   PORTFOLIO OPTIMIZATION   #
#============================#

/*--- Portfolio optimization with expected value
# Scenario: Allocate funds across stocks, bonds, and cash to maximize expected return
# Method: Expected value solver — optimizes based on weighted average of scenarios

pr()

o1 = new stzStochasticSolver()
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

    # Define scenarios with returns under different market conditions
    AddScenario("bull", "High growth", [["stock_return", 0.12], ["bond_return", 0.05], ["cash_return", 0.01]], 0.3)
    AddScenario("bear", "Low growth", [["stock_return", 0.04], ["bond_return", 0.03], ["cash_return", 0.01]], 0.3)
    AddScenario("normal", "Moderate growth", [["stock_return", 0.08], ["bond_return", 0.04], ["cash_return", 0.01]], 0.4)

    # Objective: Maximize expected return
    Maximize("stock_return*stocks + bond_return*bonds + cash_return*cash")

    # Use expected value solver
    SetSolverType("expected")
    Solve()
    Show()
}

#-->
# Displays optimal allocation, expected return, and scenario feasibility
# Typically favors stocks for higher returns, balanced by constraints
#-->
'
╭───────────────────────────────╮
│ Stochastic Programming Problem │
╰───────────────────────────────╯

• Variables:
  stocks ∈ [0, 100] (continuous)
  bonds ∈ [0, 100] (continuous)
  cash ∈ [0, 100] (continuous)

• Objective:  
  MAXIMIZE stock_return*stocks + bond_return*bonds + cash_return*cash

• Scenarios:
  bull: High growth (p=0.3)
    stock_return = 0.12
    bond_return = 0.05
    cash_return = 0.01
  bear: Low growth (p=0.3)
    stock_return = 0.04
    bond_return = 0.03
    cash_return = 0.01
  normal: Moderate growth (p=0.4)
    stock_return = 0.08
    bond_return = 0.04
    cash_return = 0.01

• Constraints:
  stocks + bonds + cash = 100
  stocks <= 70
  cash >= 10

╭─────────╮
│ Solution │
╰─────────╯
• Status: optimal
• Solver: expected
• Variable Values:
  stocks = 70
  bonds = 20
  cash = 10
• Expected Objective Value: ~0.069 (varies slightly by solver implementation)
• Scenario Analysis:
  bull (p=0.3): ~0.094 ✓
  bear (p=0.3): ~0.039 ✓
  normal (p=0.4): ~0.069 ✓
'
pf()
# Executed in ~0.1 second(s) in Ring 1.22

/*--- Portfolio optimization with robust approach
# Scenario: Minimize risk under worst-case market conditions
# Method: Robust solver — focuses on worst-case scenario performance

pr()

o2 = new stzStochasticSolver()
o2 {
    # Same variables and constraints
    AddVariable("stocks", 0, 100)
    AddVariable("bonds", 0, 100)
    AddVariable("cash", 0, 100)

    AddConstraint("stocks + bonds + cash", "=", 100)
    AddConstraint("stocks", "<=", 70)
    AddConstraint("cash", ">=", 10)

    # Same scenarios with risk parameters
    AddScenario("bull", "High growth", [["stock_risk", 0.15], ["bond_risk", 0.04]], 0.3)
    AddScenario("bear", "Low growth", [["stock_risk", 0.08], ["bond_risk", 0.02]], 0.3)
    AddScenario("normal", "Moderate growth", [["stock_risk", 0.12], ["bond_risk", 0.03]], 0.4)

    # Objective: Minimize risk
    Minimize("stock_risk*stocks + bond_risk*bonds")

    # Use robust solver
    SetSolverType("robust")
    Solve()
    Show()
}

#-->
# Prioritizes low-risk assets (bonds, cash) under worst-case scenario
#-->
pf()

/*--- Portfolio optimization with chance constraints
# Scenario: Maximize return with a high probability of meeting a minimum threshold
# Method: Chance-constrained solver — ensures reliability across scenarios

pr()

o3 = new stzStochasticSolver()
o3 {
    # Same variables and constraints
    AddVariable("stocks", 0, 100)
    AddVariable("bonds", 0, 100)
    AddVariable("cash", 0, 100)

    AddConstraint("stocks + bonds + cash", "=", 100)
    AddConstraint("stocks", "<=", 70)
    AddConstraint("cash", ">=", 10)

    # Same scenarios
    AddScenario("bull", "High growth", [["stock_return", 0.12], ["bond_return", 0.05], ["cash_return", 0.01]], 0.3)
    AddScenario("bear", "Low growth", [["stock_return", 0.04], ["bond_return", 0.03], ["cash_return", 0.01]], 0.3)
    AddScenario("normal", "Moderate growth", [["stock_return", 0.08], ["bond_return", 0.04], ["cash_return", 0.01]], 0.4)

    # Objective: Maximize expected return
    Maximize("stock_return*stocks + bond_return*bonds + cash_return*cash")

    # Chance constraint: Return >= 5% with 90% probability
    AddChanceConstraint("stock_return*stocks + bond_return*bonds + cash_return*cash", ">=", 5, 0.9)

    # Use chance-constrained solver
    SetSolverType("chance")
    Solve()
    Show()
}

#-->
# Balances return and reliability, ensuring 5% return in most scenarios
#-->
pf()
