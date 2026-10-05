# Wave 4, graph2 -- defects found while probing (code, not comments; none fixed)

Format: Class.method: symptom: cause. Each verified with a second call on different data.

## stzGraphQuery
- OrderBy: never sorts; asc keeps the match order, desc reverses it (verified on age, name, city): `@SortOn(_aValues_, 2)` returns the sorted list and `_ApplyOrderBy` drops it. Also only the first OrderBy is read, and a sort field that is not in the projected row reads as empty.
- ValidateWith("text"): stores [ [ [ ] ] ] and raises R21 when the query runs (verified with "x", "connected", :DAG): `paValidators = [paValidators]` self-wrap; a list of names works and a failing group raises "Validation failed".
- SelectXT / SelectAndRun: run the query twice (Select already ran it), so Create/Set/Delete parts take effect twice (nodes 4 -> 5 on one call); answer 1, not the rows.
- ToGraphQ (and ToViewQ): after Select they run the query again, because only Execute sets the executed flag.
- OrderBy(field) with one argument: R19 (pcDirection has no default).
- Set("age", v) without an alias dot silently changes nothing (target must read alias.property).

## stzGraphex
- Match: cache signature = node/edge counts + node ids, labels ignored; a second graph with the same ids and other labels returns the first graph's cached answer (verified Start/PROCESS/end vs Alpha/Beta/Gamma; ClearCache restores the right answer).
- EnableDebugMode / DisableDebugMode / SetDebugMode (+ EnableDebug, DisableDebug, SetDebug): store a flag nothing reads; every `if @bDebugMode` branch in the class is empty.
- ParseSingleToken / Match: the quantifier (+ * ?) fills min/max, but matching never reads them: `{@Node(Start) -> @Node(zz)*}` is FALSE although * allows zero.
- ParsePattern: removes the first and last character without checking for braces; "@Node(abc) -> @Node(def)" yields one token with an empty label.
- TraversePatternNode: an unknown id raises "Node ':zz' does not exist!" from This.Node(); the `if _aNode_ = ""` guard after it can never run.
- IsSubsequence: a negated pattern label is tested only against the target item right after the previous match, not the rest of the target ([a,c] vs [a,b,c] with c negated is TRUE).
- Match: negation applies per path, not per graph (a path with Start and no end satisfies `Start -> @!Node(end)` even when another path holds end).
- Match: @Cycle, @Path and bare @Node/@Edge tokens carry no label and match any graph (`{@Cycle}` is TRUE on a DAG).
- BuildPatternGraph: called a second time it grafts the new tokens onto the existing pattern graph with ids restarting at :p1.

## stzMathFigure
- Pin: raises "has nothing a rule left free" for every shape of 35 sample figures covering all ten kinds (every shape's geometry is fixed by the rules); an unknown path raises "not a shape any rule minted".
- DragTo: raises "has no free centre" for every shape of 9 sample figures across the kinds, for the same reason; Unpin is harmless but therefore does nothing.
- SetTheme: stores any name without a check; an unknown name ("nonsense", "paper", "blueprint") raises a stzColor error "'background' is not a colour" only when the figure is next drawn, and the figure stays on it.
- RenditionAs("image"): writes rendition_function.png into the current folder (no path argument), where ToPNG takes a path.
- SetDatum: object and key are not checked ("zzz" accepted silently); changing fr.samples changes the datum, not the sampled curve (the SVG stayed byte-identical in length).
- Zeros / Extrema: on a non-function figure they raise through Marks ("a boxplot figure has no Marks"), so the message names Marks, not the method called.

## stzOrgChart (and the helper classes of graph/stzOrgChart.ring)
- SuccessionRisk / ValidateSuccession / GenerateSuccessionReport / ViewAtRisk: a successor is looked for in `@aPositions[i][:attributes]`, a key AddPositionXTT never writes (attributes are flattened into the record); every filled position is at risk always, and SetNodeProperty("vp1", "successor", ...) changes nothing (before and after both [ceo, vp1]).
- GenerateVacancyReport / VacancyReport: every detail's level is "staff" (vp2 is management): level read from the same missing :attributes key.
- ResetAllNodeColors / AssignPerson / ApplyFocusTo: the "restore level colour" step reads :attributes[:level], never found, so nodes end white after AssignPerson (ceo executive assigned: white) and after every reset.
- ViewNonCompliant: raises R20 for "vacancy", "bceao" and "sod": calls This.Validate(pcNorm), Validate takes no argument.
- ViewNotAtRisk: raises R24 (@bshowtitle) with and without a title: the attribute is defined nowhere in the hierarchy.
- ViewDepartment: with a title set raises R24 ppcdepartmentid (typo of `@aDepartments[PpcDepartmentId]`); works with no title.
- ViewPath / ViewReportingPath / HilightPath / FocusOnPath: with a title set the subtitle line indexes `@aNodes[pcFromId]` on a list and adds a node with an empty id (node count 5 -> 6); without a title they work.
- ViewNodeWithProperties, ViewNodesWithTags: empty TODO stubs, do nothing.
- AddPosition / AddPerson: a repeated id is accepted: two records and two graph nodes of the same id (node count 5 -> 6).
- ReportsTo: a second supervisor adds a second edge and overwrites the record's reportsTo; a self-report ("ceo", "ceo") is accepted (the notation's refusals act only at Validate and the editor gestures).
- ChangeReportingLine: no cycle check ("ceo" under "vp2" accepted, edge vp2>ceo added).
- RemovePosition: subordinates keep the removed id as their reportsTo and are not reconnected.
- AssignPerson / ReassignPerson with an unknown position id: no error; the person points to the unknown id (and ReassignPerson has already vacated the old position).
- VacancyRate and Explain: R1 divide by zero on a chart with no position.
- DirectReports (and DirectReportsCount, ValidateSpanOfControl, AverageSpanOfControl, ColorByDepartment, ViewDepartment): reading `rec[:key]` on a hash list that lacks the key ADDS the key with an empty value (reportsto="" appears on root positions; department="" on positions without one) -- Ring hash-list behaviour used as if it were a read.
- ImportStzOrg: the positions of a department come back wrapped in quotes ('"ceo"'); the `orgchart "name"` line is parsed and dropped.
- SetDepartmentColor: only departments added afterwards take the colour (clusters take @cClusterColor when created; Dot unchanged for an existing cluster).
- Validate: a validator name it does not know gives status "error", which is not counted as a failure, so SetValidators(["zzz"]) passes; the validators "noncompliance" raises R14 (ValidateNonCompliance does not exist) and "summary" gives a not_run verdict.
- LoadRuleBase: a stub, records the source and nothing evaluates it.
- stzOrgChartSimulation.ApplyChanges: a change_reporting change raises "Cannot add edge: one or both nodes do not exist!" (the clone copies the records but has no graph nodes); an unknown :type is skipped silently.
- stzOrgChartReporter / stzOrgChartBCEAOValidator / stzOrgChartSODValidator: init stores a COPY of the chart (Ring copies a stored object), so a position added afterwards is not seen (reporter saw 1 of 2 positions; validator kept saying no board after one was added).
- stzSODValidator / ValidateSegregationOfDuties: the message says "reports through Treasury" but only the direct supervisor is checked.

## stzGraphPlanner (and PlanComparison, MultiPlanComparison, HistoricalComparison, PlanFilter)
- Execute / ExecutePlan: a criterion naming an edge property that is not on every edge (Minimize("nope"), Using(:safest) on a graph without danger and risk) raises "This edge propert (' + cProperty + ') does not exist!": the message is a literal with unfilled concatenation, and the `if pValue = "" then 1` fallback in _CalculateTransitionCost is never reached because EdgeProperty raises first. Verified with two data.
- Maximize / MaximizeIn: a maximised property enters as a negative cost (Maximize("distance") gave Cost -30), and the search (uniform cost, non-negative assumed) is not sure to find the best route; Maximize("gold") on a node-only property raises the edge property error above.
- init: the planner stores a COPY of the graph; a node added afterwards is unknown to it (Execute raises "Node 'c' does not exist!"; a fresh planner finds the route).
- AddPlan: a name already used is added a second time; _FindPlan always finds the first, so the second plan (the new current one) cannot be reached by name (Cost() read the first plan's result).
- Profile(":fastest"): returns [ ] for a name with a colon, where Using(":fastest") strips it first.
- Plan(name): the lookup is made on the unlowered name and only works because hash-list keys ignore case; an unknown name raises R2 (index out of range).
- CostBreakdown: a hand-written criterion without :weight searches with weight 1 but CostBreakdown shows weight "" and contribution 0 (a fallback of 1 exists in _CalculateTransitionCost only).
- Why / Efficiency: raise R2 on a plan that was not executed; Efficiency raises R1 (divide by zero) when the route is empty (goal not reached, start = goal is fine: ratio 1).
- Alternatives: `chosen` is the first neighbour of the node, not the one the route took (chosen suburb_a on a route through suburb_b).
- Explain vs CompareMany / FilterPlans / HistoricalAverage: steps means edges in Explain (2) and route nodes everywhere else (3).
- A goal that cannot be reached (graph is directed: customer -> warehouse) gives an executed plan with Route [ ], Cost 0 and the text "No path found"; CompareTo then names it the cheaper plan against any real route.
- CompareWithHistory / CompareWithHistoryXT: after ClearHistory, raise R13 "Object is required" because CompareWithHistoryXTQ returns a message text where the object is expected (CompareWithHistoryQ returns the text itself).
- PlansThatAvoid: raises R14: calls PlansAvoiding, while the root is the misspelled PlansAvoinding (the Q form PlansThatAvoidQ works).
- HistoAverage(): raises R19: calls HistoricalAverage with no criterion.
- CostOf(:Plan = "x"): raises R21 (only :Of and :OfPlan are accepted as the pair key); RouteOf and ActionsOf accept :Of and :In.
- CompareMany: plans not found or not executed are dropped silently, while total_plans still counts the requested names; best_by_* raise "No ranks returned" when none is left.
- stzPlanFilter.ShowRankingTable with no matching plan prints "No plans match the filters." then raises "paTable must be a list" (RankingTable returned nothing).
- stzPlanFilter.PlansXT: the key is spelled constrains_applied.
- stzHistoricalComparison: the history it averages includes the compared plan's own run.
