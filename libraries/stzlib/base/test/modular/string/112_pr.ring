# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #112.

load "../../../stzBase.ring"


? Q("♥").RepeatedNTimes(3)
#--> ♥♥♥

? Q("♥").Repeated3Times()
#--> ♥♥♥

? NCopies(3, "♥")
#--> ♥♥♥

? 3Copies(:of="♥")
#--> ♥♥♥

pf()
