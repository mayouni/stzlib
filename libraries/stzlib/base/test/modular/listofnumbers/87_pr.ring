# Narrative
# --------
# pr()
#
# Extracted from stzlistofnumberstest.ring, block #87.

load "../../../stzBase.ring"


o1 = new stzListOfNumbers(1:8)
o1.ReplaceSectionWith(3, 5, 2)
#--> [ 1, 2, 2, 2, 2, 6, 7, 8 ]
? @@( o1.Content() )

pf()
# Executed in 0.03 second(s)
