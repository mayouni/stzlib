# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #217.

load "../../../stzBase.ring"


o1 = new stzString('this code : txt1 = "<    leave spaces    >" and this code: txt2 = "< leave spaces >"')

? @@( o1.SubStringsBoundedBy('"') )
#--> [
#	'<    leave spaces    >',
#	'< leave spaces >'
# ]

pf()
# Executed in 0.01 second(s) in Ring 1.21
