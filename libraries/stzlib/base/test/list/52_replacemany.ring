# Narrative
# --------
# ReplaceMany: collapse several distinct items into one value.
#
# Every occurrence of any item in [ "+", "-", "/" ] becomes "*". This is
# value-addressed (positions don't matter): the three operators scattered
# through the list all fold to "*", while "=" -- not in the search set --
# is left as-is. The :by label reads "replace many [...] by *".
#
# Extracted from stzlisttest.ring, block #52.

load "../../stzBase.ring"

pr()

o1 = new stzList([ "a", "+", "b", "-", "c", "/", "d", "=", "0" ])
o1.ReplaceMany( ["+", "-", "/" ], :by = "*" )
? o1.Content()	
#--> [ "a", "*", "b", "*", "c", "*", "d", "=", "0" ]

pf()
#--> Executed in 0.04 second(s)
