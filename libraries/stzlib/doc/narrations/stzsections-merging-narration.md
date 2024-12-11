# Understanding Section Merging Features in Softanza
![Merging Sections in Softanza, by Microsoft Image Create AI](../images/stzsections-merging.jpg)

---

## Introduction

Softanza library provides three sophisticated methods for **merging sections** (mainly in the `stzListOfSections` class): `MergeInclusive()`, `MergeOverlapping()`, and `MergeSections()`. These features are designed to handle different types of section-merging scenarios, offering both specialized and comprehensive solutions for real-world algorithmic problems.

## The Nature of Sections in Softanza

Before exploring the merging features, let’s clarify what we mean by "**sections**". In Softanza, a **section** is represented as a pair of numbers `[n1, n2]`, where:

- `n1` is the **starting position** in the string or list
- `n2` is the **ending position** in the string or list

`n1` can be ≤ `n2` or vice versa; **whichever the case**, the section `[n1, n2]` is returned.

A Section in Softanza differs from a **Range**. The fellowing returns the substring from position 3 to 5:

```ring
Q("SOFTANZA").Section(3, 5) #--> "TAN"
```

While the fellowing returns the substring **starting at** position 3 **and spanning** 5 positions forward:

```ring
Q("SOFTANZA").Range(3, 5) #--> "TANZA" : 
```

The `Section()` function works the same way with both **strings** and **lists**:

```ring
? Q([ "S", "O", "F", "T", "A", "N", "Z", "A" ]).Section(3, 5) #--> [ "T", "A", "N" ]
```

>The `Range()` function is also used in the same way with both strings and lists.


## MergeInclusive(): Handling Contained Sections

`MergeInclusive()` is designed to merge sections where one section **completely contains another**. This is particularly useful when dealing with nested sections that need to be simplified.

**Example:**

```ring
o1 = new stzListOfSections([
	[ 4, 6  ], # Contains all the following sections
	[ 4, 4  ],
	[ 4, 5  ],
	[ 5, 5  ],
	[ 5, 6  ],
	[ 6, 6  ]
])

o1.MergeInclusive()
? @@( o1.Content() )
#--> [ [ 4, 6 ] ]  # All sections were included in [4, 6]
```

>**NOTE**: The `@@()` function, resembling a pair of glasses for better clarity, is designed to produce a readable string representation of a list or any other value provided to it.


## MergeOverlapping(): Handling Adjacent or Overlapping Sections

`MergeOverlapping()` merges sections that either **overlap or are adjacent** to each other. This is useful when you need to combine sections that share common points or are consecutive.

**Example:**

```ring
o1 = new stzListOfSections([
	[ 8, 11  ], # Each section overlaps with the next
	[ 9, 12  ],
	[ 10, 13 ],
	[ 11, 14 ],
	[ 12, 15 ],
	[ 26, 29 ]  # This one stands alone
])

o1.MergeOverlapping()
? @@( o1.Content() )
#--> [ [ 8, 15 ], [ 26, 29 ] ]
```


## MergeSections(): Comprehensive Section Merging


`MergeSections()` combines **both inclusive and overlapping** merging strategies, providing the most compact representation possible of the given sections.

**Example:**

```ring
o1 = new stzListOfPairs([
	# Inclusive sections
	[ 4, 6  ], [ 4, 4 ], [ 5, 6 ],
	
	# Overlapping sections
	[ 8, 10 ], [ 10, 12 ], [ 12, 14 ],
	
	# Both inclusive and overlapping
	[ 20, 25 ], [ 22, 23 ], [ 24, 27 ], [ 26, 28 ]
])

o1.MergeSections()
? @@( o1.Content() )
#--> [ [ 4, 6 ], [ 8, 14 ], [ 20, 28 ] ]
```

## Practical Applications

We’ll demonstrate the section-merging feature in Softanza with three practical examples. The issue presented in the third example was the key motivation for adding this feature to the library, so it will be covered in greater detail.

### 1. Time Slot Management

These features are valuable for managing calendar events or scheduling systems:

```ring
# Meeting time slots (in 24-hour format)
aSlots = [
	[9, 10],   # 9:00-10:00 meeting
	[9, 11],   # 9:00-11:00 meeting (includes previous)
	[10, 12],  # 10:00-12:00 meeting (overlaps)
	[15, 16],  # 3:00-4:00 meeting (separate)
]

oSlots = new stzListOfPairs(aSlots)
oSlots.MergeSections()
? @@( oSlots.Content() )
#--> [ [ 9, 12 ], [ 15, 16 ] ]
# Shows actual blocked time periods
```

### 2. Memory Section Optimization

> REMINDER: We use "Memory Section" instead of "Memory Range" because they are distinct in Softanza, and what we mean here is specifically a Section, not a Range.

Useful for systems programming and memory management:

```ring
# Memory sections to allocate
aSections = [
	[1000, 2000],
	[1500, 2500],  # Overlaps with previous
	[2400, 3000],  # Overlaps with previous
	[5000, 6000]   # Separate section
]

oSections = new stzListOfPairs(aSections)
oSections.MergeSections()
? @@( oSections.Content() )
#--> [ [ 1000, 3000 ], [ 5000, 6000 ] ]
# Shows actual memory sections needed
```

### 3. String Section Management: A Deep Dive

One of the primary motivations for implementing these features in Softanza was to enhance string manipulation operations, particularly when dealing with **duplicated substrings**. 

Let's explore a practical example where we want to remove consecutive duplicated names of programming languages from a string like `"PhpRingRingRingPythonRubyRuby"` to get `"PhpRingPythonRuby"` as our final result.

First, let's examine our input string and analyze its duplicated substrings:

```ring
o1 = new stzString("PhpRingRingRingPythonRubyRuby")

# Get the duplicated substrings along with their sections:

? @@( o1.DupSecutiveSubStringsZZ() ) # The ZZ() suffix adds sections to the substrings
#--> [
#	[ "ingR", [ [ 9, 12 ] ] ],
#	[ "ngRi", [ [ 10, 13 ] ] ],
#	[ "Ruby", [ [ 26, 29 ] ] ],
#	[ "gRin", [ [ 11, 14 ] ] ],
#	[ "Ring", [ [ 8, 11 ], [ 12, 15 ] ] ]
# ]
```

This output shows us all the duplicated substrings and their positions (as sections) in the string. For our purpose, we need just the sections themselves, so let's just add `Find` at the beginning of the `DupSecutiveSubStringsZZ()` method:

```ring
# Extract just the sections:
? @@( o1.FindDupSecutiveSubStringsZZ() )
#--> [ [ 9, 12 ], [ 10, 13 ], [ 26, 29 ], [ 11, 14 ], [ 8, 11 ], [ 12, 15 ] ]

# Sort them in descending order for processing
aSections = reverse( @Sort(o1.FindDupSecutiveSubStringsZZ()) )
? @@(aSections)
#--> [ [ 26, 29 ], [ 12, 15 ], [ 11, 14 ], [ 10, 13 ], [ 9, 12 ], [ 8, 11 ] ]
```

Now, let's demonstrate why proper section merging is crucial. If we try to remove these sections one by one without merging them first:

```ring
for section in aSections
	o1.RemoveSection(section[1], section[2])
next
? o1.Content()
#--> PhpRing   # This is not what we wanted!
```

We get an unexpected result! The problem lies in the nature of our sections - they are **either overlapping or inclusive** of each other. When we remove them sequentially, we end up removing more text than intended because the sections interact with each other.

Here's how we solve this problem using Softanza's section merging capability embedded behind the `RemoveSections()` feature:

```ring
o1 = new stzString("PhpRingRingRingPythonRubyRuby")
o1.RemoveSections(aSections)
? o1.Content()
#--> PhpRingPythonRuby   # Perfect! This is what we wanted.
```

The magic happens behind the scenes. Let's see how Softanza made it:

```ring
? @@( StzListOfSectionsQ(aSections).MergeSectionsQ().Content() )
#--> [ [ 8, 15 ], [ 26, 29 ] ]
```

What happened here is remarkable. Softanza took our complex list of overlapping sections:
```
[ [ 9, 12 ], [ 10, 13 ], [ 26, 29 ], [ 11, 14 ], [ 8, 11 ], [ 12, 15 ] ]
```

And merged them into two clean, **non-overlapping** sections:
```
[ [ 8, 15 ], [ 26, 29 ] ]
```

This merging process ensures that our string manipulation operations work correctly. The first merged section `[8, 15]` cleanly captures all the overlapping `"Ring"` duplicates, while the second section `[26, 29]` handles the duplicated `"Ruby"`. When these merged sections are used internally with `RemoveSections()`, we get exactly the result we want.

This example demonstrated the critical importance of **proper section merging in string manipulation**. Without this feature, operations involving overlapping or inclusive sections could produce unexpected and incorrect results.

---

## Conclusion

The **section merging** features in Softanza provide a robust solution for handling different types of section-merging scenarios. Whether you need to merge **contained sections** (`MergeInclusive()`), **overlapping sections** (`MergeOverlapping()`), or **both** (`MergeSections()`), these methods offer both specialized and comprehensive solutions.

The implementation of these features, like the wide majority of Softanza, was driven by **real-world needs**, particularly in string manipulation scenarios where consistent handling of sections is crucial. However, their utility extends **far beyond string operations**, making them valuable tools for any situation involving section management, from scheduling systems to memory allocation.
