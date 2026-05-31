# Narrative
# --------
# #NLP
#
# Extracted from stzlisttest.ring, block #143.

load "../../../stzBase.ring"


pr()

# Word frequency analysis
aWords = [
    "the", "cat", "sat", "on", "the", "mat",
    "the", "cat", "sat", "there"
]

oWords = new stzList(aWords)

# Find all duplicate words

? @@(oWords.Duplicates()) + NL
#--> ["the", "cat", "sat"]

# Get word positions with context

? @@(oWords.DuplicatesZ())
#--> [ [ "the", [ 5, 7 ] ], [ "cat", [ 8 ] ], [ "sat", [ 9 ] ] ]

pf()
# Executed in almost 0 second(s).
