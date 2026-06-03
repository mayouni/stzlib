# Narrative
# --------
# Find numbers with specific context
#
# Extracted from stzregexmakertest.ring, block #43.

load "../../stzBase.ring"


pr()

rxma() {
	MustBePrecededByWord("version").
	MustBeFollowedByWord("release").
	ThenMatch("\d+\.\d+")

	? Pattern()
}
#--> (?<=\bversion\b)(?=\brelease\b)\d+\.\d+

pf()
# Executed in almost 0 second(s) in Ring 1.22
