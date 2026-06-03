# Narrative
# --------
# Match HTML tags with specific attributes
#
# Extracted from stzregexmakertest.ring, block #42.

load "../../../stzBase.ring"


pr()

o1 = new stzRegexLookAroundMaker
o1 {
	MustBeFollowedByWord("class").
	ThenMatch("<\w+\s+")
	? Pattern()
}
#--> (?=\bclass\b)<\w+\s+

pf()
# Executed in almost 0 second(s) in Ring 1.22
