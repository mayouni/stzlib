# stzGraphQuery: Asking Questions to Your Graph

When working with graphs, a moment inevitably arrives when the graph stops being just a structure of nodes and edges and starts becoming a **world you want to explore**.

You look at it and begin asking questions:

- *Who are all the people in this network?*
- *Which employees earn more than 50k?*
- *Who knows whom?*
- *Which relationships connect these two nodes?*

Before `stzGraphQuery`, answering such questions meant writing loops, traversals, and filters.

With **stzGraphQuery**, the experience changes.

You don't write traversal logic anymore.  
You **ask the graph directly**.

---

# The First Question: What Is Inside My Graph?

Every exploration starts with curiosity.

Let's build a small graph.
```ring
oGraph = new stzGraph("social")
oGraph {
	AddNodeXT("alice","Person")
	AddNodeXT("bob","Person")
	AddNodeXT("company_x","Company")
}
````

Now the natural question appears:

*"What nodes exist in this graph?"*
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

Three nodes.

Let's inspect the first one.
```ring
? @@( aResults[1]["node"][:id] )
```
Output
```
alice
```
Without writing any loops, the graph has already revealed its contents.

# Narrowing the Question: Only Persons

Real graphs mix many kinds of nodes. You rarely want **everything**. Often you want something specific. The programmer naturally asks:

*"Show me only the persons."*

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
The graph now responds with:
```
alice
bob
```

What changed?

Only the **intent** of the query.

Instead of filtering manually, we simply **described the nodes we wanted**.


# Looking for Specific Properties

Soon the graph grows richer.

Nodes begin to carry **properties**.

Let's rebuild the graph with a bit more information.

```ring
oGraph = new stzGraph("social")
oGraph {
	AddNodeXTT("alice","Person",[:age=30,:city="Paris"])
	AddNodeXTT("bob","Person",[:age=25,:city="London"])
	AddNodeXTT("carol","Person",[:age=30,:city="Paris"])
}
```

Now the programmer asks a new question:

*"Who is 30 years old?"*

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

The graph answers:

```
alice
carol
```

The beauty here is subtle but powerful:
the query reads almost like **spoken language**.

---

# When Relationships Matter

Graphs become truly interesting when nodes start **interacting**.

Let's introduce relationships.

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

Now the programmer wonders:

*"Which relationships exist in this network?"*

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

Let's inspect the first connection.

```ring
? @@(aResults[1]["a"][:id])
? @@(aResults[1]["b"][:id])
```

Output

```
alice
bob
```

The graph just revealed a friendship.


# Asking Better Questions with Conditions

Once queries become part of your thinking process, the questions naturally become **more precise**.

Consider a company graph.

```ring
oGraph = new stzGraph("employees")
oGraph {
	AddNodeXTT("alice","Employee",[:salary=50000])
	AddNodeXTT("bob","Employee",[:salary=60000])
	AddNodeXTT("carol","Employee",[:salary=50000])
}
```

A manager might ask:

*"Who earns exactly 50k?"*

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

Employees found:

```
alice
carol
```


# Comparison Queries

Soon the questions become more analytical.

*"Who earns more than 55k?"*

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

The graph answers clearly:

```
bob
```


# Searching Text

Queries can also explore **textual information**.

Let's model names.

```ring
oGraph = new stzGraph("people")
oGraph {
	AddNodeXTT("alice_smith","Person",[:name="Alice Smith"])
	AddNodeXTT("bob_jones","Person",[:name="Bob Jones"])
	AddNodeXTT("alice_brown","Person",[:name="Alice Brown"])
}
```

A natural question appears:

*"Show me everyone named Alice."*

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


# Combining Conditions

Real questions often combine multiple criteria.

Let's imagine we want:

*"Employees aged 30 in Engineering."*

```ring
oGraph = new stzGraph("employees")
oGraph {
	AddNodeXTT("alice","Employee",[:age=30,:dept="Engineering"])
	AddNodeXTT("bob","Employee",[:age=25,:dept="Engineering"])
	AddNodeXTT("carol","Employee",[:age=30,:dept="Sales"])
}
```

Now the query becomes:

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


# Letting Functions Decide

Sometimes the condition becomes complex.

Instead of expressing it declaratively, we simply provide a **function**.

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

The query engine simply delegates the decision to your function.


# Extracting Only What Matters

Sometimes you don't want nodes — you want **data**.

Let's ask the graph:

*"What are the ages of all employees?"*

```ring
aResults = StzGraphQueryQ(oGraph).
	MatchQ([:node="n"]).
	Select("n.age")

? @@(aResults)
```

Output

```
[ 30, 25, 30 ]
```

The result is now **data extracted from the graph** rather than the nodes themselves.

---

# Ordering the Answers

Questions sometimes require ordering.

For example:

*"Who is the youngest?"*

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

The graph answers with the youngest employee.

---

# Large Graphs: Skipping and Limiting

As graphs grow large, exploration often happens **in slices**.

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

The query now returns only a **window into the graph**.

---

# Creating Nodes Through Queries

Eventually, exploration becomes **action**.

Queries can also **modify the graph**.

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

A new node has been created.

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

The relationship now exists inside the graph.

---

# The Experience of Querying Graphs

Using `stzGraphQuery` changes how programmers interact with graphs.

Instead of:

* traversing nodes manually
* writing filtering loops
* managing traversal state

the workflow becomes **conversational**:

1. Ask the graph a question
2. Observe the result
3. Refine the question
4. Ask again

The graph becomes not just a data structure but a **knowledge system you can interrogate**.

Combined with `stzGraph`, `stzGraphQuery` enables powerful applications such as:

* knowledge graphs
* dependency analysis
* social networks
* workflow modeling
* semantic reasoning systems

All directly inside **Ring and the Softanza ecosystem**.

```

---

If you want, I can also produce a **final “Softanza-style” version even closer to your `stzGraph` document** — with sections like:

- **“The Moment You Need to Ask the Graph”**
- **“Refining the Question”**
- **“Following Relationships”**
- **“Turning Queries into Actions”**

That version would make **`stzGraph` and `stzGraphQuery` read like two chapters of the same story**, which would make the documentation **very powerful.**