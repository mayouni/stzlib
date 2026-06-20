# Narrative
# --------
# ExtractLast(item): the mirror of ExtractFirst -- find the LAST
# occurrence of a value, return it, and remove it.
#
# Internally it counts the occurrences and extracts the nth (last) one,
# so on a list with several copies it peels off the trailing one. Here a
# trailing "_" sentinel is removed.
#
# Extracted from stzlisttest.ring, block #225.

load "../../stzBase.ring"

pr()

o1 = new stzList([ "A", "B", "C", "_" ])

? o1.ExtractLast("_") + NL
#--> "_"

? o1.Content()
#--> [ "A", "B", "C" ]

StopProfiler()

pf()
# Executed in almost 0 second(s)
