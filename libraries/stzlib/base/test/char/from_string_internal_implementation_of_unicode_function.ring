# Narrative
# --------
# #narration INTERNAL IMPLEMENTATION OF UNICODE() FUNCTION
#
# Extracted from stzStringTest.ring, block #853.
#ERR Error (R3) : Calling Function without definition: stzcharerror

load "../../stzBase.ring"


pr()

# In Softanza you get the unicode number of a char by saying:

? Unicode("鶊")
#--> 40330

# Once you have the code, you can pass it as an imput to a stzChar
# char object to get the char:

? StzCharQ(40330).Content()
#--> 鶊

# The engine is used internally to get the Unicode code.
# We use StzChar to get the character from a decimal unicode:

? StzCharQ(:FromUnicode = 40220).Content()
#--> 鶊

pf()
# Executed in 0.01 second(s) in Ring 1.22
