### Puzzle 2 · Two vectors, one sum

Two vectors of 4,000 numbers: `a` holds 0, 1, 2, 3 ... and `b` holds 0, 0.5, 1, 1.5 ... Write the
kernel that puts their sum into `c`: `c[i] = a[i] + b[i]`.

Each thread owns one element of EVERY vector it declares: `@a` and `@b` are that thread's two
numbers, `@c` where its answer goes. Start from

    in a
    in b
    out c

A kernel that reads `a` twice and never `b` is right at the first element (both are 0) and wrong
from the second; the checker names the element.

**What the GPU did differently from a loop:** a loop would walk two arrays side by side, index by
index. Here every thread already stands at its own index in both; no walking happened.
