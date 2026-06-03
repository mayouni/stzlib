# Narrative
# --------
# Investment portfolio optimization
#
# Extracted from stzlinearsolvertest.ring, block #5.

load "../../stzBase.ring"


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
