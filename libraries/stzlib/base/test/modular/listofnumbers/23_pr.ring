# Narrative
# --------
# pr()
#
# Extracted from stzlistofnumberstest.ring, block #23.

load "../../../stzBase.ring"


? @@( Q(["one", "two", "three", "four", "five", "six" ]) / 3 ) + NL
#--> [ [ "one", "two" ], [ "three", "four" ], [ "five", "six" ] ]

? @@( ( Q(["one", "two", "three", "four", "five", "six" ]) / Q(3) ).Content() )
#     \______________________________ ____________________________/
#                                    V
#                           a stzList object

#--> [ [ "one", "two" ], [ "three", "four" ], [ "five", "six" ] ]

pf()
# Executed in 0.03 second(s) in Ring 1.21
