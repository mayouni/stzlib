### Puzzle 23 · A running total that starts over

Two vectors of 4,096 numbers: values `a` (0 to 12) and marks `b`. A mark **below 2** starts a **segment** at that
element. Put into `c`, for each element, the total of the values of its segment up to itself, inside each group of 256
(a group starts over at its own edge).

The last puzzle's total ran straight through a group. This one must start over at every start, and no thread can see
where the others' segments begin, so every element works out a **segment number**: the count of starts up to and
including itself. That is a running total of 1s and 0s, the scan of the last puzzles. Then an element totals the elements
at or before it that share its segment number:

    in a
    in b
    out c
    shared t 256
    shared s 256
    shared r 256
    stage { @t[@l] = @a }
    stage { @s[@l] = when(@b < 2, 1, 0) }
    stage { @r[@l] = sum(j, 0, 256, when(j <= @l, @s[j], 0)) }

Write the body. A second right answer counts the starts strictly before an element and adds its own start back when
the numbers are compared; find it. The checker verifies both, and it names the element where a near miss goes wrong:
one that forgets the resets (the plain running total), one that compares the marks themselves and not the segment
numbers, and one that counts only the starts before an element, so that a start joins the segment before it.

**What the GPU did differently from a loop:** a loop keeps one running total and resets it when it meets a start, so it
has to read the elements in order. Here every element learned its segment from a count and totalled its own segment's
earlier elements without waiting for another thread. The library's `SegmentedScan` folds the reset into the scan itself:
pairs of (start, total) are combined so that a start throws away what came before it, and the same three-phase scan then
works across a whole vector. `SegmentedReduce` keeps the last total of each segment: one number per segment.
