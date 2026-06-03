# Narrative
# --------
# pr()
#
# Extracted from stzextinpythonTest.ring, block #8.
#ERR Error (R14) : Calling Method without definition: isupper

load "../../stzBase.ring"

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
