# Narrative
# --------
# StartProfiler()
#
# Extracted from stzlisttest.ring, block #324.
#ERR Error (R14) : Calling Method without definition: removesubstringsboundedbyib

load "../../stzBase.ring"

pr()

o1 = new stzString('Hello ]---[Ring!]---[')

o1.RemoveSubStringsBoundedByIB([ "]","[" ])
? o1.Content()
#--> Hello Ring!

StopProfiler()

pf()
# Executed in 0.04 second(s)
