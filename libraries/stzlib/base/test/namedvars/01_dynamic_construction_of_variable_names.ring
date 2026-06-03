# Narrative
# --------
# #narration DYNAMIC CONSTRUCTION OF VARIABLE NAMES
#
# Extracted from stznamedvarstest.ring, block #1.

load "../../stzBase.ring"


pr()

# Softanza makes it possible to contruct variable
# names in a dynamic way.

# This can be helful when you have a large number
# of variables that obey to the same naming pattern
# (example: name1, name2, name3, ..., name100) and you
# want to avoid their declaration in 100 lines of code!

# Or when the names of the variables depend on some data
# that you are going to have only in runtime (part of the
# variable name comes from the ID of the user, or from a
# hashed part of the file name uploaded, etc...).

# Or many other advanced cases related to realtime interactive
# apps, generative video game worlds, machine learning and AI,
# rules and inference engines, and genetic algorithms.

# For me, in particular, this feature is made to enable some
# advanced features in Near Natural Language programming.

# Let's show how this works with a simple example.

# Our objective is to declare 10 variables (name1, name2, ...,
# name10), along with their respective values 10, 20, ...100

# As you can see, there is an interesting common pattern between
# our variables names and their values:
# 	- the names end with a dynamic part: the numbers 1 to 10
# 	- the values are all multiple of 10 by the numbers 1 to 10

# And so, we can dynamically use a loop with an index number i,
# from 1 to 10, and than construct both the names of the variables
# and their values, in one line, like this:

for i = 1 to 10 { Vr( 'name' + i ) '=' Vl( 10 * i ) } 

# We get the name of the variable name3
? v( :name3 )
#--> 30

# You can change the value of name3, like this:
Vr( :name3 ) '=' Vl( 44 )

# check it:
? v(:name3)
#--> 44

# Or you can change it like this:
VrVl( :name3 = 30 )
? v(:name3)
#--> 30

# We get the name of the variable and its value by
# adding the xt extension to the v() small function:

? @@( vxt( :name3 ) )
#--> [ "name3", 30 ]

# We can get all the variables along with their values

for i = 1 to 10 { ? @@(vxt( 'name' + i )) }
#--> [ "name1", 10 ]
#    [ "name2", 20 ]
#    [ "name3", 30 ]
#    [ "name4", 40 ]
#    [ "name5", 50 ]
#    [ "name6", 60 ]
#    [ "name7", 70 ]
#    [ "name8", 80 ]
#    [ "name9", 90 ]
#    [ "name10", 100 ]

pf()
# Executed in 0.01 second(s) in Ring 1.23
# Executed in 0.37 second(s) in Ring 1.21
