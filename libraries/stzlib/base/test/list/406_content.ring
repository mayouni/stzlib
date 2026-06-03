# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #406.
#ERR Error (R50) : Object does not support operator overloading

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
