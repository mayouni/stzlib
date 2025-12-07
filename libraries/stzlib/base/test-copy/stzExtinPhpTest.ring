load "../stzbase.ring"

/*==== Using a PHP code inside Ring  #===
*/
# This code snippet is written in PHP. It calculates the min
# and max of two lists of numbers:
"
echo(min(0, 150, 30, 20, -8, -200));  #--> -200
echo(max(0, 150, 30, 20, -8, -200));  #--> 150
"

# Nearly the same code can be written in Ring thanks to the
# Min(), Max() and echo() functions of SoftanzaLib:

pr()

echo( Min([0, 150, 30, 20, -8, -200]) );   #--> -200	#ERROR #TODO
echo( Max([0, 150, 30, 20, -8, -200]) );   #--> 150

#NOTE that the only difference is to put the numbers in a list
# by bounding them by [ and ], inside the min() and max() functions

pf()
# Executed in almost 0 second(s) in Ring 1.21
# Executed in 0.04 second(s) in Ring 1.20

/*======== PHP

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
