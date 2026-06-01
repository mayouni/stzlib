# Narrative
# --------
# #ringqt #ERROR #TODO post it in the ring-group for correction
#
# Extracted from stzStringTest.ring, block #234.

load "../../../stzBase.ring"

# Read this discussion:
# https://groups.google.com/d/msgid/ring-lang/c5f6c5ea-9afd-411d-8000-6a695d8db2f4n%40googlegroups.com?utm_medium=email&utm_source=footer

pr()

cStr = "•••••••••"

? substr(cStr, "")
#--> 0

? substr(cStr, "•")
#--> 1

pf()
