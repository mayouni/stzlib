# Narrative
# --------
# Example 14: Empty Child Pattern
#
# Extracted from stzregexmakertest.ring, block #29.

load "../../stzBase.ring"


pr()

o10 = new stzRecursiveRegexMaker()
o10 {
    EnableNamedRecursion()
    AddLevel("parent", "start")
    AddChildLevel("parent", "empty", "")
    ? Pattern()
    #--> (?P<parent>start)(?P<empty>)
}

pf()
# Executed in almost 0 second(s) in Ring 1.22
