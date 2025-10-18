# stzGraph: The Art of Connected Thinking

## Philosophy — Structure and Separation

`stzGraph` embodies Softanza's core principle: **separate structure from semantics**. It handles pure connectivity—paths, cycles, bottlenecks—while domain layers (stzEntity, stzDiagram) add meaning. This yields clarity: algorithms stay independent, extensions compose cleanly.

A graph maps relationships. Whether modeling workflows, semantic networks, or system dependencies, `stzGraph` turns complexity into elegance through APIs that read like prose.

---

## Quick Start

Create a graph, visualize it, query it:

```ring
oGraph = new stzGraph("MyFlow")
oGraph {
    AddNode(:@start, "Start")
    AddNode(:@middle, "Process")
    AddNode(:@end, "End")
    
    AddEdge(:@start, :@middle, "flows")
    AddEdge(:@middle, :@end, "completes")
    
    Show()  # See it immediately
}

? oGraph.NodeCount()        #--> 3
? oGraph.PathExists(:@start, :@end)  #--> TRUE
```

For richer nodes with metadata:

```ring
oGraph.AddNodeXT(:@step, "Validate", :Process, [
    "priority" = "high",
    "owner" = "team-a"
])
```

---

## Problem → Solution Map

| Your Question | Method | Returns |
|---|---|---|
| Can A reach B? | `PathExists(:@a, :@b)` | TRUE / FALSE |
| All routes from A to B? | `FindAllPaths(:@a, :@b)` | Array of paths |
| Any circular dependencies? | `CyclicDependencies()` | TRUE / FALSE |
| All nodes reachable from X? | `ReachableFrom(:@x)` | Array of nodes |
| Critical hub nodes? | `BottleneckNodes()` | Array of node IDs |
| System coupling strength? | `NodeDensity()` | Percentage (0-100) |
| Longest process chain? | `LongestPath()` | Edge count |
| Direct outgoing edges? | `NeighborsOf(:@x)` | Array of nodes |
| Direct incoming edges? | `IncomingTo(:@x)` | Array of nodes |
| Graph insights? | `Explain()` | Structured analysis |
| Node/edge exist? | `NodeExists(:@id)`, `EdgeExists(:@from, :@to)` | TRUE / FALSE |

**Visualization methods:**
- `Show()` / `ShowV()` — vertical layout
- `ShowH()` / `ShowHorizontal()` — horizontal layout  
- `ShowWithLegend()` — annotate bottlenecks and markers

---

## Connectivity — Does the Path Exist?

**Problem:** Verify your system can reach its goal.

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

Visualization:

```
  ╭───────────────────╮  
  │ Request Submitted │  
  ╰───────────────────╯  
            |            
         submit          
            |            
            v            
   ╭────────────────╮    
   │ Manager Review │    
   ╰────────────────╯    
            |            
        escalate         
            |            
            v            
  ╭───────────────────╮  
  │ Director Approval │  
  ╰───────────────────╯  
            |            
        finalize         
            |            
            v            
      ╭──────────╮       
      │ Approved │       
      ╰──────────╯
```

---

## Alternative Routes — Finding All Paths

**Problem:** Understand redundancy and convergence points.

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
    
    aPaths = FindAllPaths(:@start, :@end)
    ? len(aPaths)  #--> 2
    
    ShowWithLegend()
}
```

Visualization:

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

`Explain()` validates health:

```ring
? @@NL( oProcess.Explain() )
#--> [
    ["general", ["Graph: MultiPathProcess", "Nodes: 4 | Edges: 4"]],
    ["bottlenecks", ["No bottlenecks (average degree = 2)"]],
    ["cycles", ["No cycles - acyclic graph (DAG)"]],
    ["metrics", ["Density: 33.33% (moderate)", "Longest path: 3 hops"]]
]
```

---

## Cyclic Dependencies — Detect Infinite Loops

**Problem:** Find circular dependencies that break logic.

```ring
oCyclic = new stzGraph("CyclicWorkflow")
oCyclic {
    AddNode(:@p1, "Process 1")
    AddNode(:@p2, "Process 2")
    AddNode(:@p3, "Process 3")
    
    AddEdge(:@p1, :@p2, "next")
    AddEdge(:@p2, :@p3, "next")
    AddEdge(:@p3, :@p1, "loop")
    
    ? oCyclic.CyclicDependencies()  #--> TRUE
}
```

Vertical view via `Show()`:

```
      ╭───────────╮      
      │ Process 1 │      
      ╰───────────╯      
            |            
          next           
            |            
            v            
      ╭───────────╮      
      │ Process 2 │      
      ╰───────────╯      
            |            
          next           
            |            
            v            
      ╭───────────╮      
      │ Process 3 │      
      ╰───────────╯      
            |            
      <CYCLE: loop>   
            |                  ↑ 
            ╰──> [Process 1] ──╯
```

Horizontal view via `ShowH()`:

```
╭───────────╮         ╭───────────╮         ╭───────────╮
│ Process 1 │--next-->│ Process 2 │--next-->│ Process 3 │
╰───────────╯         ╰───────────╯         ╰───────────╯
      ↑                                           |
      ╰────────────────────loop───────────────────╯
```

---

## Reachability — Measure Scope and Influence

**Problem:** Quantify how many nodes depend on a given node.

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
    
    ? @@(oHierarchy.ReachableFrom(:@person))
    #--> [@person, @employee, @manager]
    
    ShowWithLegend()
}
```

Visualization:

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

Legend:

╭─────────┬────────────────────────────────────╮
│  Sign   │              Meaning               │
├─────────┼────────────────────────────────────┤
│ !label! │ High connectivity hub (bottleneck) │
╰─────────┴────────────────────────────────────╯
```

`Explain()` shows cascading dependencies:

```ring
? @@NL( oHierarchy.Explain() )
#--> [
    ["general", ["Graph: TypeSystem", "Nodes: 4 | Edges: 3"]],
    ["bottlenecks", ["Bottleneck nodes: @person, @employee"]],
    ["cycles", ["No cycles - acyclic graph (DAG)"]],
    ["metrics", ["Density: 25% (moderate)", "Longest path: 3 hops"]]
]
```

Person and Employee are bottlenecks—changes propagate downstream.

---

## Bottleneck Nodes — Identify Critical Hubs

**Problem:** Find single points of failure where paths converge.

```ring
oGraph = new stzGraph("BottleneckTest")

oGraph.AddNode(:@1, "A")
oGraph.AddNode(:@2, "B")
oGraph.AddNode(:@3, "C")
oGraph.AddNode(:@hub, "Hub")

oGraph.AddEdge(:@1, :@hub, "")
oGraph.AddEdge(:@2, :@hub, "")
oGraph.AddEdge(:@3, :@hub, "")
oGraph.AddEdge(:@hub, :@1, "")

? @@( oGraph.BottleneckNodes() )
#--> [ "@hub" ]

oGraph.Show()
```

Visualization:

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
      <CYCLE:  >   
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
      <CYCLE:  >   
            |              ↑
            ╰──> [!Hub!] ──╯
```

`Explain()` reveals the risk:

```ring
? @@NL( oGraph.Explain() )
#--> [
    ["general", ["Graph: BottleneckTest", "Nodes: 4 | Edges: 4"]],
    ["bottlenecks", ["Bottleneck nodes: @hub", "@hub: degree 4 (above average)"]],
    ["cycles", ["WARNING: Circular dependencies detected"]],
    ["metrics", ["Density: 33.33% (moderate)", "Longest path: 2 hops"]]
]
```

Hub's degree 4 = all paths funnel through it. Critical failure point.

---

## Complexity Metrics — Assess Architecture

**Problem:** Evaluate system coupling and sequential depth.

```ring
? oGraph.NodeDensity()   # 0-100: tightness of connections
? oGraph.LongestPath()   # Maximum hops in any path
```

- High density (near 100): tightly coupled, brittle
- Low density (near 0): modular, loose
- Long paths: deep chains, potential latency
- Short paths: simple flows, fast completion

---

## Direct Dependencies — Neighborhoods

**Problem:** Understand immediate neighbors without transitive closure.

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

Use for local debugging, unit testing, or modular analysis.

---

## Core Operations

Create and modify:

```ring
oGraph.AddNode(:@new, "Label")
oGraph.RemoveNode(:@old)
oGraph.AddEdge(:@from, :@to, "label")
oGraph.RemoveEdge(:@from, :@to)
```

Query existence:

```ring
? oGraph.NodeCount()
? oGraph.EdgeCount()
? oGraph.NodeExists(:@id)
? oGraph.EdgeExists(:@from, :@to)
```

---

## Advanced Features

### Graph Introspection

`Explain()` provides structured analysis of bottlenecks, cycles, metrics, and general stats. Use for validation, reporting, or automated checks.

### Visualization Options

- `Show()` / `ShowV()` — vertical ASCII
- `ShowH()` / `ShowHorizontal()` — horizontal ASCII
- `ShowWithLegend()` — annotate hubs and path separators

Markers:
- `!label!` — bottleneck node
- `////` — path separator (multiple routes)
- `<CYCLE: label>` — feedback loop
- `[Node]` — part of cycle path

---

## Extension Points

`stzGraph` seeds higher-level frameworks:

- **stzDiagram** — workflow visualization and layout
- **stzEntity / stzRelation** — semantic and knowledge graphs
- **Custom domains** — governance, analytics, simulation

---

## Epilogue

Structure stays pure. Semantics remain modular. Complexity becomes elegant.

`stzGraph` is both foundation and framework—the language of connectivity in SoftanzaLib.