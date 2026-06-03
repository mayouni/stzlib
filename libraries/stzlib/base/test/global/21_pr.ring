# Narrative
# --------
# pr()
#
# Extracted from stzGlobalTest.ring, block #21.

load "../../stzBase.ring"


@ForEach( [ :Name, :Age ], :In = [ :Heni = 25, :Omar = 32, :Sonia = 14 ] ) { X('
	? name + " " + age
')}
#--> heni 25
#    omar 32
#    sonia 14

pf()
# Executed in 0.04 second(s)
