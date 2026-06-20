# Narrative
# --------
# HasSameContent(:As = ...): order-INsensitive equality -- do two lists
# hold the same items, regardless of arrangement?
#
# [ "I", "B", "M" ] and [ "B", "M", "I" ] are a reordering of one
# another, so HasSameContent is TRUE even though a positional == would be
# FALSE. The CS variant adds the case dial: with :CS = FALSE, "I","B","M"
# matches "b","m","i" once case is folded. (Contrast HasSameContentAs,
# the positional/multiset core this delegates to.)
#
# Extracted from stzlisttest.ring, block #369.

load "../../stzBase.ring"

pr()

? Q([ "I", "B", "M" ]).HasSameContent( :As = [ "B", "M", "I" ] )
#--> TRUE

? Q([ "I", "B", "M" ]).HasSameContentCS( :As = [ "b", "m", "i" ], :CS = FALSE )
#--> TRUE

pf()
# Executed in almost 0 second(s)
