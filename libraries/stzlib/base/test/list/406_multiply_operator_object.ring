# Narrative
# --------
# Repeating a list by multiplying with a wrapped numeric object.
#
# The Q-elevation rule: Q([...]) * 2 returns a RAW list; using a numeric
# stz-object on the RHS -- Q([...]) * Q(2), or Q([...]) * TRUEObject() (a
# stzTrueObject carries TRUE ~> 1) -- returns the SAME content ELEVATED into a
# chainable stzList object. So ( Q([...]) * Q(2) ).Content() equals
# Q([...]) * 2. The (*) operator coerces a numeric stz-object RHS to its
# numeric value and wraps the result.
#
# Extracted from stzlisttest.ring, block #406.

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
#--> [ "ONE", "TWO", "THREE", "ONE", "TWO", "THREE" ]

pf()
# Executed in 0.03 second(s) in Ring 1.22
