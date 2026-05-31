# Narrative
# --------
# pr()
#
# Extracted from stzhashlisttest.ring, block #12.

load "../../../stzBase.ring"


o1 = new stzHashList([
	:Zero	= 0,
	:One		= "One",
	:Two  	= [ :is, :will, :can, :some, :can ],
	:Three	= "Three",
	:Four	= [ :can, :will ],
	:Five	= [ :will ],
	:Six		= 6,
	:Seven	= 7,

	:Ten		= NullObject(),
	:Eleven	= ATRUEObject(),
	:Twelve	= AFALSEObject(),

	:Thirteen  = StzNamedNumberQ( :@number = 10 ),
	:Forteen   = StzNamedStringQ( :@string = "Forteen" ),
	:Fifteen   = StzNamedListQ( :@list = 1:3 ),
	:Sixtenn   = StzNamedHashListQ( :@hashlist = [ :x = 10, :y = 20 ]),
	:Seventeen = [ :will ]
])

? @@( o1.FindLists() ) + NL
#--> [ 3, 5, 6, 16 ]

? @@( o1.ListsZ() ) + NL
#--> [
#	[ [ "is", "will", "can", "some", "can" ], [ 3 ] ],
#	[ [ "can", "will" ], [ 5 ] ],
#	[ [ "will" ], [ 6, 16 ] ],

# ]

#--

? @@( o1.FindList([ "will" ]) ) + NL
#--> [ 6, 16 ]

? @@( o1.ListZ([ "will" ]) )
#--> [ [ "will" ], [ 6, 16 ] ]

#--

? @@( o1.FindTheseLists([ [ "can", "will" ], [ "will" ] ]) ) + NL
#--> [ 5, 6, 16 ]

? @@( o1.TheseListsZ([ [ "can", "will" ], [ "will" ] ]) )
#--> [ [ [ "can", "will" ], [ 5 ] ], [ [ "will" ], [ 6, 16 ] ] ]

pf()
# Executed in 0.04 second(s) in Ring 1.21
