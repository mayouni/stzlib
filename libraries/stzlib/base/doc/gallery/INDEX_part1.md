# Gallery index, part 1 (graph, math, graphics, datetime, list, table, number, regex)

Pass: STZLIB-DOCREFORM-01, visual perception (CENTRAL-PERCEPTGATE-01).
Date: 2026-10-05. Ring 1.27 on the author's machine, GPU present (`StzGraphicsDevice()` = 1).

**Perceived by: the stzlib-docs visual pass, a MODEL reading each PNG through the Read tool, or reading the captured
text. No human has looked at these pictures.** UNPERCEIVED by a person is a state, not a failure: a human verdict is still owed.

How to read the table:
- Every picture lives in `<Class>/<name>.png` (or `.txt`) with the script that made it beside it as `<name>.ring`.
  A script that makes several pictures is copied once per picture, so each file runs on its own.
  Run with `cd libraries/stzlib/base/test/reflect` then `ring <file>` (the engine DLL path breaks from other folders).
- Verdict RIGHT = what I saw agrees with what the class doc block and the call say. WRONG = the picture contradicts
  the block or the data. UNCERTAIN = something looks off and I cannot tell whether it is a defect or a design choice.
- A "DOT tier" picture is the class's own `Dot()` text rendered by graphviz 14.0.0 (`dot -Tpng`), not by the native canvas.
- SVG files (`diag_flow.svg`, `diag_rules_clusters.svg`, `canvas_shapes.svg`) were NOT looked at: this pass has no
  SVG rasteriser. They are kept beside the PNGs so a person can open them. UNPERCEIVED.

Totals (41 pictures or text sections judged): RIGHT 20, WRONG 9, UNCERTAIN 12. The findings list (what each picture contradicts, with a suggested fix to the block or the code) was NOT written to
FINDINGS_part1.md: the Write tool refused that file ("subagents return findings as text"), so it travelled in the
pass's final report to the caller, who files it. The "what I SAW" column above carries the evidence for every line.

---

## stzDiagram

| picture | the call | what I SAW | verdict | perceived by | date |
|---|---|---|---|---|---|
| `diag_flow_default.png` | 5-node flow (start ellipse, process, decision diamond, endpoint, red danger box), `ToPNG("x.png")` with no options | Five correct SHAPES in the right order (ellipse, rounded box, diamond, double circle, red box) and arrows between them, but NOT ONE WORD: no node label, no edge label ("next", "yes", "no" are absent). 3.9 KB. Every node is the same navy except the red one | WRONG | stzlib-docs visual pass (a model reading the PNG) | 2026-10-05 |
| `diag_flow_font.png` | same flow, `ToPNGXT(path, [ :Font = oF, :NodeWidth = 130, :NodeHeight = 44, :FontSize = 14, :Width = 700, :Height = 520 ])` | Labels "Order Received", "Validate", "Valid?", "Done", "Rejected" inside their nodes, edge labels "next", "yes", "no" beside the edges. Reading order top to bottom with "Rejected" to the right of the decision. The "no" label sits ON the line to "Rejected"; the picture is placed in the left 60% of the canvas with an empty right third | RIGHT | stzlib-docs visual pass (a model reading the PNG) | 2026-10-05 |
| `diag_colours_lr.png` | 7 nodes with :color success/primary/warning/danger/info/neutral, `SetTheme("dark")`, `SetLayout(:LeftRight)`, `SetTitle("SEMANTIC COLOURS")`, `ToPNGXT` with font | Left to right layout is honoured. Colours: Start green, Process blue, decision orange, Danger red, Store (cylinder) blue, Neutral grey, End green. BUT the background is WHITE (dark theme ignored), the title is NOT drawn, "primary" and "info" are the same blue, the arrow from "Neutral" stops about 35 px short of "End", and the decision label "Warning?" is under the diamond, not inside | WRONG | stzlib-docs visual pass (a model reading the PNG) | 2026-10-05 |
| `diag_rules_clusters.png` | 4 pricing nodes with Price 0/10/50/200, three registered visual rules (green / blue / gold), `ApplyVisualRules()`, two clusters "Entry plans" and "Paid plans", `ToPNGXT` | The two clusters are drawn as pale boxes behind their nodes with their titles, the sequence arrows cross the gap between them correctly. ALL FOUR nodes are the same navy: the green, blue and gold rules and the thick gold border are not drawn. Canvas has an empty bottom fifth | WRONG | stzlib-docs visual pass (a model reading the PNG) | 2026-10-05 |
| `diag_colours_dot.png` | the same dark/LeftRight diagram, `Dot()` through graphviz | Title "SEMANTIC COLOURS" is drawn, left to right, "Danger" red and "Warning?" orange as in the native tier, but "Process" is pale lavender (native: solid blue), "Neutral" is light grey (native: mid grey), the background is white although the theme is "dark", and the edges are #D1D1D1 on white, nearly invisible | UNCERTAIN | stzlib-docs visual pass (a model reading the PNG) | 2026-10-05 |
| `diag_rules_clusters_dot.png` | the pricing diagram, `Dot()` through graphviz | Free and Basic light green, Pro blue with white text, Enterprise gold with a thick border, two titled clusters. The visual rules ARE applied in this tier | RIGHT | stzlib-docs visual pass (a model reading the PNG) | 2026-10-05 |

Text exporters, read from the captured output of `diag_flow_default.ring`: `Dot()` declares shapes ellipse / box / diamond / doublecircle and
fills; `Mermaid()` writes `graph TD` for every layout (the LeftRight diagram in `diag_colours.mmd` is also `graph TD`) and no colours. Not rendered.

## stzGraph

| picture | the call | what I SAW | verdict | perceived by | date |
|---|---|---|---|---|---|
| `graph_ascii_vertical.txt` | 8-node supply graph with a fork at "smelt" and a join at "ecu", `AsciiArt()` | The graph is cut into TWO straight chains printed one after the other with `////` between: mine-smelt-chip-board-ecu-car, then smelt-cell-pack-ecu-car. "smelt" and "ecu" appear twice (marked `!smelt!`, `!ecu!`), a `↑╯` hook marks the repeat. All 8 edges are present but the fork and the join cannot be seen as such | UNCERTAIN | stzlib-docs visual pass (a model reading the captured text) | 2026-10-05 |
| `graph_ascii_horizontal.txt` | same graph, `AsciiArtHorizontal()` | One row: mine ----> smelt ----> chip ----> board ----> ecu ----> car. The nodes "cell" and "pack" and their three edges are NOT SHOWN, and nothing says anything was dropped | WRONG | stzlib-docs visual pass (a model reading the captured text) | 2026-10-05 |
| `graph_canvas_hier.png` | `GraphCanvas([ :Layout = :Hierarchical, :SizeBy = :Impact, :ColorBy = :Impact, :Font = oF ])`, 760x520 | Dark picture, 8 discs with labels (ids). mine is largest and red, smelt orange, chip and cell yellow-green, then greens getting smaller down to car. Hierarchy reads top to bottom. NO arrowheads, so direction is lost; the short edge mine-smelt runs through the label "mine" | UNCERTAIN | stzlib-docs visual pass (a model reading the PNG) | 2026-10-05 |
| `graph_canvas_force.png` | same with `:Layout = :Force, :SizeBy = :Degree, :ColorBy = :Degree` | Hexagon ring layout, smelt and ecu big red discs, "mine" and "car" (degree 1) shrunk to pin-points about 2 px wide, labels readable. No arrowheads | UNCERTAIN | stzlib-docs visual pass (a model reading the PNG) | 2026-10-05 |

## stzKnowledgeGraph

| picture | the call | what I SAW | verdict | perceived by | date |
|---|---|---|---|---|---|
| `kg_ascii.txt` | zoo graph of 5 facts, `AsciiArt()` | Four chains, `////` between them, edge labels (is-a, lives-in, eats) printed on the arrows. Dog, Cat, Animal repeat; `!Dog!` and `!Animal!` carry bottleneck marks. Reads as four small stories, not as one graph | UNCERTAIN | stzlib-docs visual pass (a model reading the captured text) | 2026-10-05 |
| `kg_canvas.png` | `GraphCanvas([ :Layout = :Hierarchical, :SizeBy = :Degree ... ])` | Six discs: dog and cat top, animal large red middle, meat, fish, zoo small. Labels are the lowercase ids ("dog"), NOT the predicates: the picture has no "is-a", "eats", "lives-in" anywhere and no arrowheads, so the facts are gone and only a skeleton remains | WRONG | stzlib-docs visual pass (a model reading the PNG) | 2026-10-05 |
| `kg_dot.png` | `Dot()` through graphviz | Boxes Dog, Cat, Animal, Meat, Fish, Zoo; arrows with the predicate labels is-a, eats, lives-in; arrowheads present. Correct reading of the five facts | RIGHT | stzlib-docs visual pass (a model reading the PNG) | 2026-10-05 |

## stzOrgChart

| picture | the call | what I SAW | verdict | perceived by | date |
|---|---|---|---|---|---|
| `org_tree.png` | CEO > CTO, CFO > 2 developers, accountant; 3 people assigned; `ToPNG(path, [ :Font, :Title ])` | Title "TechCo organisation", dark tree, CEO on top, CTO and CFO below, 2 Developer boxes under CTO, Accountant under CFO, right-angle connector lines, nothing clipped. It shows POSITION TITLES only: Alice, Bob and Carol (assigned) and the 3 vacancies are not visible | RIGHT | stzlib-docs visual pass (a model reading the PNG) | 2026-10-05 |
| `org_vacant_native.png` | same chart after `ApplyFocusTo(VacantPositions())`, native tier `ToPNGXT` | The 3 vacant positions (CFO, 2nd Developer, Accountant) are magenta with white text, CEO, CTO and the first Developer are white. Curved edges with arrowheads. Matches the vacancy list `[ "@cfo", "@dev2", "@acct" ]` | RIGHT | stzlib-docs visual pass (a model reading the PNG) | 2026-10-05 |
| `org_vacant_dot.png` | same chart, `Dot()` through graphviz | Same three nodes magenta, rest white with grey outline, straight edges | RIGHT | stzlib-docs visual pass (a model reading the PNG) | 2026-10-05 |

## stzGraphPlanner

The class has no drawing method: it prints plans as text. No plan can be drawn on its graph through the class.

| picture | the call | what I SAW | verdict | perceived by | date |
|---|---|---|---|---|---|
| `planner_show.txt` | graph a-b-c-d with distance and cost properties, plans "short" and "cheap", `ShowPlan` for both, `CostBreakdownXT`, `CompareManyQ(...).ShowRankingTable()` | "short" is a>b>c>d with total 14 and Steps: 3; "cheap" is a>c>d with total 5 and Steps: 2. The ranking table (boxed) puts cheap first at cost 5 but its Steps column says 3 for cheap and 4 for short: a different count (nodes) from the Steps line above (moves) | UNCERTAIN | stzlib-docs visual pass (a model reading the captured text) | 2026-10-05 |

## stzMathFigure

| picture | the call | what I SAW | verdict | perceived by | date |
|---|---|---|---|---|---|
| `math_function.png` | `:Function`, f = x^3 - 3*x on [-2.2, 2.2], zeros and extrema marked, tangent at 1.5 | Cubic through (-1.7321, 0), (0, 0), (1.7321, 0) with open circles, max (-1, 2) and min (1, -2) with filled dots, axes labelled x and y, title y = x^3 - 3x, tangent line dark. All five marked values are correct. Two notes crowd the right zero: "(1.5, -1.125)" (the tangent point) floats up-left near the zero label, 50 px from its own point, and "min (1, -2)" is touched by the tangent line's lower end | UNCERTAIN | stzlib-docs visual pass (a model reading the PNG) | 2026-10-05 |
| `math_numberline.png` | `:NumberLine` on [-3, 9], points 4, -2, 6.5, (0.5 "half"), jump 1 to 5 | Axis -3..9 with arrowheads, jump arc "+ 5" from 1 landing on 6 with an arrowhead, points drawn. "6.5" and "half = 0.5" are labelled; 4 and -2 are dots with no label; "half = 0.5" touches the foot of the jump arc | UNCERTAIN | stzlib-docs visual pass (a model reading the PNG) | 2026-10-05 |
| `math_fraction.png` | `:Fraction`, compare 3/4, 2/3, 2/4, 1/2 | Four bars on one scale: 3 of 4 shaded (ends at 75%), 2 of 3 (66.7%), 2 of 4 and 1 of 2 both end at exactly the same place. Relation symbols between rows read `>`, `>`, `=` which is correct | RIGHT | stzlib-docs visual pass (a model reading the PNG) | 2026-10-05 |
| `math_matrix_product.png` | `:Matrix`, product [[1,2],[3,4]] x [[5,6],[7,8]], show [1, 2] | A (2x2), B (2x2), A.B (2x2) with row 1 of A and column 2 of B shaded and cell (1,2) of the result shaded. Result 19 22 / 43 50 is correct, and 1*6+2*8 = 22 is the shaded cell | RIGHT | stzlib-docs visual pass (a model reading the PNG) | 2026-10-05 |
| `math_boxplot.png` | `:BoxPlot`, two groups of eight | morning: whiskers 12 to 18, box 13.75-16.5, median 15, outlier circle at 40. noon: whiskers 20 to 26, box 21.75-24.25, median 22.5. Values agree with the sentence the figure gives about itself | RIGHT | stzlib-docs visual pass (a model reading the PNG) | 2026-10-05 |
| `math_surface.png` | `:Surface`, z = x^2 - y^2, 16 samples | Wire-mesh saddle in a box: up along x, down along y, pinched at the saddle point. Axis names x, y, z and end values 1 and -1, z -0.9956 to 0.9956. Reads as a saddle | RIGHT | stzlib-docs visual pass (a model reading the PNG) | 2026-10-05 |
| `math_complexplane.png` | `:ComplexPlane`, roots of z^3 = 1, unit circle | Three roots on the unit circle: 1, -0.5 + 0.866i, -0.5 - 0.866i, labelled, axes Re and Im with 0.5i ticks. Correct | RIGHT | stzlib-docs visual pass (a model reading the PNG) | 2026-10-05 |
| `math_stemplot.png` (+ `math_stemplot_text.txt`) | `:StemPlot` of 17 values 112..197 | Nine rows 11 to 19 with leaves; 13 | 1 4 8, 14 | 2 5 7, 15 | 0 1 3 8; caption "leaf unit 1 -- 11 | 2 means 112". All 17 values recovered | RIGHT | stzlib-docs visual pass (a model reading the PNG) | 2026-10-05 |

## stzCanvas

| picture | the call | what I SAW | verdict | perceived by | date |
|---|---|---|---|---|---|
| `canvas_shapes.png` | rect, round rect, circle, ellipse, two gradient rects, line, polyline (flat list), polygon (flat list), two texts; `ToPNG` | Red rect with thick black outline, blue round rect, gold circle with brown ring, green ellipse, left-to-right white-to-black gradient, top-to-bottom red-to-blue gradient, purple line, orange zigzag, teal triangle with outline, "Hello stzCanvas 123" and a small 12 px text. Everything present and in place | RIGHT | stzlib-docs visual pass (a model reading the PNG) | 2026-10-05 |
| `canvas_shapes_nested_points_misuse.png` | same, but polyline and polygon given as nested pairs `[ [x,y], ... ]` | The zigzag and the triangle are ABSENT. No error was raised and no hint was given; the block says the list is flat | UNCERTAIN | stzlib-docs visual pass (a model reading the PNG) | 2026-10-05 |
| `canvas_hires.png` | `ToPNGHiRes` of rect, circle, two 1 px lines | Same size as the canvas (480x320), 1 px diagonals smooth, rect and circle clean | RIGHT | stzlib-docs visual pass (a model reading the PNG) | 2026-10-05 |

## stzFont

| picture | the call | what I SAW | verdict | perceived by | date |
|---|---|---|---|---|---|
| `font_sample.png` | five lines drawn on a stzCanvas each over a box of `WidthOf`: Latin, Arabic, Hebrew, Korean with Segoe alone, Korean with Malgun as fallback; a red caret at `CaretRectAt(..., 5)` | The width box ends exactly at the last ink of every line. Arabic is joined and right-to-left, Hebrew correct. Segoe alone gives FIVE HOLLOW BOXES for the Korean (coverage `[ 0, 5 ]`), with the fallback the Hangul is drawn (`[ 5, 0 ]`). The caret sits between "Hambu" and "rg" for byte index 5. The Latin line also shows the kerned "AVA" | RIGHT | stzlib-docs visual pass (a model reading the PNG) | 2026-10-05 |

## stzTimeLine

| picture | the call | what I SAW | verdict | perceived by | date |
|---|---|---|---|---|---|
| `timeline_text.txt` (bar) | year 2024, points launch (Feb 14) and review (Sep 2), spans ALPHA (Mar 1 to Apr 30) and BETA (Jun 1 to Aug 15), `ToString()` / `ShowShort()` | The axis line `|──●─●───●───●────●─●─────○─►` has 6 numbered marks. The label line above reads `ALPHALPHALPHA ╞===BETA=BETA`: the span label is REPEATED to fill and cut (ALPHALPHALPHA), ALPHA starts at column 7 (under the launch mark) when it should start at column 9 and ends at column 19 when it should end at 17, ALPHA has no `╞` start glyph while BETA has one, BETA ends one column late. Two blank lines above | WRONG | stzlib-docs visual pass (a model reading the captured text) | 2026-10-05 |
| `timeline_text.txt` (table) | same | Boxed table with 8 rows: timeline start, 6 numbered events, timeline end, with dates matching the calls | RIGHT | stzlib-docs visual pass (a model reading the captured text) | 2026-10-05 |

## stzCalendar

| picture | the call | what I SAW | verdict | perceived by | date |
|---|---|---|---|---|---|
| `calendar_text.txt` (grid) | October 2024, Mon to Fri work, holiday Wed Oct 9, `Show()` | Grid starts on Tuesday 1 (correct), weekend cells print `░░` in place of their dates, the holiday prints `[9]`, the last row stops at Thu 31. February 2024 (leap): starts Thursday, 29 last (correct). The legend says `[D] = Holiday` but the picture shows `[9]` | UNCERTAIN | stzlib-docs visual pass (a model reading the captured text) | 2026-10-05 |
| `calendar_text.txt` (summary) | same `Show()` | Summary says Working Days 23, Weekend Days 7, Holidays 1, Total Available Hours 161. October 2024 has 8 weekend days (5, 6, 12, 13, 19, 20, 26, 27), and the detail table below shows 22 working days at 7 h = 154 h plus the holiday | WRONG | stzlib-docs visual pass (a model reading the captured text) | 2026-10-05 |
| `calendar_text.txt` (heat map) | `ShowHeatMap()` | Five "weeks" of 5/5, 4/5, 5/5, 5/5, 3/5. The weeks are blocks of 7 days counted from the 1st, not the Monday to Sunday weeks of the grid above (grid week 1 is Oct 1-6 and has 4 working days, the heat map calls it 5/5) | UNCERTAIN | stzlib-docs visual pass (a model reading the captured text) | 2026-10-05 |
| `calendar_text.txt` (detail table) | `ShowTable()` | 31 rows, weekend rows say WEEKEND with 0h, Oct 9 says HOLIDAY with 0h, other days 09:00-17:00 with the 12:00-13:00 break and 7h. Correct row by row | RIGHT | stzlib-docs visual pass (a model reading the captured text) | 2026-10-05 |

## stzGrid

| picture | the call | what I SAW | verdict | perceived by | date |
|---|---|---|---|---|---|
| `grid_text.txt` (Show) | 10x6 grid, wall in column 3 (gap at row 5), wall in column 7 (gap at row 1), `Show()` | Boxed grid with column numbers 1 2 3 4 5 6 7 8 9 0, `x` at (1,1), `■` obstacles where they were added, `>` and `v` direction marks on the frame | RIGHT | stzlib-docs visual pass (a model reading the captured text) | 2026-10-05 |
| `grid_text.txt` (ShortestPath) | `ShowPath(ShortestPath([1,1],[10,6]), "+")` | `+` path down column 1, along row 5 through the gap (3,5), up column 6, through the gap (7,1), down column 8 and along row 6 to (10,6). It is a valid route and its length (22 moves) is the minimum (6 + 8 + 8). The raw answer lists (10,6) first, as the block warns | RIGHT | stzlib-docs visual pass (a model reading the captured text) | 2026-10-05 |
| `grid_text.txt` (ShowNodes, ShowRegions) | `ShowNodes([[2,2],[9,5]], "%")`, `ShowRegions()` with both walls complete except (3,5) | `%` at (2,2) and (9,5). Two regions: 1 on the left of the column-7 wall, 2 on the right; the gap (3,5) keeps the left part joined | RIGHT | stzlib-docs visual pass (a model reading the captured text) | 2026-10-05 |

## stzTable

| picture | the call | what I SAW | verdict | perceived by | date |
|---|---|---|---|---|---|
| `table_show.txt` | 4 columns, 5 rows including `Côte d'Ivoire`, `日本`, `مصر`, a negative and an empty cell, `Show()` | Boxed grid, header centred, text left, numbers right, empty cell blank, accents aligned. The CJK row is padded as if each ideograph were one column wide, so in a terminal that draws them two wide the right border of that row shifts by two. POPULATION shows 340.10, 1430.10, 28.20 but 112 (a mix of two decimals and none in one column) | UNCERTAIN | stzlib-docs visual pass (a model reading the captured text) | 2026-10-05 |

## stzMatrix

| picture | the call | what I SAW | verdict | perceived by | date |
|---|---|---|---|---|---|
| `matrix_show.txt` | 3x4 matrix with a negative, 4.25, 1000 and 0.001, `Show()`; and an empty matrix | Bracketed grid, numbers right-aligned. The cell holding 0.001 prints as `0`, identical to the true zero beside it (with `decimals(6)` it prints 0.001). The empty matrix prints a closed empty frame | WRONG | stzlib-docs visual pass (a model reading the captured text) | 2026-10-05 |

## stzGraphex

| picture | the call | what I SAW | verdict | perceived by | date |
|---|---|---|---|---|---|
| `graphex_show.txt` | pattern `{@Node(start) -> @Edge(flows) -> @Node(done)}` and `{@Node(a) -> @!Edge(x) -> @Node(b)}`, `ShowPatternGraph()` | Three boxes joined by "sequences" arrows. In BOTH patterns the middle box is printed `!edge(...)!` with exclamation marks, including the pattern with no negation. The negated and the plain token cannot be told apart | WRONG | stzlib-docs visual pass (a model reading the captured text) | 2026-10-05 |

---

Not rendered, and why:
- stzGraphPlanner: no drawing method exists, so no plan could be drawn on its graph (text only above).
- stzDiagram `View()` / `Display()` and stzOrgChart `ViewVacant()` and the other `View*` calls: they start an external viewer; rendered through
  `ToPNGXT` and through `Dot()` plus graphviz instead, as asked.
- stzDiagram `ToPages`, the headless editor (`PickAt`, `OnPress`, `Edit`): not part of this pass.
- stzCalendar year and quarter views: the block says they cannot be drawn.
- SVG output of every class: no rasteriser here (see top).
