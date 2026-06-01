# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #744.

load "../../../stzBase.ring"


o1 = new stzString("Use these two letters: س and ص.")

o1.ReplaceCharsWXT(
	:Where = '{ @char != " " and StzCharQ(@Char).IsArabicLetter() }',
	:With = "*"
)

? o1.Content()
#--> "Use these two letters: * and *."

pf()
# Executed in 0.36 second(s).
