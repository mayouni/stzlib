# stzGraph: The Art of Connected Thinking

## What Is a Graph?

A **graph** is one of the most elegant ideas in computer science — a structure made of **nodes** (things) and **edges** (relationships).
It models how parts of a system depend, influence, or interact with one another.

Whether you're modeling **workflows**, **program code**, **data schemas**, or **natural language conversations**, a graph turns complexity into clarity.
In `stzGraph`, this clarity comes alive: the code reads like plain reasoning, and the structure you imagine becomes visible, explorable, and exportable — right from your terminal.

---

## Quick Start

Create a graph, visualize it, query it, augment it with metadata:

```ring
oGraph = new stzGraph("MyFlow")
oGraph {
    AddNode(:@start, "Start")
    AddNode(:@middle, "Process")
    AddNode(:@end, "End")
    
    AddEdge(:@start, :@middle, "flows")
    AddEdge(:@middle, :@end, "completes")
    
    Show()
}
```

Output:

```
        ╭───────╮        
        │ Start │        
        ╰───────╯        
            |            
          flows          
            |            
            v            
      ╭───────────╮      
      │ !Process! │      
      ╰───────────╯      
            |            
        completes        
            |            
            v            
         ╭─────╮         
         │ End │         
         ╰─────╯
```

Quick checks:

```ring
? oGraph.NodeCount()        #--> 3
? oGraph.PathExists(:@start, :@end)  #--> TRUE
```

Augment nodes with domain properties:

```ring
oGraph.AddNodeXT(:@middle, "Process", [
    "priority" = "high",
    "owner" = "team-a"
])
```

`stzGraph` feels conversational — you declare relationships, it makes sense of them.
No configuration, no setup, just pure connected logic.


## Natural API: Your Questions Become Methods

Every method mirrors how you actually think about graphs. Ask the question naturally; the method name follows:

| What You're Thinking        | Method You Call                              | What You Get        |
| --------------------------- | ---------------------------------------------- | ------------------- |
| Can A reach B?              | `PathExists(:@a, :@b)`                         | TRUE / FALSE        |
| Show me all routes A to B   | `FindAllPaths(:@a, :@b)`                       | Array of paths      |
| Any loops here?             | `CyclicDependencies()`                         | TRUE / FALSE        |
| What can X influence?       | `ReachableFrom(:@x)`                           | Array of nodes      |
| Which nodes are critical?   | `BottleneckNodes()`                            | Array of node IDs   |
| How tightly coupled?        | `NodeDensity()`                                | Percentage (0-100)  |
| What's the longest chain?   | `LongestPath()`                                | Edge count          |
| What leaves this node?      | `NeighborsOf(:@x)`                             | Array of nodes      |
| What reaches this node?     | `IncomingTo(:@x)`                              | Array of nodes      |
| Tell me about this graph    | `Explain()`                                    | Structured analysis |
| Does this exist?            | `NodeExists(:@id)`, `EdgeExists(:@from, :@to)` | TRUE / FALSE        |
| See vertical layout         | `Show()` / `ShowV()`                           | ASCII diagram       |
| See horizontal layout       | `ShowH()` / `ShowHorizontal()`                 | ASCII diagram       |
| See annotated graph         | `ShowWithLegend()`                             | ASCII + legend      |

The API speaks your language. No translation layer.


## Connectivity — Does the Path Exist?

Every structure hides a story. Sometimes you just want to know: *Can this system reach its goal?*

```ring
oWorkflow = new stzGraph("ApprovalProcess")
oWorkflow {
    AddNode(:@request, "Request")
    AddNode(:@manager, "Manager")
    AddNode(:@director, "Director")
    AddNode(:@approved, "Approved")
    
    AddEdge(:@request, :@manager, "submit")
    AddEdge(:@manager, :@director, "escalate")
    AddEdge(:@director, :@approved, "finalize")
    
    Show()
}
```

Output (vertical):

```
       ╭─────────╮       
       │ Request │       
       ╰─────────╯       
            |            
         submit          
            |            
            v            
      ╭───────────╮      
      │ !Manager! │      
      ╰───────────╯      
            |            
        escalate         
            |            
            v            
     ╭────────────╮      
     │ !Director! │      
     ╰────────────╯      
            |            
        finalize         
            |            
            v            
      ╭──────────╮       
      │ Approved │       
      ╰──────────╯ 
```

Query:

```ring
? oWorkflow.PathExists(:@request, :@approved)  #--> TRUE
```


## Alternative Routes — Finding All Paths

Real systems rarely have one straight route. They branch, merge, or overlap.

```ring
oProcess = new stzGraph("MultiPathProcess")
oProcess {
    AddNode(:@start, "Start")
    AddNode(:@fast, "Fast Path")
    AddNode(:@standard, "Standard Path")
    AddNode(:@end, "Complete")
    
    AddEdge(:@start, :@fast, "expedited")
    AddEdge(:@start, :@standard, "normal")
    AddEdge(:@fast, :@end, "finish")
    AddEdge(:@standard, :@end, "finish")
    
    ShowH()
}
```

Output (horizontal):

```
╭───────╮              ╭───────────╮           ╭──────────╮
│ Start │--expedited-->│ Fast Path │--finish-->│ Complete │
╰───────╯              ╰───────────╯           ╰──────────╯
```

Query:

```ring
aPaths = oProcess.FindAllPaths(:@start, :@end)
? len(aPaths)  #--> 2
```

**Feature 1: Independent Branches**

Identify which branches diverge yet have no overlapping downstream:

```ring
? oProcess.ParallelizableBranches()
#--> [[:@fast, :@standard]]

? oProcess.DependencyFreeNodes()
#--> [:@start]
```

These branches can advance independently without interference.

*Note: Concrete use cases like concurrent execution appear in domain-specific classes. `stzCodeModel` applies this for concurrent code; `stzWorkflow` for parallel activities.*


## Cyclic Dependencies — Detect Feedback Loops

Graphs make circular structures visible — and `stzGraph` identifies them.

```ring
oCyclic = new stzGraph("CyclicStructure")
oCyclic {
    AddNode(:@p1, "P1")
    AddNode(:@p2, "P2")
    AddNode(:@p3, "P3")
    
    AddEdge(:@p1, :@p2, "")
    AddEdge(:@p2, :@p3, "")
    AddEdge(:@p3, :@p1, "")
    
    Show()
}
```

Output:

```
         ╭────╮          
         │ P1 │          
         ╰────╯          
            |            
            v            
         ╭────╮          
         │ P2 │          
         ╰────╯          
            |            
            v            
         ╭────╮          
         │ P3 │          
         ╰────╯          
            |            
      <CYCLE: >   
            |           ↑
            ╰──> [P1] ──╯
```

Query:

```ring
? oCyclic.CyclicDependencies()  #--> TRUE
```

**Feature 3: Structural Constraints**

Enforce rules to guarantee design properties:

```ring
oGraph = new stzGraph("DAGStructure")
oGraph {
    AddNode(:@a, "A")
    AddNode(:@b, "B")
    AddNode(:@c, "C")
    
    AddConstraint("NO_CYCLES", "ACYCLIC")
    AddConstraint("CONNECTIVITY", "CONNECTED")
    
    AddEdge(:@a, :@b, "")
    AddEdge(:@b, :@c, "")
}

? oGraph.ValidateConstraints()
#--> TRUE
```

Supported constraints: `ACYCLIC`, `NO_CYCLES`, `CONNECTED`. Validate structural correctness at any point in your analysis.


## Reachability — Measure Scope and Influence

Not all nodes are equal. Some trigger cascades. When you modify a concept that many others depend on, the entire structure ripples with change.

Nodes marked with `!label!` are **bottlenecks**—high-connectivity hubs where many paths converge. These are critical junction points:

```ring
oHierarchy = new stzGraph("TypeSystem")
oHierarchy {
    AddNode(:@entity, "Entity")
    AddNode(:@person, "Person")
    AddNode(:@employee, "Employee")
    AddNode(:@manager, "Manager")
    
    AddEdge(:@entity, :@person, "is_a")
    AddEdge(:@person, :@employee, "is_a")
    AddEdge(:@employee, :@manager, "is_a")
    
    Show()
}
```

Output:

```
       ╭────────╮        
       │ Entity │        
       ╰────────╯        
            |            
          is_a           
            |            
            v            
      ╭──────────╮       
      │ !Person! │       
      ╰──────────╯       
            |            
          is_a           
            |            
            v            
     ╭────────────╮      
     │ !Employee! │      
     ╰────────────╯      
            |            
          is_a           
            |            
            v            
       ╭─────────╮       
       │ Manager │       
       ╰─────────╯  
```

**Person** and **Employee** are marked because they sit at critical points in the hierarchy—change them, and everything downstream is affected.

Query the influence:

```ring
? oHierarchy.ReachableFrom(:@person)
#--> [:@person, :@employee, :@manager]
```

Understand the structure holistically:

```ring
? oHierarchy.Explain()
#--> [
    ["general", ["Graph: TypeSystem", "Nodes: 4 | Edges: 3"]],
    ["bottlenecks", ["Bottleneck nodes: @person, @employee", ...]],
    ["cycles", ["No cycles - acyclic graph (DAG)"]],
    ["metrics", ["Density: 25%...", "Longest path: 3 hops"]]
]
```


## Bottleneck Nodes — Identify Critical Hubs

Some nodes are crossroads — everything passes through them. When they fail, the system halts.

```ring
oGraph = new stzGraph("BottleneckTest")
oGraph {
    AddNode(:@a, "A")
    AddNode(:@b, "B")
    AddNode(:@c, "C")
    AddNode(:@hub, "Hub")
    
    AddEdge(:@a, :@hub, "")
    AddEdge(:@b, :@hub, "")
    AddEdge(:@c, :@hub, "")
    AddEdge(:@hub, :@a, "")
    
    ShowWithLegend()
}
```

Output:

```
          ╭───╮          
          │ B │          
          ╰───╯          
            |            
            v            
        ╭───────╮        
        │ !Hub! │        
        ╰───────╯        
            |            
            v            
          ╭───╮          
          │ A │          
          ╰───╯          
            |            
      <CYCLE: >   
            |              ↑
            ╰──> [!Hub!] ──╯

          ////

          ╭───╮          
          │ C │          
          ╰───╯          
            |            
            v            
        ╭───────╮        
        │ !Hub! │        
        ╰───────╯        
            |            
            v            
          ╭───╮          
          │ A │          
          ╰───╯          
            |            
      <CYCLE: >   
            |              ↑
            ╰──> [!Hub!] ──╯

Legend:

╭────────────┬─────────────────────────────────────────────────────╮
│    Sign    │                       Meaning                       │
├────────────┼─────────────────────────────────────────────────────┤
│ bottleneck │ [ "!label!", "High connectivity hub (bottleneck)" ] │
│ feedback   │ [ "[...] ↑", "Feedback loop" ]                      │
│ branch     │ [ "////", "Branch separator (multiple paths)" ]     │
╰────────────┴─────────────────────────────────────────────────────╯
```

Query:

```ring
? oGraph.BottleneckNodes()
#--> [:@hub]
```

**Feature 2: Criticality & Impact Analysis**

Understand which nodes matter most and what fails when they fail:

```ring
oSystem = new stzGraph("SystemDependencies")
oSystem {
    AddNode(:@database, "Database")
    AddNode(:@api, "API")
    AddNode(:@worker1, "Worker1")
    AddNode(:@worker2, "Worker2")
    
    AddEdge(:@database, :@api, "")
    AddEdge(:@api, :@worker1, "")
    AddEdge(:@api, :@worker2, "")
}

? oSystem.ImpactOf(:@api)
#--> 2

? oSystem.FailureScope(:@api)
#--> [:@worker1, :@worker2]

? oSystem.MostCriticalNodes(2)
#--> [:@api, :@database]
```

Risk assessment made visible.


## Complexity Metrics — Assess Architecture

```ring
? oGraph.NodeDensity()   # 0-100: tightness of connections
? oGraph.LongestPath()   # Maximum hops in any path
```

* High density (near 100): tightly coupled, brittle
* Low density (near 0): modular, loose
* Long paths: deep chains, potential latency
* Short paths: simple flows, fast completion


## Direct Dependencies — Neighborhoods

```ring
oGraph = new stzGraph("Services")
oGraph {
    AddNode(:@api, "API")
    AddNode(:@auth, "Auth")
    AddNode(:@db, "DB")
    
    AddEdge(:@api, :@auth, "")
    AddEdge(:@api, :@db, "")
}

? oGraph.NeighborsOf(:@api)   #--> [:@auth, :@db]
? oGraph.IncomingTo(:@auth)   #--> [:@api]
```

Quick neighborhood checks reveal connectivity patterns.


## Core Operations

```ring
oGraph.AddNode(:@new, "Label")
oGraph.RemoveNode(:@old)
oGraph.AddEdge(:@from, :@to, "label")
oGraph.RemoveEdge(:@from, :@to)

? oGraph.NodeCount()
? oGraph.EdgeCount()
? oGraph.NodeExists(:@id)
? oGraph.EdgeExists(:@from, :@to)
```


## Power User Features

### Feature 4: Rich Querying

Search nodes and paths by type or custom predicate:

```ring
oGraph = new stzGraph("Codebase")
oGraph {
    AddNodeXT(:@fn1, "function1", [:type = "function"])
    AddNodeXT(:@fn2, "function2", [:type = "function"])
    AddNodeXT(:@mod1, "module1", [:type = "module"])
    
    AddEdge(:@fn1, :@fn2, "calls")
    AddEdge(:@fn2, :@mod1, "imports")
}

? oGraph.Query([:nodeType = "function"])
#--> [:@fn1, :@fn2]

? oGraph.Query([:edgeLabel = "calls"])
#--> edges with label "calls"

? oGraph.FindNodesWhere(func node { 
    return substr(node["label"], "function") > 0 
})
#--> [:@fn1, :@fn2]
```

Metadata attached to nodes enables domain-aware searches.


### Feature 5: Inference & Implicit Knowledge

Automatically derive relationships from logic rules:

```ring
oGraph = new stzGraph("Organization")
oGraph {
    AddNode(:@alice, "Alice")
    AddNode(:@bob, "Bob")
    AddNode(:@carol, "Carol")
    
    AddEdge(:@alice, :@bob, "manages")
    AddEdge(:@bob, :@carol, "manages")
    
    AddInferenceRule("HIERARCHY", "TRANSITIVITY")
    ? oGraph.ApplyInference()
    #--> 1
}

? oGraph.EdgeExists(:@alice, :@carol)
#--> TRUE (transitively derived)
```

Supported rules: `TRANSITIVITY`, `SYMMETRY`, `COMPOSITION`.


### Feature 6: Temporal Evolution & Snapshots

Track graph changes over time:

```ring
oGraph = new stzGraph("DatabaseSchema")
oGraph {
    AddNode(:@users, "users")
    AddNode(:@orders, "orders")
    AddEdge(:@users, :@orders, "has_many")
    
    Snapshot("v1.0")
    
    AddNode(:@payments, "payments")
    AddEdge(:@orders, :@payments, "has_many")
}

? oGraph.ListSnapshots()
#--> ["v1.0"]

aChanges = oGraph.ChangesSince("v1.0")
? aChanges["nodesAdded"]
#--> [:@payments]

oGraph.RestoreSnapshot("v1.0")
? oGraph.NodeCount()
#--> 2
```

Schema versioning, migration audits, rollback scenarios.


### Feature 7: Export & Interoperability

Serialize to multiple formats:

```ring
oGraph = new stzGraph("Pipeline")
oGraph {
    AddNode(:@input, "Input")
    AddNode(:@process, "Process")
    AddNode(:@output, "Output")
    AddEdge(:@input, :@process, "feeds")
    AddEdge(:@process, :@output, "produces")
}

? oGraph.ExportDOT()      # GraphViz format
? oGraph.ExportJSON()     # JSON with metrics
? oGraph.ExportYAML()     # YAML representation

oGraph.RegisterExporter("MERMAID", func {
    acNodes = oGraph.AllNodes()
    acEdges = oGraph.AllEdges()
    cMermaid = "graph LR;" + nl
    
    for i = 1 to len(acNodes)
        aNode = acNodes[i]
        cMermaid += "  " + aNode["id"] + "[" + aNode["label"] + "]" + nl
    end
    
    for i = 1 to len(acEdges)
        aEdge = acEdges[i]
        cMermaid += "  " + aEdge["from"] + " --> " + aEdge["to"] + nl
    end
    
    return cMermaid
})

? oGraph.ExportUsing("MERMAID")
```

CI/CD visualization, documentation generation, graph database import.


## Visualization Options

Use `Show()` to render:

* `Show()` / `ShowV()` — vertical ASCII layout
* `ShowH()` / `ShowHorizontal()` — horizontal ASCII layout
* `ShowWithLegend()` — annotated with markers

Markers in output:

* `!label!` — bottleneck node (high connectivity)
* `~label~` — participates in cycle
* `!~label~!` — hub with cyclic dependency
* `<CYCLE: label>` — feedback loop indicator
* `[Node]` — part of cycle path
* `////` — branch separator (multiple independent routes)

---

## Why stzGraph?

`stzGraph` treats **relationships as first-class code constructs** — concise, visual, analytical.

| Dimension                | stzGraph                                       | NetworkX                   | Neo4j                | GraphQL               |
| ------------------------ | ---------------------------------------------- | -------------------------- | -------------------- | --------------------- |
| **Structure Validation** | ✅ `.Explain()` facts: cycles, bottlenecks      | ◯ Manual analysis          | ◯ Query-based        | ◯ Schema only         |
| **Development Speed**    | ✅ Instant—no deps                              | ◯ `pip install` + setup    | 🟠 Server required   | 🟠 Endpoint + schema  |
| **Language Integration** | ✅ Native Ring fluency                          | ◯ Python idiomatic         | 🟠 Java/Cypher       | 🟠 JSON/REST layer    |
| **Visualization**        | ✅ ASCII instant (stzDiagram: Graphviz layouts) | 🟠 Matplotlib              | ◯ Web UI             | ✗ Results only        |
| **Introspection**        | ✅ Programmatic data arrays                     | ✗ Manual traversal         | 🟠 Query results     | ◯ Schema tools        |
| **Temporal Tracking**    | ✅ Snapshots + change history                   | ◯ Attribute-based          | 🟠 Transaction logs  | ✗ None                |
| **Inference Engine**     | ✅ Rules-based derivation                       | ◯ Manual computation       | 🟠 Query inference   | ✗ None                |
| **Custom Exporters**     | ✅ Pluggable format serialization               | ◯ Format-specific          | 🟠 Cypher only       | ✗ Schema-bound        |
| **Reusability**          | ✅ One codebase across domains                  | ◯ Research focus           | ◯ Graph DB specific  | 🟠 API-specific       |
| **Best For**             | ✅ Validate, extend systems                     | ✅ Algorithm research       | ✅ Persistent queries | ◯ Data APIs           |


## Extension: Foundation for Domain-Specific Reasoning

`stzGraph` is the architectural spine for domain-specific systems:

* **stzWorkflow** — task dependencies and execution order
* **stzDecisionTree** — branching logic and outcomes
* **stzSemanticModel** — concept relationships
* **stzDataModel** — schema and cardinality
* **stzCodeModel** — module and function dependencies
* **stzNaturalLanguage** — semantic role networks

Each inherits `stzGraph`'s power while specializing its vocabulary. **Structure is universal; semantics is domain-specific.**

---

## Conclusion

Every programmer who touches complexity eventually feels it — the moment where diagrams blur, dependencies cross, logic seems alive.

Graphs are the map for that territory.

`stzGraph` turns invisible connections into visible order. You learn to think not in lines of code, but in flows of influence, chains of reasoning, cycles of cause and effect.

The 7 features transform it from visualization into a **reasoning engine**: independent branches, criticality analysis, constraint validation, rich querying, inference, temporal tracking, and format interoperability.

From the first node to the final export, you've learned to **think like a graph**.