# Narrative
# --------
# IsQuietEqualTo: APPROXIMATE list equality, with a tunable tolerance.
#
# Two lists count as "quietly equal" if they are exactly equal, or if the
# relative difference in their lengths -- abs(lenA - lenB) / lenA -- is
# below the global QuietEqualityRatio (0.09 by default). Here a 5-item and
# a 7-item list differ by 2/5 = 0.40, so they are NOT equal at 0.09; raise
# the tolerance past 0.40 (SetQuietEqualityRatio(0.41)) and they are.
#
# The exact-equality test is the engine-backed content compare; the
# tolerance check is plain scalar arithmetic (no element scan).
#
# Extracted from stzlisttest.ring, block #508.

load "../../stzBase.ring"

pr()

# Softanza can compare lists (and strings also) in an approximative way.
# The degree of approximation can be tuned to fit your need.

o1 = new stzList([ "f","a","y","e","d" ])

? o1.IsQuietEqualTo([ "a","l", "f", "a","y","e","d" ])
#--> FALSE

# By default, the approximation factor is 0.09

? QuietEqualityRatio()
#--> 0.09

# And you can change it:

SetQuietEqualityRatio(0.41)

# Now the equality becomes TRUE

? o1.IsQuietEqualTo([ "a","l", "f", "a","y","e","d" ])
#--> TRUE

pf()
# Executed in almost 0 second(s)
