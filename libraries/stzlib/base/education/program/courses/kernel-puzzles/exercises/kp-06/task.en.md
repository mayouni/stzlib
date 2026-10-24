### Puzzle 6 · Look at your neighbours

A vector `a` of 4,000 numbers that go 0, 7, 1, 8, 2, 9 ... (each is `(i * 7) % 13`). Write the kernel
that smooths it: each element becomes the mean of its left neighbour, itself and its right
neighbour, `c[i] = (a[i-1] + a[i] + a[i+1]) / 3` -- and the two edges, which have only one
neighbour, are left unwritten.

A thread may read ANOTHER element of an input: `@a[@i - 1]` is the one before, `@a[@i + 1]` the one
after. Outside the vector a read answers 0, so the edges are yours to guard:

    in a
    out c
    guard { @i > 0 and @i < n - 1 }

Without the edge guard, the edges get written and the verdict is *mismatch at element 1*: the
first edge, which the task says to leave.

**What the GPU did differently from a loop:** every thread read three numbers at once, and its
neighbours were reading the same numbers at the same instant; nobody waited for the thread before.
