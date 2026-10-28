### Puzzle 13 · Two prices

A vector of 4,000 amounts, `a`, holds 0, 7, 1, 8, 2, 9 ... (never more than 12), and a scalar `t`
is 6. The first `t` units of an amount cost 1 each, and every unit past `t` costs 2. Write the
kernel that puts the price of each amount into `c`: 5 costs 5, and 9 costs 6 + 2 x 3 = 12.

The price has two formulas, and which one applies depends on the amount.
`when(condition, value if true, value if false)` is that choice:

    in a
    scalar t
    out c
    body { @c = when(@a <= t, ..., ...) }

The condition compares values, as a guard does: `@a <= t`. It is not a number, so `(@a > t) * 2`
is refused, and so is a number where the condition goes, `when(@a - t, ...)`. Put the two prices in
each other's place and the checker names the first element where they differ.

There is a second answer with no `when` in it: the price is the amount, plus what is over `t` once
more. Find it; the checker verifies it too.

**What the GPU did differently from a loop:** in a loop, an `if` runs one side and skips the other.
The threads of a group run in step, so this kernel computes BOTH prices and keeps one: its WGSL is
`select(value if false, value if true, condition)`, the false value first. A choice on a GPU costs
both of its sides. Here each side is one line of arithmetic, so the cost is small; when one side is
long, every thread of the group waits for it.
