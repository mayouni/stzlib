# Narrative
# --------
# # Here (using "Until()"), you need to be careful, because you could easily fall
#
# Extracted from stzchainofvaluetest.ring, block #7.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"

pr()

# in an infinite loop problem! Try this for example (execute it in the console
# to be able to interrupt it without blocking Ring Notepad):

Until(:v).Is("11000").DoThis('{ v += "0" ? v }') #--> Infinite loop (stackoverflow)
# That's because v, beeing equal to "12", and the incrementation code (in "DoThis()")
# would never elevate it to react the value 11000.

pf()
