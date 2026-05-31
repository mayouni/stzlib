# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #403.

load "../../../stzBase.ring"


o1 = new stzList([ "VALUE1", "VALUE2", "VALUE3" ])
o1.MultiplyBy([ 1001, 1002, 1003 ])
? @@SP( o1.Content() )
#--> [
#	[  "VALUE1", [ 1001, 1002, 1003 ] ],
#	[  "VALUE2", [ 1001, 1002, 1003 ] ],
#	[  "VALUE3", [ 1001, 1002, 1003 ] ]
# ]

pf()
# Executed in almost 0 second(s).
