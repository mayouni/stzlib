### Puzzle 17 · Count the votes

4,000 people voted, each for one of 13 candidates numbered 0 to 12: the vote of person `i` is
`a[i]`. Count every candidate's votes into `h`, so that `h[k]` is how many people voted for `k`.

Until now each thread wrote its own element. Here 4,000 threads write into 13 counters, and many of
them into the same one at the same moment. A plain store would lose votes: two threads read 307,
both write 308, and one vote is gone. The output is declared as counters that only add:

    in a
    out h atomic 13
    body { @h[@a] += 1 }

`@h[index] += value` adds `value` to counter `index`, safely, whoever else adds to it at the same
time; `max=` and `min=` keep the larger or the smaller. The counters hold whole numbers and start at
0. An index outside 0 to 12 is dropped, not stored. The order the votes arrive in cannot change a
sum, so the checker's own count, on the CPU, is the answer the device must give.

**What the GPU did differently from a loop:** a loop counts one vote at a time and never has two
hands on one counter. Here every vote is counted at once, and the device makes the threads that
share a counter take turns. The more votes a candidate gets, the longer its line, which is why a
fast histogram on a GPU gives each group its own counters first, in shared memory, and adds them up
at the end.
