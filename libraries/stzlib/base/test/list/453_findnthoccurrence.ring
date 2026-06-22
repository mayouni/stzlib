# Narrative
# --------
# Finds the position of the Nth occurrence of a value inside a list.
#
# FindNthOccurrence(n, :Of = value) walks the list counting how many
# times the value appears and returns the index where the n-th match
# lands. Here "A" sits at positions 1, 4 and 7, so the 3rd occurrence
# resolves to position 7. The :Of = "A" named-argument form is the
# readable Softanza idiom for "the n-th occurrence of this value".
# The follow-up Content() confirms the underlying list is unchanged.
#
# Extracted from stzlisttest.ring, block #453.

load "../../stzBase.ring"

pr()

o1 = new stzList([ "A", "B", "C", "A", "D", "B", "A" ])
? o1.FindNthOccurrence(3, :Of = "A")
#--> 7

? @@( o1.Content() )
# [ "A", "B", "C", "A", "D", "B", "A" ]

pf()
# Executed in 0.01 second(s) in Ring 1.21
