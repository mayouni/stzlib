# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #162.

load "../../stzBase.ring"

pr()

? @@( Q("--<<♥♥♥>>--<<♥♥♥>>---<<♥♥♥>>").
	FindBoundedByAsSections([ "<<", ">>" ]) ) # Or Simply FindBoundedByZZ()
#--> [ [ 5, 7 ], [ 14, 16 ], [ 24, 26 ] ]

pf()
# Executed in 0.01 second(s) in Ring 1.22
# Executed in 0.12 second(s) in Ring 1.18
