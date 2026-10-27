### Puzzle 10 · A matrix product in tiles

`a` is a 32 x 64 matrix and `b` a 64 x 48 one, row after row. Write `c = a x b`, 32 x 48:
`c[row][col]` is the sum over j of `a[row][j] * b[j][col]`. The scalars say the shape: `k` = 64 is
the inner length, `w` = 48 the width of `b` and `c`.

`width w` makes the output a matrix worked in **16 x 16 tiles**: each group of 256 threads computes
one tile of `c`, and a thread names its cell by `@row` and `@col`, its place inside the tile by
`@lx` (column, 0-15) and `@ly` (row, 0-15).

The plain way is right and slow: each thread reads 64 numbers of `a` and 64 of `b` from memory.
The tiled way turns `tiles t { k / 16 }` times; on each turn the group stages a 16 x 16 tile of `a`
and one of `b` into its own memory, and every thread adds sixteen products from there. Each number
is read from memory once per group instead of once per thread. The starter stages `a`'s tile:

    stage { @ta[@ly * 16 + @lx] = @a[@row * k + t * 16 + @lx] }

Write the tile of `b` (row `t * 16 + @ly`, column `@col`), then

    accumulate { @acc = @acc + sum(j, 0, 16, @ta[@ly * 16 + j] * @tb[j * 16 + @lx]) }
    body { @c = @acc }

`@acc` is the thread's running total, kept across turns. Turn once only and each cell has its
first sixteen products: *mismatch at element 1*. The hidden shape is another matrix, 16 x 80 times
80 x 32, so a kernel that knows 64 and 48 by heart fails there.

**What the GPU did differently from a loop:** a loop computes one cell after another. Here 256
cells were computed at once, and the numbers they all need were fetched once, together.
