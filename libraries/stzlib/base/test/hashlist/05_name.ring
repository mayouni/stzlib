# Narrative
# --------
# pr()
#
# Extracted from stzhashlisttest.ring, block #5.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"

pr()

? NullObject().Name()
#--> @nullobject

? TRUEObject().Name()
#--> @trueobject

? FALSEObject().Name()
#--> @falseobject

? ObjectVarName( NullObject() )
#--> @nullobject

? ObjectVarName( TRUEObject() )
#--> @trueobject

? ObjectVarName( FALSEObject() )
#--> @falseobject

pf()
#--> Executed in 0.06 second(s)
