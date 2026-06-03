# Narrative
# --------
# #narration
#
# Extracted from stzStringTest.ring, block #46.

load "../../stzBase.ring"


pr()

# In Softanza, you can get a part of a list (or string) using
# Section() function, also called Slice()

o1 = new stzString("123456789")

? o1.Section(3, 5)
#--> "345"

# When you inverse the params so the first is greater then the second,
# nothing happens to the result ( the Section() function is not aware
# of the direction of parsing ) :

? o1.Section(5, 3)
#--> "345"

# You may argue that it would be useful, in this case, to embrace the
# Python-way of returning an inversed string (or list)...

# Softanza does not reject that, and finds it very useful too! But, it just
# requires that you use the extended form of the function, SectionXT() :

? o1.SectionXT(5,3)
#--> "543"

# As you see, the section has been reversed. But you can do more, and use
# negative numbers to order Softanza to start parsing from the end:

? o1.SectionXT(-4, -2)
#--> 678

? o1.SectionXT(-2, -4)
#--> 876

# Remember : if you try these fency things with the more conservative Section()
# methond (without ...XT() extension), and for Softanza to stay simple and
# consitent for the most common use cases, you will get an error:

//? o1.Section(-2, -4)
#--> Error message: Indexes out of range! n1 and n2 must be inside the string.

# Before you leave : All what works for stzString, will work for stzList.
# For our case, just change the first line of the code to use stzList instead
# of stzString, like this :

o1 = new stzList("1":"9")

# Now you can run the code sucessfully withou any modification.

pf()
# Executed in 0.01 second(s)
