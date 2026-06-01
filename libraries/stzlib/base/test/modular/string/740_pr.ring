# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #740.

load "../../../stzBase.ring"


o1 = new stzString("Use these two letters: س and ص.")
? o1.FindCharsW(
	:Where = '{
		StzCharQ(This[@i]).IsLetter() AND
		NOT StzCharQ(This[@i]).IsLatinLetter()
	}'
)
#--> [ 24, 30 ]

? o1.CharsW(
	:Where = '{
		StzCharQ(This[@i]).IsLetter() AND
		NOT StzCharQ(This[@i]).IsLatinLetter()
	}'
)
#o--> [ "س", "ص" ]

pf()
# Executed in 0.64 second(s).
