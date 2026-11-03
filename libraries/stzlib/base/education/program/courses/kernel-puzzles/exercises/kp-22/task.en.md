### Puzzle 22 · Sort a group

A vector `a` of 4,096 numbers, each from 0 to 12. Sort **each group of 256** into ascending order: the group's
smallest number first. (A short last group would see its missing numbers as 0.)

A loop would swap neighbours until nothing moves. No thread can see the whole order, so the answer comes from what
each thread can work out alone: its **rank**, how many numbers in the group go before its own. Equal numbers need a
tie-break, or two of them claim the same rank and a slot is left empty: here, the one that sits first in the group
goes first.

    in a
    out c
    shared t 256
    shared r 256
    stage { @t[@l] = @a }
    stage { @r[@l] = sum(j, 0, 256, when(@t[j] < @t[@l] or (@t[j] == @t[@l] and j < @l), 1, 0)) }

`@r[l]` is now the place the number at `l` belongs in. As in the last puzzle, a kernel writes only the place it owns,
so slot `@l` looks for the number whose rank is `@l`: write that body. A second right answer breaks the ties the other
way (the equal number that sits later goes first); find it. The checker verifies both, and it names the element where
a near miss goes wrong: ties given the same rank, which leaves holes and doubles; a count that includes the number
itself, which makes every rank one too high; and a ranking by the larger, which sorts downward.

**What the GPU did differently from a loop:** a sorting loop moves numbers past one another, one comparison after
another. Here all 256 numbers were compared with all 256 at once, and every one learned its place from the count:
65,536 comparisons in one step, no thread waiting for another. That is wasteful for a large vector, which is why the
library's `Sort` does not do it: it makes eight passes of four bits, each placing every key by counting the keys whose
digit comes before its own, so the work grows with the size of the vector and not with its square.
