# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #769.

load "../../stzBase.ring"

pr()

o1 = new stzString("eeebxeTuniseee")
o1 {

	RemoveNLeftChars(3)
	RemoveNRightChars(3)

	# or alternatively:
	# RemoveFirstNChars(3)
	# RemoveLastNChars(3)

	? Content()
	#--> bxeTunis
	
}

pf()
# Executed in 0.01 second(s).
