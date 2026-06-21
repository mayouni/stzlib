# Narrative
# --------
# EachItemIsA / ItemsAre: assert a property holds for EVERY item.
#
# EachItemIsA(:Number) checks a single type for all items; ItemsAre takes a
# list of qualifiers ([ :Positive, :Even, :Numbers ]) and is TRUE only when
# every item satisfies all of them. A compact way to validate a list's
# shape in one expressive line.
#
# Extracted from stzlisttest.ring, block #3.

load "../../stzBase.ring"

pr()

o1 = new stzList([ 2, 4, 8 ])
? o1.EachItemIsA(:Number)
#--> TRUE
? o1.ItemsAre([ :Positive, :Even, :Numbers ])
#--> TRUE

pf()
# Executed in almost 0 second(s)
