# Intelligence in Motion: Graph Planning in Softanza
*When Your Code Needs to Think About Routes*

---

## Introduction: From Structure to Strategy

Softanza's Graph Module already gives you powerful tools for representing connected systems. With **stzGraph**, you model networks of nodes and edges. With **stzDiagram**, you visualize relationships. **stzWorkflow** captures process flows, **stzOrgChart** maps hierarchies, **stzKnowledgeGraph** encodes semantic relationships. These classes help you *build* the structure of your problem space.

But structure alone doesn't make decisions. Once you have a graph—whether it's a warehouse layout, a workflow diagram, or a knowledge network—the next question emerges: **How do I navigate it optimally?**

This is where **stzGraphPlanner** enters. It transforms your static graphs into *decision spaces*. You don't just have a network—you have a reasoning partner that finds optimal paths, explains choices, compares strategies, learns from history, and filters by constraints. Where other graph classes answer "what is the structure?", stzGraphPlanner answers "what should I do?"

---

## The Question That Makes It Real

You're building a warehouse management system. Using **stzGraph**, you've modeled the facility—loading docks, aisles, storage zones, and shelves as nodes; corridors as edges with distance and congestion properties. The structure is clear.

Now a robot needs to move from loading dock to shelf 42. Dozens of paths exist through your graph. Some are shorter. Some avoid congestion. Some use less energy.

**How do you make this decision?**

Traditional answer: Implement complex pathfinding algorithms. Manage data structures. Debug for weeks.

Softanza answer: **Describe what you want. The planner figures out how.**

```ring
oPlanner = new stzGraphPlanner(oGraph)
oPlanner {
    AddPlan("warehouse_route")
    Walk(:From = "entrance", :To = "shelf_42")
    Minimizing("distance")
    Execute()
    
    // Now see the results
    ? Cost()
    #--> 45
    
    ? Route()
    #--> [ "entrance", "receiving", "storage", "shelf_42" ]
    
    ? Explain()
    #--> Step 1: entrance -> receiving (cost: 10)
    #    Step 2: receiving -> storage (cost: 25)
    #    Step 3: storage -> shelf_42 (cost: 10)
}
```

Three lines to plan. Three lines to understand. No algorithm knowledge required. The robot finds its way, and you can ask: *Why this route? What alternatives existed? How does this compare to yesterday?*

This is stzGraphPlanner—where graph structure meets strategic intelligence.

### The Journey Ahead

This article explores graph planning through three fundamental questions:

**How do we find optimal paths?** We'll see how to express what matters—whether minimizing distance, avoiding danger, or balancing multiple criteria—and let the planner discover the best routes automatically.

**How do we understand our choices?** We'll examine what happens after finding a path: explaining costs, comparing alternatives, and understanding why one route was chosen over another.

**How do we plan smarter?** We'll discover advanced capabilities: comparing multiple strategies at once, learning from past executions, and filtering solutions by real-world constraints.

The progression is deliberate: first finding paths, then understanding them, finally mastering complex planning scenarios. Each capability builds on the previous, moving from single-route optimization to sophisticated multi-criteria decision support.

The concepts may be subtle, but the code remains simple. By the end, you'll see graph planning not as implementing algorithms, but as having a reasoning partner for navigating complex networks.

---

## Part One: The Essence of Planning

### What Makes Planning Different from Search

When you search, you explore until you find something. When you plan, you **reason about the best path** before taking a step. The difference is profound.

Let's start with the fundamental act: getting from point A to point B. You've built a graph representing your warehouse layout—nodes are locations, edges are paths. Now you want to navigate it:

```ring
oPlanner = new stzGraphPlanner(oGraph)
oPlanner {
    AddPlan("warehouse_route")
    Walk(:From = "entrance", :To = "shelf_42")
    Minimizing("distance")
    Execute()
}
```

Three things just happened that matter:

**First**, you expressed *intent* ("minimize distance"), not *implementation* ("use A* with Euclidean heuristic"). The planner chose the right algorithm automatically.

**Second**, the result isn't just a path—it's a *plan object* you can interrogate:

```ring
? Cost()           // How expensive was it?
? Route()         // What's the route?
? Explain()        // Why this route?
```

**Third**, you got transparency. When the plan returns `cost: 45` and route `entrance → receiving → storage → shelf_42`, you can ask *why*.

### The Intelligence: Discovering Hidden Patterns

Your warehouse has a shortcut—a corridor that bypasses two aisles. But it's not obvious from looking at the graph. You have:

- Long route: entrance → receiving → aisle_a → aisle_b → storage → shelf_42 (distance: 57)
- Hidden shortcut: entrance → receiving → storage → shelf_42 (distance: 45)

You don't tell the planner about the shortcut. You just say "minimize distance." The planner **discovers** the shortcut by exploring intelligently. It uses smart search algorithms (like A*—a pathfinding algorithm that estimates which direction looks most promising) but you never had to implement them.

**Principle**: *Planning is pattern discovery, not path following.*

---

## Part Two: When Destination Becomes Condition

### The Paradigm Shift: Goal-Based Thinking

Sometimes you don't know where you want to go. You know what you're looking for.

Imagine a game character needing treasure—any treasure worth at least 1000 gold. You could hardcode "go to the dungeon." But what if game state changes?

**Goal-based planning** thinks differently:

```ring
oPlanner {
    AddPlan("treasure_hunt")
    Walk(
        :From = "village",
        :UntilYouReachF = func(node) {
            return node[:properties][:gold] >= 1000
        }
    )
    Minimizing("danger")
    Execute()
}
```

You didn't specify a destination *node*. You specified a destination *condition*. The planner:

1. Explores from your starting point
2. Evaluates each node: "Does this satisfy the goal?"
3. Returns optimal path to first qualifying node
4. Still respects optimization criteria

Result: `village → forest → dungeon` (cost: 9 danger points). The dungeon was nearest location with sufficient treasure, reached via the safest route.

This pattern appears everywhere:
- **Logistics**: "Find warehouse with 500+ units, closest to customer"
- **Healthcare**: "Route to any hospital with cardiac capability, fastest response"
- **Manufacturing**: "Find production line where quality > 95%, with capacity"

You're not routing to a place. You're routing to a **state of the world that satisfies your needs**.

---

## Part Three: The Transparency Revolution

### When Plans Explain Themselves

Most AI systems are black boxes. You get an answer but no understanding. Softanza believes plans should be *conversational*.

You've generated a delivery route, but the cost seems high:

```ring
? ExplainCostBreakdown()
```

Output:
```
=== COST BREAKDOWN ===

Step 1: warehouse → suburb_a
  • distance: 12 × 1 (minimize) = 12
  • traffic: 2 × 1 (minimize) = 2
  Total: 14

Step 2: suburb_a → downtown  
  • distance: 15 × 1 (minimize) = 15
  • traffic: 8 × 1 (minimize) = 8
  Total: 23
```

Now you see it: the second leg has heavy traffic (8 points). Not a mystery—just math, explained.

### The "Why" Conversation

Want more context?

```ring
? ExplainWhy("route")
```

```
This route was selected because:
• Total cost: 37
• Explored 8 nodes to find it
• Optimized for: minimize distance, minimize traffic
```

And to understand alternatives:

```ring
? ExplainAlternatives()
```

```
Key decisions made:
• At 'warehouse', chose 'suburb_a' (2 options available)
• At 'suburb_a', chose 'downtown' (3 options available)
```

In regulated industries (healthcare, finance, transportation), you may be **legally required** to explain automated decisions. With stzGraphPlanner, explanation is built in. The plan *knows* why it was created.

---

## Part Four: Strategy as Language

### The Profile System: Named Intentions

You keep optimizing for the same combinations. Fast deliveries minimize time and fuel. Safe routes minimize danger and maximize cover. Budget operations minimize cost and maintenance.

Instead of rewriting criteria every time, **profiles** encode strategy as named concepts:

```ring
// Instead of this every time:
Minimizing("time").Minimizing("fuel").WithWeight(0.6, 0.4)

// Just say this:
Using(:fastest)
```

Six profiles come standard: `:fastest`, `:safest`, `:cheapest`, `:shortest`, `:balanced`, `:efficient`. Each encodes a common optimization strategy.

### Profiles in Action

An ambulance dispatch system:

```ring
// During low traffic: prioritize speed
AddPlan("rush_hour")
Walk(:From = "hospital", :To = "emergency")
Using(:fastest)
Execute()

// During peak hours: prioritize reliability
AddPlan("reliable")
Walk(:From = "hospital", :To = "emergency")
Using(:safest)    // Avoids unpredictable routes
Execute()
```

Same graph, same endpoints—different strategies. Profiles make strategy **part of the domain language**, not buried in code.

---

## Part Five: The Comparison Problem

### When One Solution Isn't Enough

Real decisions involve trade-offs. Do we take the fast route or safe one? Cheap production or high-quality?

Traditional systems give you *one answer*. Intelligent decision-making requires understanding *alternatives*.

### Comparing Plans

You've planned two delivery routes—one for speed, one for fuel economy:

```ring
AddPlan("fast")
Walk(:From = "warehouse", :To = "customer")
Using(:fastest)
Execute()

AddPlan("economical")
Walk(:From = "warehouse", :To = "customer")
Using(:cheapest)
Execute()

SetCurrentPlan("fast")
? ExplainDifference("economical")
```

Output:
```
PATH ANALYSIS:
Plans use DIFFERENT routes
  Plan 1: [ "warehouse", "highway", "downtown", "customer" ]
  Plan 2: [ "warehouse", "local_road", "suburb", "customer" ]
  
  Paths diverge at step 2

COST ANALYSIS:
  Plan 1 cost: 25 (time)
  Plan 2 cost: 80 (fuel cost)
  ✓ Plan 1 is faster, Plan 2 is cheaper
```

### Trade-off Analysis

```ring
? ShowTradeoffs("economical")
```

```
CRITERION COMPARISON:
  Cost:        Plan 2 wins (saves $35)
  Path Length: Tie

RECOMMENDATION:
  → Choose Plan 1 for time-sensitive deliveries
  → Choose Plan 2 for routine deliveries
```

The comparison system doesn't make decisions for you. It **structures the decision** so you can judge intelligently.

---

## Part Six: Multi-Plan Intelligence

### Comparing Many Strategies Simultaneously

Real scenarios have multiple alternatives. Compare them all at once:

```ring
// Create 4 different strategies
AddPlan("ultra_fast")
Walk(:From = "warehouse", :To = "destination")
Using(:fastest)
Execute()

AddPlan("budget")
Using(:cheapest)
Execute()

AddPlan("short_distance")
Using(:shortest)
Execute()

AddPlan("balanced")
Using(:balanced)
Execute()

// Compare all 4
oMulti = CompareMultiple(["ultra_fast", "budget", "short_distance", "balanced"])
```

Get rankings:

```ring
? oMulti.RankBy("cost")
//→ [ ["budget", 25], ["balanced", 45], ["short_distance", 50], ["ultra_fast", 90] ]

oMulti.ShowRankingTable()
```

Output:
```
=== PLAN RANKING TABLE ===

Rank | Plan Name      | Cost  | Steps
-----+----------------+-------+------
1    | budget         | 25    | 3
2    | balanced       | 45    | 3
3    | short_distance | 50    | 3
4    | ultra_fast     | 90    | 3
```

### Quick Decision Support

```ring
? oMulti.BestBy("cost")
//→ "budget"

? oMulti.WorstBy("cost")
//→ "ultra_fast"
```

**Pattern**: When you have many options, ranking tables and quick queries help identify the right strategy for your context.

---

## Part Seven: Learning from History

### Historical Comparison: Plans Remember

Every plan execution is stored in history. Compare current performance against past:

```ring
// Execute multiple delivery runs
for i = 1 to 5
    AddPlan("delivery_" + i)
    Walk(:From = "depot", :To = "customer")
    Minimize("cost")
    Execute()
next

// Analyze performance
? HistoryCount()
//→ 5

? HistoricalAverage("cost")
//→ Shows average cost across all 5 runs

? BestHistoricalPlan("cost")
//→ "delivery_3"  (returns best performing plan)
```

### Is This an Improvement?

```ring
SetCurrentPlan("delivery_5")
oHistComp = CompareWithHistory()

? oHistComp.Explain()
```

Output:
```
=== HISTORICAL COMPARISON ===

Current Plan: delivery_5
  Cost: 30
  Steps: 3

Historical Average:
  Cost: 35
  Steps: 3

✓ Current plan is 14.3% better than average

Best historical plan: delivery_3
```

Methods:
```ring
? oHistComp.IsImprovement()
//→ TRUE

? oHistComp.ImprovementPercentage()
//→ 14.3
```

**Pattern**: Historical tracking transforms planning from one-off computation to continuous improvement. You learn what works.

---

## Part Eight: Constraint-Based Filtering

### Finding Plans That Meet Requirements

When you have many plans, filter by constraints:

```ring
// Create multiple route plans
AddPlan("cheap_route")
// ... execute ...

AddPlan("fast_route")
// ... execute ...

AddPlan("safe_route")
// ... execute ...

// Filter: cost <= 50
oFilter = FilterPlans([:maxCost = 50])
? oFilter.Count()
//→ 2

oFilter.Show()
```

### Avoiding Nodes

```ring
// Plans that avoid dangerous downtown area
oFilter = PlansAvoiding("downtown")
oFilter.Show()
```

### Requiring Waypoints

```ring
// Plans that must visit distribution center
oFilter = PlansRequiring("distribution_center")
? oFilter.Count()
```

### Tolerance-Based Filtering

```ring
// Find plans within 10% of optimal cost
oFilter = PlansWithin(10, :of = "optimal_plan")
? oFilter.Count()
//→ Shows plans that are "good enough"

? oFilter.BestBy("cost")
//→ Returns cheapest from filtered set

oFilter.ShowRankingTable()
```

### Multiple Constraints

```ring
// Complex real-world filtering
oFilter = FilterPlans([
    :maxCost, 50,
    :avoid, "downtown",
    :maxSteps, 4
])

? "Found " + oFilter.Count() + " plans matching all constraints"
```

**Pattern**: Filtering transforms "find the best" into "find the best that meets my requirements"—crucial for real-world constraints.

---

## Part Nine: The Architecture of Intelligence

### What's Happening Under the Hood

The fluent interface feels simple. Behind it:

- **Smart pathfinding algorithms** (like A*, which intelligently estimates distances to find optimal routes) with automatic selection based on your graph structure
- **Best-first search** (exploring the most promising paths first) for goal-based planning with early termination when a match is found
- **Multi-criteria optimization** combining multiple factors (time, cost, distance) with weighted importance
- **Exploration tracking** logging every decision point for later explanation

You never have to know this. The interface abstracts complexity without hiding reasoning.

### The Three-Layer Design

**Expression Layer**: State intent
```ring
Walk(:From = "A", :To = "B").Using(:fastest)
```

**Reasoning Layer**: Algorithms work (hidden but accessible)
```ring
A* exploration, cost calculation, path reconstruction
```

**Explanation Layer**: Transparency emerges
```ring
ExplainWhy(), ExplainAlternatives(), CompareTo()
```

Traditional systems have layers 1 and 2. Softanza adds layer 3, transforming from "computational tool" to "reasoning partner."

---

## Part Ten: Planning in the Wild

### Real Systems, Real Decisions

**Warehouse Robotics**: Robots receive pick orders with varying priority and size. The planner:
- Minimizes travel time for urgent orders (`:fastest`)
- Minimizes energy for routine orders (`:cheapest`)
- Avoids congested aisles during peak hours
- Explains routing decisions to managers

**Result**: 30% faster picks, 20% energy savings, zero confusion.

**Emergency Dispatch**: 911 calls need nearest appropriate unit. The planner:
- Uses goal-based search: "Find any ambulance where distance < 10 miles AND capabilities match"
- Optimizes for actual response time, not just distance
- Compares multiple plans: fastest vs most reliable
- Provides explanation for dispatch logs (regulatory requirement)

**Result**: 2-minute improvement in response time. More importantly: explainable decisions.

**Manufacturing Workflow**: Custom orders have quality requirements, deadlines, cost constraints. The planner:
- Routes orders through production stages
- Optimizes per order (luxury: `:balanced`, commodity: `:cheapest`)
- Compares alternative workflows showing trade-offs
- Explains decisions to customers

**Result**: Better communication, strategic resource allocation, 15% cost reduction.

**Pattern**: The planner isn't replacing judgment—it's structuring decisions so humans can judge better. This is **augmented intelligence**.

---

## Part Eleven: The Educational Dimension

### Learning Planning by Using Planning

Students learning pathfinding traditionally:
1. Study A* algorithm
2. Implement from scratch
3. Debug for weeks
4. See it work on toy examples

With stzGraphPlanner:

```ring
// Day 1: Use it
AddPlan("first_path")
Walk(:From = "A", :To = "B")
Execute()

// Day 2: Understand it
? ExplainEfficiency()
//→ "Explored 7 nodes for 5-node path (1.4:1 ratio - very efficient)"

// Day 3: Compare approaches
AddPlan("fastest")
Using(:fastest)
Execute()

AddPlan("shortest")
Using(:shortest)
Execute()

? ExplainDifference("shortest")

// Day 4: Now you understand pathfinding deeply
```

Students learn by *using* and *querying*, not drowning in implementation. They see algorithm behavior, understand decisions, compare strategies.

More importantly, they learn **why planning matters**—strategic thinking, not just mechanics. When comparing `:fastest` vs `:safest` and seeing trade-offs quantified, they're learning decision-making. When asking `ExplainWhy()`, they're learning transparency.

**Philosophy**: Tools that teach by being conversational.

---

## The Softanza Advantage

### Comparison with Leading Graph Planning Libraries

| Feature | **Softanza** | NetworkX (Python) | JGraphT (Java) | Boost Graph (C++) | igraph (Python/R) | Pathfinding.js |
|---------|--------------|-------------------|----------------|-------------------|-------------------|----------------|
| **Intent-Based API** | ✅ Natural language | ❌ Algorithm-centric | ❌ Class-based | ❌ Template-heavy | ❌ Function calls | ❌ Config objects |
| **Built-in Explanations** | ✅ Multi-level | ❌ None | ❌ None | ❌ None | ❌ None | ❌ None |
| **Multi-Plan Comparison** | ✅ Native support | ❌ Manual | ❌ Manual | ❌ Manual | ❌ Manual | ❌ Manual |
| **Historical Tracking** | ✅ Automatic | ❌ External | ❌ External | ❌ External | ❌ External | ❌ External |
| **Constraint Filtering** | ✅ Declarative | ⚠️ List comprehensions | ⚠️ Streams/filters | ⚠️ STL algorithms | ⚠️ Vector subset | ⚠️ Array.filter |
| **Named Strategy Profiles** | ✅ `:fastest, :safest` | ❌ Weight dicts | ❌ Builder patterns | ❌ Policy classes | ❌ Parameters | ❌ Options object |
| **Goal-Based Search** | ✅ First-class | ⚠️ Custom predicates | ⚠️ Interface impl | ⚠️ Visitor pattern | ⚠️ Lambda functions | ❌ Not built-in |
| **Fluent Interface** | ✅ Full fluency | ❌ Function chaining | ⚠️ Builder only | ❌ Separate calls | ❌ Separate calls | ⚠️ Method chaining |
| **Learning Curve** | Gentle | Moderate | Steep | Very steep | Moderate | Gentle |
| **Target Audience** | Domain experts | Data scientists | Enterprise Java | C++ experts | Researchers | Web developers |
| **Explainability** | Conversational | Debug prints | Logging | Debug output | Verbose mode | Console logs |

**Legend**: ✅ Native/Excellent | ⚠️ Possible but manual | ❌ Not available

---

These are excellent libraries, each powerful in its domain. NetworkX excels at graph analysis, JGraphT at enterprise reliability, Boost at performance, igraph at statistical computing, Pathfinding.js at web visualization.

**Softanza's distinction**: It transforms graph planning from *algorithmic implementation* to *strategic conversation*. Where others require you to construct searches, Softanza lets you express intent. Where others return paths, Softanza explains reasoning. Where others process one query, Softanza compares strategies, learns from history, and filters by constraints—all through a fluent, natural interface.

The difference isn't in the algorithms (A* is A*). It's in how you interact with them. Traditional libraries speak the language of computer science. Softanza speaks the language of your problem domain.

---

## Conclusion

Graph planning in Softanza isn't about mastering algorithms—it's about expressing intent and understanding outcomes. Where traditional libraries demand you construct searches, stzGraphPlanner lets you describe strategies. Where others return paths, Softanza explains reasoning, compares alternatives, learns from history, and filters by constraints.

The transformation is fundamental: from computational tool to reasoning partner. You state what matters (`:fastest`, `:safest`, "within 10%", "avoid downtown"), the planner handles how, and together you explore the decision space through conversation.

This is planning that teaches as it works, explains as it decides, and remembers as it improves. **Not artificial intelligence replacing judgment—augmented intelligence structuring it.**

---

*For complete working examples with 20 sections covering basic pathfinding through advanced filtering and comparison, see the test files.*

*Welcome to intelligent planning in Softanza.* 🎯