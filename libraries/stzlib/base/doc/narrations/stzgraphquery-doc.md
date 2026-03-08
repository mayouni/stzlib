# stzGraphQuery: The Moment You Need to Ask the Graph

Graphs begin simply.

At first, you create a few nodes, connect them with edges, and visualize the structure.  
The relationships are clear. The system feels transparent.

But then something changes.

The graph grows.

More nodes appear.  
More relationships accumulate.  
Properties and metadata enrich the structure.

Soon the graph becomes **a living system**.

And a new need emerges:

> *You don't just want to see the graph anymore.  
> You want to ask it questions.*

This is the moment when **stzGraphQuery** enters the scene.

It transforms a graph from a static structure into something interactive —  
a **knowledge system that can be interrogated**.

Instead of writing loops and traversals, you simply describe **what you are looking for**.

The graph answers.

---

# The First Question: What Is Inside This Graph?

Every exploration begins with curiosity.

Let's build a very small graph.

```ring
oGraph = new stzGraph("social")
oGraph {
	AddNodeXT("alice","Person")
	AddNodeXT("bob","Person")
	AddNodeXT("company_x","Company")
}
````

Now imagine a programmer encountering this graph for the first time.

The most natural question appears immediately:

> *What nodes exist here?*

```ring
aResults = StzGraphQueryQ(oGraph).
	MatchQ(:nodes).
	Select("*")

? len(aResults)
```

Output

```
3
```

The graph contains three nodes.

Let's inspect the first one.

```ring
? @@(aResults[1]["node"][:id])
```

Output

```
alice
```

The graph has begun to reveal itself.

---

# Refining the Question

Very quickly, curiosity becomes more precise.

The graph may contain different types of entities — people, companies, products, tasks.

Often the programmer wants to focus on one category.

The question evolves:

> *Show me only the persons.*

```ring
aResults = StzGraphQueryQ(oGraph).
	MatchQ([:nodes,:labeled="Person"]).
	Select("*")

? len(aResults)
```

Output

```
2
```

The graph answers with two nodes:

```
alice
bob
```

The code did not need to iterate through nodes or perform manual filtering.

The programmer simply **described the intention**.

---

# When Properties Begin to Matter

Graphs rarely remain purely structural.

Soon nodes acquire properties:

* age
* location
* salary
* status

These properties add **meaning** to the graph.

Let's enrich the nodes.

```ring
oGraph = new stzGraph("social")
oGraph {
	AddNodeXTT("alice","Person",[:age=30,:city="Paris"])
	AddNodeXTT("bob","Person",[:age=25,:city="London"])
	AddNodeXTT("carol","Person",[:age=30,:city="Paris"])
}
```

Now the question becomes more analytical.

> *Who is 30 years old?*

```ring
aResults = StzGraphQueryQ(oGraph).
	MatchQ(:nodes).
	WhereQ([:age,"=",30]).
	Select("*")

? len(aResults)
```

Output

```
2
```

Matching nodes:

```
alice
carol
```

The query reads almost like spoken language.

---

# Following Relationships

The true strength of graphs appears when nodes interact.

Let's create a small network.

```ring
oGraph = new stzGraph("social")
oGraph {
	AddNode("alice")
	AddNode("bob")
	AddNode("carol")

	ConnectXT("alice","bob","KNOWS")
	ConnectXT("bob","carol","KNOWS")
}
```

Now the programmer asks:

> *Who knows whom?*

```ring
aResults = StzGraphQueryQ(oGraph).
	MatchEdgeQ([:from="a",:to="b",:labeled="KNOWS"]).
	Select(["a","b"])

? len(aResults)
```

Output

```
2
```

Inspecting the first relationship:

```ring
? @@(aResults[1]["a"][:id])
? @@(aResults[1]["b"][:id])
```

Output

```
alice
bob
```

The graph is now telling a story of connections.

---

# Asking Analytical Questions

As the graph grows, the questions become more analytical.

Let's imagine an employee network.

```ring
oGraph = new stzGraph("employees")
oGraph {
	AddNodeXTT("alice","Employee",[:salary=50000])
	AddNodeXTT("bob","Employee",[:salary=60000])
	AddNodeXTT("carol","Employee",[:salary=50000])
}
```

A manager might ask:

> *Which employees earn exactly 50k?*

```ring
aResults = StzGraphQueryQ(oGraph).
	MatchQ(:nodes).
	WhereQ([:salary,"=",50000]).
	Select("*")

? len(aResults)
```

Output

```
2
```

Results:

```
alice
carol
```

---

# Comparing Values

The next question may involve comparisons.

> *Who earns more than 55k?*

```ring
aResults = StzGraphQueryQ(oGraph).
	MatchQ(:nodes).
	WhereQ([:salary,">",55000]).
	Select("*")

? len(aResults)
```

Output

```
1
```

The answer is simple:

```
bob
```

---

# Searching for Patterns

Graphs also contain textual information.

Suppose we store names.

```ring
oGraph = new stzGraph("people")
oGraph {
	AddNodeXTT("alice_smith","Person",[:name="Alice Smith"])
	AddNodeXTT("bob_jones","Person",[:name="Bob Jones"])
	AddNodeXTT("alice_brown","Person",[:name="Alice Brown"])
}
```

Now the question becomes intuitive:

> *Show me everyone named Alice.*

```ring
aResults = StzGraphQueryQ(oGraph).
	MatchQ(:nodes).
	WhereQ([:name,:contains,"Alice"]).
	Select("*")

? len(aResults)
```

Output

```
2
```

Matching nodes:

```
alice_smith
alice_brown
```

---

# Combining Conditions

Real-world questions rarely involve a single condition.

Consider this scenario:

> *Which employees are 30 years old and work in Engineering?*

```ring
oGraph = new stzGraph("employees")
oGraph {
	AddNodeXTT("alice","Employee",[:age=30,:dept="Engineering"])
	AddNodeXTT("bob","Employee",[:age=25,:dept="Engineering"])
	AddNodeXTT("carol","Employee",[:age=30,:dept="Sales"])
}
```

The query becomes:

```ring
aResults = StzGraphQueryQ(oGraph).
	MatchQ(:nodes).
	WhereQ([:age,"=",30,:and,:dept,"=","Engineering"]).
	Select("*")

? len(aResults)
```

Output

```
1
```

Result:

```
alice
```

---

# When Logic Becomes Custom

Sometimes conditions become too complex for simple expressions.

At this moment the programmer introduces **custom logic**.

```ring
StzGraphQueryQ(oGraph) {

	Match(:nodes)

	WhereF(func aBinding {
		aNode = aBinding["node"]
		return aNode[:properties]["age"] > 26
	})

	aResults = Select("*")

	? len(aResults)
}
```

Output

```
2
```

Matching nodes:

```
alice
carol
```

---

# Extracting Knowledge

Sometimes the programmer doesn't want nodes.

They want **information extracted from the graph**.

For example:

> *What are the ages of all employees?*

```ring
aResults = StzGraphQueryQ(oGraph).
	MatchQ([:node="n"]).
	Select("n.age")

? len(aResults)
```

Output

```
3
```

The graph is now acting as a **data source**.

---

# Ordering the Answers

Sometimes results must be ordered.

The question becomes:

> *Who is the youngest employee?*

```ring
aResults = StzGraphQueryQ(oGraph).
	MatchQ([:node="n"]).
	OrderByQ("n.age","ASC").
	Select("n")

? @@(aResults[1]["n"][:id])
```

Output

```
bob
```

The graph responds immediately.

---

# Exploring Large Graphs

Large graphs require **navigation techniques**.

Queries can skip and limit results.

```ring
StzGraphQueryQ(oGraph) {

	Match([:node="n"])
	OrderBy("n.age",:InAscending)
	Skip(1)
	LimitQ(2)

	aResults = Select("n")
}

? len(aResults)
```

Output

```
2
```

The graph can now be explored **piece by piece**.

---

# When Questions Become Actions

At some point exploration turns into action.

Queries can **create nodes**.

```ring
oGraph = new stzGraph("test")

StzGraphQueryQ(oGraph) {

	Create([:node,:labeled="Person",:props=[:name="Alice"]])

	? GraphQ().NodeCount()
}
```

Output

```
1
```

A new node now exists in the graph.

---

# Creating Relationships

Queries can also connect nodes.

```ring
oGraph = new stzGraph("test")
oGraph {
	AddNode("alice")
	AddNode("bob")
}

StzGraphQueryQ(oGraph) {

	Match([:node="a",:where=[:id,"=","alice"]])
	Match([:node="b",:where=[:id,"=","bob"]])

	Create([:edge,:from="a",:to="b",:labeled="KNOWS"])

	? GraphQ().EdgeCount()
}
```

Output

```
1
```

The graph has evolved.

---

# The Experience of Querying a Graph

Using `stzGraphQuery` changes how programmers think about graphs.

Instead of writing algorithms to navigate structures, they begin to **converse with the graph**.

The workflow becomes natural:

1. Ask a question
2. Observe the answer
3. Refine the question
4. Ask again

The graph becomes a **knowledge system**, not just a data structure.

Together, **stzGraph** and **stzGraphQuery** provide a powerful foundation for building:

* knowledge graphs
* dependency systems
* workflow engines
* semantic models
* social networks

And most importantly, they allow programmers to **think in questions rather than loops**.