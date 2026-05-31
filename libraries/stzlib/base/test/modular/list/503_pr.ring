# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #503.

load "../../../stzBase.ring"


# All these return TRUE

? Q( 1:5 ).IsListOf(:Numbers)
#--> TRUE

? Q( "A":"E" ).IsListOf(:Strings)
#--> TRUE

? Q([ 1:5, "A":"E" ]).IsListOf(:Lists)
#--> TRUE

? Q( [ 1:5, 6:10, 11:15 ] ).IsListOf(:ListOfNumbers)
#--> TRUE

? Q( [ 1:5, 6:10, 11:15 ] ).IsListOf(:ListsOfNumbers) // #NOTE the support of plural form
#--> TRUE

? Q( [ "A":"E", "a":"e" ] ).IsListOf(:ListOfStrings)
#--> TRUE

? Q( [ "A":"E", "a":"e" ] ).IsListOf(:ListsOfStrings) //#NOTE the support of plural form
#--> TRUE

pf()
# Executed in 0.09 second(s).
