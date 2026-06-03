# Narrative
# --------
# #narration
#
# Extracted from stzStringTest.ring, block #581.

load "../../stzBase.ring"


pr()

# In Softanza, to remove a substring from left or right
# you can use RemoveFromLeft() and RemoveFromRight() functions:

o1 = new stzString("let's say welcome to everyone!")
o1.RemoveFromLeft("let's say ")
? o1.Content()
#--> welcome to everyone!

# But when right-to-left strings are used, this can be confusing,
# since left is no longer at the start of the string, nor the
# right is at the end!

# Hence, if you want to retrieve a substring from the beginning
# of a right-to-left arabic text ("هذه" in the following example),
# you should inverse the orientation and use RemoveFromRight()
# instead...

o1 = new stzString("هذه الكلمات الّتي سوف تبقى")
? o1.NRightCharsAsSubstring(4) #--> "هذه "

o1.RemoveFromRight("هذه ")
? o1.Content() #--> "الكلمات الّتي سوف تبقى"

# To avoid this complication, Softanza provides a more general (semantic)
# solution working both for left-to-right and right-to-left strings:
# the RemoveFromStart() and RemoveFromEnd() functions...

o1 = new stzString("let's say welcome to everyone!")
o1.RemoveFromStart("let's say ")
? o1.Content() #--> welcome to everyone!

# and the same code working for arabic:

o1 = new stzString("هذه الكلمات الّتي سوف تبقى")
o1.RemoveFromStart("هذه ")
? o1.Content() #--> "الكلمات الّتي سوف تبقى"

pf()
# Executed in 0.02 second(s) in Ring 1.20
# Executed in 0.07 second(s) in Ring 1.17
