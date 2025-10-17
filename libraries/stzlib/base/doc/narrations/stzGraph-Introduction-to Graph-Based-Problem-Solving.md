# stzGraph: Introduction to Graph-Based Problem Solving

## What Is a Graph?

A graph is a structure for representing relationships. It consists of **nodes** (entities) and **edges** (connections between them). Graphs model real-world systems: organizational hierarchies, approval workflows, data flows, service dependencies—anything where entities relate to one another.

## How Softanza Approaches Graphs

Softanza separates concerns cleanly. **stzGraph** handles pure structure—connectivity, paths, cycles, bottlenecks. It answers: "Can I reach B from A? What are all possible routes? Where are the critical hubs?" 

Domain specializations (like stzDiagram, and future frameworks like stzEntity) inherit stzGraph's capabilities and add meaning—validation rules, semantics, rendering. This separation creates clarity: structure stays distinct from semantics.

---

## Creating Your First Graph

The simplest way:

```ring
oGraph = new stzGraph("SimpleGraph")
oGraph {
    AddNode(:@1, "Node 1")
    AddNode(:@2, "Node 2")
    AddNode(:@3, "Node 3")
    
    AddEdge(:@1, :@2, "connects")
    AddEdge(:@2, :@3, "flows")
    
    ? NodeCount() #--> 3
    ? EdgeCount() #--> 2
}
```

Structure created:

```
[Node 1] ----connects----> [Node 2] ----flows----> [Node 3]
```

**Nodes** are entities (ID + label). **Edges** are directed relationships (FROM → TO with a label).

---

## Understanding Nodes and Edges

```ring
AddNode(:@employee, "Alice")         # Node: ID and human-readable name
AddEdge(:@alice, :@bob, "reports_to") # Directed: Alice → Bob
```

---

## Adding Metadata with Properties

Use `AddNodeXT()` for extended node creation with domain-specific metadata:

```ring
oGraph = new stzGraph("Workflow")
oGraph {
    AddNodeXT(:@step1, "Validate Data", :Process, [
        "priority" = "high",
        "owner" = "data-team",
        "estimated_time" = 300,
        "criticality" = "blocking"
    ])
    
    AddNodeXT(:@step2, "Transform Data", :Process, [
        "priority" = "high",
        "owner" = "transform-team",
        "estimated_time" = 600,
        "criticality" = "normal"
    ])
}
```

Properties are metadata—they don't affect algorithms. Domain specializations use them for validation, responsibility tracking, performance analysis, compliance checking.

---

## Connectivity: Can Systems Reach Their Goals?

**What This Reveals**: In workflows, approval chains, or language models, can the system actually reach its intended endpoint? A broken chain stops everything.

**Use Cases**:
- **Workflows**: Verify request → manager → director → approval is connected
- **Language Models**: Ensure semantic entities can reach expected target entities through relation chains
- **Data Pipelines**: Confirm data sources connect to analysis endpoints

**Solution**: Use `PathExists()` to query whether one node can reach another through the graph.

```ring
oWorkflow = new stzGraph("ApprovalProcess")
oWorkflow {
    AddNode(:@request, "Request Submitted")
    AddNode(:@manager, "Manager Review")
    AddNode(:@director, "Director Approval")
    AddNode(:@approved, "Approved")
    
    AddEdge(:@request, :@manager, "submit")
    AddEdge(:@manager, :@director, "escalate")
    AddEdge(:@director, :@approved, "finalize")
}

? oWorkflow.PathExists(:@request, :@approved)  #--> TRUE
```

Structure:

```
[Request Submitted]
       |
     submit
       |
       V
[Manager Review]
       |
    escalate
       |
       V
[Director Approval]
       |
    finalize
       |
       V
  [Approved]
```

Language modeling example:

```ring
oLanguageModel = new stzGraph("SemanticModel")
oLanguageModel {
    AddNode(:@person, "Person")
    AddNode(:@employee, "Employee")
    AddNode(:@manager, "Manager")
    AddNode(:@organization, "Organization")
    
    AddEdge(:@person, :@employee, "is_a")
    AddEdge(:@employee, :@manager, "can_be")
    AddEdge(:@manager, :@organization, "works_in")
}

? oLanguageModel.PathExists(:@person, :@organization)  #--> TRUE
```

PathExists returns TRUE—the semantic model is sound. If manager doesn't connect to organization, you've found a design gap.

---

## Alternative Routes: Understanding All Possibilities

**What This Reveals**: Real processes and semantic models often have multiple valid paths. You need to understand all alternatives, identify convergence points, and discover single points of failure.

**Use Cases**:
- **Workflows**: Do all requests go through one hub? Are there parallel approval paths?
- **Language Models**: Can an entity reach a target through different semantic paths? What if one relation chain is blocked?
- **Service Architectures**: Are there redundant routes or critical bottlenecks?

**Solution**: Use `FindAllPaths()` to discover every possible route from start to end.

```ring
oProcess = new stzGraph("MultiPathProcess")
oProcess {
    AddNode(:@start, "Start")
    AddNode(:@path_a, "Fast Path")
    AddNode(:@path_b, "Standard Path")
    AddNode(:@end, "Complete")
    
    AddEdge(:@start, :@path_a, "expedited")
    AddEdge(:@start, :@path_b, "normal")
    AddEdge(:@path_a, :@end, "finish")
    AddEdge(:@path_b, :@end, "finish")
}

aAllPaths = oProcess.FindAllPaths(:@start, :@end)
? len(aAllPaths)  #--> 2
```

Structure:

```
[Start]
  |
  ├----expedited----> [Fast Path]
  |                       |
  |                       └----finish----┐
  |                                       |
  └----normal------> [Standard Path]     |
                         |                |
                         └----finish---->[Complete]
```

Language modeling example:

```ring
oSemanticPaths = new stzGraph("EntityRelations")
oSemanticPaths {
    AddNode(:@author, "Author")
    AddNode(:@book, "Book")
    AddNode(:@publisher, "Publisher")
    AddNode(:@award, "Award")
    
    AddEdge(:@author, :@book, "writes")
    AddEdge(:@book, :@publisher, "published_by")
    AddEdge(:@author, :@award, "receives")
    AddEdge(:@award, :@publisher, "given_by")
}

aAllPaths = oSemanticPaths.FindAllPaths(:@author, :@publisher)
? len(aAllPaths)  #--> 2
```

Two distinct semantic routes:
- Author → Book → Publisher
- Author → Award → Publisher

This reveals connectivity flexibility and relationship alternatives.

---

## Circular Dependencies: Detecting Infinite Loops

**What This Reveals**: Semantic models and workflows can accidentally create cycles—A depends on B, B depends on C, C depends on A. This breaks logic and creates infinite loops.

**Use Cases**:
- **Workflows**: Prevent processes that never terminate
- **Language Models**: Detect circular type definitions or semantic loops (e.g., "Person is_a Employee" but "Employee is_a Person")
- **Dependency Systems**: Flag unresolvable circular imports

**Solution**: Use `CyclicDependencies()` to check for any cycles in the graph.

```ring
oInvalid = new stzGraph("BrokenWorkflow")
oInvalid {
    AddNode(:@p1, "Process 1")
    AddNode(:@p2, "Process 2")
    AddNode(:@p3, "Process 3")
    
    AddEdge(:@p1, :@p2, "")
    AddEdge(:@p2, :@p3, "")
    AddEdge(:@p3, :@p1, "")  # Cycle created
}

? oInvalid.CyclicDependencies()  #--> TRUE
```

Broken workflow (with cycle):

```
[P1] -------> [P2] -------> [P3]
 ↑___________________________|

Circular: P1→P2→P3→P1 repeats forever
```

Language modeling example:

```ring
oInvalidModel = new stzGraph("CircularTypes")
oInvalidModel {
    AddNode(:@person, "Person")
    AddNode(:@role, "Role")
    AddNode(:@team, "Team")
    
    AddEdge(:@person, :@role, "has")
    AddEdge(:@role, :@team, "belongs_to")
    AddEdge(:@team, :@person, "contains")  # Cycle!
}

? oInvalidModel.CyclicDependencies()  #--> TRUE
```

TRUE indicates a semantic contradiction. The model breaks logical coherence.

Valid model (no cycle):

```ring
oValid = new stzGraph("ValidModel")
oValid {
    AddNode(:@person, "Person")
    AddNode(:@role, "Role")
    AddNode(:@team, "Team")
    
    AddEdge(:@person, :@role, "has")
    AddEdge(:@role, :@team, "belongs_to")
    # No backwards edge—hierarchy is clean
}

? oValid.CyclicDependencies()  #--> FALSE
```

---

## Scope and Influence: Understanding Reach

**What This Reveals**: In organizations or semantic models, you need to know: from a given node, how many entities are reachable? What's the scope of influence or semantic consequence?

**Use Cases**:
- **Organizations**: Does a manager oversee 2 people or 50?
- **Language Models**: If a type changes, how many other types depend on it transitively?
- **Data Systems**: Does a database connect to 3 services or 30?

**Solution**: Use `ReachableFrom()` to find all nodes reachable from a starting point.

```ring
oOrg = new stzGraph("Organization")
oOrg {
    AddNode(:@ceo, "CEO")
    AddNode(:@director, "Director")
    AddNode(:@manager, "Manager")
    AddNode(:@dev1, "Developer 1")
    AddNode(:@dev2, "Developer 2")
    
    AddEdge(:@ceo, :@director, "reports_to")
    AddEdge(:@director, :@manager, "reports_to")
    AddEdge(:@manager, :@dev1, "reports_to")
    AddEdge(:@manager, :@dev2, "reports_to")
}

aReachableFromManager = oOrg.ReachableFrom(:@manager)
? len(aReachableFromManager)  #--> 3

aReachableFromCEO = oOrg.ReachableFrom(:@ceo)
? len(aReachableFromCEO)  #--> 5
```

Structure:

```
[CEO]
  |
  V
[Director]
  |
  V
[Manager]
  |
  ├──-> [Developer 1]
  |
  └──-> [Developer 2]
```

Language modeling example:

```ring
oTypeHierarchy = new stzGraph("TypeSystem")
oTypeHierarchy {
    AddNode(:@entity, "Entity")
    AddNode(:@person, "Person")
    AddNode(:@employee, "Employee")
    AddNode(:@manager, "Manager")
    
    AddEdge(:@entity, :@person, "is_a")
    AddEdge(:@person, :@employee, "is_a")
    AddEdge(:@employee, :@manager, "is_a")
}

aReachableFromEmployee = oTypeHierarchy.ReachableFrom(:@employee)
? len(aReachableFromEmployee)  #--> 2  # (self + Manager)

aReachableFromPerson = oTypeHierarchy.ReachableFrom(:@person)
? len(aReachableFromPerson)  #--> 3  # (self + Employee + Manager)
```

ReachableFrom reveals semantic scope:
- Employee reaches 2 (itself + Manager specialization)
- Person reaches 3 (itself + Employee + Manager)
- This shows how many dependent types exist in the hierarchy

---

## Critical Hubs: Identifying Single Points of Failure

**What This Reveals**: In data flows, service architectures, or semantic models, some nodes become critical convergence points. If they fail or change, everything downstream is affected.

**Use Cases**:
- **Data Systems**: Central hub processes all data from multiple sources
- **Language Models**: A core entity type that many others reference (e.g., "Person" used by dozens of other types)
- **Organizational Structures**: A manager through whom all information flows

**Solution**: Use `BottleneckNodes()` to find nodes where many paths converge.

```ring
oDataFlow = new stzGraph("DataSystem")
oDataFlow {
    AddNode(:@source_a, "Data Source A")
    AddNode(:@source_b, "Data Source B")
    AddNode(:@source_c, "Data Source C")
    AddNode(:@hub, "Central Hub")
    AddNode(:@analysis, "Analysis Service")
    
    AddEdge(:@source_a, :@hub, "feed")
    AddEdge(:@source_b, :@hub, "feed")
    AddEdge(:@source_c, :@hub, "feed")
    AddEdge(:@hub, :@analysis, "output")
}

aBottlenecks = oDataFlow.BottleneckNodes()
? aBottlenecks  #--> [:@hub]
```

Structure:

```
[Source A]
  |
  V
[Source B] ---> [Central Hub] ---> [Analysis Service]
  |              
  V              
[Source C]

All data flows through the hub
```

Language modeling example:

```ring
oSemanticModel = new stzGraph("TypeDependencies")
oSemanticModel {
    AddNode(:@entity, "Entity")
    AddNode(:@user, "User")
    AddNode(:@product, "Product")
    AddNode(:@order, "Order")
    AddNode(:@payment, "Payment")
    
    AddEdge(:@user, :@entity, "specializes")
    AddEdge(:@product, :@entity, "specializes")
    AddEdge(:@order, :@entity, "specializes")
    AddEdge(:@payment, :@entity, "specializes")
}

aBottlenecks = oSemanticModel.BottleneckNodes()
? aBottlenecks  #--> [:@entity]
```

Entity is a bottleneck—everything specializes from it. Changes to Entity cascade to all types.

---

## Complexity Metrics: Measuring Interconnection and Depth

**What This Reveals**: How tightly coupled is this system? How many steps must complete before a process ends? High coupling = fragile. Long sequences = slow completion.

**Use Cases**:
- **System Design**: Assess if architecture is modular or tightly coupled
- **Language Models**: Understand type hierarchy depth (shallow vs. deeply nested inheritance)
- **Workflows**: Measure process complexity and steps to completion

**Solution**: Use `NodeDensity()` to measure coupling and `LongestPath()` to measure process depth.

```ring
oSystem = new stzGraph("SystemA")
oSystem {
    AddNode(:@1, "Component A")
    AddNode(:@2, "Component B")
    AddNode(:@3, "Component C")
    
    AddEdge(:@1, :@2, "")
    AddEdge(:@2, :@3, "")
    AddEdge(:@1, :@3, "")  # Extra connection
}

? oSystem.NodeDensity()  #--> 33
? oSystem.LongestPath()  #--> 2
```

**Density** measures coupling:
- High (near 100): everything connects to everything = complex, brittle
- Low (near 0): few connections = simple, modular

**Longest Path** measures sequence depth:
- Long sequences: many steps before completion
- Short sequences: simple, fast

Language modeling example:

```ring
oTypeHierarchy = new stzGraph("TypeSystem")
oTypeHierarchy {
    AddNode(:@top, "Top")
    AddNode(:@middle1, "Middle1")
    AddNode(:@middle2, "Middle2")
    AddNode(:@leaf, "Leaf")
    
    AddEdge(:@top, :@middle1, "is_a")
    AddEdge(:@top, :@middle2, "is_a")
    AddEdge(:@middle1, :@leaf, "is_a")
    AddEdge(:@middle2, :@leaf, "is_a")
}

? oTypeHierarchy.NodeDensity()  #--> 50
? oTypeHierarchy.LongestPath()  #--> 2
```

High density reveals multiple inheritance paths. Long paths reveal deep type hierarchies.

---

## Direct Dependencies: Neighborhoods

**What This Reveals**: Immediate, direct connections without tracing entire paths. What does a node directly depend on? What directly depends on it?

**Use Cases**:
- **Testing**: Understand direct dependencies for unit test mocking
- **Language Models**: What entities directly reference this type?
- **Debugging**: Find immediate causes, not transitive effects

**Solution**: Use `Neighbors()` and `Incoming()` for direct connections.

```ring
oGraph = new stzGraph("Services")
oGraph {
    AddNode(:@api, "API Gateway")
    AddNode(:@auth, "Auth Service")
    AddNode(:@db, "Database")
    AddNode(:@cache, "Cache")
    
    AddEdge(:@api, :@auth, "call")
    AddEdge(:@api, :@db, "query")
    AddEdge(:@db, :@cache, "store")
}

# What does API directly call?
aNeighbors = oGraph.Neighbors(:@api)
? aNeighbors  #--> [:@auth, :@db]

# What directly calls Auth?
aIncoming = oGraph.Incoming(:@auth)
? aIncoming  #--> [:@api]
```

Language modeling example:

```ring
oModel = new stzGraph("EntityModel")
oModel {
    AddNode(:@person, "Person")
    AddNode(:@address, "Address")
    AddNode(:@contact, "Contact")
    AddNode(:@organization, "Organization")
    
    AddEdge(:@person, :@address, "has")
    AddEdge(:@person, :@contact, "has")
    AddEdge(:@person, :@organization, "works_in")
}

# What entities does Person directly reference?
aPersonDeps = oModel.Neighbors(:@person)
? aPersonDeps  #--> [:@address, :@contact, :@organization]

# What entities directly reference Address?
aAddressDeps = oModel.Incoming(:@address)
? aAddressDeps  #--> [:@person]
```

---

## Basic Queries

```ring
? oGraph.NodeCount()               # How many nodes?
? oGraph.EdgeCount()               # How many edges?
? oGraph.NodeExists(:@id)          # Does node exist?
? oGraph.EdgeExists(:@from, :@to)  # Does edge exist?
```

---

## Modifying Graphs

```ring
oGraph.AddNode(:@new, "New Node")
oGraph.RemoveNode(:@old)

oGraph.AddEdge(:@from, :@to, "label")
oGraph.RemoveEdge(:@from, :@to)
```

---

## Key Takeaways

1. **Connectivity** verifies systems reach their goals
2. **Alternative routes** reveal flexibility and bottlenecks
3. **Cycle detection** prevents infinite loops
4. **Reachability** measures scope and influence
5. **Bottleneck identification** highlights critical risk points
6. **Complexity metrics** guide design and refactoring decisions
7. **Direct neighborhoods** enable local dependency analysis
8. **Properties** store domain metadata for interpretation
9. **Language modeling**: stzGraph powers semantic frameworks (stzEntity, stzRelation, stzListOfEntities)

---

## Next Steps

Use stzDiagram for workflows, or build semantic frameworks with stzEntity and stzRelation. stzGraph provides the computational foundation. Your domain code provides meaning.