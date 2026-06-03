# Narrative
# --------
# Transportation Problem for Logistics Education
#
# Extracted from stzlinearsolvertest.ring, block #8.

load "../../stzBase.ring"

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
