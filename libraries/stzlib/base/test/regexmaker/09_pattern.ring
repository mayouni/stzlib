# Narrative
# --------
# pr()
#
# Extracted from stzregexmakertest.ring, block #9.

load "../../stzBase.ring"

pr()

rx(pat(:isoDate)) {

	# Getting the pattern string

	? Pattern() + NL
	#--> ^\d{4}-(0[1-9]|1[0-2])-(0[1-9]|[12][0-9]|3[01])$

	# Getting a short explanation of the pattern

	? Explain() + NL
	#--> Matches ISO dates (YYYY-MM-DD)

	# Getting a long explanation

	? ExplainXT()
	#-->
	# - `^` and `$`: Start and end of the string.
	# - `\d{4}`: Four-digit year.
	# - `(?:0[1-9]|1[0-2])`: Months 01-12.
	# - `(?:0[1-9]|[12]\d|3[01])`: Days 01-31.
	# 
	# - Matches: `2024-01-14`, `2023-12-31`
	# - Non-matches: `2024-13-01`, `2024-01-32`

}

pf()
# Executed in almost 0 second(s) in Ring 1.22
