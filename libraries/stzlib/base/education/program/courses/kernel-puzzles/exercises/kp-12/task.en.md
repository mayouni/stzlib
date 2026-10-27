### Puzzle 12 · How fast can it be?

Write `c = alpha * a + b` over two vectors (`alpha` is 2.5). It is puzzle 2 with a scalar, and you
will get it right on the first try. The puzzle is what comes after the verdict.

Once your kernel verifies, the page runs it again on 4,194,304 elements and places it under this
machine's two **roofs**, measured on the spot with the engine's own kernels:

- the **bandwidth roof**: how many bytes per second a plain copy moves here;
- the **compute roof**: how many operations per second a kernel of nothing but multiply-adds does.

Your kernel reads two numbers, writes one and does two operations: 12 bytes for 2 operations. That
is far less work per byte than the device can do, so it waits on memory, and the number that
matters is its share of the bandwidth roof. The page says which roof is the lower one for it.

Then try this one, also right:

    body { @c = alpha * @a + @b + 0 * sum(k, 0, 64, @a[k]) }

It gives the same numbers, and every thread reads 64 more. Compare the two shares. *verified* says
the answer is right; it does not say the kernel is good.

**What the GPU did differently from a loop:** a loop's time is its steps. A kernel's time is the
slowest of two things, the bytes it moves and the arithmetic it does, and here it is almost always
the bytes.
