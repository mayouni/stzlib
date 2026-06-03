# Narrative
# --------
# Password Validation
#
# Extracted from stzregexmakertest.ring, block #45.

load "../../stzBase.ring"


pr()

o1 = new stzRegexMaker
o1 {
	AddWordBoundary(:start)
	AddCapturingGroup("length", ".{8,}")           # Min 8 chars
	AddCapturingGroup("upper", ".*[A-Z].*")        # Has uppercase
	AddCapturingGroup("lower", ".*[a-z].*")        # Has lowercase  
	AddCapturingGroup("digit", ".*\d.*")           # Has number
	AddCapturingGroup("special", ".*[!@#$%^&*].*") # Has special char
	AddWordBoundary(:end)

	? Pattern()
	#--> \b(?P<length>.{8,})(?P<upper>.*[A-Z].*)(?P<lower>.*[a-z].*)(?P<digit>.*\d.*)(?P<special>.*[!@#$%^&*].*)\b
}

pf()
