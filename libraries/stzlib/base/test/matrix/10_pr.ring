# Narrative
# --------
# The updateColumn() retirement, ASSERTED
#
# Extracted from stzmatrixtest.ring, block #10 -- then the API it exercised
# was retired: updateColumn() was a global from the RingFastPro wrapper,
# deliberately deprecated and archived on 2026-06-13 (ea3868111, M-DEP1);
# it survives only under base/archive/number/stzFastPro.ring, which stzBase
# does not load. For a while this file stood as a documented tombstone that
# ERRORED on every run -- a permanent false alarm in full-suite sweeps.
#
# Now it asserts the retirement instead: the call MUST fail (if it ever
# succeeds, a global updateColumn came back and the M-DEP1 retirement
# broke), and the LIVING idiom -- stzMatrix.MultiplyCols, covered in full
# by test 11 -- reproduces the block's originally documented result.

load "../../stzBase.ring"

pr()

aMatrix = [
    [ 1, 2, 3 ],
    [ 4, 5, 6 ],
    [ 7, 8, 9 ]
]

# the retired global stays retired -- the error IS the expectation
bRetired = FALSE
try
    updateColumn(aMatrix, :mul, 1, 2, :mul, 3, 2)
catch
    bRetired = TRUE
done
if bRetired
    ? "[OK] updateColumn() stays retired (archived with RingFastPro, M-DEP1)"
else
    ? "[FAIL] a global updateColumn() came BACK -- the M-DEP1 retirement broke"
ok

# the living way to say the same thing: columns 1 and 3, doubled --
# exactly the result block #10 originally documented
o1 = new stzMatrix(aMatrix)
o1.MultiplyCols([1, 3], :By = 2)
o1.Show()
#-->
# ┌         ┐
# │  2 2  6 │
# │  8 5 12 │
# │ 14 8 18 │
# └         ┘

pf()
# Executed in almost 0 second(s) in Ring 1.22
