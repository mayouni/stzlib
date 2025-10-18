# stzGraph: Computational Foundation and Design

## Core Philosophy

stzGraph separates **structure** (how things connect) from **semantics** (what connections mean). This single decision enables reuse across workflows, org hierarchies, data flows, service maps, and language models.

Most graph systems mix concerns—debug structure, understand domain logic. stzGraph is intentionally narrow: pure algorithms + introspection. Extensions (stzDiagram, stzEntity, stzRelation) add meaning.

---

## What stzGraph Provides

### Structural Analysis
- **Path Analysis**: Routes from A to B
- **Reachability**: All nodes reachable from X
- **Cycle Detection**: Circular dependencies
- **Bottleneck Identification**: Critical hubs
- **Metrics**: Density (coupling), longest path (depth)
- **Neighborhoods**: Direct in/out connections

### Design Features: Visibility & Expressiveness

**Visibility (Native ASCII Visualization)**
- `Show()` / `ShowV()` — vertical layout
- `ShowH()` / `ShowHorizontal()` — horizontal layout
- `ShowWithLegend()` — annotated with structural markers
- Markers: `!label!` (bottleneck), `////` (path separator), `<CYCLE:>` (loop), `[Node]` (cycle member)
- Built-in, tool-independent, immediate feedback during development

**Expressiveness (Structured Explanation)**
- `.Explain()` returns programmatic analysis:
  - `general`: node/edge counts
  - `bottlenecks`: hub nodes and degree distribution
  - `cycles`: cycle detection + risk assessment
  - `metrics`: density, longest path
- Enables CI/CD validation, automated linting, structured reporting

Example:
```ring
if Explain()["cycles"][1].contains("WARNING")
    throw("Cycles detected—invalid structure")
end
```

### Properties: Metadata Bridge
Nodes store metadata without interpreting it:
```ring
AddNodeXT(:@step, "Validate", :Process, ["priority" = "high", "owner" = "team-a"])
```
stzGraph keeps properties inert; domain layers interpret them (stzDiagram uses priority/owner; stzEntity adds cardinality/constraints).

---

## Design Principles

**Computational Purity**: One implementation serves workflows, hierarchies, data flows, type systems, service maps.

**Explicit Representation**: All nodes/edges observable; no hidden state.

**Algorithmic Safety**: Visited tracking prevents infinite loops even in cyclic graphs.

**Visibility & Expressiveness**: Visualization and explanation are first-class features, not add-ons.

---

## Problem Classes Solved

| Domain | Key Questions |
|--------|---|
| **Workflows** | Invalid chains? Bottlenecks? Circular dependencies? |
| **Organizations** | Reporting imbalances? Critical nodes? Propagation paths? |
| **Data Architectures** | Flow paths? Circular data deps? Missing transformations? |
| **Service Dependencies** | Critical services? Cascade failure points? |
| **Natural Language Modeling** | Type contradictions? Semantic reachability? Multi-path inference? |

---

## Natural Language Modeling: A Semantic Foundation

stzGraph enables coherent language models through validation-first design:

```ring
# Step 1: Model type hierarchy
oTypes = new stzGraph("TypeSystem")
oTypes.AddEdge(:@entity, :@person, "is_a")
oTypes.AddEdge(:@person, :@employee, "is_a")
oTypes.AddEdge(:@employee, :@manager, "is_a")

# Step 2: Validate before interpretation
if oTypes.CyclicDependencies()
    throw("Type system logically incoherent")
end

# Step 3: Use reachability for inference
aReachable = oTypes.ReachableFrom(:@person)
# Result: [Person, Employee, Manager] — what Person inherits

# Step 4: Find semantic alternatives
aAllPaths = oTypes.FindAllPaths(:@person, :@manager)
# Result: multiple inference routes if they exist
```

**Benefit**: Language models built on sound relational foundations. Type contradictions caught at graph level before semantic interpretation.

Layering:
- **stzGraph** validates structure (acyclic? consistent? coherent?)
- **stzEntity** adds constraints (cardinality, required fields, type rules)
- **Application** interprets meaning ("Manager inherits all Person rules")

---

## Comparison to Other Systems

| Aspect | stzGraph | NetworkX (Python) | Neo4j |
|--------|----------|-------------------|-------|
| **Scope** | Pure structure only | Structure + analysis | Structure + semantics + persistence |
| **Visualization** | Built-in ASCII | Requires Matplotlib | Web-based UI |
| **Explanation** | Structured introspection (.Explain()) | Manual inspection | Query language (Cypher) |
| **Semantics** | None—by design | Basic node/edge attributes | Full schema, validation rules |
| **Scalability** | In-memory, single instance | In-memory, single instance | Distributed, persistent |
| **Language** | Ring | Python | Java-based |
| **Use Case** | Model + validate structure quickly | Analysis algorithms | Production graph database |
| **Strength** | Clarity, reusability, purity | Comprehensive algorithms | Enterprise scale, querying |

**When to use stzGraph:**
- Validate structure before semantic interpretation
- Build domain layers (stzDiagram, stzEntity, custom)
- Need quick structural feedback without external tools
- Reasoning independent from domain logic

**When to use NetworkX:**
- Extensive graph algorithms (centrality, clustering, matching)
- Pure Python environment

**When to use Neo4j:**
- Persistent, queryable graph storage
- Production enterprise scale
- Rich query language needed

---

## How Softanza Approach Differs

Traditional: Graph + domain semantics + validation + rendering = monolithic.

Softanza: Separate layers.
```
stzGraph (algorithms + introspection)
  ↓ inherited by
stzDiagram (workflow semantics + rendering)
  or
stzEntity + stzRelation (type systems + constraints)
  ↓ inherited by
Application (business logic + interpretation)
```

Result: Test graph algorithms independently. Reuse across domains. Add semantics layerwise. Reason about structure vs. meaning separately.

---

## Algorithmic Guarantees

- **Correct**: Valid results for any input
- **Terminating**: Always finish (no infinite loops)
- **Efficient**: O(V + E) complexity
- **Deterministic**: Same input → same output

---

## Why This Design

**Narrowness enables:**
- **Testability**: Verify algorithms without domain logic
- **Reusability**: One implementation, many domains
- **Maintainability**: Focused, stable codebase
- **Extensibility**: New specializations inherit automatically
- **Transparency**: Structure vs. semantics explicit
- **Developer Experience**: Visualization + explanation built-in

**Scope (intentional exclusions):**
- ✗ Sophisticated rendering (stzDiagram handles it)
- ✗ Validation rules (domain layers handle it)
- ✗ Type constraints (stzEntity handles it)
- ✗ Persistence (specializations handle it)

---

## Conclusion

stzGraph is computational foundation: pure, correct, introspectable algorithms for relational reasoning.

Specializations add meaning:
- **stzDiagram** → workflows
- **stzEntity / stzRelation** → language modeling
- **Custom** → any relational domain

All build on the same foundation. Visualization and explanation make that foundation transparent. Separation of concerns makes it reusable.