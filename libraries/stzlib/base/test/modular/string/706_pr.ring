# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #706.

load "../../../stzBase.ring"


o1 = new stzString("__b和平س__a_ووو")

? o1.PartsUsing(' StzCharQ(This[@i]).Script() ' )
# #--> [ "__", "b", "和平", "س", "__", "a", "_", "ووو" ]

pf()
# EExecuted in 0.09 second(s) in Ring 1.22
