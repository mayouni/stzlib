# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #805.

load "../../../stzBase.ring"


? StzStringQ("{nnnnn}").IsBoundedBy(["{","}"])
#--> TRUE

o1 = new stzString("بسم الله الرّحمن الرّحيم")
? o1.IsBoundedBy(["بسم", "الرّحيم"])
#--> TRUE

pf()
# Executed in 0.01 second(s)
