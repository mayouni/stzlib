# Narrative
# --------
# Q(list) * N repeats the wrapped list N times. With a singleton
# list this is the natural "give me a vector of zeros" idiom:
# Q([0]) * 3  ->  [ 0, 0, 0 ].
#
# Extracted from stzlisttest.ring, the operator-overload block.

load "../../stzBase.ring"

pr()

? @@( Q([0]) * 3 )
#--> [0, 0, 0]

? @@( Q("ABC") / 3 )
#--> [ "A", "B", "C" ]

? @@( ( Q("A":"C") / Q(3) ).Content() )
#--> [ [ "A" ], [ "B" ], [ "C" ] ]
# (Correct per the "/ n -> n parts" contract: a 3-item list / 3 is three
#  one-item parts. The flat ["A","B","C"] would be inconsistent with [1..6]/3.)

pf()
# Executed in almost 0 second(s) in Ring 1.27
