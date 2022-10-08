load "stzlib.ring"


/*----------------

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

? o1.Classes() 		#--> [ :red, :white, :green, :yellow ]
? o1.NumberOfClasses()	#--> 4
? o1.Klass(:white)	#--> [ :two, :three, :seven ]

//? o1.KlassFreq()	#--> 3/8

# ? o1.ClassesAndTheirFrequencies	// same as ClassesXT()
#--> [ :red = 3, :white = 2, :green = 2, :yello = 1 ]

# ? o1.StrongestClass()	#--> :white
# ? o1.WeakestClass()	#--> :yellow

# ? o1.Top3Classes()	#--> [ :white, :red, :green ]
# ? o1.Top3ClassesXT()	#--> [ :white = 3, :red = 2, :red = 2 ]

/*----------------

o1 = new stzHashList([
	:one 	= :red,
	:two 	= :white,
	:three 	= :white
])

o1.PerformOnKeys(' { @key += @i }')
? o1.Keys() #--> [ :on1, :two2, :three3 ]


/*----------------

SAME EXAMPLE ABOVE SHOULD WORK FOR ....INLIST() EXTENSION

/*----------------

# While working with stzHashLists, there may be a special need where you
# want to find a given item inside values that are of type list.

# Let's understand it by example:

	o1 = new stzHashList([
		:Positive	= [ :happy, :nice, :glad, :beatiful, :wanderful ],
		:Neutral  	= [ :is, :will, :can, :some ],
		:Negative	= [ :no, :not, :must, :difficult, :problem ]
	])

# If you need to find the value :nice, you won't be able to get using:
	? @@(o1.FindValue(:nice))	#--> [ ]


# That's because there is no sutch value equal to the string :nice in all
# the three pairs of the hashlist.

# In fact, these values are all of type list. So you want tho find one of them
# you should provide it as a hole list, like that:

	? @@( o1.FindValue([ :is, :will, :can, :some ]) )	#--> [ 2 ]

# Now, because finding directly a value (which is an item of a value of type list)
# is something that you will need in practice, in many data-driven applications,
# Softanza proposes the extension ...InList() to all the functions related to
# finding values in hashlists.

# Hence, you can find :nice directly by saying:

	? @@( o1.FindValueInList(:nice)	) #--> [ 1 ]

/*==================

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




? @@( o1.Classify() )
#--> [ 
#	:africa 	= [ "egypt", "tunisia", "niger" 	],
#	:asia 		= [ "saudi_arabia", "iraq", "japan" 	],
#	:america 	= [ "canada", "panama", :argentina	],
#	:europe 	= [ "france", :spain, "poland" 		]
#    ]

? @@( o1.Klass(:asia) )
#--> [ "saudi_arabia", "iraq", "japan" ]

/*---------------

# The keys of a hashlist must be unique. Otherwise you won't be able to
# create the hashlist objectS

o1 = new stzHashList([ :name = "Brad", :job = "actor", :job = "singer" ])
# --> Error message: The list you provided is not a hash list!

/*---------------

# You need to pay attention to the syntax you use in creating a stzHashlList
# Hence, the follwing syntax is incorrect:

//o1 = new stzHashList( [ "one" = 1, "two" = 2 ] )
//? o1.Keys() # --> ERROR: The list you provided is not a hash list!

# In fact, the ( = value  ) syntax is allowed only if you use ( : ) like this:

o1 = new stzHashList( [ :one = 1, :two = 2 ] )
? o1.Keys() # --> [ "one", "two" ]

# Or, you can opt for an explicit syntax like this:

o1 = new stzHashList( [ [ "one", 1], [ "two", 2] ] )
? o1.Keys() # --> [ "one", "two" ]

/*--------------- <<<<<<<<<<<< TODO: check this <<<<<<<<<<<<<<<

o1 = new stzHashList([ :math = 18, :stats = "good", :chemistry = 18, :history = [ 10, 15 ] ])
//? o1.FindValue(18) # --> [ 1, 3 ] 
//? o1.FindValue("good") # --> [ 2 ]	// TODO: CaseSensitivity
? o1.FindValue([ 10, 15 ]) # --> ERROR

/*---------------

o1 = new stzHashList([ :math = 18, :stats = 16, :history = 14 ])
? o1.ValueByKey(:stats) # --> 16
? o1[:stats]		# --> 16

/*--------------

o1 = new stzHashList([ [ "NAME", "Mansour"] , [ "AGE" , 45 ] ])
? o1.Content() # Keys are automatically lowercased
# --> [ :name = "Mansour", :age = 45 ]

/*--------------

o1 = new stzHashList([ :name = "mansour", :age = 45, :job = "programmer" ])
? o1.ContainsKeys([:name, :age, :job]) # --> TRUE

o1.RemoveByKey(:age)
? o1.Content() # --> [ :name = "mansour", :job = "programmer" ]

? o1.RemovePairByKeyQ(:job).Content() # --> [ :name = "mansour" ]

/*--------------

o1 = new stzHashList([ :name = "Hussein", :age = 1, :grandftaher = "Hussein" ])
o1.RemoveAllPairsWithValue("Hussein")
? o1.Content() # --> [ :age = 1 ]

/*-------------

o1 = new stzHashList([ :name = "Hussein", :age = 1, :grandftaher = "Hussein" ])
o1.AddPair( :mother = "Cherihen" )
o1.Show()
