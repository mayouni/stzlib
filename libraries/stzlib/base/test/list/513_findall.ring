# Narrative
# --------
# Locating and managing the Softanza singleton objects (TRUE, FALSE, NULL)
# stored as live items inside a stzList.
#
# A stzList can hold the special object instances returned by TRUEObject(),
# FALSEObject(), and NullObject() alongside ordinary values. FindAll(obj)
# returns every position holding a given object; FindObjects() returns the
# positions of all such singleton objects at once; and FindMany([...]) finds
# the union of positions for a set of objects. Those same objects are valid
# operands for the mutating ops: Remove, Replace, and RemoveMany delete or
# swap them by identity, with @trueobject/@falseobject being how @@() renders
# the singletons in logical bracketed form.
#
# Extracted from stzlisttest.ring, block #513.

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
