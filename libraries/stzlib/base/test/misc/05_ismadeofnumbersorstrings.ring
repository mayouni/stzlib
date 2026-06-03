# Narrative
# --------
# pr()
#
# Extracted from stzmisctest.ring, block #5.

load "../../stzBase.ring"

pr()

Q([ 1, 2, "three", 4, "five" ]) {

	? IsMadeOfNumbersOrStrings()
	#--> TRUE

	? IsMadeOfNumbersAndStrings()
	#--> TRUE
}

Q([ 1, 2, 3, 4, 5 ]) {

	? IsMadeOfNumbersOrStrings()
	#--> TRUE

	? IsMadeOfNumbersAndStrings()
	#--> FALSE

}

pf()

# Executed in almost 0 second(s) in Ring 1.21
# Executed in 0.04 second(s) in Ring 1.20
