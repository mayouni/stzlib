# Narrative
# --------
# Example 13: Unicode Support
#
# Extracted from stzregexmakertest.ring, block #28.

load "../../stzBase.ring"


pr()

o9 = new stzRecursiveRegexMaker()
o9 {
    EnableNamedRecursion()
    AddLevel("unicode", "[\u0410-\u044F]+")
    AddChildLevel("unicode", "space", "\s+")
    ? Pattern()
    #--> (?P<unicode>[\u0410-\u044F]+)(?P<space>\s+)
}

pf()
# Executed in almost 0 second(s) in Ring 1.22
