# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #859.

load "../../stzBase.ring"


? Q("M").NumberOfChars()
#--> 1

? Q("🐨").NumberOfChars()
#--> 1

? len("🐨")
#--> 4 (bytes, not chars)

pf()
# Executed in almost 0 second(s).
