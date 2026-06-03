# Narrative
# --------
# pr()
#
# Extracted from stzhashlisttest.ring, block #11.

load "../../stzBase.ring"

pr()

o1 = new stzHashList([
	:Zero	= 0,
	:One	= "One",
	:Two  	= [ :is, :will, :can, :some, :can ],
	:Three	= "Three",
	:Four	= [ :can, :will ],
	:Five	= [ :will ],
	:Six	= 6,
	:Seven	= 7,

	:Ten	= NullObject(),
	:Eleven	= TRUEObject(),
	:Twelve	= FALSEObject(),

	:Thirteen = StzNamedNumberQ( :@number = 10 ),
	:Forteen  = StzNamedStringQ( :@string = "Forteen" ),
	:Fifteen  = StzNamedListQ( :@list = 1:3 ),
	:Sixtenn  = StzNamedHashListQ( :@hashlist = [ :x = 10, :y = 20 ])
])

? o1.FindLists()
#--> [ 3, 5, 6 ]

? @@( o1.Lists() ) + NL
#--> [ [ "is", "will", "can", "some", "can" ], [ "can", "will" ], [ "will" ] ]

#--

? o1.FindNumbers()
#--> [1, 7, 8]

? o1.Numbers()
#--> [ 0, 6, 7 ]

#--

? o1.FindStrings()
#--> [2, 4]

? o1.Strings()
#--> [ "One", "Three" ]

#--


? o1.FindObjects()
#--> [9, 10, 11, 12, 13, 14, 15]

? @@( o1.Objects() )
#--> [ @nullobject, @trueobject, @falseobject, @number, @string, @list, @hashlist ]

#===

? @@( o1.FindStzLists() ) + NL
#--> [ 14 ]

? @@( o1.StzLists() ) + NL
#--> [ @list ]

#--

? @@( o1.FindStzNumbers() ) + NL
#--> [ 12 ]

? @@( o1.StzNumbers() )
#--> [ @number ]

#--

? @@( o1.FindStzStrings() ) + NL
#--> [ 13 ]

? @@( o1.StzStrings() )
#--> [ @string ]

#--

? @@( o1.FindStzObjects() )
#--> [ 9, 10, 11, 12, 13, 14, 15 ]

? @@( o1.StzObjects() )
#--> [ @nullobject, @trueobject, @falseobject, @number, @string, @list, @hashlist  ]

#--

? @@( o1.FindStzHashLists() )
#--> [ 15 ]

? @@( o1.StzHashLists() )
#--> [ @hashlist ]

pf()
# Executed in 0.21 second(s) in Ring 1.21
