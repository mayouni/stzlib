# Narrative
# --------
# Example 6: Multiple Independent Levels
#
# Extracted from stzregexmakertest.ring, block #22.
#ERR Error (R19) : Calling function with less number of parameters

load "../../stzBase.ring"


pr()

o3 = new stzRecursiveRegexMaker()
o3 {
    EnableNamedRecursion()
    AddLevel("first", "abc")
    AddLevel("second", "def")
    ? Pattern()
    #--> (?P<first>abc)(?P<second>def)
}

pf()
# Executed in almost 0 second(s) in Ring 1.22
