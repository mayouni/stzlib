# Narrative
# --------
# o1 = new stzString("this is just عربي latin script")
#
# Extracted from stzTtexttest.ring, block #37.
#ERR Error (E9) : Can't open file 37_o1_new_stzstringthis_is_just_????_latin_script.ring

load "../../stzBase.ring"

pr()

? o1.ToStzText().Scripts()
#--> [
#	:latin,
#	:common,
#	:arabic
#    ]

pf()
