# Narrative
# --------
# pr()
#
# Extracted from stzhashlisttest.ring, block #10.

load "../../stzBase.ring"

pr()

o1 = new stzHashList([
	:One	= :NONE,
	:Two  	= [ :is, :will, :can, :some, :can ],
	:Three	= :NONE,
	:Four	= [ :can, :will, :will ],
	:Five	= [ :will ]
])

? @@( o1.FindInLists(:will) )
#--> [ [ 2, [ 2 ] ], [ 4, [ 2, 3 ] ], [ 5, [ 1 ] ] ]

pf()
# Executed in 0.02 second(s)
