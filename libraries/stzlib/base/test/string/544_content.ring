# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #544.
#ERR Error (C27) : Syntax Error!

load "../../stzBase.ring"

pr()

o1 = new stzString("
	The xCommodore X64X, also known as the XC64 or the CBMx 64, is an x8-bit
	home computer introduced in January 1982x by CommodoreXx International 
")

o1.Simplify()

o1.RemoveCharsWXT('{ lower(@char) = "x" }')
? o1.Content()

#--> The Commodore 64, also known as the C64 or the CBM 64, is an 8-bit
# home computer introduced in January 1982 by Commodore International

pf()
# Executed in 0.55 second(s) in Ring 1.22
