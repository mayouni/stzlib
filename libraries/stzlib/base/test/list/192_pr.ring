# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #192.

load "../../stzBase.ring"


aLarge = []
for i = 1 to 299_000
	aLarge + "*"
next

? ElapsedTime()
#--> Extecuted in 0.08 second(s) in seconds

o1 = new stzList( aLarge + 10 + 20 + [ "+", "-" ] )
? len( o1.OnlyStrings() )
#--> 299000
# Executed in 2 second(s)

pf()
# Executed in 0.61 second(s) in Ring 1.22
# Executed in 2.25 second(s) in Ring 1.18
