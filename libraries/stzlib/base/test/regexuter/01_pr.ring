# Narrative
# --------
# pr()
#
# Extracted from stzregexutertest.ring, block #1.

load "../../stzBase.ring"

pr()

? @@NL([ [ "Contact: john@email.net 123-456-7890 12345", "INVALID {Contact: john@email.net 123-456-7890 12345}" ], [ "123-456-7890", "INVALID {123-456-7890}" ], [ "12345", "12345" ] ])
#--> [
#	[
#			"Contact: john@email.net 123-456-7890 12345",
#			"INVALID {Contact: john@email.net 123-456-7890 12345}"
#	],
#	[
#			"123-456-7890",
#			"INVALID {123-456-7890}"
#	],
#	[ "12345", "12345" ]
# ]

pf()
