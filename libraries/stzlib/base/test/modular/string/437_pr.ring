# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #437.

load "../../../stzBase.ring"


# Because Softanza mimics natural language train of thoughts,
# the computational form:

? NOT Q("*").IsLetter()

# Can be written:

? Q("*").IsNotLetter() + NL

# This called @FunctionNegativeForm in Softanza.

#NOTE: Not all Softanza functions made ready for their negative forms,
# but this will be done in the future.

#NOTE: @FunctionNegativeForm is different from @FunctionPassiveForm,
# which is the linguitsic passive form of the function verb. For example:

o1 = new stzString("RIxxNxG")
o1.Remove("x") # ~> This is the active form of the function
#--> All "x" chars are now removed from the object content.
? o1.Content()
#--> RING

# Hence, the active form (expressed with the verb Remove()) modifies
# the content of the object. In some cases, however, you need to
# perform the removal without altering the original content...

# Lingusitically speaking, you want a copy of this string from
# wich the "x" chars are removed, while leaving the original content as is.

# Here comes the usefulness of the @FunctionPassiveform. Let's redo
# the same sample to show you this:

o1 = new stzString("RIxxNxG")
? o1.Removed("x")
#--> RING

# and the original obkect is not changed:
? o1.Content()
#--> RIxxNxG


pf()
# Executed in 0.01 second(s) in Ring 1.21
