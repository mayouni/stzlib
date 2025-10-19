# stzGraph: A Design Foundation for Connected Domains

## Introduction

`stzGraph` is not merely a data structure. It is the **architectural foundation** upon which Softanza builds an entire ecosystem of domain-specific reasoning systems.

In computer science, we often solve problems by choosing appropriate containers: arrays for sequences, trees for hierarchies, tables for relations. But there is a container more fundamental than all of these—one that captures how things connect, influence, and relate.

That container is the graph.

What makes `stzGraph` strategic is not that it implements graph algorithms—many libraries do that. What makes it strategic is that it embodies a **design philosophy**: *separate structure from semantics*. The graph cares only about topology. The domain cares only about meaning. Neither needs to know how the other works.

This separation enables an ecosystem where:

- A **code analyzer** uses stzGraph to represent function calls
- A **workflow engine** uses stzGraph to represent task sequences
- A **semantic reasoner** uses stzGraph to represent entities and their relationships
- A **natural language processor** uses stzGraph to coordinate lexical, grammatical, and semantic layers
- A **database designer** uses stzGraph to represent tables and their dependencies
- All of them speak the same language: nodes, edges, paths, reachability, cycles

This article explores how stzGraph serves as the conceptual spine of this ecosystem, and how each specialized class extends it to answer domain-specific questions while contributing universal patterns back to the core.

---

## Part 1: The Core Insight — All Domains Are Graphs

### Why Graphs?

Consider a database schema. It has tables (entities) and foreign keys (relationships). That's a graph.

Consider a program. It has functions (entities) and calls (relationships). That's a graph.

Consider an organization. It has people (entities) and reporting lines (relationships). That's a graph.

Consider a sentence. It has words (entities) and grammatical relationships (relationships). That's a graph.

The pattern is universal: **any system with multiple interacting parts is, fundamentally, a graph**.

The question is not whether to use graphs, but how to make them accessible, queryable, and reasoned about in ways that feel natural to each domain.

### The Design Philosophy: Structure ≠ Semantics

`stzGraph` rests on a single principle: **a graph has no opinion about what its nodes and edges mean**.

A node can represent:
- A function, a task, a person, a word, a state, a condition, a table, a concept, a decision

An edge can represent:
- A function call, a workflow transition, a supervisory relationship, a grammatical link, a state change, a logical branch, a foreign key, a synonym

`stzGraph` handles the structure—the topology, the paths, the connectivity. It asks:
- Can A reach B?
- What paths exist from A to B?
- Are there cycles?
- Which nodes are critical?
- Which parts can evolve independently?

Each domain layer (*Code*, *Workflow*, *Organization*, *Language*) adds the semantic labels and domain-specific reasoning. It asks:
- What does this path mean in my domain?
- What constraints apply to valid structures?
- What optimizations are possible?

This separation is what makes the architecture extensible. A new domain doesn't reimplement graph algorithms—it inherits them. It adds only what is unique to itself.

---

## Part 2: The Layered Ecosystem

### The Pattern: Domain Classes as Semantic Specializations

Each Softanza domain class follows the same pattern:

1. **Inherit from stzGraph** — Get all structural operations for free
2. **Define node types** — What kinds of things exist in this domain?
3. **Define edge types** — What kinds of relationships?
4. **Add domain methods** — What insights are unique to this domain?
5. **Export insights to core** — What patterns serve all domains?

This pattern scales. As new domains are added, the core grows richer without becoming cluttered.

---

### stzCode: Programs as Call Graphs

When a programmer thinks about their codebase, they think in terms of functions, modules, and calls.

`stzCode` represents this directly:
- **Nodes** = functions, modules, classes
- **Edges** = calls, imports, dependencies

From this simple structure, powerful questions emerge:

```ring
oCode = new stzCode("MyApplication")
oCode {
    AddNode(:@main, "main()", :function)
    AddNode(:@validate, "validate()", :function)
    AddNode(:@process, "process()", :function)
    
    AddEdge(:@main, :@validate, "calls")
    AddEdge(:@validate, :@process, "calls")
    
    ? DeadCode()                      #--> Functions never called
    ? CyclicCalls()                   #--> Infinite recursion risk
    ? ParallelizableBranches()        #--> Functions with no data dependency
    ? CriticalPath()                  #--> Longest sequential chain
}
```

The `DeadCode()` and `CyclicCalls()` methods are domain-specific. But underneath, they use stzGraph's `PathExists()` and `ReachableFrom()` operations.

**Key Insight from stzCode:** The ability to detect *independent branches*—functions that can run in parallel because they don't share state. This pattern will recur in every domain and deserves promotion to core.

---

### stzWorkflow: Processes as Task Sequences

When a business analyst thinks about a process, they think in terms of tasks, handoffs, and branching paths.

`stzWorkflow` represents this:
- **Nodes** = tasks, activities, decisions
- **Edges** = transitions, handoffs, dependencies

```ring
oWorkflow = new stzWorkflow("ApprovalProcess")
oWorkflow {
    AddNode(:@request, "Request Submitted", :task)
    AddNode(:@review, "Under Review", :task)
    AddNode(:@decision, "Approve/Reject?", :decision)
    AddNode(:@approved, "Approved", :task)
    AddNode(:@rejected, "Rejected", :task)
    
    AddEdge(:@request, :@review, "submit")
    AddEdge(:@review, :@decision, "complete")
    AddEdge(:@decision, :@approved, "approve")
    AddEdge(:@decision, :@rejected, "reject")
    
    ? TasksWithoutPredecessor()       #--> Where does the process start?
    ? BottleneckTasks()               #--> Tasks many others depend on
    ? AlternativeRoutes(:@request, :@approved)  #--> Multiple endings?
}
```

Here, the domain is asking: "What are the rules of this process?" The underlying graph operations are identical to stzCode, but the interpretation is completely different.

**Key Insight from stzWorkflow:** Tasks can have multiple successors (branching) and multiple predecessors (convergence). The notion of *bottlenecks*—tasks that many others depend on—applies universally.

---

### stzStateMachine: Automata as State Transitions

When a systems engineer thinks about a protocol or device, they think in terms of states and the events that cause transitions between them.

`stzStateMachine` represents this:
- **Nodes** = states (Running, Paused, Stopped)
- **Edges** = events that trigger state changes

```ring
oStateMachine = new stzStateMachine("MediaPlayer")
oStateMachine {
    AddNode(:@idle, "Idle", :state)
    AddNode(:@playing, "Playing", :state)
    AddNode(:@paused, "Paused", :state)
    
    AddEdge(:@idle, :@playing, "play")
    AddEdge(:@playing, :@paused, "pause")
    AddEdge(:@paused, :@playing, "resume")
    AddEdge(:@playing, :@idle, "stop")
    
    ? IsValidSequence([:@idle, :@playing, :@paused])
      #--> Can this sequence of states be reached?
    
    ? DeadStates()                #--> States with no outgoing transitions
    ? CyclicBehavior()            #--> Can the system loop indefinitely?
}
```

What's interesting here is that the graph is now interpreted as a *state automaton*, not a workflow. The same `PathExists()` and `ReachableFrom()` operations now answer: "What states can the system enter from here?"

**Key Insight from stzStateMachine:** Finite state machines are graphs with constraints—states are mutually exclusive, transitions are atomic. These constraints are valuable to model explicitly.

---

### stzDecisionTree: Logic as Branching Paths

When a data scientist or business rules designer thinks about decision logic, they think in terms of conditions and outcomes.

`stzDecisionTree` represents this:
- **Nodes** = conditions (decisions) and outcomes (results)
- **Edges** = branches based on test results

```ring
oDecision = new stzDecisionTree("LoanApproval")
oDecision {
    AddNode(:@creditCheck, "Credit > 700?", :decision)
    AddNode(:@incomeCheck, "Income > 50k?", :decision)
    AddNode(:@approve, "Approve", :outcome)
    AddNode(:@deny, "Deny", :outcome)
    
    AddEdge(:@creditCheck, :@incomeCheck, "yes")
    AddEdge(:@creditCheck, :@deny, "no")
    AddEdge(:@incomeCheck, :@approve, "yes")
    AddEdge(:@incomeCheck, :@deny, "no")
    
    ? AllOutcomes()           #--> All possible results
    ? DecisionPathTo(:@approve)  #--> What conditions lead here?
    ? RedundantDecisions()    #--> Tests that don't affect outcome
}
```

Again, the same graph structure, different interpretation. Now paths represent *chains of logic*, not workflows or calls.

**Key Insight from stzDecisionTree:** Trees have a notion of depth and balance. Unreachable outcomes suggest errors in logic. These structural properties are worth detecting programmatically.

---

### stzSemanticModel: Knowledge as Entities and Relations

When a knowledge engineer thinks about a domain, they think in terms of entities (things that exist) and the relationships between them.

`stzSemanticModel` inherits from stzGraph and represents:
- **Nodes** = entities (Alice, Bob, the Project)
- **Edges** = semantic relations (manages, reports_to, depends_on)

```ring
oModel = new stzSemanticModel("Organization")
oModel {
    AddNode(:@alice, "Alice", :person, [
        "role" = "CEO",
        "email" = "alice@org.com"
    ])
    
    AddNode(:@bob, "Bob", :person, [
        "role" = "Engineer",
        "email" = "bob@org.com"
    ])
    
    AddNode(:@project, "Project X", :project)
    
    AddEdge(:@alice, :@bob, "manages")
    AddEdge(:@bob, :@project, "works_on")
    
    ? PathExists(:@alice, :@project)  #--> Can alice influence project?
    ? FindAllPaths(:@alice, :@project)  #--> Through which relationships?
    ? InferredRelations()     #--> Transitivity: alice→manages→bob→works_on→project
}
```

Here, the power is in *inference*. If we know alice manages bob, and bob works on project, we can infer that alice influences project. This inference uses graph transitivity—a universal pattern.

**Key Insight from stzSemanticModel:** Domains have implicit relationships that can be inferred from explicit ones. Inference rules themselves should be modeled as graphs (or at least queryable structures).

---

### stzDataModel: Persistence as Table Dependencies

A database designer thinks in terms of tables, columns, and the foreign keys that relate them.

`stzDataModel` represents this:
- **Nodes** = tables
- **Edges** = foreign key relationships

```ring
oDataModel = new stzDataModel("Ecommerce")
oDataModel {
    AddNode(:@users, "users", :table, [
        "columns" = ["id", "name", "email"]
    ])
    
    AddNode(:@orders, "orders", :table, [
        "columns" = ["id", "user_id", "total"]
    ])
    
    AddNode(:@items, "order_items", :table, [
        "columns" = ["id", "order_id", "product_id", "qty"]
    ])
    
    AddEdge(:@orders, :@users, "has_one", [
        "foreign_key" = "user_id"
    ])
    
    AddEdge(:@items, :@orders, "belongs_to", [
        "foreign_key" = "order_id"
    ])
    
    ? PathExists(:@users, :@items)    #--> Can these tables be joined?
    ? JoinPaths(:@users, :@items)     #--> What is the join sequence?
    ? OrphanTables()                  #--> Tables unreachable from entry point
    ? TablesReachable(:@users)        #--> What data is accessible from users?
}
```

The data model is just another graph. The questions it answers are identical to those of workflows or code: reachability, paths, connectivity. But the *meaning* is completely different—now we're asking about data flow and query planning, not execution flow.

**Key Insight from stzDataModel:** Complex queries often require traversing multiple relationships. Detecting these paths programmatically enables query optimization and data lineage analysis.

---

## Part 3: The Multi-Layered Orchestrator — stzNaturalLanguage

### The Problem: Language Has Multiple Dimensions

Natural language is uniquely complex because it operates on multiple levels simultaneously:

1. **Lexical Level** — Individual words and their meanings
2. **Grammatical Level** — How words combine into structures
3. **Semantic Level** — What the utterance *means*

Most NLP systems treat these as sequential steps: tokenize → parse → extract meaning. But this pipeline misses something crucial: each level influences the others. A word's meaning depends on context (grammar). A sentence's structure depends on word senses (lexicon). The meaning depends on both.

What if we modeled each level as a graph, and made them *work together* to understand language?

### Layer 1: stzLexicon — The Conceptual Dictionary

The lexicon is a graph of words and their conceptual relationships.

**Nodes** = words (lexemes)
**Edges** = relationships (synonym, antonym, hypernym, hyponym, related_to)
**Attributes** = part of speech, frequency, semantic field, sentiment

```ring
oLexicon = new stzLexicon("English")
oLexicon {
    # Words as nodes
    AddNode(:@manage, "manage", :verb, [
        "definition" = "to handle or direct",
        "domain" = ["business", "control"],
        "frequency" = "high"
    ])
    
    AddNode(:@oversee, "oversee", :verb, [
        "definition" = "to supervise"
    ])
    
    AddNode(:@direct, "direct", :verb)
    AddNode(:@boss, "boss", :noun, [
        "definition" = "person in charge"
    ])
    
    # Conceptual relationships
    AddEdge(:@manage, :@oversee, "synonym", ["confidence" = 0.9])
    AddEdge(:@manage, :@direct, "related_to", ["confidence" = 0.85])
    AddEdge(:@manage, :@boss, "agent_noun", ["confidence" = 0.7])
    
    # Query the lexicon
    ? SynonymsOf(:@manage)        #--> [:@oversee, :@direct]
    ? HypernymsOf(:@boss)         #--> Higher-level concepts
    ? RelatedWords(:@manage)      #--> Associated terms
}
```

The lexicon is **not** the dictionary of definitions. It is the network of *relationships* between words. It answers: "What words are conceptually close to this one?"

This is crucial because synonyms are not absolute—they depend on context. In a business context, "manage" and "oversee" are very similar. In a medical context, they diverge. The lexicon captures these relationships with confidence scores.

### Layer 2: stzGrammar — The Structural Rules

Grammar is also a graph—two graphs, actually.

**Grammar Graph 1: Syntactic Structure**

Nodes = grammatical categories (S, NP, VP, Det, N, V, Adj)
Edges = composition rules (NP → Det + N, VP → V + NP)

```ring
oSyntax = new stzGrammar("EnglishSyntax")
oSyntax {
    # Grammatical categories as nodes
    AddNode(:@s, "Sentence", :category)
    AddNode(:@np, "Noun Phrase", :category)
    AddNode(:@vp, "Verb Phrase", :category)
    AddNode(:@det, "Determiner", :category)
    AddNode(:@n, "Noun", :category)
    AddNode(:@v, "Verb", :category)
    
    # Composition rules as edges
    # S consists of NP (subject) + VP (predicate)
    AddEdge(:@s, :@np, "subject")
    AddEdge(:@s, :@vp, "predicate")
    
    # NP consists of Det + N
    AddEdge(:@np, :@det, "determiner")
    AddEdge(:@np, :@n, "head")
    
    # VP consists of V + NP
    AddEdge(:@vp, :@v, "verb")
    AddEdge(:@vp, :@np, "object")
    
    # Query: is a valid sentence structure?
    ? CanCompose(:@s)  #--> Can we build an S from these rules?
}
```

This graph represents the *structure* of language. A parse tree is a path through this graph.

**Grammar Graph 2: Transformation Rules**

Natural language allows infinite variations through transformations:
- Active voice → Passive voice
- Declarative → Interrogative
- Affirmative → Negative

```ring
oTransform = new stzGrammar("EnglishTransforms")
oTransform {
    AddNode(:@activeVoice, "Active Voice", :structure)
    AddNode(:@passiveVoice, "Passive Voice", :structure)
    AddNode(:@declarative, "Declarative", :mood)
    AddNode(:@interrogative, "Interrogative", :mood)
    
    # Transformation rules as edges
    AddEdge(:@activeVoice, :@passiveVoice, "voice_transform", [
        "rule" = "NP1 V NP2 → NP2 be V-ed by NP1"
    ])
    
    AddEdge(:@declarative, :@interrogative, "mood_transform", [
        "rule" = "S → V NP S?"
    ])
    
    # Query: what structures can derive from this one?
    ? TransformableFrom(:@activeVoice)  #--> [:@passiveVoice]
}
```

The transformation graph explains why "Alice manages Bob" and "Bob is managed by Alice" mean the same thing—they are connected by a transformation edge.

### Layer 3: stzSemanticModel — The Meaning

Once we've parsed a sentence through lexicon and grammar, we extract its meaning—what it actually *says*.

```ring
oMeaning = new stzSemanticModel("ParsedDocument")
oMeaning {
    # Entities mentioned in the text
    AddNode(:@alice, "Alice", :person)
    AddNode(:@bob, "Bob", :person)
    AddNode(:@manages, "manages", :action)
    
    # Relationships between them
    AddEdge(:@alice, :@manages, "agent")
    AddEdge(:@manages, :@bob, "patient")
    
    # This encodes: Alice (agent) performs the action manages, with Bob (patient)
}
```

The semantic model is the *output* of understanding. It's extracted from the sentence through the lens of grammar and lexicon.

### The Orchestrator: stzNaturalLanguage

Now we connect these three layers into a coherent system. `stzNaturalLanguage` is the **orchestrator**—it coordinates lexicon, grammar, and semantics to transform raw text into structured meaning.

```ring
oNLP = new stzNaturalLanguage("DocumentAnalysis")

# Register the three layers
oNLP.SetLexicon(oLexicon)         # Word/concept graph
oNLP.SetGrammar(oSyntax)          # Structural rules
oNLP.SetSemanticModel(oMeaning)   # Meaning repository

# Parse sentences: orchestrator runs them through all layers
aTexts = [
    "Alice manages Bob.",
    "Bob is managed by Alice.",
    "Bob reports to Alice."
]

aTexts.each { |text|
    oNLP.ParseSentence(text)
}

# Query the semantic result
? oNLP.NodeCount()                      #--> Semantic nodes extracted
? oNLP.PathExists(:@alice, :@bob)      #--> Relationship exists?
? oNLP.FindAllPaths(:@alice, :@bob)    #--> Multiple ways they relate?

# Inspect individual layers
oLex = oNLP.GetLexicon()
? oLex.SynonymsOf(:@manage)             #--> What are alternatives?

oGram = oNLP.GetGrammar()
? oGram.ParseTree("Alice manages Bob.") #--> Structure

oSem = oNLP.GetSemanticModel()
? oSem.Explain()                        #--> Facts extracted
```

### How the Layers Collaborate: A Deep Example

**Sentence:** "The CEO, who manages the team, reports to the board."

**Step 1: Lexical Analysis**
- Lexicon recognizes: CEO, manage, team, report, board
- Lexicon finds synonymies: manage ↔ oversee, team ↔ group
- Lexicon identifies: CEO is related to authority, report is related to hierarchy

**Step 2: Grammatical Analysis**
- Syntax parser identifies: subject (The CEO), verb (reports), object (to the board)
- Parser detects: appositive phrase (who manages the team)
- Parser recognizes: complex sentence with embedded clause

**Step 3: Semantic Extraction**
- Creates nodes: @ceo_entity, @team_entity, @board_entity, @manages_event, @reports_event
- Creates edges: @ceo—agent→@manages, @manages—patient→@team, @ceo—agent→@reports, @reports—recipient→@board
- **Inference**: Since @ceo manages @team and @ceo reports to @board, we can infer a hierarchy

**Step 4: Disambiguation**
- Orchestrator uses lexicon + grammar to resolve: "CEO" and "who" refer to the same entity
- Uses semantic model to confirm: the entity acts as agent in both manages and reports

**Result: Unified Semantic Graph**

```
        @board
          ↑
     reports_to
          |
        @ceo ←──manages──→ @team
```

All three sentences ("Alice manages Bob", "Bob is managed by Alice", "Bob reports to Alice") create the same semantic graph, just approached from different angles. The orchestrator recognizes this through:
- Lexical synonymies
- Grammatical transformations
- Semantic equivalence

### Why This Architecture Is Powerful

1. **Modularity** — Each layer can be tested, improved, or replaced independently. Upgrade the lexicon without touching grammar.

2. **Reusability** — The lexicon works for word games, sentiment analysis, and domain-specific terminology. The grammar works for syntax highlighting and code generation. The semantics works for fact checking and knowledge bases.

3. **Extensibility** — Add a new language by providing new lexicon and grammar. Add a new domain by extending the semantic model. Both use the same graph framework.

4. **Explainability** — Users can see exactly how understanding emerged:
   - Which lexical relationships were used?
   - Which grammar rules applied?
   - What semantic entities were created?
   - Where might ambiguity remain?

5. **Robustness** — When one layer is uncertain, others can help resolve it. If two parse trees are possible, semantic constraints can rule one out.

---

## Part 4: Universal Patterns and Core Enhancement

### Patterns That Emerge Across Domains

By examining Code, Workflow, StateMachine, DecisionTree, SemanticModel, DataModel, and NaturalLanguage, we discover patterns that serve all domains:

#### 1. Independence and Parallelization

Every domain has parallel structures:
- **Code:** Functions with no shared state can run concurrently
- **Workflow:** Tasks with no data dependencies can execute in parallel
- **Semantics:** Unrelated facts can be reasoned about independently
- **Language:** Unrelated clauses can be processed in parallel

These are detected by finding **node-disjoint paths**—paths that don't share nodes.

**Promoted to core:**

```ring
oGraph.ParallelizableBranches()    #--> Paths with no shared nodes
oGraph.DependencyFreeNodes()       #--> Nodes with no predecessors
```

#### 2. Criticality and Impact

Every system has bottlenecks:
- **Code:** Functions called from many places
- **Workflow:** Tasks many others depend on
- **Organization:** People through whom communication flows
- **Database:** Tables central to many queries

These are detected by measuring **node degree** (in + out connections).

**Promoted to core:**

```ring
oGraph.ImpactOf(:@node)      #--> How many downstream nodes depend on this?
oGraph.FailureScope(:@node)  #--> What breaks if this node fails?
```

#### 3. Constraints and Validation

Every domain has rules about valid structures:
- **Code:** No circular calls
- **StateMachine:** Valid state sequences
- **Workflow:** Can't skip mandatory steps
- **Database:** Foreign keys must reference valid tables

**Promoted to core:**

```ring
oGraph.AddConstraint(:name, :rule)
oGraph.ValidateConstraints()
oGraph.ConstraintViolations()
```

#### 4. Inference and Implicit Knowledge

Every domain has implicit relationships that can be derived:
- **Code:** If A calls B and B calls C, then A can affect C
- **Semantics:** If Alice manages Bob and Bob works on Project X, Alice influences Project X
- **Language:** If word1 is a synonym of word2, and word2 relates to word3, then word1 is related to word3
- **Database:** If table A joins to B via foreign key, and B joins to C, then the join path exists

These use **graph transitivity**—inferring edges from paths.

**Promoted to core:**

```ring
oGraph.AddInferenceRule(:name, :rule)
oGraph.ApplyInference()
oGraph.InferredEdges()
```

#### 5. Rich Querying

Every domain needs flexible ways to ask structural questions that combine multiple conditions.

**Promoted to core:**

```ring
oGraph.Query(:pattern)                    #--> "Find all nodes of type X connected to type Y"
oGraph.FindNodesWhere(:predicate)         #--> Filter by custom condition
oGraph.FindPathsMatching(:pattern)        #--> "Find paths where edge is type X and Y"
```

#### 6. Temporal Evolution

Systems change. Capturing snapshots and changes enables auditing and analysis.

**Promoted to core:**

```ring
oGraph.Snapshot(:name)
oGraph.RestoreSnapshot(:name)
oGraph.ChangesSince(:snapshot)
```

#### 7. Export and Interoperability

Each domain has standard formats:
- **Code:** Call graphs for profilers
- **Workflow:** BPMN for business process notation
- **Database:** SQL schemas
- **Semantics:** OWL, RDF
- **Language:** Parse trees, RDF triples

**Promoted to core:**

```ring
oGraph.ExportDOT()
oGraph.ExportJSON()
oGraph.ExportYAML()
oGraph.RegisterExporter(:name, :callback)
```

---

You're absolutely right. Let me provide the complete continuation from where the ASCII diagram was interrupted:

---

## Part 5: The Integration Challenge — Making Layers Work Together

### Why Integration Matters

Consider a real scenario: a bank designing a new loan approval process.

The business analyst designs a workflow (stzWorkflow). The data architect designs a schema (stzDataModel). The compliance officer specifies decision rules (stzDecisionTree). The requirements are documented in natural language (stzNaturalLanguage).

Without a unified framework, these artifacts drift apart:
- The workflow mentions a "credit check"—but the database has no credit score column
- The decision tree says "approve if score > 700"—but the workflow doesn't call the credit check first
- The natural language requirements say "always verify identity"—but nobody translated that into the workflow or database

Each domain solved its own problem perfectly. But they didn't solve the *system* problem.

### stzDomainLanguage: The Meta-DSL

This is where `stzDomainLanguage` becomes crucial. It provides a framework for designing **DSLs for each domain** while maintaining coherence across all of them.

Ring's declarative syntax—the ability to define objects with braces notation—is uniquely powerful here:

```ring
# A DSL for defining relationships between domains
oSystemDSL = new stzDomainLanguage("LoanApprovalSystem")

# Define domain types
oSystemDSL {
    DefineNodeType(:workflow_task, [
        "name" = :string,
        "description" = :string,
        "dataModel" = :reference     # Links to data model
    ])
    
    DefineNodeType(:database_table, [
        "name" = :string,
        "columns" = :array
    ])
    
    DefineEdgeType(:accesses, [
        "source" = :workflow_task,
        "target" = :database_table
    ])
    
    DefineEdgeType(:decides, [
        "source" = :workflow_task,
        "target" = :decision_node
    ])
}

# Now users write the system in the DSL
oSystem = new SystemBlock {
    workflow_task("credit_check") {
        description = "Verify applicant credit score"
        accesses("credit_scores_table")
    }
    
    database_table("credit_scores") {
        columns = ["applicant_id", "score", "updated_at"]
    }
    
    decision_node("score_acceptable") {
        condition = "score > 700"
    }
    
    workflow_task("credit_check").decides("score_acceptable")
}

# Extract and validate across all domains
oIntegration = new stzIntegrationModel("LoanSystem")
oIntegration.ImportFromDSL(oSystem)

# Now we can ask cross-domain questions:
? oIntegration.DataAccessedButNotRead()    
  #--> Tables declared but never used in workflow

? oIntegration.DecisionWithoutData()
  #--> Decisions that reference data not available to them

? oIntegration.UnderspecifiedTasks()
  #--> Workflow tasks without corresponding data or decisions

? oIntegration.Explain()
  #--> Complete system coherence report
```

This is powerful because:

1. **Users write naturally** — The DSL is declarative, just like normal Ring code
2. **Relationships are explicit** — Connections between workflow, database, decisions are visible
3. **Validation is automatic** — The system checks for inconsistencies across domains
4. **Visualization is unified** — A single graph can show all domains and their relationships

### The Integration Graph

`stzIntegrationModel` is itself a graph that contains multiple sub-graphs:

```
┌──────────────────────────────────────────────────────────────┐
│      stzIntegrationModel (Super-Graph)                       │
│                                                               │
│  ┌─────────────────┐  ┌─────────────────┐  ┌──────────────┐ │
│  │  stzWorkflow    │  │  stzDataModel   │  │stzDecisionT. │ │
│  │                 │  │                 │  │              │ │
│  │  task1 ──→ t2   │  │  users ──→ ord. │  │  cond1──→o1  │ │
│  │   │      │      │  │   │      │     │  │   │      │    │ │
│  │  task3   task4  │  │ items   orders │  │  cond2  cond3 │ │
│  └─────────────────┘  └─────────────────┘  └──────────────┘ │
│         │                     │                    │         │
│         └─────────────────────┼────────────────────┘         │
│         Cross-domain edges (accesses, decides, etc)          │
│                                                               │
└──────────────────────────────────────────────────────────────┘
```

The integration graph has:

**Sub-graphs (domain-specific):**
- Workflow graph showing task flow
- Data model graph showing table relationships
- Decision tree graph showing condition logic
- Semantic model graph showing entities and relationships

**Cross-domain edges:**
- `task.accesses(table)` — workflow tasks that read/write data
- `task.decides(condition)` — workflow tasks that trigger decisions
- `condition.requires(column)` — decisions that need specific data
- `entity.storedIn(table)` — semantic entities mapped to storage

**Methods for Integration Model:**

```ring
oIntegration.DataAccessedButNotDeclared()   
  #--> Workflow uses undefined tables

oIntegration.DataDeclaredButNotAccessed()   
  #--> Tables never referenced in any workflow

oIntegration.DecisionWithoutData()          
  #--> Decisions that reference columns not in accessed tables

oIntegration.TasksWithoutDecisions()        
  #--> Workflow branches not handled by decision logic

oIntegration.AmbiguousEdges()               
  #--> Dependencies unclear or contradictory

oIntegration.CrossDomainPaths()             
  #--> Trace a request through all domains
  #--> Example: task → data → decision → outcome

oIntegration.FindInconsistencies()
  #--> Natural language says X, but workflow/data disagree

oIntegration.GenerateDocumentation()
  #--> Create specification from integrated model

oIntegration.Explain()                      
  #--> Comprehensive system coherence report
```

**Real-World Example:**

```ring
oIntegration.CrossDomainPaths()
  #--> Returns paths showing complete flow:
  #    "credit_check" (workflow)
  #      → accesses "credit_scores" (data)
  #      → evaluates "score_acceptable" (decision)
  #      → affects "approval_status" (outcome)
```

This reveals whether the system is internally consistent: does the workflow actually have access to the data the decision needs? Are all workflow states mapped to outcomes?

---

## Part 6: Real-World Scenarios — How It All Comes Together

### Scenario 1: Understanding a Codebase Through Multiple Lenses

A developer joins a large project and needs to understand the codebase quickly.

**Layer 1: Structural Analysis (stzCode)**
```ring
oCode = new stzCode("LargeApp")
oCode.ImportFromSourceTree("./src")

? oCode.DeadCode()                     #--> Unused functions: 47
? oCode.CyclicCalls()                  #--> Circular dependencies: 12
? oCode.BottleneckNodes()              #--> Critical functions: 5
```

**Layer 2: Dependency Analysis**
```ring
oCode.ParallelizableBranches()         #--> Can optimize parallelization
oCode.CriticalPath()                   #--> Longest call chain: 18 hops
```

**Layer 3: Risk Assessment**
```ring
oCritical = oCode.BottleneckNodes()
oCode.FailureScope(:@critical_func)    #--> 342 functions would break if this fails
```

**Result:** The developer has a complete map of the codebase: what's essential, what's unused, where to focus optimization efforts.

---

### Scenario 2: Designing a Microservices Architecture

An architect needs to design service boundaries for a new system.

**Step 1: Extract Domain Entities (stzSemanticModel)**
```ring
oDomain = new stzSemanticModel("EcommerceSystem")
oDomain {
    AddNode(:@user, "User", :entity)
    AddNode(:@product, "Product", :entity)
    AddNode(:@order, "Order", :entity)
    AddNode(:@payment, "Payment", :entity)
    
    AddEdge(:@user, :@order, "creates")
    AddEdge(:@order, :@product, "contains")
    AddEdge(:@order, :@payment, "requires")
}
```

**Step 2: Analyze Coupling (stzGraph operations)**
```ring
? oDomain.NodeDensity()              #--> How tightly coupled are entities?
? oDomain.CommunicationClusters()    #--> Natural groupings?
```

**Step 3: Design Services Based on Independence**
```ring
aServices = [
    ["UserService", [:@user]],
    ["ProductCatalog", [:@product]],
    ["OrderService", [:@order, :@payment]],
    ["PaymentService", [:@payment]]
]

# Validate: do these services minimize coupling?
oCommunication = oDomain.InterServiceCalls(aServices)
? oCommunication.CallCount()           #--> Should be minimized
? oCommunication.CircularDependencies()  #--> Should be zero
```

**Result:** Service boundaries are based on semantic analysis, not guesswork. Coupling is measurable and optimizable.

---

### Scenario 3: Reverse-Engineering Legacy Workflows

A business analyst needs to document a complex, undocumented workflow.

**Step 1: Extract From Observations (stzNaturalLanguage)**
```ring
oNLP = new stzNaturalLanguage("WorkflowExtraction")

aDescriptions = [
    "When a request comes in, it goes to the validator.",
    "If validation passes, it's reviewed by the approver.",
    "The approver can approve or reject.",
    "If approved, it goes to fulfillment.",
    "Fulfillment notifies the requester."
]

aDescriptions.each { |desc|
    oNLP.ParseSentence(desc)
}

# Extract semantic relationships
oExtracted = oNLP.GetSemanticModel()
```

**Step 2: Visualize as Workflow**
```ring
oWorkflow = new stzWorkflow("DocumentedProcess")
oWorkflow.ImportFromSemanticModel(oExtracted)

oWorkflow.ShowWithLegend()  #--> Beautiful ASCII diagram
```

**Step 3: Validate and Question**
```ring
? oWorkflow.DeadStates()           #--> Are there unreachable states?
? oWorkflow.TasksWithoutPredecessor()  #--> What are entry points?
? oWorkflow.AlternativeRoutes()    #--> Multiple paths?
```

**Result:** Natural language descriptions are transformed into queryable workflow graphs. Gaps and inconsistencies are revealed.

---

### Scenario 4: Optimizing a Database Query

An engineer needs to optimize a slow query.

**Step 1: Analyze Schema (stzDataModel)**
```ring
oSchema = new stzDataModel("ProductionDB")
oSchema.ImportFromSQLSchema("schema.sql")
```

**Step 2: Analyze Query (stzQuery — hypothetical)**
```ring
oQuery = new stzQuery(oSchema)
oQuery.ParseSQL("SELECT users.name, orders.total FROM users...")

# What tables are accessed?
aTables = oQuery.TablesAccessed()

# What are the join paths?
aJoins = oQuery.JoinSequence()
```

**Step 3: Optimize**
```ring
# Can we reorder joins for efficiency?
aOptimal = oSchema.OptimalJoinOrder(aTables)

# Are there missing indexes?
aMissingIndexes = oSchema.RecommendedIndexes(aJoins)

# Is there redundancy?
aRedundantColumns = oSchema.UnusedColumns(aJoins)
```

**Result:** Query optimization is data-driven, not guesswork. The schema graph reveals hidden optimization opportunities.

---

## Part 7: Implementation Principles

### Design Rule 1: Inherit from stzGraph, Don't Reimplement

Every domain class should inherit from stzGraph:

```ring
class stzCode from stzGraph
    # Add domain-specific methods
    # Inherit all graph operations
end

class stzWorkflow from stzGraph
    # Add domain-specific methods
    # Inherit all graph operations
end
```

This ensures:
- **Consistency** — All domains use the same API
- **Reusability** — Core improvements benefit all domains
- **Composability** — Domains can work together seamlessly

### Design Rule 2: Nodes and Edges Have Semantics, Graph Has None

```ring
# Good: semantics on nodes/edges, graph is neutral
oGraph.AddNode(:@func, "myFunction()", :function)
oGraph.AddEdge(:@func1, :@func2, "calls")

# Bad: trying to encode semantics in graph operations
oGraph.AddFunctionNode(:@func, "myFunction()")
oGraph.AddCallEdge(:@func1, :@func2)
```

The graph doesn't care what you call things. The domain does. This separation is critical.

### Design Rule 3: Export Patterns to Core

When a domain discovers a useful pattern, promote it:

```ring
# Pattern discovered in stzCode: detection of parallelizable branches
# Useful in stzWorkflow, stzDataModel, stzSemanticModel
# → Promote to stzGraph.ParallelizableBranches()

# Pattern discovered in stzStateMachine: valid sequences
# Useful in stzWorkflow, stzDecisionTree
# → Promote to stzGraph constraint validation
```

Over time, stzGraph becomes richer without losing simplicity. Each addition serves multiple domains.

### Design Rule 4: Multi-Layer Orchestration, Not Single Interpretation

`stzNaturalLanguage` shows the power of layering:

```ring
# Each layer is independent and queryable
oLexicon = oNLP.GetLexicon()
oGrammar = oNLP.GetGrammar()
oSemantics = oNLP.GetSemanticModel()

# Yet they work together to understand
? oNLP.ParseSentence("Complex utterance")
```

This pattern should be applied whenever a domain has internal structure:
- Language (lexical, grammatical, semantic)
- Databases (schema, queries, optimization hints)
- Workflows (tasks, decisions, data flow)

---

## Conclusion: A Unified Reasoning Framework

`stzGraph` is not just a data structure. It is the **conceptual spine** of Softanza's approach to software architecture.

By recognizing that all domains are graphs—from code to workflows to language—we unlock a powerful insight: *all domains can reason about themselves using the same operations.*

The path-finding algorithm that discovers cycles in code also detects circular dependencies in workflows and self-referential concepts in knowledge bases.

The reachability analysis that identifies dead code also finds unreachable states in automata and orphaned tables in databases.

The bottleneck detection that optimizes code also identifies critical tasks in workflows and central figures in organizations.

What emerges is not a collection of disconnected tools, but a **unified reasoning framework** where:

1. **Each domain sees itself as a graph** — code as call graphs, workflows as task sequences, language as multi-layered relationship networks
2. **Each domain defines its own semantics** — what nodes mean, what edges mean, what constraints apply
3. **Each domain inherits universal operations** — paths, cycles, reachability, criticality, inference
4. **Each domain contributes back patterns** — new ways of reasoning that serve all domains

This is the promise of stzGraph: not to replace domain-specific thinking, but to **liberate it** from reimplementing graph fundamentals, allowing each domain to focus on what makes it unique while sharing deep structural insights with all others.

The graph is the canvas. The domain is the painting. Together, they create a coherent ecosystem where structure and semantics work in harmony.

### The Roadmap

As Softanza matures:

1. **Core enhancements** — Implement the universal patterns (parallelization, criticality, constraints, inference, querying, versioning, export)

2. **Domain expansion** — Add new domain classes as needed, each contributing and drawing from core

3. **Cross-domain integration** — Build bridges between domains (code→workflow, schema→datamodel, language→semantics)

4. **Visualization ecosystem** — Extend stzDiagram to handle multi-layered graphs, cross-domain views, and interactive exploration

5. **DSL meta-language** — Mature stzDomainLanguage into a platform for rapid domain design

The foundation is stzGraph. Everything else is building upon that truth: **the world is connected, and graphs are the native language for understanding those connections.**