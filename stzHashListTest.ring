load "stzlib.ring"

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
