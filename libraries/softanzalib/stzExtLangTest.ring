load "stzlib.ring"



/*==== Using a Python code inside Ring ===

pron()

	? range(3)
	#--> [ 0, 1, 2 ]
	
	? range([-3, 3+1, 2])
	#--> [ -3, -1, 1, 3 ]
	
proff()
# Executed in 0.03 second(s)

/*------------

pron()

bestlang = "Ring"

print( f("My best language is {bestlang}!") )
#--> My best language is Ring!

proff()
# Executed in 0.08 second(s)

/*------------
*/
string1 = "Hello, world!"
string2 = "Hello, beautiful world!"

oDiff = new diff_algorithm(string1, string2)
differences = oDiff.diff()
? @@(difference.diff())


for( [ :change, :char ], :in = differences) {

	if v(:change) = '='
        	print( f("Unchanged: {char}") )

    	but v(:change) = '+'
        	print( f("Added: {char}") )

    	but v(:change) = '-'
        	print( f("Deleted: {char}") )
	ok

}
	
class diff_algorithm
	n
	m
	max_length
	v

	def init(string1, string2)
		n = len(string1)
    		m = stlen(string2)
    		max_length = n + m
   		v = Q([0]) * (2 * max_length) //<<<

	def snake(k, x, y)

        	while x < n and y < m and string1[x] = string2[y]
           		x += 1
            		y += 1
            		k += 1
		end

        	return [k, x, y]

   	def diff()

		for d in range(max_length) //<<<

        		for k in range(-d, d + 1, 2) //<<<

            			if k = -d or (k != d and v[k - 1] < v[k + 1])
               				x = v[k + 1]
            			else
                			x = v[k - 1] + 1
	   			ok

            			y = x - k

            			Vr([ :k, :x, :y ]) = Vl( snake(k, x, y) ) //<<<<<
           			v[v(:k)] = v(:x)

            			if v(:x) >= n and v(:y) >= m
                			return construct_diff(v, string1, string2)
	    			ok
			next
		next

		return None  # No diff found


	def construct_diff(v, string1, string2)

		diff = []
		n = len(string1)
		m = len(string2)
		x = n
		y = m
	
	    	while x > 0 or y > 0
	        	if x > 0 and y > 0 and Q(string1[x - 1]).Equals(Q(string2)[y - 1])
	           		Q(diff).append([ '=', Q(string1)[x - 1] ]) //<<<
	            		x -= 1
	           		 y -= 1
	
	        	but y > 0 and ( x = 0 or v[x - 1] < v[x + 1] )
	            		Q(diff).append([ '+', Q(string2)[y - 1] ])
	           		 y -= 1
	
	        	else
	            		Q(diff).append(['-', Q(string1)[x - 1]])
	           		 x -= 1
			ok
	
	    	end
	
	    	return Q(diff)['::-1'] //<<<<<< diff reversed


/*----------------

pron()

# In Softanza, you can define many variables and affect
# values to them in one line like this:

V([ :x = 10, :y = 20, :z = 30 ])

# Then, you can get the values by calling the variables
# using their names like this:

? v(:x) #--> 10
? v(:y)	#--> 20
? v(:z) #--> 30

? ""

# Or you can compose them in a list and print them like this:

? v([ :x, :y, :z ])
#--> [ 10, 20, 30 ]

proff()
# Executed in 0.05 second(s)

/*----------------

pron()

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



proff()


/*--------------

# I asked Bard (Google AI) about a code in Python that returns the
# uppercase strings from a given list of strings...

# Bard generated this code wich seems great!

'
	def uppercase_strings(list_of_strings):
		uppercase_strings = []
		
		for string in list_of_strings:
	    		if string.isupper():
	      			uppercase_positions.append(index)

	 	return uppercase_strings
	
	print( uppercase_strings([ "HELLO", "world", "this is", "RING!" ]) )
	#--> { "HELLO", "RING!" ]
	
'

# In Ring, I pasted the same code, organized it the Ring way (functions go at
# the end), and slightly change just one line of code. And then I run it, and
# it works!

	print( uppercase_strings([ "HELLO", "world", "this is", "RING!" ]) )
	#--> { "HELLO", "RING!" ]

	# Here is the function code

	def uppercase_strings(list_of_strings)
		uppercase_strings = []
	
		for str in list_of_strings

			if Q(str).isupper() # str is elevated to a stzString object using Q()
				uppercase_strings = Q(uppercase_strings).appendedWith(str)
				# This line was slightly tweakened, to keep things logical and expressive
			ok
		end
	
		return uppercase_strings

	# All the rest is keot unchanged.

/*==== Using a PHP code inside Ring  #===
	
# This code snippet is written in PHP. It calculates the min
# and max of two lists of numbers:
"
	echo(min(0, 150, 30, 20, -8, -200));  #--> -200
	echo(max(0, 150, 30, 20, -8, -200));  #--> 150
"

# Nearly the same code can be written in Ring thanks to the
# Min(), Max() and echo() functions of SoftanzaLib:

StartProfiler()

	echo( Min([0, 150, 30, 20, -8, -200]) );   #--> -200
	echo( Max([0, 150, 30, 20, -8, -200]) );   #--> 150

	# Note that the only difference is to put the numbers in a list
	# by bounding them by [ and ], inside the min() and max() functions

StopProfiler()
# Executed in 0.04 second(s)

/*==== Using a C# code inside Ring  #===

StartProfiler()

	# This is a C# code showing string interpolation:
	'
	int max = int.MaxValue;
	int min = int.MinValue;
	Console.WriteLine($"The range of integers is {min} to {max}");
	'

# And here is the same code translated to Ring:

	int max = int.MaxValue;
	int min = int.MinValue;
	Console.WriteLine( $("The range of integers is {min} to {max}") );
	#--> The range of integers is '-999_999_999_999_999' to '999_999_999_999_999'

	# Note that the only change made to the original C# code is to bound the string with ()
	
StopProfiler()
# Executed in 0.10 second(s)

/*==== USING a JS code inside Ring  #===

# The following JS code translate some string to
# uppercase in a locale sensitive way:
# (you can paste/test it here: https://bit.ly/3WdzMdF)
	"
	console.log('tunis'.toUpperCase());
	//--> TUNIS
	console.log('Iİıi'.toLocaleUpperCase('TR'));
	//--> IİIİ
	console.log('ß'.toLocaleUpperCase('de'));
	//--> SS
	"
# You can write nearly the same code, with almost the
# same JS-style, in Ring, using Softanza:
StartProfiler()

	console.log( Q('tunis').toUpperCase() );
	#--> TUNIS
	
	console.log( Q('Iİıi').toLocaleUpperCase('TR') );
	#--> IİII
	
	console.log( Q('ß').toLocaleUppercase('de') );
	#--> SS

	# Note hat the only difference is to elevate the string to
	# stzString objects using Q()

StopProfiler()
# Executed in 0.05 second(s)
