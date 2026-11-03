### Puzzle 18 · Round up to a power of two

Each element of `a` is a size, from 0 up to 3,999. Put into `c` the smallest power of two that holds
it, and at least 1: 1 for 0 and 1, 2 for 2, 4 for 3 and 4, 8 for 5 to 8, and so on up to 4,096.

The number of doublings depends on the size, so the kernel needs a loop whose length differs from one
element to the next. This is `iterate`:

    in a
    out c
    body { @c = iterate(k, 0, 40, s, 0.5, s * 2, s >= @a) }

`iterate(k, from, to, s, init, step, stop)` runs a **state** `s`, starting at `init`; on every pass
`k` counts up from `from` and the state becomes `step`. When the optional `stop` condition holds after
a pass, the loop ends with that pass's state, and its value is the state. Here: start at a half, double,
and stop as soon as the state holds the size. The loop runs at most 4,096 passes whatever you write, so
a kernel always ends, and a literal span past that is refused. `sum(k, a, b, e)` is the special case
that adds `e` each pass.

The state can be a float, an int (write `int(1)` to start one) or a vector. There is a second right
answer with no `stop`, and a third with an int state: find them. The checker verifies all three, and
it names the element where a near miss goes wrong: a stop that is `>` instead of `>=`, a start at 1, too
few passes.

**What the GPU did differently from a loop:** nothing, in the answer. In the cost, a great deal. Every
thread runs its OWN copy of this loop, a size of 3,000 for thirteen passes and a size of 1 for one. The
threads of a group move in step, so a group that holds one thread needing thirteen passes is held up
for thirteen, and the threads that finished early wait for it. A loop that stops early saves a thread's
work, not its group's time, unless the sizes next to each other are alike.
