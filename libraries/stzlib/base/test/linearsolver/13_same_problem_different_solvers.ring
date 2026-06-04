# Narrative
# --------
# Same problem, different solvers
#
# Extracted from stzlinearsolvertest.ring, block #13.
#ERR Error (R19) : Calling function with less number of parameters

load "../../stzBase.ring"

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
