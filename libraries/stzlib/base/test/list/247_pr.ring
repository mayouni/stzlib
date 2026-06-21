# Narrative
# --------
# Lowercase + stringify + substring-replace every item of a stzList in one pass.
#
# StringifyLowercaseAndReplaceXT(",", "*") walks the list, coerces each
# non-string item to its string form (the numbers 10/100/1000 and the 1:3
# sublists), lowercases every string, and replaces "," with "*" inside each
# item (a codepoint-safe SUBSTRING replace). The result is a flat list of the
# transformed strings: "EMM, ahh," -> "emm* ahh*", "oh, bah,," -> "oh* bah**",
# and a 1:3 sublist renders as "[ 1, 2, 3 ]" then becomes "[ 1* 2* 3 ]" only
# where it held a comma. The transform returns the rewritten list itself, not
# any side index of which items changed.
#
# Extracted from stzlisttest.ring, block #247.

load "../../stzBase.ring"

pr()

o1 = new stzList(
	[] +
	"EMM, ahh," +
	"emm, ahh*" +
	"emm* AHH*" +
	1:3 +
	10 +
	100 +
	1:3 +
	1000 +
	"oh, bah,," +
	"[ 1* 2* 3 ]"
)

o1.StringifyLowercaseAndReplaceXT(",", "*")
o1.Show()
#--> [ "emm* ahh*", "emm* ahh*", "emm* ahh*", "[ 1* 2* 3 ]", "10", "100", "[ 1* 2* 3 ]", "1000", "oh* bah**", "[ 1* 2* 3 ]" ]

pf()
# Executed in 0.01 second(s)
