# stzGraph: Computational Foundation and Design

## Introduction: What This Article Is About

stzGraph is the foundational layer of Softanza's graph ecosystem. It handles one focused responsibility: representing and reasoning about the structure of relationships.

This article explains the design philosophy—why it's intentionally narrow in scope, how it separates concerns, and what role it plays in the larger system. It also explores two major features made by deliberate design: **Visualization** and **Explanation**.

The core insight: separating _how things connect_ from _what those connections mean_.

***

## The Problem: Mixed Concerns

Most systems conflate two distinct concerns:

1. **Structure**: How entities connect, which paths exist, what reaches what
2. **Semantics**: What entities represent, what connections mean, what rules apply

This conflation creates problems:

```
Traditional Approach:
┌──────────────────────────────────┐
│  Workflow Engine                 │
│  ├─ Graph structure              │
│  ├─ Validation rules             │
│  ├─ Domain semantics             │
│  ├─ Visual rendering             │
│  └─ Compliance checking          │
│                                  │
│  (Everything mixed together)     │
└──────────────────────────────────┘
         ↓
Result: Hard to test, hard to extend, 
        hard to reason about independently
```

***

## The stzGraph Vision

stzGraph handles **only structure**. Structural questions:

* Can I reach point B from point A?
* What are all possible routes from A to B?
* Does a circular dependency exist?
* Which nodes are bottlenecks?
* How connected is this structure?

stzGraph deliberately doesn't care what nodes represent or what semantics matter. This isn't a limitation—it's the point.

```
Clean Architecture:
┌────────────────────────────────────┐
│  stzGraph (Pure Structure)         │
│  ├─ Nodes and edges               │
│  ├─ Pathfinding algorithms        │
│  ├─ Cycle detection               │
│  ├─ Reachability analysis         │
│  ├─ Bottleneck identification     │
│  ├─ Metrics                       │
│  ├─ Visualization (ASCII)         │
│  └─ Explanation (structured)      │
│                                   │
│  (No domain logic, no semantics—  │
│   pure algorithms + introspection)│
└────────────────────────────────────┘
         ↑ (Inherited by)
┌────────────────────────────────────┐
│  Domain Specializations            │
│  ├─ stzDiagram (workflows)         │
│  ├─ stzEntity (type hierarchies)   │
│  ├─ stzRelation (relations)        │
│  ├─ Custom domains                 │
│  └─ ... (any with relationships)   │
└────────────────────────────────────┘
```

***

## What stzGraph Provides

### Core: Structural Analysis

1. **Path Analysis**: What routes exist from A to B?
2. **Reachability**: From X, what else is reachable?
3. **Cycle Detection**: Are there circular dependencies?
4. **Bottleneck Identification**: Which nodes are critical hubs?
5. **Metrics**: Density (coupling), longest path (depth)
6. **Neighborhoods**: Direct incoming/outgoing connections

### Design Feature 1: Visualization

stzGraph includes **native ASCII visualization**. This is deliberate design, not an afterthought.

**Why built-in visualization matters:**

* Developers see structure immediately without external tools
* ASCII avoids tool dependencies; works in terminal, logs, docs, version control
* Visualization is computational feedback—quick validation during development
* Enables visual debugging and communication between programmers

**Visualization modes:**

* `Show()` / `ShowV()` — vertical layout (sequential flows)
* `ShowH()` / `ShowHorizontal()` — horizontal layout (parallel paths)
* `ShowWithLegend()` — annotate structural characteristics

**Legend markers** (added by design):

* `!label!` — bottleneck node (high-degree hub)
* `////` — path separator (multiple alternative routes)
* `<CYCLE: label>` — feedback loop indicator
* `[Node]` — node participating in cycle

Example: A multi-path workflow visualized with `ShowWithLegend()`:

```
       ╭─────────╮       
       │ !Start! │       
       ╰─────────╯       
            |            
        expedited        
            |            
            v            
     ╭─────────────╮     
     │ !Fast Path! │     
     ╰─────────────╯     
            |            
         finish          
            |            
            v            
     ╭────────────╮      
     │ !Complete! │      
     ╰────────────╯      

          ////

       ╭─────────╮  ↑
       │ !Start! │──╯
       ╰─────────╯       
            |            
         normal          
            |            
            v            
   ╭─────────────────╮   
   │ !Standard Path! │   
   ╰─────────────────╯   
            |            
         finish          
            |            
            v            
     ╭────────────╮      
     │ !Complete! │      
     ╰────────────╯
```

Marks show:

* `!Start!`, `!Fast Path!`, `!Standard Path!`, `!Complete!` are bottlenecks (high degree)
* `////` separates two distinct paths
* Multiple routes to completion visible at a glance

**Design principle**: Visualization surfaces structural insights without interpretation. A programmer sees the actual topology, not a filtered or prettified version.

***

### Design Feature 2: Explanation

stzGraph includes `.Explain()` — **structured introspection**. This is deliberate design.

**Why built-in explanation matters:**

* Graph characteristics become programmable facts, not just visual observations
* Enables automated reporting, validation, linting
* Structured output (not prose) allows downstream processing
* Bridges visual understanding with computational reasoning

**Explanation structure:**

```ring
Explain() returns an array with four sections:

[
    ["general", [
        "Graph name and counts"
    ]],
    ["bottlenecks", [
        "Identified bottleneck nodes",
        "Degree analysis",
        "Which nodes exceed average degree"
    ]],
    ["cycles", [
        "Cycle detection result",
        "If cycles exist: nature and risk"
    ]],
    ["metrics", [
        "Density percentage",
        "Longest path length"
    ]]
]
```

Example output for a cyclic workflow:

```ring
[
    ["general", ["Graph: CyclicWorkflow", "Nodes: 3 | Edges: 3"]],
    ["bottlenecks", ["Bottleneck nodes: @p1", "@p1: degree 3 (above average)"]],
    ["cycles", ["WARNING: Circular dependencies detected"]],
    ["metrics", ["Density: 50% (dense)", "Longest path: 2 hops"]]
]
```

**Use cases:**

```ring
# Validation in CI/CD
if Explain()["cycles"][1].contains("WARNING")
    throw("Pipeline has cycles—fix before deploying")
end

# Automated reporting
oReport.AddSection("Bottlenecks", oGraph.Explain()["bottlenecks"])

# Linting
if oGraph.Explain()["metrics"][1].toNumber() > 75
    log("Warning: Dense coupling detected")
end
```

**Design principle**: Explanation extracts structural facts into programmable form. Developers reason about graphs using data, not interpretation.

***

## Properties: Metadata Without Semantics

stzGraph stores node properties without interpreting them:

```ring
AddNodeXT(:@step, "Validate", :Process, [
    "priority" = "high",
    "owner" = "eng-team",
    "sla" = "99.9%"
])
```

Properties remain **inert to graph algorithms**. But domain specializations interpret them:

* **stzDiagram** uses priority for rendering, owner for accountability
* **Semantic Framework** uses constraints: `min_cardinality`, `max_cardinality`, `is_abstract`
* **Custom domains** add their own metadata: cost, risk, compliance status

Properties are the bridge between pure structure and semantic richness.

***

## Design Principles

### Computational Purity

stzGraph contains algorithms, not semantics:

* Same code works for workflows, type systems, org hierarchies, data flows, service architectures
* Algorithms are provably correct (no domain logic to get wrong)
* Specializations safely inherit and extend

### Explicit Representation

Everything is observable:

```ring
? oGraph.NodeCount()
? oGraph.EdgeCount()
? oGraph.NodeExists(:@id)
? oGraph.EdgeExists(:@from, :@to)
```

No hidden state, no implicit relationships.

### Algorithmic Safety

All traversal algorithms use visited tracking to prevent infinite loops—even in cyclic graphs. This is non-negotiable for production systems.

### Visibility: Native Visualization

ASCII visualization is deliberate design:

* **Immediate feedback** during development without external tools
* **Tool-independent** (works in terminal, logs, docs, version control)
* **Semantic-neutral** (shows actual structure, not interpretation)
* **Programmable markers** (legends encode structural facts)

Methods: `Show()` / `ShowV()` (vertical), `ShowH()` / `ShowHorizontal()` (horizontal), `ShowWithLegend()` (annotated)

Legend markers reveal structure:

* `!label!` — bottleneck node (high-degree hub)
* `////` — path separator (multiple routes)
* `<CYCLE: label>` — feedback loop
* `[Node]` — node in cycle

Example multi-path workflow with `ShowWithLegend()`:

```
       ╭─────────╮       
       │ !Start! │       
       ╰─────────╯       
            |            
        expedited        
            |            
            v            
     ╭─────────────╮     
     │ !Fast Path! │     
     ╰─────────────╯     
            |            
         finish          
            |            
            v            
     ╭────────────╮      
     │ !Complete! │      
     ╰────────────╯      

          ////

       ╭─────────╮  ↑
       │ !Start! │──╯
       ╰─────────╯       
            |            
         normal          
            |            
            v            
   ╭─────────────────╮   
   │ !Standard Path! │   
   ╰─────────────────╯   
            |            
         finish          
            |            
            v            
     ╭────────────╮      
     │ !Complete! │      
     ╰────────────╯
```

### Expressiveness: Structured Explanation

`.Explain()` makes graph characteristics programmable:

* **Structured introspection** returning organized analysis data
* **Programmatic validation** (test properties in CI/CD, not by inspection)
* **Automated linting** (check density, degree distribution, cycles)
* **Systematic understanding** without manual graph inspection

Returns array with sections:

* `general`: Graph name and counts
* `bottlenecks`: Hub nodes and degree analysis
* `cycles`: Cycle detection and risk
* `metrics`: Density percentage, longest path

Example for cyclic workflow:

```ring
[
    ["general", ["Graph: CyclicWorkflow", "Nodes: 3 | Edges: 3"]],
    ["bottlenecks", ["Bottleneck nodes: @p1", "@p1: degree 3 (above average)"]],
    ["cycles", ["WARNING: Circular dependencies detected"]],
    ["metrics", ["Density: 50% (dense)", "Longest path: 2 hops"]]
]
```

Use cases:

```ring
# Validation in CI/CD
if Explain()["cycles"][1].contains("WARNING")
    throw("Pipeline has cycles—fix before deploying")
end

# Automated reporting
oReport.AddSection("Bottlenecks", oGraph.Explain()["bottlenecks"])

# Linting
if oGraph.Explain()["metrics"][1].toNumber() > 75
    log("Warning: Dense coupling detected")
end
```

***

## Algorithmic Guarantees

stzGraph algorithms are:

* **Correct**: Valid results for any input
* **Terminating**: Always finish (visited tracking prevents infinite loops)
* **Efficient**: O(V + E) complexity
* **Deterministic**: Same input always produces same output

These properties matter because downstream specializations (stzDiagram, semantic frameworks, compliance checkers) depend on reliable computation.

***

## The Role in the Ecosystem

stzGraph is the **computational foundation** enabling:

1. **Workflow analysis** (stzDiagram): Detect invalid processes, validate completeness, check compliance

2. **Natural language modeling** (Semantic Framework):

   * Leverage sound graph algorithms for type hierarchies, inheritance, entity relations
   * Express language structure naturally while building on proven foundations

3. **Organizational analysis**: Reveal structure, identify bottlenecks, understand flow

4. **Data architecture**: Trace flows, detect cycles, identify dependencies

5. **System design**: Analyze services, find critical paths, guide resilience

6. **Custom domains**: Any problem with relational structure

All build on stzGraph's foundation. They inherit pathfinding, cycle detection, reachability, metrics, visualization, and explanation. They add domain-specific validation, rendering, rules, and semantics.

***

## Why This Design

Most graph systems mix concerns. Debugging structural issues requires understanding domain logic. Algorithms can't be tested independently. Code doesn't reuse across domains.

stzGraph breaks this pattern by being intentionally narrow:

```
stzGraph scope:
  ✓ Node and edge management
  ✓ Path analysis
  ✓ Reachability
  ✓ Cycle detection
  ✓ Bottleneck analysis
  ✓ Metrics
  ✓ ASCII Visualization
  ✓ Structured Explanation
  
  ✗ Rendering (sophisticated layouts)
  ✗ Validation rules
  ✗ Domain semantics
  ✗ Compliance checking
  ✗ Type constraints
```

This narrowness enables:

* **Testability**: Verify algorithms independently
* **Reusability**: One implementation serves all domains
* **Maintainability**: Small, focused codebase
* **Extensibility**: New domains inherit automatically
* **Transparency**: Structure vs. semantics is explicit
* **Developer Experience**: Visualization and explanation built-in, not bolted-on

***

## Visualization and Explanation as Core Features

### Why they're part of stzGraph (not delegated to specializations)

1. **Universal need**: Any graph-based problem needs to see and understand structure
2. **Foundation responsibility**: A foundation should aid comprehension, not hide complexity
3. **No semantic bias**: ASCII visualization and structured explanation don't impose domain assumptions
4. **Development velocity**: Built-in feedback accelerates iteration

### What they enable

**Visualization** enables:

* Quick validation during graph construction
* Immediate visibility into structural issues
* Natural debugging (see the actual topology)
* Communication between programmers

**Explanation** enables:

* Programmatic validation (test graph properties in CI/CD)
* Automated compliance checking
* Quantitative analysis (density, degree distribution, path lengths)
* Structured reporting without custom parsing

### What they avoid

Both features are **intentionally simple**:

* Visualization doesn't interpret structure (doesn't add domain layout logic)
* Explanation doesn't judge structure (doesn't enforce domain rules)
* Neither requires external dependencies

This keeps stzGraph lightweight while providing essential developer tools.

***

## Conclusion

stzGraph provides rock-solid computational thinking at the foundation. It handles one thing: the mathematics of relationships.

**Core responsibility**: Correct algorithms for path analysis, reachability, cycle detection, bottleneck identification, and metrics.

**Developer experience features** (visualization and explanation) are part of the design—not afterthoughts—because a foundation should aid understanding.

Domain specializations add meaning to that structure:

* stzDiagram brings workflow semantics
* Semantic Framework enables natural language modeling
* Custom applications add their own meaning

They all build on a foundation that doesn't change—a foundation of pure, correct, introspectable algorithms.

This is Softanza philosophy: make the thinking clear first (through visualization and explanation), then build tools on top of clarity.
