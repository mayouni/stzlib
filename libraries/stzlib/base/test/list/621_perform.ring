# Narrative
# --------
# PERFORM
#
# Extracted from stzlisttest.ring, block #621.

load "../../stzBase.ring"

/*--
*/
pr()

o1 = new stzList([ 1, "ring", 3, "python", 5, "ruby" ])

o1.PerformW('isString(this[@i])', 'upper(this[@i])')

? @@( o1.Content() )
#--> [ 1, "RING", 3, "PYTHON", 5, "RUBY" ]

pf()
# Executed in 0.05 second(s) in Ring 1.22

#---

pr()

o1 = new stzList([ 1, "ring", 3, "python", 5, "ruby" ])

o1.PerformWXT('isString(@item)', 'upper(@item)')

? @@( o1.Content() )
#--> [ 1, "RING", 3, "PYTHON", 5, "RUBY" ]

pf()
# Executed in 0.14 second(s) in Ring 1.22

#==

pr()

o1 = new stzList([ 1, "ring", 3, "python", 5, "ruby" ])

o1.PerformAtW([ 2, 4, 6 ], 'isString(this[@i])', 'upper(this[@i])')

? @@( o1.Content() )
#--> [ 1, "RING", 3, "PYTHON", 5, "RUBY" ]

pf()
# Executed in 0.05 second(s) in Ring 1.22

#---

pr()

o1 = new stzList([ 1, "ring", 3, "python", 5, "ruby" ])

o1.PerformAtWXT([ 2, 4, 6 ], 'isString(@item)', 'upper(@item)')

? @@( o1.Content() )
#--> [ 1, "RING", 3, "PYTHON", 5, "RUBY" ]

pf()
# Executed in 0.14 second(s) in Ring 1.22
