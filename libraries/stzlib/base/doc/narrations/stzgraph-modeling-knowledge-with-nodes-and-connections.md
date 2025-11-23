# stzGraph — Modeling Knowledge Through Structure

Software systems today are built on relationships: microservices depend on one another, workflows move across steps, configurations link modules to environments, and business rules weave threads between entities that must interact correctly.
Behind all these patterns lies a simple truth:

> **Every interesting system is a graph.**

**stzGraph** was created with this perspective in mind.
It transforms nodes and edges into a practical language for modeling architectures, pipelines, taxonomies, dependency maps, and rule-driven knowledge graphs — all within the simplicity of Ring.

This article takes you on a guided exploration of stzGraph, relying solely on the real examples found in its test suite.
The goal is not to list features, but to **build understanding**.

---

# 1. A Graph Begins With Meaning

Before writing code, stzGraph asks a simple question:

> *What does each piece of your system represent, and how does it relate to the others?*

Nodes carry meaning.
Edges express relationships.
Labels make the graph readable.
Properties enrich nodes with context.
Rules turn the graph into an intelligent system.

Let’s start with the simplest possible example: three concepts forming a linear flow.

```ring
oGraph = new stzGraph("SimpleGraph")
oGraph {
    AddNodeXT("n1", "Node 1")
    AddNodeXT("n2", "Node 2")
    AddNodeXT("n3", "Node 3")

    Connect("n1", "n2")
    Connect("n2", "n3")

    Show()
}
```

Output:

```
╭────────╮        
│ Node 1 │        
╰────────╯        
     |            
     v            
╭──────────╮       
│ !Node 2! │       
╰──────────╯       
     |            
     v            
╭────────╮        
│ Node 3 │        
╰────────╯  
```

This is the philosophy of stzGraph:
**you describe what exists, and the tool turns it into something humans and machines can understand.**


# 2. Building Intuition: Presence, Reachability & Flow

Once your graph exists, natural questions arise:

* Is a certain node part of the system?
* Is a relationship defined?
* Can I reach component C if I start from A?
* Which exact paths allow movement or data flow?

These questions match the way engineers reason about systems.

```ring
HasNode("a")         #--> TRUE  
EdgeExists("a","b")  #--> TRUE  
PathExists("start","end") #--> TRUE
```

To know *how* execution flows, you inspect all possible paths:

```ring
FindAllPaths("start","end")
#--> [ ["start","middle","end"] ]
```

A graph becomes a navigable space — not merely a data structure.


# 3. Neighborhoods and Influence

Understanding who influences whom is critical for debugging and architecture design.

```ring
Neighbors("hub")   #--> ["n3"]
Incoming("hub")    #--> ["n1","n2"]
```

This immediately reveals:

* which nodes depend on **hub** (incoming),
* which nodes **hub** influences (outgoing).

This is lightweight **dependency analysis**, embedded directly inside the graph.


# 4. Nodes as Actors With Properties

A graph becomes powerful when nodes carry semantic meaning.
stzGraph lets you attach metadata easily:

```ring
AddNodeXTT("n1","Node 1", [:priority=10, :status="active"])
NodeProperty("n1","priority")   #--> 10

SetNodeProperty("n1","owner","alice")
NodeProperty("n1","owner")      #--> "alice"
```

You can also inspect properties:

```ring
Properties()
#--> ["priority","status","owner"]
```

Your graph now describes not just relationships, but **context** and **intent**.


# 5. Evolving the Graph: Insert, Remove, Replace, Merge

Systems change; dependencies evolve.
stzGraph mirrors these realities by offering direct structural operations:

* Insert nodes before/after others
* Replace a node while preserving edges
* Duplicate nodes (with or without edges)
* Merge nodes into clusters
* Remove nodes safely

Example: inserting a new step into an existing chain:

```ring
InsertNodeBefore("n3","n2","N2")
```

Or merging two server nodes:

```ring
MergeNodes(["s1","s2"],"cluster","Cluster")
```

These operations make structural modifications **safe, expressive, and readable**.


# 6. Asking Smarter Questions: Query by Properties & Tags

Filtering nodes by attributes is crucial for architecture analysis:

```ring
NodesWithProperty("env") 
#--> ["n1","n2","n3"]

NodesWithPropertyXT("env","prod")
#--> ["n1","n3"]
```

Tags add an orthogonal dimension:

```ring
NodesWithAnyTag(["critical","monitoring"])
#--> ["n1","n3"]

NodesWithAllTags(["critical","production"])
#--> ["n1"]
```

Your graph becomes a basic **knowledge database** with expressive querying.


# 7. Structural Insight: Cycles, Bottlenecks & Metrics

Graph theory reveals structural truths that documentation often hides.

### Cycles

```ring
CyclicDependencies()
#--> TRUE
```

### Bottlenecks

```ring
BottleneckNodes()
#--> ["hub"]
```

### Metrics

```ring
NodeDensity()    #--> 50
LongestPath()    #--> 2
```

These insights are critical for scalability, stability, and dependency management.


# 8. Rules: Turning Structure Into Intelligence

The rule system is one of stzGraph’s defining features.
Rules let the graph validate itself, infer new edges, or enrich nodes.

### Validation example

```ring
When(:IsApproved, :Equals=FALSE)
SetInvalid()
AddViolation("Requires approval")
```

Output:

```
isvalid = FALSE
violation = "Requires approval"
```

### Inference example

```ring
WhenPathExists(:FromNode="a", :ToNode="c")
AddEdge("a","c")
```

This transforms:

```
EdgeCount() #--> 3
```

Rules turn stzGraph into a **semantic engine** rather than a static structure.


# 9. Understanding What Happened: Rule Analysis

After applying rules, stzGraph explains:

```ring
NodesAffectedByRules()
#--> ["n1","n2"]

RulesApplied()[:summary]
#--> "2 rule(s) defined, 2 element(s) affected"
```

This supports traceability and trust.


# 10. Sharing the Graph: DOT, JSON & YAML

stzGraph exports your graph in formats ready for visualization or integration.

### DOT

```
digraph ExportTest {
  a [label="A"];
  b [label="B"];
  a -> b;
}
```

### JSON

```json
{
  "id": "JSONTest",
  "nodes": [...],
  "edges": [...],
  "metrics": {
    "nodecount": 2,
    "edgecount": 1,
    "density": 50,
    "longestpath": 1,
    "hascycles": 0
  }
}
```

### YAML

Readable and configuration-friendly.


# 11. Visual Thinking: ASCII Graphs

For quick inspection or debugging:

```
╭───────╮
│ Start │
╰───────╯
   |
   v
╭──────────╮
│ !Middle! │
╰──────────╯
```

Or:

```
╭───────╮     ╭──────────╮     ╭─────╮
│ Start │---->│ !Middle! │---->│ End │
╰───────╯     ╰──────────╯     ╰─────╯
```

A fast, zero-dependency way to understand topology.

>**NOTE:** A more sophisticated visualisation system is provided in the stzDiagram class that is based on stzGraph. More on this in the dedicated article to stzDiagram.

# 12. EXPLAIN: A Snapshot of the Graph

The Explain() command gives a concise diagnostic:

```
"Graph: ExplainTest"
"Nodes: 3 | Edges: 3"
"WARNING: Circular dependencies detected"
"Longest path: 2 hops"
```

Perfect for debugging or reporting.


# 13. stzGraph at the Core of Larger Constructs

stzGraph is not only a standalone utility — it is the **structural foundation** of several advanced components in the Softanza ecosystem.

### stzDiagram — The Visual Representation Layer

Builds on stzGraph to provide:

* automatic layouts,
* shapes, connectors, annotations,
* diagrams for architecture, workflows, or states.

### stzWorkflow — Executable Graphs

Workflows are graphs:

* nodes = steps,
* edges = transitions,
* properties = parameters or conditions.

stzWorkflow uses stzGraph as the structural backbone of process execution.

### stzComputableGraph — Reasoning on Graphs

Enables:

* property propagation,
* dependency evaluation,
* semantic inference,
* “what-if” analysis.

This elevates graphs into **computable knowledge structures**.


# 14. The Softanza Advantage

Graphs exist in every ecosystem — NetworkX in Python, cytoscape.js in JavaScript, Boost Graph Library in C++, and many others.
Each is powerful in its domain.
**Softanza takes a different path**, treating graphs not as mathematical objects but as tools for *understanding systems*.

The comparison below highlights this philosophy.


## Comparative Grid — stzGraph vs. Typical Graph Frameworks

| Dimension                      | **stzGraph**                                | Typical Graph Libraries                          |
| ------------------------------ | ------------------------------------------- | ------------------------------------------------ |
| **Design philosophy**          | Graphs as narratives about systems          | Graphs as adjacency lists / algorithm containers |
| **API vocabulary**             | Human verbs: Add, Connect, Replace, Explain | Technical primitives: add_edge, search, iterate  |
| **Metadata (properties/tags)** | **Native, integrated**                      | Often external or manually managed               |
| **Semantic features (rules)**  | **Built-in** validation & inference         | Rare or external                                 |
| **Visualization**              | ASCII + DOT + integrated stzDiagram         | External tools needed                            |
| **Workflow modeling**          | **Native** via stzWorkflow                  | Not built-in                                     |
| **Computable graphs**          | stzComputableGraph for inference            | Usually absent                                   |
| **Learning curve**             | Very low — expressive & narrative           | Often algorithmic and steep                      |
| **Ecosystem integration**      | Part of a unified Softanza toolkit          | Usually standalone                               |
| **Primary goal**               | Understanding, modeling, and reasoning      | Data structure manipulation                      |


### Why This Matters

stzGraph is more than a graph library:
it is the **unifying abstraction** behind structure, meaning, visualization, workflow, and reasoning in the Softanza ecosystem.

It turns graphs into a **thinking tool**.

---

# Conclusion — A Graph as a Model of Thought

The true value of stzGraph is not in the number of methods it provides, but in the philosophy behind them:

* if something represents a concept → it is a node;
* if two concepts relate → they are connected;
* if meaning is needed → properties add it;
* if structure must be understood → queries reveal it;
* if reasoning is required → rules enforce it;
* if systems evolve → mutations support change;
* if clarity is needed → visualization helps;
* if insight is needed → Explain() summarizes it.

stzGraph is where **code meets architecture**,
where **relationships become language**,
and where **systems can describe themselves**.

It is not just a data structure —
it is a descriptive tool for engineers who think in terms of flows, dependencies, and meaning.