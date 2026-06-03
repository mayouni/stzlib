# Narrative
# --------
# PHP
#
# Extracted from stzextinphptest.ring, block #2.
#ERR Error (R20) : Calling function with extra number of parameters

load "../../stzBase.ring"


pr()
	
# In PHP we use indirection to dynamically
# call the name of a variable, like this:
'
$job = "programmer"
$var = "job"

echo($var) 
#--> job
echo($$var)
#--> programmer
'
# In Ring, with StzLib, we write quite
# the same code:
	
$(:job = "programmer")
$(:var = "job")

echo( $(:var) )
#--> job
echo( $$(:var) )
#--> programmer
	
# And we can also say (using named variables feature):
	
Vr(:job) '=' Vl("programmer")
Vr(:var) '=' Vl("job")

echo( v(:var) )
#--> job
echo( vv(:var) )
#--> programmer
	
# Or even say:
	
Vr(:job) '=' Vl("programmer")
Vr(:var) '=' Vl("job")

echo( v(:var) )
#--> job
echo( v(v(:var)) )
#--> programmer

pf()
# Executed in 0.01 second(s) in Ring 1.23
# Executed in 0.11 second(s) in Ring 1.21
