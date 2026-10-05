# w3 diagram wave: defects found (method: symptom: cause), each verified with a second call on different data

## stzFont (graphics/stzFont.ring)
- DrawsEveryGlyphOf: answers TRUE for a freed font (and for any text): CoverageOf answers [0, 0] after Free, so "no notdef" reads as full coverage. Code defect, not fixed.
- GlyphsOf: the source comment says eight numbers per glyph; the engine returns nine (the ninth is the id of the font that supplied the glyph, so a fallback glyph shows its fallback's id). Comment defect.
- FallbackCount: -1 (not 0) for a freed font, while HasFallbacks answers 0.

## stzCanvas (graphics/stzCanvas.ring)
- Stats: comment lists five counters, the engine returns ten. Comment defect.
- Resize: the comment above it belongs to Clear (the two comments run together). Comment defect.
- SetRegion: ToSVG ignores the region (draws the whole canvas); only ToPNG / ToPixels answer the region. Behaviour worth knowing, documented in the note.
- ToPNG, ToPNGHiRes, ToPixels, ToPixelsHiRes: answer "" when no device exists; not exercised here (this machine has a GPU). Show: not exercised (window / viewer).

## stzTimeLine (datetime/stzTimeLine.ring)
- HasMoment (and HasInstant, ContainsMoment, ContainsInstant): R4 Stack Overflow: HasMoment calls itself (HasPoint is the working method). Verified with HasMoment, HasInstant, ContainsMoment.
- FindSpan, HasSpan, RemoveSpan, RenameSpanLabel: never find a span whose label has a lowercase letter: AddSpan stores the label as given, these four compare the query turned to capitals. Verified with "Alpha" and "alpha2". Span, SpanStart, SpanEnd, SpanDuration compare exactly with no folding, so Span("ALPHA") fails on "Alpha" and Span("beta") fails on "BETA".
- WhatsAt (time of day, e.g. "12:00:00"): matches nearly every span: the test is `time >= span start time OR time <= span end time`, which is only meant for spans that cross midnight. Verified with a 00:00-to-00:00 span set and with 22:00-06:00 and 09:00-17:00 spans (07:00 and 23:30 both matched the 09:00-17:00 span).
- Gaps, UncoveredPeriods: wrong when one span contains later ones: only consecutive spans in start order are compared, so the stretch between two short spans inside a long span is reported as a gap. Verified with A(01-01..12-01)+B+C and BIG+S1+S2.
- UncoveredPeriods, ToStringUncovered: a timeline with no span answers [ ] / "Timeline is fully covered by spans" instead of reporting all of it uncovered.
- Distance (also DurationXT, Interval...): only point labels work; a span label raises; two date-and-time strings answer 0 and a label plus a date answers a meaningless number, because Point() turns a date into a WhatsAt lookup.
- init, SetStart, SetEnd: an end before the start is accepted (negative Duration); SetStart / SetEnd do not check the points and spans already added; SetEnd("2024-01-02") gives midnight where the constructor gives 23:59:59 for a date-only end; SetEnd("2024-01-02 12:00") keeps the text as given.
- Copy: leaves out blocked points and blocked spans. Clear: keeps them.
- RemoveMInstant: typo for RemoveInstant (the Q form is spelled RemoveInstantQ).
- Point(date or time): answers a list of [label, kind] (a WhatsAt result), not a date and time.

## stzDiagram (graph/stzDiagram.ring) and its helper classes
- PenWidth: R24 uninitialized variable @nPenWidth, which nothing sets (also after SetPenWidth). Verified before and after a set.
- NodesWith: R20 (extra parameters): it builds stzGraphQuery with the wrong number of arguments. Verified with "=" and ">" comparisons.
- propertiesLegend: R13 "Object is required" as soon as a visual rule is registered: reads .@cConditionType on rules that RegisterVisualRule stores as hash lists. Verified with a range rule and an equality rule. With no rule it answers [ heading, "" ].
- Explain: R13 as soon as a visual rule is registered (reads .@cRuleId of a hash list); verified with two rule sets, before and after ApplyVisualRules.
- ComputeMetrics: R1 divide by zero for an empty diagram, for nodes without edges; the counts are reachable nodes minus one and nodes reaching a single node are left out. Verified on three shapes.
- SaveToStzDiagInFolder: R14, calls WriteToDiagFileXT (exists nowhere) with the global $pcFolder; the SaveToStzDiagFileInFolder / SaveToStzDiagFileXT spellings call WriteToDiagFile(pcFolder), also missing. Verified once, the rest by reading.
- ToSVG, ToPNG (and ToSVGXT, ToPNGXT, Rendition vector, RenditionAs image): free their canvas but leave it recorded as the last picture, so PickAt answers [ ] and OnPress does nothing until ToCanvas is called again. Verified with ToSVG and with ToPNG.
- SlotMap stays [ ] after a default render, so SlotAtPixel / PixelAtSlot answer 0 and OnRelease of a drag pins the node at slot 0. Verified on two renders (plain and after a pin); other layouts not tried.
- SetPenWidth sets only the node width; SetNodePenWidth sets node AND edge widths (names the wrong way round); NodePenWidth answers [ node, node ] (the node width twice) when the widths differ, not [ node, edge ].
- EdgeLineStyle / EdgeLineType getters answer the edge routing, not the line style their setters take.
- OutputFormat: the default comes from $cDefaultDiagramOutputFormat, defined nowhere, so a new diagram answers the text NULL.
- ImportDiag: into a diagram that already holds the text's first node it re-adds the remaining nodes (duplicates) and raises "There is already an edge" on the first existing edge. ImportAsSubdiagram drops edge labels.
- Edit(:Link, ...): a link between already-linked nodes, or naming a missing node, raises instead of answering FALSE.
- LoadStyle of a missing file: R35; stzStylParser.Parse: only single-digit values become numbers ("size: 14" stays text).
- stzDiagramToStzDiag.DataToString: a value that is a list raises "Bad parameter type".
- AddTemplate / ApplyTemplates: any object is accepted; ApplyTemplates raises R14 for one without Apply.
- stzColorResolver.ResolveWithPalette: "green+" (shade mark on a name that is neither semantic nor node-type) answers "".
- Not exercised: Display, View (graphviz + viewer), Step, RunIn (window), RenditionAs("image") (writes rendition_notation.png into the current folder), stzDiagramToMermaid on a stzOrgChart (my probe could not build one).
