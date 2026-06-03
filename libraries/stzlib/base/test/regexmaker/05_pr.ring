# Narrative
# --------
# pr()
#
# Extracted from stzregexmakertest.ring, block #5.

load "../../stzBase.ring"


rx(pat(:domain)) { ? Explain() + NL }
#--> Matches domain names

rx(pat(:domain)) { ? Pattern() + NL }
#--> ^(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?$

rx(pat(:domain)) { ? ExplainXT() }
#-->
# - `^` and `$`: Start and end of the string.
# - `[a-z0-9](?:[a-z0-9-]*[a-z0-9])?`: Domain segments.
# - `\.`: Dot separator.
# - Matches: `example.com`, `sub.domain.co.eg`
# - Non-matches: `-example.com`, `domain..com`

pf()
# Executed in almost 0 second(s) in Ring 1.22
