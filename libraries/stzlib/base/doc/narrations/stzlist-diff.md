# When “different” is not enough: the story behind `Diff()`, `DiffXT()` and `DiffXTT()` in stzList

In most programming libraries, *diff* is treated as a simple operation:
compare two collections and list what is not the same.

In Softanza, the question was more intentional:

> **What does it really mean for two lists to be different?**

Not just technically different, but **meaningfully different**.

This reflection led to the design of a progressive diff mechanism in `stzList`, articulated in three deliberate levels: `Diff()`, `DiffXT()` and `DiffXTT()`.

Each level answers a deeper question than the previous one.


## Level 1 — `Diff()`: seeing *what* is different

The first level addresses the most immediate need:

> *Which items are not shared between the two lists?*

```ring
o1 = new stzList([ "green", "red", "blue" ])

? @@( o1.Common([ "yellow", "red", "blue", "gray" ]) )
#--> [ "red", "blue" ]

? @@( o1.Diff([ "yellow", "red", "blue", "gray" ]) )
#--> [ "green", "yellow", "gray" ]
```

Here:

* `Common()` reveals what overlaps
* `Diff()` returns what belongs to only one side

This level is **minimal, symmetric, and direct**.
It is ideal when you only need a factual answer, without interpretation.


## Level 2 — `DiffXT()`: understanding *how* things differ

Very often, knowing *what* is different is not enough.
The next natural question is:

> *Are these differences additions, removals, or modifications?*

This is where **XT — eXTended** — comes into play.

```ring
? @@NL( o1.DiffXT([ "yellow", "red", "blue", "gray" ]) )
```

Result:

```text
[
	[
		"added",
		[ "yellow", "gray" ]
	],
	[
		"removed",
		[ "green" ]
	],
	[ "modified", [  ] ]
]
```

The diff now becomes **expressive**:

* Differences are classified
* The structure is stable and predictable
* Even empty categories are explicitly present


## Level 3 — `DiffXTT()`: understanding *why* things differ

Some differences are neither pure additions nor pure removals.
They are **transformations**.

To capture that idea, a further extension was introduced: **XTT**, *yet another eXTension*.

```ring
o1 = new stzList([ "green", [ "A", "B" ], "rediness", "blues" ])

? @@NL( o1.DiffXTT([ "yellow", "red", [ "A" ], "blue", "gray" ]) )
```

Result:

```text
[
	[
		"added",
		[ "yellow", "gray" ]
	],
	[
		"removed",
		[ "green" ]
	],
	[
		"modified",
		[
			[
				[ "A", "B" ],
				[ "A" ]
			],
			[ "rediness", "red" ],
			[ "blues", "blue" ]
		]
	]
]
```

Here, the diff exposes **relationships**:

* A list evolving from `[ "A", "B" ]` to `[ "A" ]`
* Words reduced to their semantic core
* Elements that changed form but not intent

At this level, `DiffXTT()` no longer reports differences —
it **explains them**.


## A deliberate progression, not increasing complexity

What matters most in this design is not the sophistication of the last level, but the **freedom of choice** it offers:

* Need speed and simplicity? → `Diff()`
* Need structured meaning? → `DiffXT()`
* Need transformation insight? → `DiffXTT()`

Each level is intentional, additive, and optional.


## Why this belongs in `stzList`

Although this mechanism later proved essential for higher-level structures — including graph comparisons — it **belongs first and foremost to `stzList`**.

Lists are the foundational abstraction of Softanza.
By teaching lists how to *explain* their differences, the entire ecosystem gains expressive power.

In Softanza, even a simple list comparison can tell a story —
and `Diff()`, `DiffXT()` and `DiffXTT()` are precisely that:
**narrators of change**.