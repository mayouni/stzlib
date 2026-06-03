# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #254.

load "../../stzBase.ring"

pr()

? Q("121212").IsMadeOf("12")
#--> TRUE

? Q("121212").IsMadeOf([ "1", "2" ])
#--> TRUE

? Q("984332").IsMadeOfNumbers()
#--> TRUE

pf()
# Executed in 0.01 second(s) in Ring 1.21
# Executed in 0.06 second(s) in Ring 1.18
