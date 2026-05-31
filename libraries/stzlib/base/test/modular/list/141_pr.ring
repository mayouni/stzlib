# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #141.

load "../../../stzBase.ring"


# Simulated CSV data with duplicate rows

aImportedData = [
    	["id", "name", "email"],
    	["1", "John", "john@email.com"],
    	["1", "John", "john@email.com"],	# Duplicate
    	["2", "Jane", "jane@email.com"],
    	["2", "Jane", "jane@email.com"],    	# Duplicate
	["2", "Jane", "jane@email.com"],	# Duplicate
   	["3", "Bob", "bob@email.com"]
]

oDataRecords = new stzList(aImportedData)

? @@NL(oDataRecords.DuplicatesZ()) + NL
#--> [
#	[ [ "1", "John", "john@email.com" ], [ 3 ] ],
#	[ [ "2", "Jane", "jane@email.com" ], [ 5, 6 ] ]
# ]

oDataRecords.RemoveDuplicates()
? @@NL(oDataRecords.Content())
#--> [
#	[ "id", "name", "email" ],
#	[ "1", "John", "john@email.com" ],
#	[ "2", "Jane", "jane@email.com" ],
#	[ "3", "Bob", "bob@email.com" ]
# ]

pf()
# Executed in 0.01 second(s).
