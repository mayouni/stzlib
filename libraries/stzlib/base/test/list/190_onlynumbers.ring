# Narrative
# --------
# OnlyNumbers() keeps just the numeric members of a heterogeneous list.
#
# The source mixes three kinds of items: the integer range 1:7, two
# string labels ("str1", "str2"), and a list of operator strings
# ("+", "-"). OnlyNumbers() walks the whole collection and returns a
# fresh list containing only the elements Softanza recognizes as
# numbers, dropping every string and nested item. Here the seven
# range integers survive and everything else is discarded, giving
# [ 1, 2, 3, 4, 5, 6, 7 ]. It is the numeric counterpart to the
# type-filtering family (OnlyStrings, OnlyLists, ...).
#
# Extracted from stzlisttest.ring, block #190.

load "../../stzBase.ring"

pr()

o1 = new stzList( 1:7 + "str1" + "str2" + [ "+", "-" ] )
? @@( o1.OnlyNumbers() )
#--> [ 1, 2, 3, 4, 5, 6, 7 ]

pf()
# Executed in 0.03 second(s)
