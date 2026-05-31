# Narrative
# --------
# pr()
#
# Extracted from stzhashlisttest.ring, block #21.

load "../../../stzBase.ring"


# You need to pay attention to the syntax you use in creating a stzHashList
# Hence, the follwing syntax is incorrect:

//o1 = new stzHashList( [ "one" = 1, "two" = 2 ] )
//? o1.Keys() #--> ERROR: The list you provided is not a hash list!

# In fact, the ( = value  ) syntax is allowed only if you use ':' like this:

o1 = new stzHashList( [ :one = 1, :two = 2 ] )
? o1.Keys() #--> [ "one", "two" ]

# Or, you can opt for an explicit syntax like this:

o1 = new stzHashList( [ ["one", 1], [ "two", 2] ] )
? o1.Keys() #--> [ "one", "two" ]

pf()
# Executed in 0.01 second(s)
