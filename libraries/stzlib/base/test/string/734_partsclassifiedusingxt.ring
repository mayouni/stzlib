# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #734.

load "../../stzBase.ring"

pr()

o1 = new stzString("Hanine حنين is a nice جميلة وعمرها 7 years-old سنوات girl!")

? @@NL( o1.PartsClassifiedUsingXT( 'StzCharQ(@char).Script()' ) )

#--> [
#	:latin	 	= [ "Hanine", "is", "a", "nice", "years", "old", "girl" ],
#	:common		= [ " ", " ", " ", " ", " ", " ", " 7 ", "-", " ", " ", "!" ],
#	:arabic		= [ "حنين", "جميلة", "وعمرها", "سنوات" ],
#     ]

# Alternatives to PartsClassified(): Classify() and Classified()

pf()
# Executed in 0.36 second(s).
