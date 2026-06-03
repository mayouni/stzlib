# Narrative
# --------
# Example 5: Single Level No Children
#
# Extracted from stzregexmakertest.ring, block #21.
#ERR Error (R19) : Calling function with less number of parameters

load "../../stzBase.ring"


pr()

o2 = new stzRecursiveRegexMaker()
o2 {
    EnableNamedRecursion()
    AddLevel("simple", "abc")
    ? Pattern()
    #--> (?P<simple>abc)
}

pf()
# Executed in almost 0 second(s) in Ring 1.22
