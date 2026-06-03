# Narrative
# --------
# TODO: check result correctness!
#
# Extracted from stzlistofstringstest.ring, block #75.

load "../../../stzBase.ring"


pr()

o1 = new stzList([ "tunis", "tripoli", "cairo", "casablanca" ])

o1.SortByInDescending('len(This[@item])')
? o1.Content()

pf()
