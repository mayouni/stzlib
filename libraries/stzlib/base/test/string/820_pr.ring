# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #820.
#ERR Error (R14) : Calling Method without definition: findcharswxt

load "../../stzBase.ring"

pr()

#                   1.3....8.0..
o1 = new stzString("NoWomanNoCry")

anPos = o1.FindCharsWXT( :Where = 'Q(@char).IsUppercase()')

? @@(anPos)
#--> [ 1, 3, 8, 10 ]

? o1.SplitBeforePositions(anPos)
#--> [ "No", "Woman", "No", "Cry" ]

pf()
# Executed in 0.23 second(s).
