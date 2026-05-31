# Narrative
# --------
# pr()
#
# Extracted from stzGlobalTest.ring, block #29.

load "../../../stzBase.ring"


o1 = new stzString("...emm...eh..emm...eh")

? @@( o1.FindMany([ "emm", "eh" ]) )
#--> [4, 10, 14, 20 ]

? @@(o1.FindManyAsSections([ "emm", "eh" ]))
#--> [ [ 4, 6 ], [ 10, 11 ], [ 14, 16 ], [ 20, 21 ] ]

# Many is used here for clarity, and you can avoid it,
# and let Softanza understand that the provided param
# is a list of strings. Hance, Find() calls FindMany()
# in the bkackground:

? @@( o1.Find([ "emm", "eh" ]) )
#--> [4, 10, 14, 20 ]

? @@(o1.FindAsSections([ "emm", "eh" ])) # Of FindZZ() for short
#--> [ [ 4, 6 ], [ 10, 11 ], [ 14, 16 ], [ 20, 21 ] ]

pf()
# Executed in 0.07 second(s)
