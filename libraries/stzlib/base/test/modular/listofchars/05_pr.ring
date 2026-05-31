# Narrative
# --------
# pr()
#
# Extracted from stzlistofcharstest.ring, block #5.

load "../../../stzBase.ring"


o1 = new stzListOfChars([ "a", "b", "c" ])

? o1.Unicodes()
#--> [ 97, 98, 99 ]

? CharsUnicodes([ "a", "b", "c" ])
#--> [ 97, 98, 99 ]

pf()
# Executed in 0.05 second(s).
