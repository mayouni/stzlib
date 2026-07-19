# Narrative
# --------
# Validate phone numbers
#
# Extracted from stzregexmakertest.ring, block #34.

load "../../stzBase.ring"


pr()

# Let's use the nice small function wrxm() or rxmw()
# ("w" for conditional, or you can use "c" if you want,
# and "rxm" for regex maker)

wrxm() {

	IfStartsWith("+").
   	ThenMatch("\+1\d{10}").     # International format
   	ElseMatch("\d{10}")         # Local format

	? Pattern()
}

#--> (?(?=^\+)\+1\d{10}|\d{10})
#
# IfStartsWith() takes LITERAL text and escapes it, so "+" means a plus
# sign. It used to emit (?(?=^+)...) -- a quantifier applied to ^, which
# does not compile at all, so this pattern never matched anything.

pf()
# Executed in almost 0 second(s) in Ring 1.22
