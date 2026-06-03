# Narrative
# --------
# #  DECLARATIVE DESIGN OF REGEX PATTERNS  #
#
# Extracted from stzregexmakertest.ring, block #14.

load "../../stzBase.ring"

#========================================#
*/
pr()

o1 = new stzRegexMaker()
o1 {
	# Sequence 1
	AddCharsRange( "A-Z", :RepeatedExactly, 2, :Times)

	# Sequence 2
	AddAmongChars("- ", :RepeatedAtMost, 1, :Time)

	# Sequence 3
	AddDigitsRange(	"0-9", :RepeatedBetween, 1, :And = [3, :Times])

	# Sequence 4
	AddNotAmongChars(["-", " "], :RepeatedAtMost, 1, :Time)

	# Sequence 5
	RepeatSequence(1)

	# Get the constructed pattern
	? Pattern() + NL
	#--> [A-Z]{2}[- ]?[0-9]{1,3}[^- ]?[A-Z]{2}

	# Get the pattern structure

	? @@NL( o1.FragmentsXT() )
	#--> [
	# [ "[A-Z]{2}", [ "between", "A-Z", "repeatedexactly", 2, "times" ] ],
	# [ "[- ]?", [ "among", "- ", "repeatedatmost", 1, "time" ] ],
	# [ "[0-9]{1,3}", [ "between", "0-9", "repeatedbetween", 1, 3 ] ],
	# [ "[^- ]?", [ "notamong", "- ", "repeatedatmost", 1, "time" ] ],
	# [ "[A-Z]{2}", [ "between", "A-Z", "repeatedexactly", 2, "times" ] ]


}

pf()
# Executed in 0.01 second(s) in Ring 1.22
