# Narrative
# --------
# pr()
#
# Extracted from stzlistofnumberstest.ring, block #64.

load "../../stzBase.ring"


o1 = new stzListOfNumbers([ 4, 7, 36, 9, 20 ])

? o1.FindW('{ Q(This[@i]).IsDividableBy(4) and This[@i] <= 20 }')
#--> [1, 5]

pf()
# Executed in 0.15 second(s)
