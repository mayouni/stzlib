### Puzzle 4 · Where am I?

A vector `a` of 4,000 numbers: 0, 0.5, 1, 1.5 ... Write the kernel that adds to each element its own
position: `c[i] = a[i] + i`, counting positions from 0.

Every thread knows WHERE it stands: `@i` is its element number, from 0 up. It is not a vector you
declare; it is the thread's own place, and it is there in every kernel.

    in a
    out c

Off by one -- counting from 1 -- is wrong from the very first element, and the checker says so.

**What the GPU did differently from a loop:** there was no counter to increment. Each thread was
born knowing its number; four thousand numbers existed at once.
