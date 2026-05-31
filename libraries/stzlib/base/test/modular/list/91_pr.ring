# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #91.

load "../../../stzBase.ring"


o1 = new stzList([ "--_--", [ 12, "--_--", 10], "--_--", 9 ])
o1.StringifyAndReplaceXT("_", "♥") # Used by internal staff in Softanza
? @@( o1.Content() )
#--> [
#	[ "--♥--", "[ 12, "--♥--", 10 ]", "--♥--", "9" ],
#	[ 1, 3 ],
#	[ ]
# ]

pf()
# Executed in 0.01 second(s) in Ring 1.22
# Executed in 0.05 second(s) in Ring 1.19
# Executed in 0.04 second(s) in Ring 1.19 (32 bits)
# Executed in 0.04 second(s) in Ring 1.18
# Executed in 0.03 second(s) in Ring 1.17
