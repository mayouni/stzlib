### Puzzle 7 · Many hands, first pass

A vector `a` of 16,384 numbers (0, 0.1, 0.2 ... 0.9, 0, 0.1 ...). You want their total. One thread
cannot add 16,384 numbers quickly, but 1,024 threads can each add 16: write the kernel whose thread
`i` sums its own window, `c[i] = a[16i] + a[16i+1] + ... + a[16i+15]`, into a vector of 1,024
partial sums.

A bounded sum is written `sum(k, from, to, expression)`: `k` runs from `from` up to but not
including `to`, and the expression may use `k`. The input is longer than the output here; declare
them as always:

    in a
    out c

Sum 15 instead of 16 and every partial is wrong from the first; slide the window by 1 instead of
16 and only the first partial is right -- the checker names the element either way.

**What the GPU did differently from a loop:** a loop adds 16,384 numbers one after another, sixteen
thousand steps. Here 1,024 threads each took sixteen steps, side by side: the work was the same,
the waiting was a thousandth.
