# Narrative
# --------
# ? AChar( :In = "softanza" ).Uppercased()
#
# Extracted from stzsubstringTest.ring, block #8.
#ERR Error (R3) : Calling Function without definition: somechars

load "../../stzBase.ring"

pr()

? SomeChars( :In = "softanza" ).Uppercased()

? ASubString( :In = "softanza" ).Uppercased() + NL
#--> softaNZA

? SomeSubStrings( :In = "SOFTANZA" ).Lowercased()
#--> SOFTAnza


pf()
# Executed in 0.80 second(s)
