# Narrative
# --------
# pr()
#
# Extracted from stzregexdatatest.ring, block #3.

load "../../stzBase.ring"


Rx( pat(:numbersAsValuesInHashList) ) {
	? Pattern()
	#--> =\s*(?:"([+-]?\d+(?:\.\d+)?)"|([+-]?\d+(?:\.\d+)?))

	Match('[ :name = "John", :age = 34, :salary = "64000" ]')
	? @@( Matches() )
	#--> [ "= 34", '= "64000"' ]!
}

pf()
