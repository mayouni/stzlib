# Narrative
# --------
# pr()
#
# Extracted from stzGlobalTest.ring, block #20.

load "../../../stzBase.ring"


@ForEach( :name, :in = [ "teeba", "haneen", "hussein" ]) { X('

	? upper( v(:name) )

')}
#--> TEEBA
#--> HANEEN
#--> HUSSEIN

pf()
# Executed in 0.04 second(s)
