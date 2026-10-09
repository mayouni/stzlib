# Wave 10 defects -- stzLinearSolver, stzStochasticSolver, stzMultiObjectiveSolver, stzListRandom (stzUMAP and stzTSNE: none)

Found by calling every root with real data (Ring 1.27, Windows, 2026-10-09). None was fixed; each is a warning in the doc block of the method.
Every item was confirmed with a second, different call unless marked otherwise.

## stzLinearSolver (stats/stzLinearSolver.ring)

| method | symptom | cause | evidence |
|---|---|---|---|
| CalculatePenalty, CalculateFitness, solveWithGenetic, Solve("genetic") | raise R5 Can't access the list item, Object is not list whenever the problem has a constraint | `CalculatePenalty` reads `oConst[:expression]` on line 995, a variable that is never defined, one line above the correct statement | a direct CalculatePenalty call with two constraints; Solve("genetic") with one constraint (x <= 2) and with two; with no constraint the same methods work (penalty 0, genetic answered x = 99, y = 100 on bounds 0..100) |
| BuildSimplexTableau, HasNegativeCoefficient, FindPivotColumn, FindPivotRow, PivotTableau, ExtractSimplexSolution | placeholders: constant [ [ 1, 2, 3 ], [ 4, 5, 6 ] ], 0, 1, 1, the argument unchanged, zeros | bodies are stubs (`#TODO`, "Simplified"); the real simplex runs in the engine through solveWithSimplex and never calls them | called with [ [ 1, -2 ] ] and [ [ 1, 2 ] ]: constants regardless of the argument |
| solveWithGreedy (Solve("greedy"), the default) | not optimal, not always feasible, and still status optimal | every variable is raised to its maximum even when minimizing; ">=" and "=" are read as "<="; values are floored | minimize x, x <= 4, bounds 0..5: greedy 4, simplex 0; minimize x + 2y with x + y >= 3 and x - y = -1: greedy x = 0, y = 3 (value 6, breaks x - y = -1), simplex x = 1, y = 2 (value 5) |
| solveWithBranchAndBound | always raises, status unimplemented | deliberate honesty guard on its first line; the branching code after it is unreachable | Solve("branch_bound") on a small problem; the raise text names the guard |
| solveWithSimplex | raises "the engine simplex returned an unusable result" for a problem with no constraint whose bound ranges are all at least 1000000000 | no tableau row is built (bound rows are skipped above 1e9), the engine answers a short list | one variable 0..1e12 maximize x; two variables 0..1e12 maximize a + b. With one constraint the same ranges answer status unbounded |
| addIntegerVariable, addBinaryVariable | the integer and binary marks change nothing | recorded in :type, read by no solver; simplex answers fractions | maximize n with 2n <= 5 (n integer 0..10): simplex 2.5; maximize b with 2b <= 1 (binary): simplex 0.5 |
| addVariable (and the three-argument family) | the defaults coded for a missing lower or upper bound are never reached | Ring raises R19 Calling function with less number of parameters when an argument is omitted | addVariable("v") and addVariable("v", 2) |
| addConstraint | a value given as text ("7", "") is stored as 0 | the text is looked up in the @variables list (`@variables[_value_]`) | "" and "7" both stored value 0 |
| Mutate | the first variable is mutated about twice as often | the index is drawn as RandomInt(0, n) and 0 is mapped to 1 | 300 calls on three variables: 157, 72, 71 changes |
| show | each variable, constraint and value is printed twice (plain and bulleted); the plain constraint line has no operator and value | duplicate print blocks left in the method | output of show after a greedy solve |

## stzStochasticSolver (stats/stzStochasticSolver.ring)

| method | symptom | cause | evidence |
|---|---|---|---|
| solveExpectedValue, solveRobust, solveChanceConstrained (Solve with solver types expected, robust, chance) | every variable stays at its lower bound | the assignment loop does `_sol_ = _aSolution_[i]` and then `_sol_[2] = _nValue_`: Ring copies a list on assignment, so the stored pair is never updated | scenario problem with x + y <= d (x, y in 0..10): solution [ 0, 0 ]; one variable x in 0..3, x <= 2, maximize x: solution [ x, 0 ]; the same on the robust and chance types. A four-line Ring script confirms the copy: a = [["x",0]]; s = a[1]; s[2] = 5 leaves a[1][2] at 0 |
| calculateScenarioMaxValue (and calculateExpectedMaxValue, calculateRobustMaxValue, calculateChanceMaxValue, solveForScenario, solveMonteCarlo) | no constraint limits anything: the limit is always 999999 | `switch _const_[:operator] on "=" or "<="` is a label that matches no operator (a three-line switch shows "<=", "=" and ">=" all fall to no match) | x with x <= 6, x >= 6, x = 6: 999999 each time; calculateExpectedMaxValue answered 399999.6 (999999 times a probability of 0.4); solveMonteCarlo returned x = 3 under x <= 2 and 10, 10 under x + y <= d |
| solve | status is optimal in every case, and iterations is set by the expected type only | `@cStatus = "optimal"` unconditionally | all four types |
| getWorstCaseObjective | returns the first scenario's objective, not the worst | the body keeps the first scenario (`# For simplicity, return the first scenario's objective`) | code read (the loop keeps `_scenario_ = @aScenarios[1]`); not run on an objective that names a parameter |
| SetVariableNames | stores its argument as the variable records, so a list of names breaks variableNames() | `@aVariables = pacNames`; the code has `#TODO // Add more checks here` | SetVariableNames([ "a", "b" ]) then variableNames(): R5; SetVariableNames([ [ "name", "q" ] ]) leaves variables() holding [ [ "name", "q" ] ] without bounds |
| evaluateExpression | handles one operation only | the text is split on the first operator found | "2 * 3 + 1" raises R41 Invalid numeric string |
| addScenarioConstraint, addChanceConstraint | the operator and the expression are not validated | the checks of addConstraint were not copied | code read |

## stzMultiObjectiveSolver (optim/stzMultiObjectiveSolver.ring)

| method | symptom | cause | evidence |
|---|---|---|---|
| solveWithEpsilonConstraint (Solve("epsilon_constraint")) | the front is a few points repeated, not a trade-off | each sub-problem goes to the greedy solver of stzLinearSolver, which reads ">=" as "<=" and always raises variables to their maximum (see stzLinearSolver.solveWithGreedy) | maximize x, maximize y, x + y <= 10: eleven solutions, all x = 10, y = 0 (the true front is the line x + y = 10); minimize x + y, maximize x - y, x + y >= 2 on 0..5: 11 solutions, mostly the same point |
| exportParetoFrontCSV | raises R41 Invalid numeric string for any non-empty front | `_cContent_ += value + ","` adds a comma to a number, and Ring reads the text as a number | the front of the epsilon-constraint solve on two different problems |
| calculateEpsilonRanges | uses the first two secondary objectives only | the combinations are built from ranges 1 and 2 | four objectives give 121 rows of two bounds |
| addVariable (and family), solve | the argument cannot be omitted | R19 | solve() with no argument on two solvers |

## stzListRandom (list/stzListRandom.ring)

| method | symptom | cause | evidence |
|---|---|---|---|
| NRandomPositions | never returns for n = 0 | NUniqueRandomNumbersIn(0, 1:n) loops (the helper in number/stzRandom.ring) | lists of 5 and of 3 items; the Ring process had to be killed |
| RandomItemExceptPosition | raises R2 Array Access (Index out of range) on a list of one item | RandomPositionExcept answers 0 and ItemAt(0) follows | list of one item, position 1 |
| RandomizeNumbers, RandomizeStrings, RandomizeLists, RandomizeObjects (and the Randomized forms) | reorder only runs of adjacent items of the kind: a lone number between other items never moves | each run found by Find...AsSections is shuffled on its own | [ 1, 2, 3, "a", 4, 5 ]: 60 draws, no number left its run; [ 1, "a", 2, "b" ] never changes. May be intended, it is stated in the blocks |

## stzUMAP and stzTSNE (number/stzEmbedding.ring)

No defect found. Checked on twelve points in two clusters: the same seed gives the same embedding, another seed another; a density weight of 0 equals the ordinary fit value for value; the parametric Transform of the training rows equals the embedding exactly (difference 0); Fit refuses a perplexity or neighbour count that is too large with a message that says why; the graph of UMAP survives a layout-only refit and is dropped by SetNeighbors, ReduceWithPCA, SkipPCA, LearnFromLabels, IgnoreLabels and SetTargetWeight.
Not a defect, worth a reader's attention: with only 120 iterations the classic t-SNE cost history went from 44.74 to 48.83, so the KL value reported by KLHistory and Why should not be read as decreasing on a short run (the early-exaggeration phase was not examined).
