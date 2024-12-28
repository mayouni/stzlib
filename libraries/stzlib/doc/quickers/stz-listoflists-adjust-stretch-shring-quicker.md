# Adjusting Lists of Lists in Softanza

The `stzListOfLists` class in Softanza simplifies the management of lists of lists with flexible methods to adjust, stretch, or shrink sublists dynamically. This capability is particularly useful for aligning data of varying dimensions to meet specific requirements. Below is a detailed example:

---

## Initialization

We start by creating an `stzListOfLists` object with sublists of different lengths. These sublists may represent diverse datasets such as strings, numbers, or card symbols.

```ring
o1 = new stzListOfLists([
	[ "A", "B" ],
	[ 1, 2, 3 , 4, 5 ],
	3Cards()
])

? 3Cards()
#--> [ "🂭", "🂡", "🂡" ]
```

## Adjustment

The `Adjusted()` method ensures all sublists have the same length by padding shorter lists with empty strings (`""`). This is useful when preparing data for uniform processing.

```ring
? @@SP( o1.Adjusted() ) + NL
#--> [
#	[ "A", "B",  "",  "", "" ],
#	[   1,   2,   3,   4,  5 ],
#	[ "🂡", "🂨", "🂨", "", "" ]
# ]
```

## Stretching

The `Stretched()` method extends shorter sublists to match the longest one, similar to `Adjusted()`. This is particularly handy for aligning data structures in matrix-like layouts.

```ring
? @@SP( o1.Stretched() ) + NL # Or Extended or Expanded
#--> [
#	[ "A", "B",  "",  "", "" ],
#	[   1,   2,   3,   4,  5 ],
#	[ "🂡", "🂨", "🂨", "", "" ]
# ]
```

## Shrinking

The `Shrinked()` method reduces all sublists to the length of the shortest one by removing excess elements. This operation is ideal for compacting data.

```ring
? @@SP( o1.Shrinked() )
#--> [
#	[ "A", "B" ],
#	[ 1, 2 ],
#	[ "🂡", "🂥" ]
# ]
```