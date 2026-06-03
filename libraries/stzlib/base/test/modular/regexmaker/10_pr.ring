# Narrative
# --------
# pr()
#
# Extracted from stzregexmakertest.ring, block #10.

load "../../../stzBase.ring"


rx(pat(:isoDateTime)) {

	# Getting the pattern string

	? Pattern() + NL
	#--> ^\d{4}-(0[1-9]|1[0-2])-(0[1-9]|[12][0-9]|3[01])T([01]?[0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9](\.[0-9]+)?(Z|[+-][01][0-9]:[0-5][0-9])?$

	# Getting a short explanation of the pattern

	? Explain() + NL
	#--> Mmatches ISO datetime

	# Getting a long explanation

	? ExplainXT()
	#-->
	# - `^` and `$`: Start and end of the string.
	# - `T`: Time separator.
	# - `(?:[01]\d|2[0-3])`: Hours 00-23.
	# - `[0-5]\d`: Minutes and seconds 00-59.
	# - `(?:\.\d+)?`: Optional milliseconds.
	# - `(?:Z|[+-][01]\d:[0-5]\d)`: Timezone.
	# - Matches: `2024-01-14T15:30:00Z`, `2024-01-14T15:30:00.123+01:00`
	# - Non-matches: `2024-01-14 15:30:00`, `2024-01-14T25:00:00Z`

}

pf()
# Executed in almost 0 second(s) in Ring 1.22

#---

pr()

# Test Web & Email

	rx(pat(:email)) { ? Match("user@example.com") }
	#--> TRUE
	
	rx(pat(:email)) { ? Match("invalid@email") }
	#--> FALSE
	
	rx(pat(:url)) { ? Match("http://example.com/path") }
	#--> TRUE
	
	rx(pat(:url)) { ? Match("not-a-url") + NL }
	#--> FALSE

# Test Dates & Times

	rx(pat(:isoDate)) { ? Match("2024-01-14") }
	#--> TRUE
	
	rx(pat(:isoDate)) { ? Match("2024-13-14") }
	#--> FALSE
	
	rx(pat(:time24h)) { ? Match("23:59") }
	#--> TRUE
	
	rx(pat(:time24h)) { ? Match("25:00")  + NL }
	#--> FALSE

# Test Numbers & Currency

	rx(pat(:number)) { ? Match("-12,345.67") }
	#--> TRUE

	rx(pat(:number)) { ? Match("1.2.3") }
	#--> FALSE
	
	rx(pat(:currencyValue)) { ? Match("1,234.56") }
	#--> TRUE
	
	rx(pat(:currencyValue)) { ? Match("1234.567") + NL }
	#--> FALSE

pf()
# Executed in 0.01 second(s) in Ring 1.22
