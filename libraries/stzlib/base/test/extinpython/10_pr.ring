# Narrative
# --------
# pr()
#
# Extracted from stzextinpythonTest.ring, block #10.

load "../../stzBase.ring"


# In Python, we can assign multiple values to many variables:
'
x, y, z = 10, 20, 30

print(x)
print(y)
print(z)
'

# In Ring, with Softanza, we can say it this way:

Vr([ :x, :y, :z ]) '=' Vl([ 10, 20, 30 ])

# And then you can call their values like this:

print( v(:x) )	#--> 10
print( v(:y) )	#--> 20
print( v(:z) )	#--> 30

pf()
# Executed in almost 0 second(s) in Ring 1.23
# Executed in 0.02 second(s) in Ring 1.21
# Executed in 0.06 second(s) in Ring 1.20
