# Narrative
# --------
# Example 10: Special Characters Escaping
#
# Extracted from stzregexmakertest.ring, block #25.

load "../../../stzBase.ring"


pr()

o6 = new stzRecursiveRegexMaker()
o6 {
    EnableNamedRecursion()
    AddLevel("special", "\$\^\*\+\?\{\}\[\]\(\)")
    ? Pattern()
    #--> (?P<special>\$\^\*\+\?\{\}\[\]\(\))
}

pf()
# Executed in almost 0 second(s) in Ring 1.22
