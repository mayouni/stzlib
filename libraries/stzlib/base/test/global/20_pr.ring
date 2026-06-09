# Narrative
# --------
# pr()
#
# Extracted from stzGlobalTest.ring, block #20.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"

pr()

@ForEach( :name, :in = [ "teeba", "haneen", "hussein" ]) { X('

	? upper( v(:name) )

')}
#--> TEEBA
#--> HANEEN
#--> HUSSEIN

pf()
# Executed in 0.04 second(s)
