# Narrative
# --------
# Trimming the leading and trailing "empty" items off a stzList.
#
# TrimLeft() and TrimRight() walk inward from each end and drop the
# edge items until they hit a non-trimmable one. In the current
# stzListTrimmer the only items considered trimmable are empty
# strings (isString and ring_trim = ""): numbers, NULL, and empty
# sublists [] are NOT stripped. So for [ 0, "", [], 1, 2, 3, [], NULL, 0 ]
# both ends begin with the number 0, the walk stops immediately, and
# the list is returned unchanged. The recorded #--> [ 1, 2, 3 ] reflects
# an older, broader notion of emptiness (treating 0, "", [], NULL as
# all trimmable); it no longer matches the implementation.
#
# Extracted from stzlisttest.ring, block #99.

load "../../stzBase.ring"

pr()

o1 = new stzList([ 0, "", [], 1, 2, 3, [], NULL, 0 ])

o1.TrimLeft()
o1.TrimRight()

? @@( o1.Content() )
#--> [ 1, 2, 3 ]

pf()
# Executed in almost 0 second(s) in Ring 1.22
