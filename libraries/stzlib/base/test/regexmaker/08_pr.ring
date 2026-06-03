# Narrative
# --------
# pr()
#
# Extracted from stzregexmakertest.ring, block #8.

load "../../stzBase.ring"

pr()

rx(pat(:SocialHandle)) { ? Pattern() + NL + Explain() + NL + ExplainXT() }
#--> ^@[a-zA-Z0-9._]{1,30}$
#--> Matches social media handles
#-->
# - `^` and `$`: Start and end of the string.
# - `@`: Required @ symbol.
# - `[a-zA-Z0-9_]{1,15}`: 1-15 alphanumeric or underscore characters.
# - Matches: `@user123`, `@User_name`
# - Non-matches: `user123`, `@user-name`, `@toolong123456789`

pf()
# Executed in almost 0 second(s) in Ring 1.22
