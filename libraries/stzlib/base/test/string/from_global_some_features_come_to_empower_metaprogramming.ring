# Narrative
# --------
# # Some features come to empower metaprogramming
#
# Extracted from stzGlobalTest.ring, block #38.
#ERR exit 3221225794

load "../../stzBase.ring"

pr()

# In softanza, creating new objects is made using the new keyword.
# So if you want to make a new stzString you say:

o1 = new stzString("hi")

# and when you want to make a stzList you say:

o1 = new stzList(1:3)

# But, sometimes, you need more flexibility in defining what kind
# of object you need to create. In practice, this would happen,
# when the type object to be creaded can not be known statically
# in the code, but in the runtime depending on a given value.

# To do it, Softanza comes with the new_stz() function that embraces
# the same mental model of the Ring new keyword:
#	- you define a variable and add the "=" operator ("o1 =" for example)
#	- you use "new" keyword
#	- you specify the name of the class describing the object
#	- you put the values of the required params


o1 = new_stz(:String, "hi") # now you have the stzString object created
? o1.Uppercased() #--> "HI3"

o1 = new_stz(:List, 1:3)
? o1.NumberOfItems() #--> 3

# Also, you may need to have the list of methods or attributes of a given
# object or class). Of course, you can use Ring methods() function.
# but this requires you to create a Softanza object before and then pass
# it to the function, like this:

o1 = new stzString("blablabla")
? methods(o1)

# In Softanza, you are not obliged to create any object, just say:
? Stz(:Char, :Methods)		#--> [ ... ]

# or if you want to have the attributes:
? Stz(:String, :Attributes) 	#--> [ :@oObject, :@cVarName ]

# You can even make a filter on the list of methods to return only those
# that verify a given condition:

? Stz(:Char, [ :Methods, :Where = 'Q(@Method).StartsWith("is")' ])
#--> [ :isLeftToRight, :IsRightToLeft, ... ]

pf()
