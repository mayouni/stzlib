### Puzzle 8 · Many hands, the fold

The 1,024 partial sums of puzzle 7 are now a vector `c`, and `m` (a scalar, 1,024) is how many
there are. Write the kernel that folds them into ONE number: `d[0] = c[0] + c[1] + ... + c[m-1]`.
The output has a single element.

    in c
    scalar m
    out d

Fold `m - 1` of them and the total is short by the last partial; copy `@c` and you have the first
partial, not the sum. Both are *mismatch at element 1* -- there is only one.

Together, puzzles 7 and 8 are a two-pass reduction: a thousand threads each sum sixteen, then one
thread sums the thousand. That is how a GPU adds a million numbers: never one after another the
whole way, never one thread doing it all.

**What the GPU did differently from a loop:** the loop's single running total was split into a
thousand small totals that no thread had to wait for, and then gathered once.
