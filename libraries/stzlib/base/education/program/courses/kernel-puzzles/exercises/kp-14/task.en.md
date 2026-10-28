### Puzzle 14 · Roll the dice

Each element of `a` is a seed: 0, 7, 1, 8, 2, 9 ... (whole numbers up to 12). A classic generator
turns a seed into the next number as `seed x 1664525 + 1013904223`, and a die with a thousand faces
keeps the last three digits. Write the kernel that puts each seed's roll into `c`: seed 7 rolls 898.

The numbers here are whole, and the kernel says so:

    in a int
    out c int

`int` makes `@a` a whole number, and every operation on it whole: `/` drops the remainder and `%`
gives it. A whole number that meets an int is an int; one with a decimal point is a float.

Try it in floats first, with `in a` and `out c`, and the checker names element 1. A float keeps 24
binary digits, about seven decimal ones, and 1,013,904,223 has ten: as a float it is 1,013,904,192,
so seed 0 rolls 192, not 223. An int keeps every digit.

An int and a float never meet without saying so: `@a * 0.5` is refused. Write `float(@a) * 0.5`,
or `int(...)` the other way.

**What the GPU did differently from a loop:** nothing, this time: a loop over floats on a CPU loses
the same digits. What is worth knowing is how a GPU's int behaves at its edges. It wraps around past
2,147,483,647, as on every CPU. And on the RTX 3050 this course was built on, the GPU's compiler took
`%` of a negative int as if the int had no sign (-7 % 4 came out 1, where WGSL says -3), so the
transpiler writes every int remainder out itself, and the checker found that by comparing.
