### Puzzle 16 · Turn the points

The input `p` holds 4,000 points, each a `vec2`, and the kernel must turn every one of them around
the origin by the angle whose cosine is `c` (0.6) and whose sine is `s` (0.8), about 53 degrees.
A point `(x, y)` turned by that angle is `(c x - s y, s x + c y)`. Put each turned point into `q`.

This time the input and the output hold vectors, and the declarations say so:

    in p vec2
    scalar c
    scalar s
    out q vec2

A buffer of `vec2`s holds two numbers per element, side by side: element 7 is numbers 14 and 15.
`@p` is the element's point, `@p.x` and `@p.y` its two numbers, and the body's value must be a
`vec2`, as in `vec2(..., ...)`. A number is refused there, and a `vec3` too.

There are other ways to write the same rotation. Each new component is a dot product with one row
of the rotation, and the turned point is also `c` times the point plus `s` times the point turned
a quarter, `vec2(-@p.y, @p.x)`. The checker verifies all three.

**What the GPU did differently from a loop:** a loop would walk the array two numbers at a time and
keep the pairing in its head: index 2i is x, 2i + 1 is y. Here the declaration keeps it. The kernel
reads a point and writes a point, and the pairing is in one place, so it cannot drift.
