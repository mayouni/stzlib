# Narrative
# --------
# Match words not followed by punctuation
#
# Extracted from stzregexmakertest.ring, block #41.

load "../../stzBase.ring"


pr()

# Let's use the nice small function rxma() or arxm(), with
# 'rxm' meaning regex maker and 'a' meaning looking 'a'round

rxma() {
	CantBeFollowedBy("[.,!?]").
	ThenMatch("\w+")
	? Pattern()
}
#--> (?![.,!?])\w+

pf()
# Executed in almost 0 second(s) in Ring 1.22
