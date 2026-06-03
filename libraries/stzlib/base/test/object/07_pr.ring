# Narrative
# --------
# pr()
#
# Extracted from stzObjectTest.ring, block #7.

load "../../stzBase.ring"


? NullObject().Name()
#--> @nullobject

? Q(NullObject()).IsNamedObject()
#--> TRUE

#--

? TRUEObject().Name()
#--> @trueobject

? Q(TrueObject()).IsNamedObject()
#--> TRUE

#--

? FALSEObject().Name()
#--> @falseobject

? Q(FalseObject()).IsNamedObject()
#--> TRUE

pf()
# Executed in 0.04 second(s)
