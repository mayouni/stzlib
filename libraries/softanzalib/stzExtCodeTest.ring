load "stzlib.ring"

#=========== TODO: Review string comparaision logic in stzString
/*
pron()

? Q("sam") < "samira"
#--> TRUE

? Q("samira") > "ira"
#--> TRUE

? Q("qam") = "sam"
#--> FALSE

? Q("QAM") = "qam"
#--> FALSE

proff()
# Executed in 0.06 second(s)

/*==== Using a Python code inside Ring ===

pron()

# Reversing a list, the Python-way:

? Q(1:5)['::-1']
#--> [5, 4, 3, 1]

proff()

/*--------------
*/
pron()

# In python, we get the integer part of the division using the // operator

'345 // 100'
#--> 3

# In Ring, we can simulate this Python syntax by saying:

? Q(345)['// 100']
#--> 3

proff()

/*---------------
*/
pron()

# In Python, this code concatenates a list of items into a string using a given separator:
/*
' + '.join([ "a", "b", "c" ])
*/
#--> a + b + c

# In Ring, with Softanza, we can use the same code like this:

? Q(' + ').join([ "a", "b", "c" ])
#--> a + b + c

proff()
# Executed in 0.05 second(s)

/*--------------


# We asked Bard AI about a python code that performs the
# Google Diff Algortithm (comparing two strings and
# showing their differences)...

# Here is the code proposed by Bard:
'
	def diff(old_string, new_string):
	  """Returns a list of diffs between two strings."""
	  diffs = []
	  i = 0
	  j = 0
	  while i < len(old_string) and j < len(new_string):
	    if old_string[i] == new_string[j]:
	      diffs.append("=")
	      i += 1
	      j += 1
	    elif old_string[i] < new_string[j]:
	      diffs.append("<")
	      i += 1
	    else:
	      diffs.append(">")
	      j += 1
	  return diffs

	def main():
	  old_string = "This is the old string."
	  new_string = "This is the new string."
	  diffs = diff(old_string, new_string)
	  print(diffs)

'
# When executed in Python, the code output is:
#--> [
# 	'=', '=', '=', '=', '=', '=', '=', '=', '=', '=', '=', '=',
#	'>', '>',
#	'<', '<', '<', '<', '<', '<', '<', '<', '<', '<'
# ]

# Using Softanza External Code facility, we can run quiet the same Python code in Ring:

pron()

def main()':' 
	old_string = "This is the old string."
	new_string = "This is the new string."

	diffs = diff(old_string, new_string)
	print( @@(diffs) )

	#--> [
	#	"=", "=", "=", "=", "=", "=", "=", "=", "=", "=", "=", "=",
	#	">", ">", ">", ">", ">", ">", ">", ">", ">", ">"
	# ]
	#--> TODO: Check the difference in output between Python and Ring+Softanza
	#--> See the difference in meaning attributed by each language to
	#    string cmparaison operators =, < and >

proff()
#Executed in 0.08 second(s)

def diff(old_string, new_string)':' # Here we put : between quotes
	"""Returns a list of diffs between two strings."""

	diffs = []
	i = 1 # Here we changed 0 by 1
	j = 1 # Idem

  	while i < len(old_string) and j < len(new_string)':' # Idem

    		if old_string[i] = new_string[j]
      			diffs = Q(diffs).appendedWith("=") # Here we changed the semantics
     			i += 1
     			j += 1
 
    		but Q(old_string[i]) < new_string[j] # Here we used Q()
      			diffs = Q(diffs).appendedWith("<") # Idem
      			i += 1

   		else':' # Idem
     			diffs = Q(diffs).appendedWith(">") # Idem
     			 j += 1
		ok
	end

 	return diffs

/*-----------

# range() is used for Pyhton-code compatibility

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
