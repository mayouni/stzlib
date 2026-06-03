# Narrative
# --------
# pr()
#
# Extracted from stzregexmakertest.ring, block #7.

load "../../stzBase.ring"


rx(pat(:IPv6)) {

	# Getting the pattern string

	? Pattern() + NL
	#--> (([0-9a-fA-F]{1,4}:){7,7}[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,7}:|([0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4})

	# Getting a short explanation of the pattern

	? Explain() + NL
	#--> Matches basic IPv6 addresses

	# Getting a long explanation

	? ExplainXT()
	#-->
	# - `^` and `$`: Start and end of the string.
	# - `[A-F0-9]{1,4}`: Hexadecimal groups.
	#- Seven groups with colons, plus final group.
	# - Matches: `2001:0DB8:0000:0000:0000:0000:1428:57AB`
	# - Non-matches: `2001::1428:57AB` (compressed form)

}

pf()
# Executed in almost 0 second(s) in Ring 1.22
