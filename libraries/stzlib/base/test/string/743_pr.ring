# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #743.

load "../../stzBase.ring"


o1 = new stzString("Use these two letters: س , ص.")

o1.RemoveCharsWhereQ('{

	StzCharQ(This[@i]).IsArabicLetter() or
	StzCharQ(This[@i]).IsPunctuation()

}')

? o1.Simplified()
#--> "Use these two letters"

pf()
# Executed in 0.33 second(s).
