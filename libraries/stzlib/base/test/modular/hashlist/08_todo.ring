# Narrative
# --------
# TODO
#
# Extracted from stzhashlisttest.ring, block #8.

load "../../../stzBase.ring"


pr()

o1 = new stzHashList([
	:One	= :can,
	:Two  	= [ :is, :will, :can, :some, :can ],
	:Three	= :NONE,
	:Four	= [ :will, :not ],
	:Five	= :can
])

? o1.FindValueOrItem(:can) # called also FindVitem(:can)
#--> [ 1, 2, 5 ]

pf()
