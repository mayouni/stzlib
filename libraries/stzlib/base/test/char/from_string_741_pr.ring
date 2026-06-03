# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #741.
#ERR Error (R14) : Calling Method without definition: replacecharsw

load "../../stzBase.ring"

pr()

o1 = new stzString("Use these two letters: س and ص.")
o1.ReplaceCharsW(

	:Where = '{
		StzCharQ(This[@i]).IsLetter() AND
		(NOT StzCharQ(This[@i]).IsLatinLetter())
	}',

	:With = '***'
)

? o1.Content()
#--> "Use these two letters: *** and ***."

pf()
# Executed in 0.35 second(s).
