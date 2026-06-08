# Narrative
# --------
# #TODO Test it after adding Yield()
#
# Extracted from stzStringTest.ring, block #413.

load "../../stzBase.ring"


pr()

o1 = new stzString("..ONE...TWO..")
? @@( o1.FindCharsWXT(:Where = 'QRT(@char, :stzChar).IsALetter()') )
#--> [ 3, 4, 5, 9, 10, 11 ]

	#WARNING
	# If you use FindW instead of FindCharsW, yu will get an error:
	# ~> Can't create the char object.
	# The error occures because FindW is presumed to be FindSubStringsW,
	# and hence the string provided ("..ONE...TWO..") is transformed to
	# a list of all possible substrings ([ ".", "..", "..O", ...]), where
	# '..O' for example can not be caste into a char.

? @@( o1.YieldCharsWXT( '@char', :Where = 'Q(@char).IsALetter()' ) )
#--> [ "O", "N", "E", "T", "W", "O" ]

pf()
# Executed in 0.57 second(s).
