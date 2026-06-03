# Narrative
# --------
# pr()
#
# Extracted from stzGlobalTest.ring, block #17.

load "../../stzBase.ring"

pr()

@ForEach( :number, :in = 1:5 ) { X('

	? v(:number)

') }

#--> 1
#    2
#    3
#    4
#    5

pf()
# Executed in 0.04 second(s)
