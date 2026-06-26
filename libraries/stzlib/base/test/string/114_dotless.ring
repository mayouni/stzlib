# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #114.
#
# DEFECT (deferred -- see _AUDIT_DEFECTS.md, "Dotless"): Dotless() is broken for
# Latin -- it should remove diacritics and turn "i" into the dotless "ı"
# (-> "alıtalıa extreme exterıeur aeoro ultra"), but instead it replaces "i" with
# the DIGIT "1" and leaves accented letters untouched
# ("al1tal1a extrême extèr1eur aéorô ûltrâ"). The source carries a #TODO.
# Left in print form; NOT asserted.

load "../../stzBase.ring"

pr()

? Dotless("alitalia extrême extèrieur aéorô ûltrâ")
#--> expected "alıtalıa extreme exterıeur aeoro ultra"

? Dotless("مشمش وخوخ وزيتون") #--> expected "مسمس وحوح ورٮٮوٮ"

pf()
