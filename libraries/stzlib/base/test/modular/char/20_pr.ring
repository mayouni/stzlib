# Narrative
# --------
# pr()
#
# Extracted from stzchartest.ring, block #20.

load "../../../stzBase.ring"


? MaxUnicodeNumber()
#--> 1114112

? UnicodeChar(1114113)
#--> ERR: Incorrect param type! p must be a number less then 1114112!

pf()
