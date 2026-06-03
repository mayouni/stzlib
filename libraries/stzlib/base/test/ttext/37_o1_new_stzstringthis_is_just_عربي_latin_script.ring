# Narrative
# --------
# o1 = new stzString("this is just عربي latin script")
#
# Extracted from stzTtexttest.ring, block #37.

load "../../stzBase.ring"

pr()

? o1.ToStzText().Scripts()
#--> [
#	:latin,
#	:common,
#	:arabic
#    ]

pf()
