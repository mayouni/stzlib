# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #102.

load "../../stzBase.ring"

pr()

# Hi Irwin, Softanza made this for you:

Q("Thank you Irwin Rodriguez!") {

	# Your name is uppercased
	UppercaseSubString("Irwin")

	# Then it's decoraded with hearts
	AddXT( 2Hearts(), :Around = "IRWIN" )

	# And finally it's nicely boxed
	? BoxedRound()

	# Thank you for your trust!
}

#--> ╭────────────────────────────────╮
#    │ Thank you ♥♥IRWIN♥♥ Rodriguez! │
#    ╰────────────────────────────────╯

pf()
# Executed in 0.03 second(s) in Ring 1.23
# Executed in 0.14 second(s) in Ring 1.18
