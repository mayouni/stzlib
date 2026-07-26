# Narrative
# --------
# pr()
#
# Extracted from stzmatrixtest.ring, block #10.
#
# CANNOT PASS, AND SHOULD NOT BE "FIXED" IN stzMatrix. The updateColumn() below
# is a global from the RingFastPro wrapper, which was deliberately deprecated and
# archived on 2026-06-13 (ea3868111, M-DEP1); it now exists only under
# base/archive/number/stzFastPro.ring, which stzBase does not load. The test
# exercises a retired API, not a matrix defect -- the equivalent matrix method,
# MultiplyCols, was repaired separately and its test (11) passes.

load "../../stzBase.ring"

pr()

aMatrix = [
    [ 1, 2, 3 ],
    [ 4, 5, 6 ],
    [ 7, 8, 9 ]
]

updateColumn(aMatrix, :mul, 1, 2, :mul, 3, 2)

? @@NL(aMatrix)
#--> [
#	[ 2, 2, 6 ],
#	[ 8, 5, 12 ],
#	[ 14, 8, 18 ]
# ]

pf()
# Executed in almost 0 second(s) in Ring 1.22
