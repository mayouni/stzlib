# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #3.

load "../../stzBase.ring"

pr()

o1 = new stzString("Softanza Programming by Heart")
o1 {
	? @@( FindZZ("Programming") )
	#--> [ [ 	10, 	20 ] ]

	ReplaceInSection("m", "M", 10, 20)
	? Content()
	# Softanza PrograMMing by Heart
}

pf()
# Executed in 0.01 second(s) in Ring 1.22
