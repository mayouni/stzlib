### Puzzle 24 · A sparse matrix times a vector

A matrix with very few non-zero numbers is not stored whole. Here it is stored **eight entries to a row**: the vector `a`
holds the entries' values, the vector `b` holds the **column** each one sits in, and row `i` owns the entries 8*i to 8*i + 7
(a row with fewer than eight is padded; this is the fixed-width form). `x` is a dense vector with one number per column.
Put into `y`, for each row, its product with `x`: the sum over the row's entries of the value times the `x` of its column.

    in a
    in b
    in x
    out y

The new thing is the **gather**: `@x[@b[k]]` reads `x` not at the thread's own place but at the place another vector
names. On a GPU a gather is the cost of sparse work: the reads of `x` land wherever the columns say, so neighbouring threads
read far-apart places, and the bandwidth the dense puzzles used is mostly lost. There is a second right answer that loops
over the entry numbers themselves; find it. The checker verifies both, and names the element where a near miss goes wrong:
one that swaps the values and the columns, one with a row stride of 7, one that reads nine entries and so borrows the next
row's first, and one that forgets to gather and multiplies by the place in the row.

**What the GPU did differently from a loop:** a loop over the rows is a loop over the entries inside a loop over the rows.
Here every row is its own thread and walks only its eight entries. This is the shape of the library's sparse product
`Spmv`, with one difference: it takes the rows of any length (the CSR form, where a row starts where the offsets say) and
chooses between a thread a row, for short rows, and a workgroup a row, for long ones.
