### Puzzle 15 · Light on a surface

Each element is a point on a surface, and three inputs hold the direction the surface faces there,
its normal: `nx`, `ny` and `nz`. The sun shines along `(sx, sy, sz)`, which is `(2, -1, -2)`. A
surface is as bright as the cosine of the angle between the two directions, and a surface facing
away from the light gets none. Write the kernel that puts each point's brightness, 0 to 1, into `c`.

Three numbers that belong together are one value, a vector:

    vec3(@nx, @ny, @nz)

`dot(a, b)` multiplies two vectors component by component and adds; for two directions one long, it
is the cosine. `normalize(v)` makes a vector one long, `length(v)` says how long it is, and `.x`,
`.y`, `.z` read one component (`.zyx` reads three, reversed). Arithmetic works component by
component, and a number meeting a vector is spread across it: `vec3(sx, sy, sz) / 3`.

An output still holds one number per element, so a vector must be reduced before the end: `@c =
normalize(...)` is refused. A vector is not compared whole, either: compare a component, or a dot.

**What the GPU did differently from a loop:** the same arithmetic, written differently. A GPU has
always worked in vectors, positions and colours, and its language has `vec3` and `dot` built in;
the kernel says it in four words where a loop would spell out nine multiplications. Where the
answer needs a square root, the device rounds its last digit its own way, so this puzzle allows a
difference of 0.00001.
