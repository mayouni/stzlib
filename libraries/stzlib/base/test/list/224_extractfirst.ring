# Narrative
# --------
# ExtractFirst(item): find the FIRST occurrence of a given value, return
# it, and remove it from the list.
#
# Unlike ExtractAt (which takes a position), ExtractFirst takes the VALUE
# to look for -- it is the destructive sibling of FindFirst. Here the
# leading "_" sentinel is pulled off, leaving the real payload behind.
#
# Extracted from stzlisttest.ring, block #224.

load "../../stzBase.ring"

pr()

o1 = new stzList([ "_", "A", "B", "C" ])

? o1.ExtractFirst("_") + NL
#--> "_"

? o1.Content()
#--> [ "A", "B", "C" ]

StopProfiler()

pf()
# Executed in almost 0 second(s)
