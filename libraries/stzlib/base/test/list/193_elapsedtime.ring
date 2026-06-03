# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #193.
#ERR Error (R24) : Using uninitialized variable: _time0

load "../../stzBase.ring"

pr()

aLarge = []
for i = 1 to 299_000
	aLarge + "*"
next

? ElapsedTime()
#--> Extecuted in 0.14 second(s)

o1 = new stzList( aLarge + 10 + 20 + [ "+", "-" ] + 30 + 40 + [ "*" ] )
? len( o1.NumbersAndStringsZ() )
#--> 299004
# Executed in 2 second(s)

pf()
# Executed in 2.35 second(s) in Ring 1.19 (64 bits)
# Executed in 3.72 second(s) in Ring 1.17
