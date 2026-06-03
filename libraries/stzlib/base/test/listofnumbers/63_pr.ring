# Narrative
# --------
# pr()
#
# Extracted from stzlistofnumberstest.ring, block #63.

load "../../stzBase.ring"


o1 = new stzCCode('{ Q(This[@i]).IsDividableBy(4) and This[@i] <= 20 }')
? o1.ExecutableSection()
#--> [1, :Last]

pf()
# Executed in 0.12 second(s)
