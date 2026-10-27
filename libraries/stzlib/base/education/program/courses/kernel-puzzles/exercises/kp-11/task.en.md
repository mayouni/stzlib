### Puzzle 11 · Softmax, one row per group

`a` holds 16 rows of 256 numbers. Turn each row into shares that add up to 1:
`c[i] = exp(a[i] - max) / sum`, where `max` is the row's largest value and `sum` the sum of
`exp(a - max)` over the row. One group of 256 threads is one row.

A **reduce** line folds a shared array into its slot 0, halving it with a barrier at each step:
256 values, then 128, 64 ... 1. `reduce m max` leaves the row's largest value in `@m[0]`;
`reduce s sum` leaves the total in `@s[0]`.

    stage { @m[@l] = @a }
    reduce m max
    stage { @s[@l] = exp(@a - @m[0]) }
    reduce s sum
    body { @c = exp(@a - @m[0]) / @s[0] }

After a reduce only slot 0 holds the answer; the other slots hold what the halving left in them.
Divide by `@s[@l]` and element 1 is right (it reads slot 0) and element 2 is not:
*mismatch at element 2*. Forget to divide: *mismatch at element 1*.

Subtracting the max does not change the answer: try the version without it and it verifies here,
on numbers between 0 and 0.9. It is there for the day the row holds 1,000, whose exponential does
not fit in a float.

**What the GPU did differently from a loop:** a loop finds the largest value by walking the row
once and adds by walking it again. Here each walk was eight halving steps, 256 threads wide.
