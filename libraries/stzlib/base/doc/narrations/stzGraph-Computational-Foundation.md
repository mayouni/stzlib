# stzGraph: Computational Foundation

## Introduction: What This Article Is About

stzGraph is the foundational layer of Softanza's graph ecosystem. It handles one focused responsibility: representing and reasoning about the structure of relationships.

This article explains the design philosophy behind stzGraph—why it's intentionally narrow in scope, how it separates concerns, and what role it plays in the larger system. If you want practical examples and tutorials, see "Getting Started with stzGraph" instead.

The core insight we'll explore: separating *how things connect* from *what those connections mean*.

## The Problem: Mixed Concerns

Most systems that work with relationships conflate two distinct concerns:

1. **The structure**: How entities connect, which paths exist, what reaches what
2. **The semantics**: What those entities represent, what the connections mean, what rules apply

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

The Softanza answer: separate these concerns cleanly.

## The stzGraph Vision

stzGraph handles **only the structure**. It answers structural questions:

- Can I reach point B from point A?
- What are all possible routes from A to B?
- Does a circular dependency exist?
- Which nodes are bottlenecks?
- How connected is this structure?

stzGraph deliberately doesn't care what the nodes represent or what semantics matter. This isn't a limitation—it's the point.

```
Clean Architecture:
┌────────────────────────────────────┐
│  stzGraph (Pure Structure)         │
│  ├─ Nodes and edges               │
│  ├─ Pathfinding algorithms        │
│  ├─ Cycle detection               │
│  ├─ Reachability analysis         │
│  ├─ Bottleneck identification     │
│  └─ Metrics                       │
│                                   │
│  (No domain logic, no rendering,  │
│   no semantics—just algorithms)   │
└────────────────────────────────────┘
         ↑ (Inherited by)
┌────────────────────────────────────┐
│  Workflow Domain (stzDiagram)      │
│  ├─ Workflow semantics            │
│  ├─ Validation rules              │
│  ├─ Visual rendering              │
│  ├─ Compliance checking           │
│  └─ Annotations                   │
└────────────────────────────────────┘
         ↑ (Inherited by)
┌────────────────────────────────────┐
│  Semantic Framework                │
│  ├─ stzEntity (type hierarchies)   │
│  ├─ stzRelation (entity relations) │
│  ├─ stzListOfEntities (collections)│
│  └─ Natural language modeling      │
└────────────────────────────────────┘
         ↑ (Inherited by)
┌────────────────────────────────────┐
│  Custom Domains                    │
│  ├─ Organization hierarchies      │
│  ├─ Data architectures            │
│  ├─ Service dependencies          │
│  └─ ...anything with relationships│
└────────────────────────────────────┘
```

This layering creates advantages:

**Testability**: Test stzGraph's algorithms independently from domain logic
**Reusability**: One graph implementation serves all domains
**Clarity**: Easy to distinguish what's structure vs. what's semantics
**Extensibility**: New domains inherit all capabilities automatically
**Natural Modeling**: Semantic frameworks can express language naturally while leveraging sound graph algorithms

## What stzGraph Actually Provides

### 1. Explicit Node and Edge Management

Nodes are entities. Edges are directed relationships.

```
Nodes: "request", "approval", "completion"
Edges: request → approval → completion
```

That's it. No hidden state, no implicit behavior.

### 2. Path Analysis Algorithms

Answer: What routes exist from one node to another?

This reveals alternatives, single points of failure, and mandatory sequences. In semantic frameworks, this enables discovering all possible inference paths between entities.

### 3. Reachability Analysis

Answer: Starting from here, what else can I reach?

This reveals scope, impact, and the extent of influence. In language models, this shows what entities are semantically accessible from a given type.

### 4. Cycle Detection

Answer: Are there circular dependencies?

Cycles are structural red flags. A process can't work if it loops back on itself. In type systems, cycles indicate contradictory definitions.

### 5. Bottleneck Identification

Answer: Which nodes are critical hubs?

These are risk points—if they fail, impact is widespread. In semantic models, bottlenecks are core entities that many others depend on.

### 6. Metrics

Answer: How complex is this structure?

Density reveals coupling. Path length reveals process complexity. In language models, these reveal how tightly types are coupled and how deep inheritance hierarchies are.

## Properties: Metadata for Later Analysis

stzGraph can store metadata in node properties. These properties don't affect graph algorithms—they're inert data.

But they're critical for domain specializations:

```
stzGraph stores:
  Node properties: [criticality = "high", owner = "eng-team", sla = "99.9%"]

stzDiagram uses them:
  - Criticality triggers compliance validation
  - Owner enables accountability checks
  - SLA enables performance analysis

Semantic Framework uses them:
  - Entity constraints: min_cardinality, max_cardinality
  - Type metadata: is_abstract, is_mutable, documentation
  - Validation rules: required_fields, allowed_values

Custom domains use them:
  - Financial domain: cost, risk, regulatory-status
  - Healthcare domain: patient-safety-impact, data-sensitivity
  - Anything: domain-specific metadata
```

Properties are the bridge between pure structure and semantic richness. stzGraph stores them neutrally. Domain specializations interpret them meaningfully.

## Design Principles

### Computational Purity

stzGraph contains algorithms, not semantics. This means:

- Same code works for org hierarchies, workflows, data flows, service architectures, type systems, entity relations
- You reason about structure without domain assumptions
- Algorithms are provably correct (no domain logic to get wrong)
- Semantic frameworks can safely inherit and extend

### Explicit Representation

Everything is observable:

```
All nodes: @aNodes
All edges: @aEdges
```

No hidden state, no implicit relationships. You can inspect the exact structure at any time.

### Algorithmic Safety

All traversal algorithms use visited tracking to prevent infinite loops—even in cyclic graphs. This is non-negotiable for production systems, especially semantic frameworks that must handle cycles gracefully without entering infinite validation loops.

### Separation Enables Composition

Because stzGraph is pure structure, you can:

- Combine graphs (merge nodes and edges)
- Transform graphs (filter, collapse, expand)
- Analyze graphs (detect patterns)
- Layer semantics on top (add domain meaning)

Each of these is independent because there's no entangled domain logic. Semantic frameworks can extend these operations safely.

## Algorithmic Guarantees

stzGraph algorithms are:

- **Correct**: They produce valid results for any input
- **Terminating**: They always finish (cycle detection prevents infinite loops)
- **Efficient**: O(V + E) where V = nodes, E = edges
- **Deterministic**: Same input always produces same output

These properties matter because downstream specializations (stzDiagram, semantic frameworks, compliance checkers, risk analyzers) depend on reliable computation.

## The Role in the Ecosystem

stzGraph is the **computational foundation** that enables:

1. **Workflow analysis** (stzDiagram): Detect invalid processes, validate completeness, check compliance
2. **Natural language modeling** (Semantic Framework):
   - **stzEntity**: Model type hierarchies, inheritance chains, entity specialization
   - **stzRelation**: Define valid relationships between entities with semantic constraints
   - **stzListOfEntities**: Collections with cardinality and constraint validation
   - Express language structure naturally while leveraging sound graph algorithms
3. **Organizational analysis**: Reveal structure, identify bottlenecks, understand information flow
4. **Data architecture**: Trace flows, detect cycles, identify dependencies
5. **System design**: Analyze services, find critical paths, guide resilience
6. **Custom domains**: Any problem with relational structure

All these build on stzGraph's foundation. They inherit path analysis, cycle detection, reachability, and metrics. They add domain-specific validation, rendering, rules, and semantics.

## Why This Design

Most graph systems mix concerns. You have to understand and modify domain logic to debug structural issues. You can't test algorithms independently. You can't reuse code across domains.

stzGraph breaks this pattern. It's intentionally narrow:

```
stzGraph scope:
  ✓ Node and edge management
  ✓ Path analysis
  ✓ Reachability
  ✓ Cycle detection
  ✓ Bottleneck analysis
  ✓ Metrics
  
  ✗ Rendering
  ✗ Validation rules
  ✗ Domain semantics
  ✗ Compliance checking
  ✗ Type constraints
  ✗ Cardinality rules
```

This narrowness enables:

- **Testability**: Verify algorithms independently from domain logic
- **Reusability**: One implementation serves workflows, semantic frameworks, and custom domains
- **Maintainability**: Small, stable, focused codebase
- **Extensibility**: New domains inherit capabilities automatically
- **Clarity**: Structure separate from semantics is explicit
- **Semantic Soundness**: Natural language models can build on mathematically proven foundations

## Conclusion

stzGraph provides rock-solid computational thinking at the foundation. It handles one thing: the mathematics of relationships.

Domain specializations add meaning to that structure:
- **stzDiagram** brings workflow semantics
- **Semantic Framework** (stzEntity, stzRelation, stzListOfEntities) enables natural language modeling
- Custom applications add their own meaning

They all build on a foundation that doesn't change—a foundation of pure, correct, testable algorithms.

This is Softanza philosophy: make the thinking clear first, then build tools on top of clarity. stzGraph is what clear computational thinking looks like for graphs. The semantic framework is what natural language modeling looks like when built on that clarity.