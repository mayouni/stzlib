# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #4.

load "../../stzBase.ring"


o1 = new stzString("Programming for programmers")
o1 {
	? @@( FindZZ([ "Programming", "programmers" ]) )
	#--> [ [ 1, 11 ], [ 17, 27 ] ]

	ReplaceInSections("m", "M", [ [ 1, 11 ], [ 17, 27 ] ])
	? Content()
	# PrograMMing for prograMMers
}

pf()
# Executed in 0.05 second(s) in Ring 1.22
