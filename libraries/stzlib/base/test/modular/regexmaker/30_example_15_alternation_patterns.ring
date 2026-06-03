# Narrative
# --------
# Example 15: Alternation Patterns
#
# Extracted from stzregexmakertest.ring, block #30.

load "../../../stzBase.ring"


pr()

o11 = new stzRecursiveRegexMaker()
o11 {
    EnableNamedRecursion()
    AddLevel("choice", "(yes|no)")
    AddChildLevel("choice", "maybe", "(?:maybe)?")
    ? Pattern()
    #--> (?P<choice>(yes|no))(?P<maybe>(?:maybe)?)
}

pf()
# Executed in almost 0 second(s) in Ring 1.22
