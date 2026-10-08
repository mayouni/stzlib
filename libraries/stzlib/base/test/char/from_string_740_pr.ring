# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #740.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"

pr()

o1 = new stzString("Use these two letters: س and ص.")
? o1.FindCharsW(
	:Where = '{
		Q(@char).IsLetter() AND
		NOT Q(@char).IsLatinLetter()
	}'
)
#--> [ 24, 30 ]

? o1.CharsW(
	:Where = '{
		Q(@char).IsLetter() AND
		NOT Q(@char).IsLatinLetter()
	}'
)
#o--> [ "س", "ص" ]

pf()
# Executed in 0.64 second(s).
