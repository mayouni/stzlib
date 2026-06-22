# Narrative
# --------
# Repeating a list by multiplying with a wrapped numeric object -- a FEATURE STUB.
#
# The intent: Q([...]) * TRUEObject() (a stzTrueObject carries TRUE ~> 1) and
# Q([...]) * Q(2) should repeat the list the way Q([...]) * 2 does. Today the
# (*) operator validates the RHS with isNumber() and rejects any stz-object
# wrapper -- "operator *: rhs must be a number" -- because it does not first
# unwrap a wrapped object to its numeric Content(). The raw-number form works
# (see blocks 146/147); the recorded outputs below are the intended behavior.
# Left as a documented stub until (*) coerces a numeric stz-object RHS.
#
# Extracted from stzlisttest.ring, block #406.
#ERR operator *: rhs must be a number.  (stz-object RHS coercion pending)

load "../../stzBase.ring"

pr()

? ( Q([ "ONE", "TWO", "THREE" ]) * TRUEObject() ).Content()
#                                  \_____ ____/
#					 V
#        A stzTrueObject holding the value TRUE ~> 1
#  \__________________________ __________________________/
#                             V
#       It's like if we wrote the fellowing expression:
#      ( Q([ "ONE", "TWO", "THREE" ]) * Q(1) ).Content()

#--> [ "ONE", "TWO", "THREE" ]

? @@( ( Q([ "ONE", "TWO", "THREE" ]) * Q(2) ).Content() )
#--> [ [ "ONE", "TWO", "THREE" ], [ "ONE", "TWO", "THREE" ] ]

pf()
# Executed in 0.03 second(s) in Ring 1.22
