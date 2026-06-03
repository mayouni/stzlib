# Narrative
# --------
# #narration List approximate comparison in Softanza
#
# Extracted from stzlisttest.ring, block #508.

load "../../stzBase.ring"


pr()

# Softanza can compare lists (and strings also), in an approximative way.
# The degree of approximation can be tuned to fit with your need.

o1 = new stzList([ "f","a","y","e","d" ])

? o1.IsQuietEqualTo([ "a","l", "f", "a","y","e","d" ])
#--> FALSE

# By default, the approximation facor is 0.09

? QuietEqualityRatio()
#--> 0.09

# And you can change it:

SetQuietEqualityRatio(0.41)

# Now the equality becomes TRUE

? o1.IsQuietEqualTo([ "a","l", "f", "a","y","e","d" ])
#--> TRUE

pf()
# Executed in almost 0 second(s).
