# Narrative
# --------
# URL protocol matcher
#
# Extracted from stzregexmakertest.ring, block #36.

load "../../../stzBase.ring"


pr()

wrxm() {
	IfContains("localhost").
	ThenMatch("http://localhost:\d+/.*").
	ElseMatch("https://.*")

	? Pattern()
}

#--> (?(?=.*localhost.*.)http://localhost:\d+/.*|https://.*))

pf()
# Executed in almost 0 second(s) in Ring 1.22
