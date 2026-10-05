# defects found (method: symptom: cause) -- each verified with a second call on different data

stzGraph
- InsertNodesBefore, InsertNodesAfter: raise R20 for any list: call InsertNodeBefore/After with 3 args, they take 2
- ConnectEdgesXTT: raises R19 for a non-empty list: calls AddEdgeXTT with 2 args, it takes 4
- LoadFromGraphML, LoadGraphML, ImportFromGraphML, ImportGraphML (and LoadFrom of .graphml): raise "Incorrect Id", leave garbled nodes ("sion=") : parser cuts at fixed offsets, not at found positions (own export, 3 graphs, and test/_data/simple.graphml)
- LoadFromStzGraf, LoadStzGraf: a node property line holding "type:" overwrites the graph type ("task" after a round trip); edge properties not written by ExportToStzGraf
- SaveTo, LoadFrom: "./g.graf" or a path with an extra dot raises "Unsupported file format": extension = 2nd piece of split(path, ".")
- CyclicNodes: always [ ] (4-cycle, 2-cycle, self-loop): looks for the node in ReachableFrom, which never lists the start
- LongestPath: counts nodes reachable from the best start, not hops (answers 4 where the longest path is 2 hops)
- BottleneckNodes: R1 divide by zero on an empty graph (so Show, AsciiArt, AsciiArtHorizontal, Explain fail on an empty graph)
- Explain: R5 on a graph with nodes and no edge ($aoExplanation global); density printed as ratio plus % ("0.20%")
- PathWeight: raises when an edge on the path has no :weight (reads it with EdgeProperty)
- EdgeProperty: raises with the text "' + cProperty + '" unexpanded
- HasRule: FALSE for derivation and validation rules, and for a lowercase file-declared constraint (names compared lower vs upper)
- RemoveRule: a lowercase file-declared rule is not removed (name uppercased, stored name kept)
- ValidationSummary, Anomalies, Violations, Issues: only a PASSING run is recorded, so violations are always empty; "" before any pass
- RemoveAllEdgesBetween, RemoveEdgeByLabel, RemoveEdgesConnectedTo (+ aliases), SetNodes, SetEdges: engine copy not invalidated, Neighbors/ReachableFrom/metrics stale until the next change
- RemoveThisNode/RemoveNode/RemoveNodeAt, Incoming, SetNodeLabel/NodeLabel, SetNodeProperty (+aliases), RemoveNodeProperties, SetEdgeProperty(+aliases), SetEdgeProperties: id not lowercased ("A" is a no-op or raises "does not exist"); SetNodeProperty/SetEdgeProperty ignore unknown ids silently
- InsertNodeBefore/After: target id compared as written (uppercase target: in-edges not moved)
- AddNode: no check for an existing id, a duplicate is appended
- WithoutConstraints, BypassingConstraints: constraints stay OFF when the function raises
- SetEdgeWeight: engine only, lost at the next rebuild
- Path, FindNode, PathsTo, Paths, ExplainPath: paths over 10 edges are not found (PathExists and ShortestPath still find them)
- MSTEdges: pair order may be reversed against the edge direction (cosmetic)

stzGraphComparison
- WithCycles, WithoutCycles: always [ ]: rows hold "TRUE"/"FALSE" text, body compares to 1/0
- Recommend: acyclic bonus never awarded (same cause); a variation with a cycle won in the sample
- Content: body empty, returns nothing

stzKnowledgeGraph
- Explain: raises R14: calls ApplyInference, defined nowhere
- RemoveFact, RemoveTriple: predicate ignored, removes whatever fact links the pair
- QueryPath: only the first pattern is answered
- Query: a pattern with no variable compares the predicate case-sensitively against the lowercase stored label
- ValidateOntology: always 1

not exercised: Display, View, Veiw (start an external Graphviz viewer; the generic probe called Display and it returned silently)
