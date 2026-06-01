# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #128.

load "../../../stzBase.ring"


o1 = new stzString("HELLOhello")

? o1.NumberOfSubStringsCS(TRUE)
#--> 55

? @@S( o1.SubStringsCS(TRUE) ) + NL
#--> [ "H", "HE", "HEL", "...", "l", "lo", "o" ]

? o1.NumberOfSubStringsCS(FALSE)
#--> 39

? @@S( o1.SubStringsCS(FALSE) ) + NL
#--> [ "h", "he", "hel", "...", "ohel", "ohell", "ohello" ]

? @@( o1.FindSubStringsCS(FALSE) ) + NL
#--> [ 1, 2, 3, 4, 5 ]

? @@S( o1.SubStringsCSZ(FALSE) ) + NL
#--> [
#	[ "h", [ 1, 6 ] ],
#	[ "he", [ 1, 6 ] ],
#	[ "hel", [ 1, 6 ] ],
#	"...",
#	[ "ohel", [ 5 ] ],
#	[ "ohell", [ 5 ] ],
#	[ "ohello", [ 5 ] ]
# ]

? @@S( o1.FindSubStringsCSZZ(FALSE) ) + NL
#--> [ [ 1, 1 ], [ 1, 2 ], [ 1, 3 ], "...", [ 5, 8 ], [ 5, 9 ], [ 5, 10 ] ]

? @@S( o1.SubStringsCSZZ(FALSE) ) + NL
#--> [
#	[ "h", [ [ 1, 1 ], [ 6, 6 ] ] ],
#	[ "he", [ [ 1, 2 ], [ 6, 7 ] ] ],
#	[ "hel", [ [ 1, 3 ], [ 6, 8 ] ] ],
#	"...",
#	[ "ohel", [ [ 5, 8 ] ] ],
#	[ "ohell", [ [ 5, 9 ] ] ],
#	[ "ohello", [ [ 5, 10 ] ] ]
# ]

? o1.NumberOfSubStringsOfNCharsCS(4, FALSE)
#--> 7

? @@( o1.SubStringsOfNCharsCS(4, FALSE) ) + NL
#--> [ "hell", "ello", "lloh", "lohe", "ohel", "hell", "ello" ]

? o1.NumberOfSubStringsOfNCharsCSU(4, FALSE) + NL
#--> 5

? @@( o1.SubStringsOfNCharsCSU(4, FALSE) ) + NL
#--> [ "hell", "ello", "lloh", "lohe", "ohel" ]

? @@( o1.SubStringsWXT('
	len(@SubString) <= 6 and
	Q(@SubString).Contains(["e", "o"]) ')
) + NL
#--> [ "Ohello", "hello", "ello" ]	# Takes 0.20 second(s)

? @@( o1.SubStringsWXTZ('
	len(@SubString) <= 6 and
	Q(@SubString).Contains(["e", "o"]) ')
) + NL
#--> [ [ "Ohello", [ 5 ] ], [ "hello", [ 6 ] ], [ "ello", [ 7 ] ] ]

? @@( o1.SubStringsWXTZZ('
	len(@SubString) <= 6 and
	Q(@SubString).Contains(["e", "o"]) ')
)
#--> [
#	[ "Ohello", [ [ 5, 10 ] ] ],
#	[ "hello", [ [ 6, 10 ] ] ],
#	[ "ello", [ [ 7, 10 ] ] ]
# ]

pf()
# Executed in 0.75 second(s) in Ring 1.21
