# Narrative
# --------
# #narration : Use of the L() small function
#
# Extracted from stzlisttest.ring, block #59.

load "../../../stzBase.ring"


pr()

# As we all know, Ring provides us with this elegant syntax:

? "A" : "D"
#--> [ "A", "B", "C", "D" ]

# Unfortunaltely, this is limited to ASCII chars.
# Hence, if we use it with other UNICODE chars we get
# just the first char:

aList = "ا" : "ج"
? aList
#o--> "ا"

# Fortunately, Softanza solves this by the L() small function:

? L( ' "ا" : "ج" ')
#o--> [ "ا", "ب", "ة", "ت", "ث", "ج" ]

# You won't need it but it manages ASCIIs as well:

? L(' "A" : "D" ')
#--> [ "A", "B", "C", "D" ]

# Interestingly, you can get any list of a numbered string:

? L(' "♥1" : "♥5" ')
#--> [ "♥1", "♥2", "♥3", "♥4", "♥5" ]

# Or maybe:

? L(' "Ring1" : "Ring3" ')
#--> [ "Ring1", "Ring2", "Ring3" ]

# This works also for any unicode string (here in arabic):

? L(' "كلمة1" : "كلمة3" ')
#o--> [ "كلمة3", "كلمة2", "كلمة1" ]

# On the other hand, as you kow, the _:_ syntax in Ring
# works also for numbers, like this:

? 1:5
#--> [ 1, 5 ]

# But it suports only integers and not real numbers (with decimals):

? 1.02 : 3.08
#--> [ 1, 2, 3 ]

# While in Softanza, using the magic of L() function, you can enumarate
# all the real numbers inbetween, what ever decimal part they have:

? L(' 1.02 : 1.05 ')
#--> [ 1.02, 1.03, 1.04, 1.05 ]
 
# Finally, if the string you feed to L() function contains a list written
# in Ring form, than the function will evaluate it and return it:

? L('[ 1, 2, 3 ]')
#--> [ 1, 2, 3 ]

pf()
# Executed in 0.24 second(s) in Ring 1.20
# Executed in 0.60 second(s) in Ring 1.17
