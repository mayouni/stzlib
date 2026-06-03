# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #108.

load "../../stzBase.ring"


o1 = new stzlist(1:120_000)
ShowShort( o1.Stringified() )
#--> [ "1", "2", "3", "...", "119998", "119999", "120000" ]

pf()
# Executed in 0.66 second(s) in Ring 1.19 (64 bits)
# Executed in 1.14 second(s) in Ring 1.17
