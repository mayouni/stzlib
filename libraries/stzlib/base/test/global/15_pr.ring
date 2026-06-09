# Narrative
# --------
# pr()
#
# Extracted from stzGlobalTest.ring, block #15.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"

pr()

@ForEach( :number, :in = 1:5 ) {

	# The code you want to execute in the loop

	X('
		? v(:number)
	')

}

pf()
# Executed in 0.04 second(s)
