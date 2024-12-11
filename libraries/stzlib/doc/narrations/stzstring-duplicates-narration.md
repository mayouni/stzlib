# Decoding Duplicates: Exploring Duplicate Detection and Removal with Softanza
![Manging Duplicates in Softanza](../images/stzstring-duplicates.jpg)
---

Let’s dive into an engaging exploration of how Softanza handles duplicate detection and management in strings. Consider this illustrative string:

```ring
o1 = new stzString("ABRACADABRA")
```

## The Question: Are there any duplicated substrings?

The `ContainsDuplicates()` function reveals the presence of duplicates:

```ring
? o1.ContainsDuplicates()
#--> TRUE
```

Yes, duplicates are present.

## Counting the Duplicates

How many duplicates are there?

```ring
? o1.CountDuplicates()
#--> 6
```

There are 6 duplicates.

## Locating the Duplicates

We locate their positions using `FindDuplicates()`:

```ring
? @@( o1.FindDuplicates() )
#--> [ 0, 3, 7, 8, 9 ]
```

The duplicates occur across 5 unique positions.

## Identifying the Duplicates

The `Duplicates()` function shows which substrings are duplicated:

```ring
? @@( o1.Duplicates() )
#--> [ "A", "AB", "B", "R", "A" ]
```

Here are all six duplicated substrings, including overlaps.

## Understanding Overlapping Duplicates

Using `DuplicatesZ()` provides insights into overlapping duplicates and their positions:

```ring
? @@( o1.DuplicatesZ() )
#--> [ ["A", 0], ["AB", 0], ["B", 1], ["R", 3], ["A", 7] ]
```

At position 0, two substrings (`"A"` and `"AB"`) overlap, explaining the count mismatch.

## Removing the Duplicates

Finally, we simplify the string by removing duplicates:

```ring
o1.RemoveDuplicates()
? o1.Content()
#--> "ABRCAD"
```

---

## Conclusion

This exploration demonstrates the power of the Softanza library's string manipulation capabilities. By identifying, analyzing, and ultimately removing duplicates, we transform a verbose string into its most concise form. This functionality is invaluable in applications ranging from text processing to data compression, offering both efficiency and clarity in handling complex string data.

