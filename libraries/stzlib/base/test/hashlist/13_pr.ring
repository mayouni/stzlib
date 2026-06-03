# Narrative
# --------
# pr()
#
# Extracted from stzhashlisttest.ring, block #13.

load "../../stzBase.ring"


o1 = new stzHashList([
	:One	= :NONE,
	:Two  	= [ :is, :will, :can, :some, :can ],
	:Three	= :NONE,
	:Four	= [ :can, :will ],
	:Five	= [ :will ]
])

? @@( o1.FindNonLists() ) + NL
#--> [ 1, 3 ]

? @@( o1.Listified() )
#--> [
#	:One	= [ :NONE ],
#	:Two  	= [ :is, :will, :can, :some, :can ],
#	:Three	= [ :NONE ],
#	:Four	= [ :can, :will ],
#	:Five	= [ :will ]
# ]

pf()
# Executed in 0.02 second(s)
