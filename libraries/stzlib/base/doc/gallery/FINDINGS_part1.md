# Visual pass, part 1 -- what the pictures show that the text did not

Perceived by the stzlib-docs visual pass: **a model reading the PNGs and the captured text, not a human** (2026-10-05).
Pictures: `doc/gallery/<Class>/`, one runnable `.ring` beside each. Judgements: `INDEX_part1.md` (41: RIGHT 20, WRONG 9, UNCERTAIN 12).
H = misleads a reader, M = omits something the block promised, L = cosmetic.
The methods marked **warned** now carry the finding as a `warning` in their doc block (and in the saved wave line).

| sev | class.method | what the picture shows | status |
|---|---|---|---|
| H | stzDiagram.ToPNG / ToSVG | with no options the shapes are right and there is NO text: the font option defaults to empty (`ToPNGXT` with a `:Font` draws labels). Fix: default to the house font that stzMathFigure already finds | warned |
| H | stzDiagram.SetTheme / SetTitle | the native canvas tier ignores `SetTheme("dark")` (white background) and does not draw the title; the Dot tier does both | warned |
| H | stzDiagram.RegisterVisualRule | rules reach the Dot output only; the native tier draws all nodes in one colour (apply them in ToCanvasXT) | warned |
| M | stzDiagram colours | "info" and "primary" are the same blue; the tiers use different palettes; the arrow into the end node stops about 35 px short; a decision label sits under its diamond | register |
| M | stzDiagram.Mermaid | left-to-right still gives `graph TD`, no colours, a decision shape is a hexagon | warned |
| L | stzDiagram.propertiesLegend | the block says it raises; it prints an empty "properties LEGEND" header (the claim about the 182x352 canvas is true) | check the block |
| H | stzGraph.AsciiArtHorizontal | on a fork/join graph it follows one path and drops nodes and edges with no hint | warned |
| M | stzGraph.AsciiArt / Show (and stzKnowledgeGraph) | a branching graph prints as separate chains split by `////` with shared nodes repeated: every edge is present, fork and join cannot be seen | warned |
| M | stzGraph.GraphCanvas | no arrowheads (a directed graph reads as undirected); `:SizeBy = :Degree` shrinks degree-1 nodes to about 2 px; an edge can run through a label | warned |
| H | stzKnowledgeGraph via GraphCanvas | no predicate drawn, no arrowheads, lowercase ids as labels; the class block says each fact is an edge labelled with its predicate; `Dot()` + graphviz is correct | warned on Explain; **class block still to correct** |
| L | stzOrgChart.ToPNG | position titles only: no people, no vacancy; dark theme while the diagram tier is white; the vacant focus view is right in both tiers | register |
| M | stzGraphPlanner.Show | "Steps: 2" for a>c>d while the ranking table says 3 (the table counts route nodes) | warned |
| L | stzMathFigure :Function | the note "(1.5,-1.125)" floats about 50 px from its own point, "min (1,-2)" is touched by the tangent, yet `Why()` says every constraint is satisfied; :NumberLine does not label the points 4 and -2. Fraction, matrix product, boxplot, surface, complex plane, stem plot were right against their data | register |
| M | stzCanvas.AddPolyline / AddPolygon | a nested list `[ [x,y], ... ]` draws nothing and raises nothing (the flat list the block asks for is right) | warned |
| H | stzTimeLine.ToString / ShowShort | the span bars are wrong: label repeated and cut, a span starts and ends a few columns off, only some spans get the start mark; the date table is correct. The block's known-defects list omitted it | warned |
| H | stzCalendar.Show | the summary disagrees with ShowTable (Oct 2024, Wednesday holiday: working 23 / weekend 7 against 22 and 8); the legend says `[D]` for a holiday but the grid prints the date | warned |
| L | stzCalendar.ShowHeatMap | weeks are 7-day blocks from the 1st, not the grid's Monday-Sunday weeks | warned |
| L | stzTable.Show | a wide-character cell (日本) is padded by character count and shifts the border; one numeric column mixes 340.10 and 112 | register |
| H | stzMatrix.Show | a cell holding 0.001 prints as 0 (Ring's global `decimals()` is 2): the picture lies, the data is intact | warned |
| H | stzGraphex.ShowPatternGraph | the middle token of ANY pattern is printed between `!` marks, negated or not | warned |
| none | stzFont, stzGrid | right: ink matches the width box, Arabic joined and right-to-left, Korean needs the fallback font; the shortest path is minimal and `ShowRegions` is right | -- |

Not looked at: SVG outputs (no rasteriser here: kept beside the PNGs, **unperceived**), View/Display/Step windows (rendered
through `ToPNGXT` and `Dot()` + graphviz instead), ToPages and the live editor, calendar year and quarter views (the block says
they cannot be drawn). A human verdict on a sample is still owed.
