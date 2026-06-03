# Narrative
# --------
# pr()
#
# Extracted from stzlistofstringstest.ring, block #83.

load "../../stzBase.ring"

pr()

cUnicodeNames = "0020;SPACE
0021;EXCLAMATION MARK
0022;QUOTATION MARK
0023;NUMBER SIGN
0024;DOLLAR SIGN
0025;PERCENT SIGN
0026;AMPERSAND
0027;APOSTROPHE
0028;LEFT PARENTHESIS
0029;RIGHT PARENTHESIS
002A;ASTERISK
002B;PLUS SIGN
002C;COMMA
002D;HYPHEN-MINUS
002E;FULL STOP
002F;SOLIDUS"

? @@(
	StzStringQ(cUnicodeNames).
	SplitQRT(NL, :stzListOfStrings).
	SplitQ(";").Content()
)
#--> [
#	[ "0020", "SPACE" ], 		[ "0021", "EXCLAMATION MARK" ],
#	[ "0022", "QUOTATION MARK" ], 	[ "0023", "NUMBER SIGN" ],
#	[ "0024", "DOLLAR SIGN" ], 	[ "0025", "PERCENT SIGN" ],
#	[ "0026", "AMPERSAND" ], 	[ "0027", "APOSTROPHE" ],
#	[ "0028", "LEFT PARENTHESIS" ], [ "0029", "RIGHT PARENTHESIS" ],
#	[ "002A", "ASTERISK" ], 	[ "002B", "PLUS SIGN" ],
#	[ "002C", "COMMA" ], 		[ "002D", "HYPHEN-MINUS" ],
#	[ "002E", "FULL STOP" ], 	[ "002F", "SOLIDUS" ]
# ]
pf()
# Executed in 0.24 second(s)
