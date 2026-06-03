# Narrative
# --------
# Supply Chain Optimization with Uncertainty
#
# Extracted from stzlinearsolvertest.ring, block #12.

load "../../stzBase.ring"

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
