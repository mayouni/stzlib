### Puzzle 3 · One number for everyone

A vector `a` of 4,000 numbers and a parameter `alpha`. Write the kernel that scales every element:
`c[i] = alpha * a[i]`.

A **scalar** is one value that every thread reads; it does not come from a vector. Declare it with
a `scalar` line and use its bare name in the body:

    in a
    scalar alpha
    out c

Do not write the number itself: the checker binds `alpha` for you, and a kernel that wrote `2`
is wrong for every element where alpha is not 2 (it is 2.5 here).

**What the GPU did differently from a loop:** the parameter was not passed four thousand times.
It sat once in a small uniform buffer, and every thread looked at the same place.
