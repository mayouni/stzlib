### Puzzle 1 · Double it

A vector `a` holds 4,000 numbers: 0, 1, 2, 3 and so on. Write the kernel that puts twice each
number into `c`, so that `c[i] = a[i] * 2` for every element.

On a GPU there is no loop. One **thread** runs for every element at once, and your description
says what each thread does with *its* element: `@a` is that thread's `a`, `@c` its `c`. Start from

    in a
    out c

and add the body line. Until you do, the checker answers *waiting for your implementation*: a
puzzle starts red.

The checker runs your kernel on the device over the 4,000 numbers, and once more over a hidden
set of a different size with different numbers, and compares every element with the description
it holds. A kernel that answers right only where it was shown is caught there. Your program prints
the checker's one word.

Run it on the desktop (`rnxc your-file.ring`) or open the course's page in a browser with WebGPU:
the same description, the same verdict.

**What the GPU did differently from a loop:** nothing happened one after another. Four thousand
threads each read one number and wrote one number, in the same instant.
