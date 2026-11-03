### Puzzle 21 · Pack the large ones

A vector `a` of 4,000 numbers, each from 0 to 12. In each group of 256, keep the numbers **above 5** and
pack them, in their order, at the front of the group's slots; the rest of the group's slots are 0. A group
that held 1, 9, 2, 7, 11, 3 ... answers 9, 7, 11 ... and then zeros. This is **stream compaction**.

A loop would append each kept number to the end of an output list. No thread knows how long the output
is so far, so the answer comes from a number each thread can work out alone: the **rank** of a kept element,
how many kept elements lie before it. That is a running total of 1s and 0s, the scan of the previous puzzle.
Here it is slow and plain, and put in a second array by its own stage:

    in a
    out c
    shared t 256
    shared r 256
    stage { @t[@l] = @a }
    stage { @r[@l] = sum(j, 0, 256, when(j <= @l, when(@t[j] > 5, 1, 0), 0)) }

`@r[j]` now says how many kept elements there are up to and including place `j`. Slot `@l` of the output
holds the kept element whose rank is `@l + 1`: write the body that finds it. A kernel writes only the
place it owns, so the packing is done by the slot looking for its element, the other way round from a
loop that pushes. There is a second right answer with the rank counted the other way (only the kept
elements before each place); find it too. The checker verifies both, and it names the element where a near
miss goes wrong: one that zeroes the small ones and packs nothing, one that reads the rank one too high,
and one that keeps the 5s.

**What the GPU did differently from a loop:** a loop's output grows as it goes, so each append depends on
the one before. Here every thread learned its place from a count made all at once, and nobody waited for
anybody. The library's `Compact` does it the way a GPU prefers when the whole vector is the problem: each kept
element scatters itself to its own rank, found by a scan over the whole vector, and the count of kept
elements comes back as one number.
