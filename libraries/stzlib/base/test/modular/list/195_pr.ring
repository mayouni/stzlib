# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #195.

load "../../../stzBase.ring"


o1 = new stzList(1 : 299_000 + 4)

? o1.FindFirst(4)
#--> 4
# Executed in 0.88 second(s)

? o1.FindLast(4)
#--> 299001
# Executed in 0.94 second(s)

? o1.FindNth(:First, 4)
#--> 4
# Executed in 0.89 second(s)

? o1.FindNth(:Last, 4)
#--> 299001
# Executed in 0.92 second(s)

pf()
# Executed in 3.56 second(s)
