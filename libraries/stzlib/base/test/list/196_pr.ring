# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #196.

load "../../stzBase.ring"


o1 = new stzList(1:299_000+4)

? len( o1.Section(80_002, 210_001) )
#--> 130_000
# Executed in 0.22 second(s)

? o1.FindNext(120_001, :StartingAt = 2)
#--> 120001
# Executed in 1.38 second(s)

pf()
# Executed in 1.78 second(s)
