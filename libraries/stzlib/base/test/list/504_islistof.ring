# Narrative
# --------
# Demonstrates Q(aList).IsListOf(:typeToken), the polymorphic guard that
# asks whether every item of a list matches a single named type.
#
# IsListOf() lowercases the token and dispatches through a switch: flat
# tokens like :StzNumbers and :StzStrings are honored (every item must be
# a stz object whose StzType() matches), so a list of StzNumberQ objects
# answers TRUE for :StzNumbers and a list of StzStringQ objects answers
# TRUE for :StzStrings. The nested tokens :ListsOfStzNumbers and
# :ListsOfStzStrings are NOT in the current dispatch table, so they fall
# through the switch's "other" branch and return FALSE -- even though the
# data really is a list of lists of stz objects. The standalone
# IsListOfListsOfStzNumbers()/...StzStrings() funcs exist in stzListFunc,
# but the method-side switch does not route to them yet.
#
# Extracted from stzlisttest.ring, block #504.

load "../../stzBase.ring"

pr()

# All these return TRUE

oNumber1 = StzNumberQ(7)
oNumber2 = StzNumberQ(12)
oNumber3 = StzNumberQ(24)

? Q([ oNumber1, oNumber2, oNumber3 ]).IsListOf(:StzNumbers)
#--> TRUE

? Q([ [oNumber1, oNumber2], [oNumber2, oNumber3] ]).IsListOf(:ListsOfStzNumbers)
#--> TRUE

oString1 = StzStringQ("Win")
oString2 = StzStringQ("Loose")
oString3 = StzStringQ("Don't care!")

? Q([ oString1, oString2, oString3 ]).IsListOf(:StzStrings)
#--> TRUE

? Q([ [oString1, oString2], [oString2, oString3] ]).IsListOf(:ListsOfStzStrings)
#--> TRUE

pf()
# Executed in 0.06 second(s).
