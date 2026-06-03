# Narrative
# --------
# pr()
#
# Extracted from stzlistofnumberstest.ring, block #74.

load "../../../stzBase.ring"


o1 = new stzString("weloveringlanguage!")

o1.SpacifySubStrings([ "love", "ring", "language" ])

? o1.Content()
# we love ring language !

pf()
# Executed in 0.06 second(s)
