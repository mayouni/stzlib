# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #553.

load "../../stzBase.ring"

pr()

? @@( Q("txt <<ring>> txt <<ring>>").FindBoundedByAsSections([ "<<", ">>" ]) ) + NL
#--> [ [ 7, 10 ], [ 20, 23 ] ]

str = 'for      txt =  "   val1  "   to  "   val2"   do  this or   that!'
? @@( Q(str).FindBoundedByAsSections('"') ) + NL
#--> [ [ 18, 26 ], [ 28, 34 ], [ 36, 42 ] ]

? @@( Q(str).Sections([ [ 18, 26 ], [ 28, 34 ], [ 36, 42 ] ]) )
#--> [ "   val1  ", "   to  ", "   val2" ]

pf()
# Executed in 0.02 second(s) in Ring 1.22
# Executed in 0.12 second(s) in Ring 1.18
