# Narrative
# --------
# Example 7: Deeply Nested Structure
#
# Extracted from stzregexmakertest.ring, block #23.
#ERR Error (R19) : Calling function with less number of parameters

load "../../stzBase.ring"


pr()

o4 = new stzRecursiveRegexMaker()
o4 {
    EnableNamedRecursion()
    AddLevel("outer", "\{")
    AddChildLevel("outer", "inner1", "\[")
    AddChildLevel("inner1", "inner2", "\(")
    AddChildLevel("inner2", "content", "[^()]*")
    AddLevel("close", "\)\]\}")
    ? Pattern()
    #--> (?P<outer>\{)(?P<inner1>\[)(?P<inner2>\()(?P<content>[^()]*)\)\]\}
}

pf()
# Executed in almost 0 second(s) in Ring 1.22
