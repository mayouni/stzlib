# Narrative
# --------

#
# Extracted from stzlisttest.ring, block #192.

load "../../stzBase.ring"

pr()

aLarge = []
for i = 1 to 299_000
	aLarge + "*"
next

? ElapsedTime()
#--> Extecuted in 0.05 second(s) in seconds

o1 = new stzList( aLarge + 10 + 20 + [ "+", "-" ] )
? len( o1.OnlyStrings() )
#--> 299000
# (OnlyStrings is now ~3s on 299k items, down from >120s -- the per-item
#  @AddItem copy was removed from stzListGetter.)

pf()
# Executed in 0.61 second(s) in Ring 1.22
# Executed in 2.25 second(s) in Ring 1.18
