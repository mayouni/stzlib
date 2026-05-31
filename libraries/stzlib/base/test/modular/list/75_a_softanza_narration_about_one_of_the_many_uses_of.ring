# Narrative
# --------
# A Softanza narration about one of the many uses of @
#
# Extracted from stzlisttest.ring, block #75.

load "../../../stzBase.ring"


pr()

# In softanza there some useful functions that you can use from
# every where, because they are defined at the global level (you
# will find them either in stzGlobal.Ring or in each class file).

# For example, if you want to check if a list contains two numbers,
# you can say :

? BothAreNumbers(5, -12)
#--> TRUE

# When it makes sense, those functions are also provided as
# methods in a given class. So, BothAreNumbers() can also be
# used inside a list to check that it contains two numbers,
# like this:

? Q([ 5, -12 ]).BothAreNumbers() # Q() elevates the list to a stzList object
#--> TRUE

#NOTE that the name of the function stays the same, but its signature
# is different. In fact, they are two different things: the first one
# (with the two numbers as parameters) is defined at the global scope,
# and the second one (the method with the same name but without any
# parameter) is defined at the object scope, a stzList in this case.

# So, when you call it inside the object, Ring will execute the one
# without parameters and ignores the one with parameters located
# at the global scope.

# Now, what happens, if you need to call the gloabl function inside
# the object, like this:

Q([ 5, -12 ]) { 		# We are inside a stzList object

	? BothAreNumbers()	# This will work.
	#--> TRUE

	? BothAreNumbers(9, -9)	# This will raise an error!
	#--> ERROR: Calling function with extra number of parameters!
}

# You may solve this by creating an other stzList object
# for the [9, -9] list and call the function on it, like this:

Q([ 5, -12 ]) { 		# We are inside a stzList object

	? BothAreNumbers()	# This will work.
	#--> TRUE

	? Q([ 9, -9 ]).BothAreNumbers()	# This will work! Creates an other stzList object
	#--> TRUE
}

# This is correct! But Softanza wants to avoid mental distruption (the
# fact of thinking of an other object that you need to create inside
# the object you are focusing on!), and provides you with a simple
# and quick solution by the use of the @ wildcard:

Q([ 5, -12 ]) { 		# We are inside a stzList object

	? BothAreNumbers()	# This will work.
	#--> TRUE

	? @BothAreNumbers(9,-9)	# works, without beaking your train of thoughts!
				# by calling an alternative name of the global function
	#--> TRUE
}

# GENRAL RULE: Every time you have a global function in Softanza that is also
# available for a given object, and you need to call it from inside that
# object, prefix its name with a @, and it will work.

pf()
# Executed in 0.06 second(s)
