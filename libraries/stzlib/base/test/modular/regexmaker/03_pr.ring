# Narrative
# --------
# pr()
#
# Extracted from stzregexmakertest.ring, block #3.

load "../../../stzBase.ring"


rx(pat(:email)) {
	? Pattern() + NL
	? ExplainXT()
}
#--> [a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}
#
# - `^` and `$`: Start and end of the string.
# - `[a-zA-Z0-9._%+-]+`: Local part allowing letters, numbers, and common special characters.
# - `@`: Required @ symbol.
# - `[a-zA-Z0-9.-]+`: Domain name allowing letters, numbers, dots, and hyphens.
# - `\.[a-zA-Z]{2,}`: Last part of the domain (TLD) with minimum 2 letters.
#
# - Matches: `user@domain.com`, `user.name+tag@example.co.uk`
# - Non-matches: `@domain.com`, `user@.com`, `user@domain`

pf()
# Executed in almost 0 second(s) in Ring 1.22
