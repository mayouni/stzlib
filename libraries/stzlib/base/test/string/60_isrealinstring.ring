# Narrative
# --------
# IsRealInString() asks whether the string content represents a real number --
# an alias of RepresentsRealNumber(). The global BothAreRealsInStrings(a, b)
# checks two at once.
#
# Extracted from stzlisttest.ring, block #60.

load "../../stzBase.ring"

pr()

? Q("2.8").IsRealInString()
#--> TRUE

? Q("3.2").IsRealInString()
#--> TRUE

? BothAreRealsInStrings("2.8", "3.2")
#--> TRUE

pf()
