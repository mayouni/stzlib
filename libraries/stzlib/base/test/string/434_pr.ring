# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #434.

load "../../stzBase.ring"


? Heart()
#--> ♥

? Q(Heart()).RepeatedNTimes(3)
#--> ♥♥♥

# or you can use the short form .NTimes(3)

? Q("Go").RepeatedNTimes(3)
#--> GoGoGo

? @@( Q([ "A", "B" ]).RepeatedNTimes(3) )
#--> [ [ "A", "B" ], [ "A", "B" ], [ "A", "B" ] ]

? Five(Star())
#--> ★★★★★

? Three(Heart())
#--> ♥♥♥

pf()
# Executed in 0.03 second(s) in Ring 1.21
