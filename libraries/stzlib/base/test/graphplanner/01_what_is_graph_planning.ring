# Narrative
# --------
# WHAT IS GRAPH PLANNING?
#
# Extracted from stzgraphplannertest.ring, block #1.

load "../../stzBase.ring"


`
Imagine you're navigating a city. Each intersection is a NODE (a state),
each street is an EDGE (a transition), and you want to find the best route.
That's graph planning!

CORE CONCEPTS:

1. GRAPH = State Space
   - Nodes represent distinct states (locations, game states, workflow steps)
   - Edges represent valid transitions (roads, actions, processes)
   - Properties store state information (coordinates, costs, conditions)

2. PATHFINDING = Finding Optimal Routes
   - A* Algorithm: Finds shortest path when you know start and goal
   - Goal-Based Search: Finds any state matching a condition
   - Cost Functions: Define what "optimal" means (time, distance, danger)

3. HEURISTICS = Smart Search Guidance
   - Estimate distance to goal without exploring all paths
   - Euclidean distance for spatial problems
   - Domain-specific estimates for other problems
   - Good heuristics = faster planning

WHY USE stzGraphPlanner?

Instead of manually coding search algorithms, you:
1. Build a graph representing your problem space
2. Define what you're optimizing (minimize cost, maximize profit)
3. Let the planner find the optimal solution automatically

REAL-WORLD APPLICATIONS:
- Warehouse robot navigation
- Manufacturing workflow optimization
- Delivery route planning
- Game AI (NPC pathfinding, quest planning)
- Network packet routing
- Supply chain optimization
`

#========================================#
#  SECTION 1: BASIC PATHFINDING WITH A*  #
#========================================#
