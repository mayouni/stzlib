# Narrative
# --------
# pr()
#
# Extracted from stzregexmakertest.ring, block #6.

load "../../../stzBase.ring"


rx(pat(:ipv4)) {
	? Explain() + NL
	? Pattern() + NL
	? ExplainXT()
}
#-->
# Matches IPv4 addresses
# ^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$
#
# - `^` and `$`: Start and end of the string.
# - `25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?`: Numbers 0-255.
# - Repeated 4 times with dots.
# - Matches: `192.168.0.1`, `10.0.0.0`
# - Non-matches: `256.1.2.3`, `1.2.3`, `a.b.c.d`

pf()
# Executed in almost 0 second(s) in Ring 1.22
