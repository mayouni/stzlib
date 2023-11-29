load "stzlib.ring"

/*--------------

pron()

StzNamedHashListQ(:myhash = [ :x = 10, :y = 20 ]) {

	? Name()
	#--> :myhash

	? StzType()
	#--> :stzhashlist

}

proff()
# Executed in 0.03 second(s)

/*-------------

pron()

? NullObject().Name()
#--> @nullobject

? TrueObject().Name()
#--> @trueobject

? FalseObject().Name()
#--> @falseobject

? ObjectVarName( NullObject() )
#--> @nullobject

? ObjectVarName( TrueObject() )
#--> @trueobject

? ObjectVarName( FalseObject() )
#--> @falseobject

proff()
#--> Executed in 0.06 second(s)

/*==============

pron()

o1 = new stzHashList([
	:one   = "here",
	:two   = "and",
	:three = "not",
	:four  = "there"
])

# Finding some values

? @@( o1.FindValues([ "here", "and", "there" ]) )
#--> [ 1, 2, 4 ]

proff()
# Executed in 0.04 second(s)

/*---------------

pron()

o1 = new stzHashList([
	:one   = [ "here" ],
	:two   = [ "and" ],
	:three = "not",
	:four  = [ "there" ]
])

# Finding some values (you are not going to find them ;)

? @@( o1.FindValues([ "here", "and", "there" ]) )
#--> [ ]

# There are no sutch values in the hashlist! In fact, they
# are hosted as items inside values of type list. So, if you
# need to find them, you can add the ..InLists() extension:

? @@( o1.FindTheseInLists([ "here", "and", "there" ]) )
#--> [ [ 1, 1 ], [ 2, 1 ], [ 4, 1 ] ]

# Or you can use the Item semantic like this:

? @@( o1.FindTheseItems([ "here", "and", "there" ]) )
#--> [ [ 1, 1 ], [ 2, 1 ], [ 4, 1 ] ]

# SEMANTIC NOTE: in the context of stzHashList, a VALUE is what
# you have side by side with the key. And you can find the VALUES
# using FindValues().
#
# When a VALUE is of type LIST, then you can find the ITEMS hosted
# inside those lists using FindInLists() or directly FindItems().
#
# WARNING: when you use FindValues, ITEMS inside lists are not found.
# And when you use FindInLists or FindItems then VALUES are not found.

proff()
# Executed in 0.18 second(s)

/*------------- TODO

pron()

o1 = new stzHashList([
	:One	= :can,
	:Two  	= [ :is, :will, :can, :some, :can ],
	:Three	= :NONE,
	:Four	= [ :will, :not ],
	:Five	= :can
])

? o1.FindValueOritem(:can) # called also FindVitem(:can)
#--> [ 1, 2, 5 ]

/*---------------- FINDING ITEMS INSIDE VALUES THAT ARE LISTS

pron()

o1 = new stzHashList([
	:One	= :NONE,
	:Two  	= [ :is, :will, :can, :some, :can ],
	:Three	= :NONE,
	:Four	= [ :can, :will ],
	:Five	= [ :will ]
])

? @@( o1.FindItem(:can) ) + NL
#--> [ [ 2, [ 3, 5 ] ], [ 4, [ 1 ] ] ]

? @@( o1.ItemZ(:can) ) + NL
#--> [ "can", [ [ 2, [ 3, 5 ] ], [ 4, [ 1 ] ] ] ]

? @@( o1.FindTheseItems([ :can, :will ]) ) + NL
#--> [ [ 2, 2 ], [ 2, 3 ], [ 2, 5 ], [ 4, 1 ], [ 4, 2 ], [ 5, 1 ] ]

? @@( o1.TheseItemsZ([ :can, :will ]) ) + NL
#--> [
#	[ "can",  [ [ 2, [ 3, 5 ] ], [ 4, [ 1 ] ] ] ],
#	[ "will", [ [ 2, [ 2 ] ], [ 4, [ 2 ] ], [ 5, [ 1 ] ] ] ]
# ]

proff()
# Executed in 0.15 second(s)

/*-----------

pron()

o1 = new stzHashList([
	:One	= :NONE,
	:Two  	= [ :is, :will, :can, :some, :can ],
	:Three	= :NONE,
	:Four	= [ :can, :will, :will ],
	:Five	= [ :will ]
])

? @@( o1.FindInLists(:will) )
#--> [ [ 2, [ 2 ] ], [ 4, [ 2, 3 ] ], [ 5, [ 1 ] ] ]

proff()

/*-----------

pron()

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
	:Eleven	= TrueObject(),
	:Twelve	= FalseObject(),

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

proff()
# Executed in 0.26 second(s)

/*-----------

pron()

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
	:Eleven	= TrueObject(),
	:Twelve	= FalseObject(),

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

proff()
# Executed in 0.11 second(s)

/*--------

pron()

o1 = new stzListOfLists([
	[ :is, :will, :can, :some, :can ],
	[ :can, :will ],
	[ :will ]
])

? @@( o1.Index() )
#--> [
#	[ "is", 	[ [ 1, 1 ] ] ],
#	[ "will", 	[ [ 1, 2 ], [ 2, 2 ], [ 3, 1 ] ] ],
#	[ "can", 	[ [ 1, 3 ], [ 1, 5 ], [ 2, 1 ] ] ],
#	[ "some", 	[ [ 1, 4 ] ] ]
# ]

proff()
# Executed in 0.09 second(s)

/*-----------

pron()

o1 = new stzHashList([
	:One	= :NONE,
	:Two  	= [ :is, :will, :can, :some, :can ],
	:Three	= :NONE,
	:Four	= [ :can, :will ],
	:Five	= [ :will ]
])

? @@( o1.FindNonLists() ) + NL
#--> [ 1, 3 ]

? @@( o1.Listified() )
#--> [
#	:One	= [ :NONE ],
#	:Two  	= [ :is, :will, :can, :some, :can ],
#	:Three	= [ :NONE ],
#	:Four	= [ :can, :will ],
#	:Five	= [ :will ]
# ]

proff()
# Executed in 0.06 second(s)

/*-----------

pron()

o1 = new stzHashList([
	:One	= :NONE,
	:Two  	= [ :is, :will, :can, :some, :can ],
	:Three	= :NONE,
	:Four	= [ :can, :will ],
	:Five	= [ :will ]
])

? @@( o1.Items() ) + NL
#--> [ "is", "will", "can", "some" ]

? @@( o1.FindItems() ) + NL
#--> [ [ 2, 1 ], [ 2, 2 ], [ 2, 3 ], [ 2, 4 ], [ 2, 5 ], [ 4, 1 ], [ 4, 2 ], [ 5, 1 ] ]

? @@( o1.ItemsZ() )
#--> [
#	[ "is", [ [ 2, 1 ] ] ],
#	[ "will", [ [ 2, 2 ], [ 4, 2 ], [ 5, 1 ] ] ],
#	[ "can", [ [ 2, 3 ], [ 2, 5 ], [ 4, 1 ] ] ],
#	[ "some", [ [ 2, 4 ] ] ]
# ]

proff()
# Executed in 0.16 second(s)

/*-----------

pron()

o1 = new stzHashList([
	:one	= Q(1),
	:two	= Q("2"),
	:three	= Q(3),
	:four	= Q(4),
	:five	= Q("5"),
	:six	= Q([6]),
	:seven	= Q([7])
])

? @@( o1.FindStzNumbers() )
#--> [ 1, 3, 4 ]

? @@( o1.FindStzStrings() )
#--> [ 2, 5 ]

? @@( o1.FindStzLists() )
#--> [ 6, 7 ]

? @@( o1.FindStzObjects() )
#--> [ 1, 2, 3, 4, 5, 6, 7 ]

proff()
# second(s)

/*=============

pron()

o1 = new stzHashList([
	:one	= "will not be classified",
	:two	= [ "will", "be", "classified" ],
	:three	= [ "this", "one", "also", "will" , "be", "classsified" ],
	:four	= "nor this will be classified",
	:five	= [ "guess", "if", "this", "will", "be", "classified" ],
	:six	= "and this",
	:seven	= "and this" # TODO: use an object an test
])

? o1.HowManyKlassInLists()
#--> 9

? @@( o1.KlassifyItemsInLists() ) # Or KlassifyInLists()
#--> [
#	[ "will", 	 [ [ 2, [ 1 ] ], [ 3, [ 4 ] ], [ 5, [ 4 ] ] ] ],
#	[ "be", 	 [ [ 2, [ 2 ] ], [ 3, [ 5 ] ], [ 5, [ 5 ] ] ] ],
#	[ "classified",  [ [ 2, [ 3 ] ], [ 5, [ 6 ] ] ] ],
#	[ "this", 	 [ [ 3, [ 1 ] ], [ 5, [ 3 ] ] ] ],
#	[ "one", 	 [ [ 3, [ 2 ] ] ] ],
#	[ "also", 	 [ [ 3, [ 3 ] ] ] ],
#	[ "classsified", [ [ 3, [ 6 ] ] ] ],
#	[ "guess", 	 [ [ 5, [ 1 ] ] ] ],
#	[ "if", 	 [ [ 5, [ 2 ] ] ] ]
# ]

proff()
# Executed in 0.10 second(s)

/*-------------
*/
pron()

o1 = new stzHashList([
	:one 	= :red,
	:two 	= :white,
	:three 	= :white,
	:four 	= :green,
	:five 	= :red,
	:six 	= :green,
	:seven 	= :white,
	:eight	= :yellow
])
/*
# Info about all classes available in the hash list

? o1.NumberOfKlasses()
#--> 4

? @@( o1.Klasses() ) + NL
#--> [ :red, :white, :green, :yellow ]

? @@( o1.KlassesSizes() )
#-->

? @@( o1.KlassesSizesXT() )


? @@( o1.KlassesFreqs() ) + NL
#--> [ 0.25, 0.38, 0.25, 0.13 ]

? @@( o1.KlassesFreqsXT() ) + NL
#--> [ [ "red", 0.25 ], [ "white", 0.38 ], [ "green", 0.25 ], [ "yellow", 0.13 ] ]

# Info about one class

? o1.ContainsKlass(:white)
#--> TRUE

? o1.KlassSize(:white)
#--> 3

? @@( o1.Klass(:white) )
#--> [ "two", "three", "seven" ]

? o1.KlassFreq(:white)
#--> 0.38

? @@( o1.KlassFreqXT(:white) ) + NL
#--> [ "white", 0.38 ]

# Info about some classes

? o1.ContainsTheseKlasses([ :white, :green ])
#--> TRUE

? @@( o1.TheseKlassesSizes([ :white, :green ]) )
#--> [ 3, 2 ]

? @@( o1.TheseKlassesSizesXT([ :white, :green ]) )
#--> [ [ "white", 3 ], [ "green", 2 ] ]

? @@( o1.TheseKlassesFreqs([ :white, :green ]) )
#--> [ 0.38, 0.25 ]

? @@( o1.TheseKlassesFreqsXT([ :white, :green ]) ) + NL
#--> [ [ "white", 0.38 ], [ "green", 0.25 ] ]
*/

# Strongest and weakest classes

? o1.StrongestKlass()
#--> :yelllow

? o1.StrongestKlassXT()

? o1.WeakestKlass()
#--> :yellow

? o1.WeakestKlassXT()

/*
# ? o1.Top3Classes()	#--> [ :white, :red, :green ]
# ? o1.Top3ClassesXT()	#--> [ :white = 3, :red = 2, :red = 2 ]

? o1.StrongestNClasses(2)
? o1.WeakestNCLasses(2)
*/

proff()

/*----------------

pron()

o1 = new stzHashList([
	:one 	= :red,
	:two 	= :white,
	:three 	= :white
])

o1.PerformOnKeys(' { @key += @i }')
? o1.Keys() #--> [ :on1, :two2, :three3 ]

proff()

/*----------------

performOnValues()

/*----------------

pron()

# While working with stzHashLists, there may be a special need where you
# want to find a given item inside values that are of type list.

# Let's understand it by example:

	o1 = new stzHashList([
		:Positive	= [ :happy, :nice, :glad, :beautiful, :wanderful ],
		:Neutral  	= [ :is, :will, :can, :some ],
		:Negative	= [ :no, :not, :must, :difficult, :problem ]
	])

# If you need to find the value :nice, you won't be able to get using:
	? @@(o1.FindValue(:nice))	#--> [ ]


# That's because there is no sutch value equal to the string :nice in all
# the three pairs of the hashlist.

# In fact, these values are all of type list. So you want to find one of them
# you should provide it as a hole list, like that:

	? @@( o1.FindValue([ :is, :will, :can, :some ]) )	#--> [ 2 ]

# Now, because finding directly an item (which is an item of a value of type list)
# is something that you will need in practice, in many data-driven applications,
# Softanza proposes the FindItem() function to do just that!

# Hence, you can find :nice directly by saying:

	? @@( o1.FindItem(:nice) ) #--> [ 1 ]

proff()
# Executed in 0.04 second(s)

/*==================

pron()

o1 = new stzHashList([
	:egypt		= :africa,
	:tunisia	= :africa,
	:saudi_arabia	= :asia,
	:spain		= :europe,
	:canada		= :america,
	:france		= :europe,
	:poland		= :europe,
	:niger		= :africa,
	:iraq		= :asia,
	:japan		= :asia,
	:panama		= :america,
	:argentina	= :america
])

? @@( o1.Classify() ) + NL
#--> [ 
#	:africa 	= [ "egypt", "tunisia", "niger" 	],
#	:asia 		= [ "saudi_arabia", "iraq", "japan" 	],
#	:america 	= [ "canada", "panama", :argentina	],
#	:europe 	= [ "france", :spain, "poland" 		]
#    ]

? @@( o1.Klass(:asia) )
#--> [ "saudi_arabia", "iraq", "japan" ]

proff()
# Executed in 1.54 second(s)

/*---------------

pron()

# The keys of a hashlist must be unique. Otherwise you won't be able to
# create the hashlist objectS

o1 = new stzHashList([ :name = "Brad", :job = "actor", :job = "singer" ])
#--> Error message: The list you provided is not a hash list!

proff()

/*---------------

pron()

# You need to pay attention to the syntax you use in creating a stzHashlList
# Hence, the follwing syntax is incorrect:

//o1 = new stzHashList( [ "one" = 1, "two" = 2 ] )
//? o1.Keys() #--> ERROR: The list you provided is not a hash list!

# In fact, the ( = value  ) syntax is allowed only if you use ':' like this:

o1 = new stzHashList( [ :one = 1, :two = 2 ] )
? o1.Keys() #--> [ "one", "two" ]

# Or, you can opt for an explicit syntax like this:

o1 = new stzHashList( [ ["one", 1], [ "two", 2] ] )
? o1.Keys() #--> [ "one", "two" ]

proff()

/*--------------- 

pron()

o1 = new stzHashList([
	:math = 18,
	:stats = "good",
	:chemistry = 18,
	:history = [ 10, 15 ]
])

? @@( o1.FindValue(18) )
#--> [ 1, 3 ] 

? @@( o1.FindValue("good") )	// TODO: CaseSensitivity
#--> [ 2 ]
	
? @@( o1.FindValue([ 10, 15 ]) )
#--> [ 4 ]

proff()
# Executed in 0.04 second(s)

/*---------------

pron()

o1 = new stzHashList([ :math = 18, :stats = 16, :history = 14 ])

? o1.ValueByKey(:stats)
#--> 16

? o1[:stats]
#--> 16

proff()
# Executed in 0.04 second(s)

/*--------------

pron()

o1 = new stzHashList([ [ "NAME", "Mansour"] , [ "AGE" , 45 ] ])
? @@( o1.Content() ) # Keys are automatically lowercased
#--> [ [ "name", "Mansour" ], [ "age", 45 ] ]

proff()
# Executed in 0.03 second(s)

/*--------------

pron()

o1 = new stzHashList([ :name = "mansour", :age = 45, :job = "programmer" ])

? o1.ContainsKeys([:name, :age, :job])
#--> TRUE

o1.RemoveByKey(:age)
? o1.Content()
#--> [ :name = "mansour", :job = "programmer" ]

? o1.RemovePairByKeyQ(:job).Content()
#--> [ :name = "mansour" ]

proff()
# Executed in 0.03 second(s)

/*--------------

pron()

o1 = new stzHashList([ :name = "Hussein", :age = 1, :grandftaher = "Hussein" ])
o1.RemovePairsByValue("Hussein")
? o1.Content() #--> [ :age = 1 ]

proff()
# Executed in 0.04 second(s)

/*-------------

pron()

o1 = new stzHashList([ :name = "Hussein", :age = 1, :grandftaher = "Hussein" ])
o1.AddPair( :grandmother = "Arem" )
o1.Show()
#--> 'name': "Hussein"
#    'age': 1
#    'grandftaher': "Hussein"
#    'grandmother': "Arem"

proff()
