### Puzzle 9 · The group's own memory

A vector `a` of 4,096 numbers (0, 1, 2 ...). Reverse it **within each group of 256**: the first group
becomes 255, 254 ... 0, the second 511, 510 ... 256, and so on.

The 256 threads of a group share a small, fast memory that the threads of other groups cannot see.
`shared t 256` declares an array of 256 numbers there. A **stage** line is one write per thread
into it; after the stage the engine puts a **barrier**: no thread goes on until every thread of the
group has written. `@l` is a thread's place in its group, 0 to 255.

    stage { @t[@l] = @a }
    body { @c = @t[255 - @l] }

After the barrier, each thread reads the slot that ANOTHER thread wrote. Without the stage the
array is all zeros: *mismatch at element 1*. Reverse the whole vector instead and element 1 is
4,095 where 255 was owed: *mismatch at element 1* again.

The stage writes the barrier for you. In a kernel written by hand, a forgotten barrier is the race
that passes most tests and fails one.

**What the GPU did differently from a loop:** a loop that reverses in place swaps pairs one after
another. Here 256 threads wrote at once, waited once, and read at once.
