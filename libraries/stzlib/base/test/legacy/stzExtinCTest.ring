load "../stzbase.ring"

/*----------

pr()

n = -12;
vr(:sign) '=' b(n > 0) '?' bt("positive") '!!' bf("negative");
printf( v(:sign) );
#--> negative

pf()
# Executed in almost 0 second(s) in Ring 1.23
# Executed in 0.01 second(s) in Ring 1.21
# Executed in 0.03 second(s) in Ring 1.20

/*--------------

pr()

# Ternary operator in C-style languages (C, C#, Java, Javascript, PHP...)
# variable = (condition) ? value1 : value2;

'
n = -12;
sign = (n > 0) ? "postive" : "negative";
printf(sign);
#--> negative
'

# The same syntax in Ring (with Softanza)

n = -12;
vr(:sign) '=' b(n > 0) '?' bt("positive") ':' bf("negative");
printf( v(:sign) );
#--> negative

pf()
# Executed in almost 0 second(s) in Ring 1.23
# Executed in 0.01 second(s) in Ring 1.21

/*------------
*/
pr()

bPositive = TRUE
Vr([ :x, :y, :z ]) '=' Vl([ 1, 2, 3 ]) _if(bPositive) _else([-1, -2, -3])
? @@( v([ :x, :y, :z ]) )
#--> [ 1, 2, 3 ]

bPositive = FALSE
Vr([ :x, :y, :z ]) '=' Vl([ 1, 2, 3 ]) _if(bPositive) _else([-1, -2, -3])
? @@( v([ :x, :y, :z ]) )
#--> [ -1, -2, -3 ]

pf()
# Executed in 0.01 second(s) in Ring 1.23
# Executed in 0.02 second(s) in Ring 1.21
# Executed in 0.12 second(s) in Ring 1.20

/*--------

pr()

bPositive = FALSE
Vr([ :x, :y, :z ]) '=' Vl([ 1, 2, 3 ]) _if(bPositive) _else([ -1 ])  # Only 1 value
? @@( v([ :x, :y, :z ]) )  #--> [ -1, 2, 3 ]  (replaces only :x; keeps :y/:z from vl())

pf()
# Executed in almost 0 second(s) in Ring 1.23

/*-----

pr()

bPositive = TRUE
Vr([ :x, :y, :z ]) '=' Vl([ 1, 2, 3 ]) _if(bPositive) _else([-1, -2, -3])
? @@( v([ :x, :y, :z ]) )
#--> [ 1, 2, 3 ]

pf()
# Executed in almost 0 second(s) in Ring 1.23
# Executed in 0.02 second(s) in Ring 1.21
# Executed in 0.07 second(s) in Ring 1.20
