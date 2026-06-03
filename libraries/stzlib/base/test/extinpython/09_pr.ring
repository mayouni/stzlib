# Narrative
# --------
# pr()
#
# Extracted from stzextinpythonTest.ring, block #9.

load "../../stzBase.ring"

pr()

# In Softanza, you can define many variables and affect
# values to them in one line like this:

V([ :x = 10, :y = 20, :z = 30 ])

# The same thing can be done like this:

Vr([ :x, :y, :z ]) '=' Vl([ 10, 20, 30 ])

# Then, you can get the values by calling the variables
# using their names like this:

? v(:x) #--> 10
? v(:y)	#--> 20
? v(:z) #--> 30

? ""

# Or you can compose them in a list and print them like this:
#TODO ERROR check it
? v([ :x, :y, :z ])
#--> [ 10, 20, 30 ]
	
? v([ :x, :z ])
#--> [ 10, 30 ]
	
? v([ :x, :x, :z, :y ])
#--> [ 10, 10, 30, 20 ]

pf()
# Executed in 0.05 second(s)
