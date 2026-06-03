# Narrative
# --------
# Event Planning with Multiple Constraints
#
# Extracted from stzlinearsolvertest.ring, block #11.
#ERR Error (R5) : Can't access the list item, Object is not list

load "../../stzBase.ring"

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
