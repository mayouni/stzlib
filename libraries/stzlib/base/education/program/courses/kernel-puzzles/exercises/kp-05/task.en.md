### Puzzle 5 · The threads that have no element

Double a vector of 4,000 numbers again -- but this time YOU write the bounds guard.

Threads come in groups of 256. For 4,000 elements the device starts 16 groups: 4,096 threads, and
the last 96 have no element. A thread past the end must not write. The guard is a line of its own,
a condition over `@i` (the thread's number) and `n` (the element count):

    in a
    out c
    guard { @i < n }

Try the puzzle three ways. With the guard: *verified*. With `guard none`: the 96 extra threads
write past the region, into the checker's margin, and the verdict names the first of them:
*write-outside at element 4001*. With `guard { @i < n - 1 }`: element 4000 is never written, and
the verdict is *mismatch at element 4000*. The checker tells the two mistakes apart.

**What the GPU did differently from a loop:** a loop stops when it reaches the end. The GPU never
stops; it starts a whole group at a time, and the threads past the end exist whether you want them
or not. The guard is how you tell them to stay silent.
