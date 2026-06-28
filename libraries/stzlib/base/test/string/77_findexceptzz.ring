# Narrative
# --------
# FindExceptZZ / Except with a LIST of separators: the spans (and substrings) of
# everything that is none of "--" or "__".
#
# Extracted from stzStringTest.ring, block #77.

load "../../stzBase.ring"

pr()

o1 = new stzString("--ring--&__softanza__")
? @@( o1.FindExceptZZ([ "--", "__" ]) )
#--> [ [ 3, 6 ], [ 9, 9 ], [ 12, 19 ] ]

? @@( o1.Except([ "--", "__" ]) )
#--> [ "ring", "&", "softanza" ]

pf()
