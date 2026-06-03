load "../stzbase.ring"

/*==== Using a Python code inside Ring ===

pr()

# Reversing a list, the Python way

? Q(1:5)['::-1']
#--> [ 5, 4, 3, 2, 1 ]

# Getting a part of the list (from 2 to 8) with a step of 2

? Q(1:10)['2:8:2']
#--> [ 2, 4, 6, 8 ]

pf()
# Executed in 0.01 second(s) in Ring 1.23

/*------------

pr()

# Reversing a list, in Python code:
'
range(1, 5)[::-1]
#--> [ 4, 3, 2, 1 ]
'

# Doing it in Ring, Python-way:

? range1Q([ 1, 5 ])['::-1']
#--> [ 4, 3, 2, 1 ]

pf()
# Executed in 0.01 second(s) in Ring 1.23

/*------------

pr()

# range(n) : 0 <= x < n	--> n not included!

? range0(3)
#--> [ 0, 1, 2 ]

? @@( range0(-3) ) + NL
#--> []

# range(n1, n2): n1 <= x < n2

? range0([ 3, 10 ])
#--> [ 3, 4, 5, 6, 7, 8, 9 ]
	
? @@( range0([ 10, 3 ]) ) + NL
#--> []
	
? range0([ -3, 3 ])
#--> [-3, -2, -1, 0, 1, 2]
	
? @@( range0([ 3, -3 ]) )
#--> []
	
? range0Q([0, 3]) = range0(3)
#--> TRUE

# range(n1, n2, step): n1 <= x < n2 (increasing by step)

? range0([ 3, 10, 2 ])
#--> [ 3, 5, 7, 9 ]

? @@( range0([ 10, 3, 2 ]) ) + NL
#--> []

? range0([ 10, 3, -2 ])
#--> [ 10, 8, 6, 4 ]

? @@( range0([ 3, 10, -2 ]) )
#--> []

# range(start, stop, 1) is equivalent to range(start, stop)

? range0Q([ 3, 10, 1 ]) = range0([ 3, 10 ])
#--> TRUE

# range(0, stop, 1) is equivalent to range(0, stop) and range(stop)

? range0Q([ 0, 10, 1 ]) = range0Q([ 0, 10 ]) = range0(10)
#--> TRUE

pf()
# Executed in 0.01 second(s) in Ring 1.23

/*--------------

pr()

# Used to suppoprt external code from 0-based languages

? range0(3)
#--> [0, 1, 2]

? range0([ 1, 3 ]) 
#--> [1, 2]

? range0([ 2, 8, 3 ])
#--> [2, 5]

# Used in Ring 1-based lists

? range1(3)
#--> [1, 2, 3]

? range1([ 1, 3 ]) 
#--> [1, 2, 3]

? range1([ 2, 8, 3 ])
#--> [2, 5, 8]

# Special accessor (python-like), used here to reverse the list

? range1(':5:-1')
#--> [ 5, 4, 3, 2, 1 ]

? range0(':5:-1')
#--> [ 4, 3, 2, 1, 0 ]

pf()
# Executed in 0.02 second(s).

/*--------------

pr()

# In python, we get the integer part of the division using the // operator

'345 // 100'
#--> 3

# In Ring, we can simulate this Python syntax by saying:

? Q(345)['// 100']
#--> 3

pf()
# Executed in almost 0 second(s) in Ring 1.23
# Executed in 0.01 second(s) in Ring 1.21

/*---------------

pr()

# In Python, this code concatenates a list of items into a string
# using a given separator:

# ' + '.join([ "a", "b", "c" ])
#--> a + b + c

# In Ring, with Softanza, we can use the same code like this:

? Q(' + ').join([ "a", "b", "c" ])
#--> a + b + c

pf()
# Executed in 0.01 second(s) in Ring 1.23
# Executed in 0.03 second(s) in Ring 1.21
# Executed in 0.05 second(s) in Ring 1.20

/*--------------
*/
pr()

# This Python code calculates the euclidean distance between
# two lists of numbers located in a and b:

'
def dist(a,b):
    s = 0.0
    n = len(a)
    for i in range(n):
        dist = a[i] - b[i]
        s += dist*dist
    return sqrt(s)

a = [ 1, 2, 3, 4, 5 ]
b = [ 4, 5, 6, 7, 8 ]

print(euc_dist(a,b))
#--> 6.71
'

# In Ring, with Softanza, we can reuse nearly the same code,
# like this :

pr()

a = 1:5
b = 4:8
	
? euc_dist_(a,b)
#--> 6.71

pf()
# Executed in almost 0 second(s) in Ring 1.21
# Executed in 0.03 second(s) in ring 1.20

def euc_dist_(a,b)':' # we put the : char between two ''
s = 0.0
n = len(a)

for i in range1(n)':'
# We use range1() to make it start from 1
# We can also leave range() and add i++

dist = a[i] - b[i]
s += dist * dist
next

return sqrt(s)

# NOTE this euc_dis() function has beeen added to Softanza.
# To avoid conflict, I added here an _ after the function name.

/*--------------

pr()

# I asked Bard (Google AI) about a Python code that returns the
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

pf()

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

# Executed in 0.04 second(s) in Ring 1.23

/*--------------

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

/*----------------

pr()

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

/*--------------

pr()

# f-strings are a feature in Python for interpolating string
# content, by dynmalically evaluating variables inside it:

'
bestlang = "Python"
print(f"My best language is {bestlang}!")
#--> My best language is Python!
'

# the same syntax can be used in Ring with Softanza like this:

bestlang = "Ring"
print( f("My best language is {bestlang}!") )
#--> My best language is Ring!

pf()
# Executed in 0.01 second(s) in Ring 1.21
# Executed in 0.08 second(s) in Ring 1.20

/*--------------

pr()

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
# 	'>', '>',
# 	'<', '<', '<', '<', '<', '<', '<', '<', '<', '<'
# ]

# Using Softanza External Code facility, we can run quiet the same
# Python code in Ring:

pr()

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

pf()

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

# Executed in 0.02 second(s) in Ring 1.23
# Executed in 0.08 second(s) in Ring 1.20
