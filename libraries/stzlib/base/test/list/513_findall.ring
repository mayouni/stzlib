# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #513.
#ERR Error (R14) : Calling Method without definition: findobjects

load "../../stzBase.ring"

pr()

oTrue  = TRUEObject()
oFalse = FALSEObject()
oNull  = NullObject()

o1 = new stzList([ "Ring", "PHP", oTrue, oTrue, "Python", oNull, oFalse, "Julia", oNull ])

? @@( o1.FindAll(oTRUE) )
#--> [ 3, 4 ]

? @@( o1.FindAll(oFalse) )
#--> [ 7 ]

? @@( o1.FindAll(oNull) ) + NL
#--> [ 6, 9 ]

? @@( o1.FindObjects() )
#--> [ 3, 4, 6, 7, 9 ]

? @@( o1.FindMany([ oTrue, oFalse, oNull ]) ) + NL
#--> [ 3, 4, 6, 7, 9 ]

o1.Remove(oNull)
? @@( o1.Content() ) + NL
#--> [ "Ring", "PHP", @trueobject, @trueobject, "Python", @falseobject, "Julia" ]

o1.Replace(oFalse, 0)
? @@( o1.Content() ) + NL
#--> [ "Ring", "PHP", @trueobject, @trueobject, "Python", 0, "Julia" ]

o1.RemoveMany([ oTrue, 0 ])
? @@( o1.Content() )
#--> [ "Ring", "PHP", "Python", "Julia" ]

pf()
# Executed in 0.34 second(s).
