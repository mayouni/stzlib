### Puzzle 19 · What changed since the slice before

A volume is a stack of slices, and each slice is a grid. The volume `a` here is 4 slices of 32 × 32 cells
(the hidden shape is another one: 3 slices of 16 × 32). Put into `c`, for every cell, how much it changed
since the slice before it: the cell minus the same cell one slice back. The first slice has nothing before
it, so it keeps its own value.

A kernel sees a volume through two lines that a plain output does not have:

    in a
    scalar w
    scalar d
    scalar p
    out c
    width w
    depth d
    body { @c = @a }

`width w` makes the output a grid `w` cells wide, worked in 16 × 16 tiles; `depth d` stacks `d` of those
grids. A cell finds its place by three names: `@slice`, which grid it is in, and `@row` and `@col`, which
are its row and column **inside that slice**. `@i` is its place in the whole volume, and the scalar `p` is
the number of cells in one slice, so one slice back is `@i - p`. `@slice` without a `depth` line is
refused, and a `depth` line needs a `width` line. A read before the first element gives 0, as it does
everywhere.

There is a second right answer that leans on that zero, and a third that moves the branch. The checker
verifies all three, and it names the element where a near miss goes wrong: one that compares rows instead
of slices, one that writes the slice size as a number (it works only for the shape shown), and one that
skips the second slice.

The slice size arrives as `p` and is not computed as `n / d`, on purpose: a float division is not exact on
every device (some multiply by a reciprocal, and fused with the subtraction the index lands a hair under
its element and reads the one before), so a size that feeds an index is better given exactly.

**What the GPU did differently from a triple loop:** the three nested loops, over slices, rows and columns,
are gone. There is one thread per cell, and it learns its slice, row and column from its place. Its group
is a 16 × 16 tile of **one** slice, never a tile that straddles two, which is why a slice must be a whole
number of tiles. The cost of this puzzle is two reads per cell, each coalesced: the neighbouring threads
of a group read neighbouring addresses, in the slice and in the slice before.
