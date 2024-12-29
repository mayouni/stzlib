# Softanza Stringify() vs DeepStringify()

One of the key enhancements Softanza brings to the Ring programming language is its powerful Find() function. Unlike Ring's native find(), which is limited to numbers and strings, Softanza’s Find() can locate any element in a list—even deeply nested structures or non-string data types. This capability is made possible through two internal methods: `Stringify()` and `DeepStringify`.

---

## The Find() function in Ring and Softanza

In Ring, writing this lead to an error:

```ring
find([ 1, [ "A", "C" ], 3 ], [ "A", "C" ])
#--> Bad parameter type!
```

In Sftanza, this works:

```ring
? Q([ 1, [ "A", "C" ], 3 ]).Find( [ "A", "C" ])
#--> 2
```

## From Find() to DeepFind()

When you use Softanza’s `Find()` to search for an item within a list, the library automatically transforms non-string elements into strings to make them searchable. This applies also to using Softanza DeepFind() function to locate items, whatever their type, in a nested list:

```ring
? Q([ 1, "♥", [ "A", "C", "♥" ], 3, "♥" ]).DeepFind( "♥")
#--> [ 2, [ 3, 3 ], 5 ]
```

## Stringigy() and DeepStringify()

Let's see how Stringify() and DeepStringify() work.

```ring
# Define a nested list with a mix of strings, numbers, and sublists

aList1 = [
	"A",
	[ "B", "♥" ],
	[ "C", "D", [ 1, 2, [ "str", 7:9, 10 ],  3 ], "♥" ],
	"♥"
]

o1 = new stzList(aList1)

# Stringified(): Converts top-level elements to strings, preserving
# nested sublists as string representations

? @@SP( o1.Stringified() ) + NL
#--> [
#	"A",
#	'[ "B", "♥" ]',
#	'[ "C", "D", [ 1, 2, [ "E", [ 7, 8, 9 ], 10 ], 3 ], "♥" ]',
#	"♥"
#]

# DeepStringified(): Recursively converts all elements into strings,
# retaining the structural hierarchy

? @@SP( o1.DeepStringified() )
#--> [
#	"A",
#	[ "B", "♥" ],
#	[ "C", "D", [ "1", "2", [ "E", [ "7", "8", "9" ], "10" ], "3" ], "♥" ],
#	"♥"
# ]
```

# Other possible use cases of Stringify() and DeepStringify()

You might find Stringify() and DeepStringify() useful in other practical scenarios.

1. **Serialization for Logging or Debugging**: Easily convert complex nested lists into strings for clear and concise logs.

2. **Exporting Data**: Transform nested lists into a text-friendly format for exporting to JSON, CSV, or other formats.

3. **Key Comparison**: Generate unique string identifiers for non-string data, such as objects or lists, for use as dictionary keys or in database operations.

4. **String-Based Manipulations**: Apply string operations to lists that mix various data types, simplifying certain text-based workflows.