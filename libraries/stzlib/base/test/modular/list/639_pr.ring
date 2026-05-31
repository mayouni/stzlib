# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #639.

load "../../../stzBase.ring"


o1 = new stzList([ :ring, 5, :php, :ruby, :python, :ring, 5 ])
? o1.NumberOfOccurrence(5)
#--> 2

? o1.NumberOfOccurrence(:ring)
#--> 2

pf()
# Executed in 0.01 second(s).
