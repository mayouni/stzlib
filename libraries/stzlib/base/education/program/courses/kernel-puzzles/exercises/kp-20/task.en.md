### Puzzle 20 · The running total of a group

A vector `a` of 4,000 numbers. Put into `c` the **running total inside each group of 256**: element `i` of a
group holds the sum of the group's elements 0 to `i`. Each group starts over, so element 256 is `a[256]`
alone, not everything before it. The last group holds 160 numbers; the 96 threads past the end add nothing.

The 256 threads of a group see each other's numbers through the group's memory (puzzle 9). The slow answer
lets every thread add up its own prefix:

    in a
    out c
    shared t 256
    stage { @t[@l] = @a }
    body { @c = sum(j, 0, 256, when(j <= @l, @t[j], 0)) }

That is up to 256 additions in a thread, and the threads wait for the longest. There is a faster answer in
eight steps, each doubling the reach: in step `s` every thread adds the number `2^s` places to its left.
It needs a second array (a stage may not read the array it writes), a `tiles` loop of eight turns and two
stages in each, and `pow(2, s)` for the distance. A read before the start of an array gives 0, so the
threads at the edge need no branch. Find it. The checker verifies both, and it names the element where a
near miss goes wrong: one that leaves out the thread's own number, one that does not start over at each
group, and one with seven steps, which reaches only 128 places back.

**What the GPU did differently from a loop:** a loop carries one running total from element to element,
so the third waits for the second. Here no thread waits for another's total. In eight steps every one of
the 256 totals is done, where the loop took 256 turns one after the other, at the price of about eight
times the additions. This is the block step of the library's `Scan`: it scans each block of 256 this way,
scans the totals of the blocks the same way, and adds each block's offset back.
