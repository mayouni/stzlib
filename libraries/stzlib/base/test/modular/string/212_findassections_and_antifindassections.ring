# Narrative
# --------
# FindAsSections() and AntiFindAsSections()
#
# Extracted from stzStringTest.ring, block #212.

load "../../../stzBase.ring"


pr()

o1 = new stzString('this code : txt1 = "<    leave spaces    >" and this code: txt2 = "< leave spaces >"')

? @@( o1.FindAsSections([ '"<    leave spaces    >"', '"< leave spaces >"' ]) )
#--> [ [ 20, 43 ], [ 67, 84 ] ]

? @@( o1.AntiFindAsSections([ '"<    leave spaces    >"', '"< leave spaces >"' ]) )
#--> [ [ 1, 19 ], [ 44, 66 ] ]

pf()
# Executed in 0.15 second(s)
