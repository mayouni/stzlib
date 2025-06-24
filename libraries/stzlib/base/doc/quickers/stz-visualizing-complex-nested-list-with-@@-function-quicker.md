# Visualizing a Complex Nested List with @@()

Let's define a list with a multi-level structure as follows:

```ring
aList = [
	1, [
    	[ "name", "Ali" ],
	[ "age", 52 ],
	[ "job", "programmer" ] ],

	[ "a", [
	[ "key1", "b" ], [ "key2", "c" ],
	[ [ "key31", "e" ], [ "key32", "f" ], "g"  ],
	"h" ],
	"d" ],
	2, 3
]
```

Printing this list directly in the console can be challenging, as the output lacks visual cues for its nested structure. Items are displayed sequentially, making it difficult to interpret the hierarchy.

```ring
? aList
#-->
1
name
Ali
age
52
job
programmer
a
key1
b
key2
c
key31
e
key32
f
g
h
d
2
3
```

The `list2code()` function in Ring offers a significant improvement by preserving the nested structure. Let's examine its output:

```ring
? list2code(aList)
#--> [
	1,
	[
		[
			"name",
			"Ali"
		],
		[
			"age",
			52
		],
		[
			"job",
			"programmer"
		]
	],
	[
		"a",
		[
			[
				"key1",
				"b"
			],
			[
				"key2",
				"c"
			],
			[
				[
					"key31",
					"e"
				],
				[
					"key32",
					"f"
				],
				"g"
			],
			"h"
		],
		"d"
	],
	2,
	3
 ]
```

However, Softanza's `@@NL()` function offers a refined balance, intelligently analyzing the complexity of inner lists and applying selective indentation for enhanced readability.

```ring
? @@NL(aList)
#--> [
	1,
	[ [ "name", "Ali" ], [ "age", 52 ], [ "job", "programmer" ] ],
	[
		"a",
		[
			[ "key1", "b" ],
			[ "key2", "c" ],
			[ [ "key31", "e" ], [ "key32", "f" ], "g" ],
			"h"
		],
		"d"
	],
	2,
	3
]
```