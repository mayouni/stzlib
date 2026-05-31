# Narrative
# --------
# #TODO
#
# Extracted from stzlisttest.ring, block #339.

load "../../../stzBase.ring"


pr()

? Q([ "واحـد", "اثنان", "ثلاثة" ]).Yield('len(@item)')
#--> [10, 10, 10]

? Q([ "واحـد", "اثنان", "ثلاثة" ]).Yield('StzLen(@item)')
#--> [5, 5, 5]

pf()
