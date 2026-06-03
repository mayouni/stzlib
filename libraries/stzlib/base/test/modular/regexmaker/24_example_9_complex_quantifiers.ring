# Narrative
# --------
# Example 9: Complex Quantifiers
#
# Extracted from stzregexmakertest.ring, block #24.

load "../../../stzBase.ring"


pr()

o5 = new stzRecursiveRegexMaker()
o5 {
    EnableNamedRecursion()
    AddLevel("list", "\[")
    AddChildLevel("list", "item", "[0-9]+")
    AddChildLevel("item", "separator", ",\s*")
    AddLevel("close", "\]")
    AddQuantifier("item", "+")
    AddQuantifier("separator", "?")
    ? Pattern()
    #--> (?P<list>\[)(?P<item>[0-9]+)(?P<separator>,\s*)?+\]
}

pf()
# Executed in almost 0 second(s) in Ring 1.22
