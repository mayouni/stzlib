# Narrative
# --------
# pr()
#
# Extracted from stzlistofnumberstest.ring, block #67.
#ERR Error (R14) : Calling Method without definition: findinsection

load "../../stzBase.ring"

pr()

o1 = new stzString("---ring---ruby--python--python--")
? @@( o1.FindInSection("ring", 4, 7) )
#--> [ 4 ]

? @@( o1.FindInSection("ruby", 9, 16) )
#--> [ 11 ]

? @@( o1.FindInSectionAsSections("python", 15, :Last) )
#--> [ [ 17, 22 ], [ 25, 30 ] ]

pf()
# Executed in 0.07 second(s)
