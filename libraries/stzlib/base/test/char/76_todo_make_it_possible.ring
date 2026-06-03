# Narrative
# --------
# TODO: Make it possible...
#
# Extracted from stzchartest.ring, block #76.

load "../../stzBase.ring"


pr()

c1 = new stzChar("1/3")
? c1.Content()
#--> Error in file stzHexNumber.ring:
#   What : Can't create the hex number.
#   Why  : The value you provided is not in correct hex form.
#   Todo : Provide a hex number in a string prefixed by "0x" and containing only hex characters (from 0 to 9 and from A to F).

pf()
