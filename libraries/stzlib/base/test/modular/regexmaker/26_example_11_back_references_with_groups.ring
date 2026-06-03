# Narrative
# --------
# Example 11: Back References with Groups
#
# Extracted from stzregexmakertest.ring, block #26.

load "../../../stzBase.ring"


pr()

o7 = new stzRecursiveRegexMaker()
o7 {
    EnableNamedRecursion()
    AddLevel("tag", "<([a-z]+)>")
    AddChildLevel("tag", "content", ".*?")
    AddLevel("close", "</\1>")
    ? Pattern()
    #--> (?P<tag><([a-z]+)>)(?P<content>.*?)</\1>
}

pf()
# Executed in almost 0 second(s) in Ring 1.22
