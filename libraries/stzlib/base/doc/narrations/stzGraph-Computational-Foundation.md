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

### Properties: Metadata Without Semantics

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

## Problem Classes stzGraph Solves

**Workflows & Processes**

* Detect impossible approval chains, dependency loops
* Find bottlenecks (single points of failure)
* Validate process completeness before execution
* Trace impact of changes

**Organization & Hierarchies**

* Map reporting structures, find span-of-control imbalances
* Identify critical nodes
* Analyze decision propagation paths
* Plan restructuring with visibility into impact

**Data Architectures**

* Trace data flows from source to consumption
* Detect circular data dependencies
* Find missing transformations
* Plan migration strategies

**Service Dependencies**

* Map microservice call graphs
* Identify critical services where failure cascades
* Plan resilience strategies
* Validate system designs

**Natural Language Modeling** (Semantic Foundation)

* Model entity hierarchies and type inheritance
* Express relationships between concepts with integrity
* Detect semantic contradictions (circular type definitions: "Person is\_a Employee" and "Employee is\_a Person")
* Build language understanding on sound relational foundations
* Enable semantic inference: "What entities are accessible from this concept?"
* Support multi-path semantic reasoning: "Can I reach meaning through alternative relations?"

Example—type hierarchy with semantic reachability:

```
Entity → Person → Employee → Manager

From Person, reachable: [Person, Employee, Manager]
Person is bottleneck: changes cascade to all specializations
Density: linear chain (loose coupling, safe to modify)
```

Example—semantic contradiction detection:

```
AddEdge(:@person, :@employee, "is_a")
AddEdge(:@employee, :@person, "is_a")  # Circular

? CyclicDependencies()  #--> TRUE
# Type system is logically incoherent
```

***

## How Softanza Enables Natural Language Modeling

**Traditional NLP**: Embed semantics directly in code.

* Type systems hardcoded, rigid
* Relations mixed with validation logic
* Difficult to reason about semantic structure independently
* Can't validate language model coherence before interpretation

**Softanza approach**: Separate semantic structure from interpretation.

```
stzGraph layer (structure):
  ├─ Entities as nodes (Person, Employee, Order, Payment)
  ├─ Relations as edges (is_a, has_a, belongs_to)
  ├─ Properties as metadata (cardinality, constraints)
  ├─ Validation: cycles, reachability, bottlenecks
  └─ Introspection: Explain() reveals logical soundness

Semantic layer (stzEntity, stzRelation):
  ├─ Type hierarchies with inheritance rules
  ├─ Cardinality constraints (1-to-1, 1-to-many, many-to-many)
  ├─ Required vs optional relationships
  ├─ Validation rules (age > 0, status in {active, inactive})
  └─ Semantic meaning (what this relation entails)

Natural language layer (application):
  ├─ Parse text to semantic graph
  ├─ Validate against type system
  ├─ Infer meaning through reachability
  ├─ Generate structured output
  └─ Explain reasoning (trace inference paths)
```

**Validation before interpretation**: Check that type system is acyclic, no contradictions, no isolated concepts before processing language.

```ring
# Validate semantic model
if oTypeSystem.CyclicDependencies()
    throw("Type system has logical contradictions")
end

# Check coherence
aAnalysis = oTypeSystem.Explain()
if aAnalysis["bottlenecks"][1].contains("Warning")
    log("Risk: Core entity is single point of failure")
end

# Proceed with language understanding
sSemanticModel.Interpret(sInput)
```

**Multi-path semantic reasoning**: Find all valid interpretations through graph pathfinding.

```ring
# Can "Document" reach "Archive" through relations?
aAllMeanings = oModel.FindAllPaths(:@document, :@archive)
# Result: multiple semantic interpretations
# Choose interpretation based on context
```

**Reachability for inference**: What knowledge is semantically accessible?

```ring
# From concept "Human", what's reachable?
aReachable = oModel.ReachableFrom(:@human)
# Result: [Human, Mortal, Living, Physical]
# Used for automatic constraint inheritance in reasoning
```

***

## Practical Workflow: NLP Example

**Step 1: Model language structure** (stzGraph)

```ring
oLanguage = new stzGraph("EnglishTypeSystem")
oLanguage.AddNode(:@entity, "Entity")
oLanguage.AddNode(:@person, "Person")
oLanguage.AddNode(:@employee, "Employee")
oLanguage.AddNode(:@manager, "Manager")

oLanguage.AddEdge(:@entity, :@person, "is_a")
oLanguage.AddEdge(:@person, :@employee, "is_a")
oLanguage.AddEdge(:@employee, :@manager, "is_a")
```

**Step 2: Validate semantic coherence** (stzGraph analysis)

```ring
? oLanguage.CyclicDependencies()      # Logically consistent?
? oLanguage.BottleneckNodes()         # Which concepts are critical?
aAnalysis = oLanguage.Explain()       # Reveal structure
```

**Step 3: Visualize** (stzGraph presentation)

```ring
oLanguage.ShowWithLegend()
# Programmer sees exact type hierarchy before interpretation
```

**Step 4: Add semantic constraints** (stzEntity layer)

```ring
oEntity = new stzEntity("Person")
oEntity.AddProperty("age", :Integer, ["min" = 0, "max" = 150])
oEntity.AddRelation(:@person, :@employee, "is_a", ["cardinality" = "1-to-many"])
```

**Step 5: Validate language interpretation** (application layer)

```ring
# Parse: "Manager John works in Engineering"
# Validate: John is a Manager (subtype of Employee, subtype of Person)
# Infer: John inherits all Person properties and constraints
# Execute: Store with proper type hierarchy
```

**Step 6: Semantic reasoning** (complex queries)

```ring
# Query: "What are all beings that inherit from Entity?"
aAllBeings = oLanguage.ReachableFrom(:@entity)
# Result: [Person, Employee, Manager]
# Used for automatic constraint propagation
```

***

## Algorithmic Guarantees

stzGraph algorithms are:

* **Correct**: Valid results for any input
* **Terminating**: Always finish (visited tracking prevents infinite loops)
* **Efficient**: O(V + E) complexity
* **Deterministic**: Same input always produces same output

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
