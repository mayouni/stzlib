# Narrative
# --------
# StartProfiler()
#
# Extracted from stzlisttest.ring, block #324.

load "../../stzBase.ring"

pr()

o1 = new stzString('Hello ]---[Ring!]---[')

o1.RemoveSubStringsBoundedByIB([ "]","[" ])
? o1.Content()
#--> Hello Ring!

StopProfiler()

pf()
# Executed in 0.04 second(s)
