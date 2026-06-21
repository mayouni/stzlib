# Narrative
# --------
# Demonstrates the L() small function: a string-fed range builder that
# generalises Ring's native ":" range operator.
#
# Ring's "A" : "D" elegantly yields [ "A", "B", "C", "D" ], but it only
# walks ASCII (an Arabic "ا" : "ج" collapses to just the first char) and
# its numeric form is integer-only ( 1.02 : 3.08 gives [ 1, 2, 3 ] ).
# L() takes the whole range as a quoted string and expands it correctly:
# Unicode letter ranges, ascending Unicode numbered strings, and real
# numbers with arbitrary decimal steps ( 1.02 : 1.05 -> four reals ). If
# the fed string is a Ring list literal, L() simply evaluates and returns
# it. Note L() does NOT expand the numbered-string endpoints into a series:
# "Ring1" : "Ring2" returns just the two endpoints, and Ring's own 1:5
# already expands to the full [ 1, 2, 3, 4, 5 ].
#
# Extracted from stzlisttest.ring, block #385.

load "../../stzBase.ring"


pr()

# As we all know, Ring provides us with this elegant syntax:

aList = "A" : "D"
? @@( aList )
#--> [ "A", "B", "C", "D" ]

# Unfortunaltely, this is limited to ASCII chars.
# And if we use it with other UNICODE chars we get
# just the first char:

aList = "ا" : "ج"
? @@( aList )
#o--> "ا"

# Fortunately, Softanza solves this by the L() small function:

? @@( L( ' "ا" : "ج" ') )
#o--> [ "ا", "ب", "ة", "ت", "ث", "ج" ]

# You won't need it but it manages ASCIIs as well:

? @@( L(' "A" : "D" ') )
#--> [ "A", "B", "C", "D" ]

# Interestingly, you can get an other form of a numbered list of strings:

? @@( L(' "Ring1" : "Ring2" ') )
#--> [ "Ring1", "Ring2" ]

# This works also for any unicode string:

? L(' "كلمة1" : "كلمة3" ')
#--> [ "كلمة1", "كلمة2", "كلمة3" ]

# On the other hand, as you kow, the _:_ syntax in Ring
# works also for numbers, like this:

? 1:5
#--> [ 1, 2, 3, 4, 5 ]

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
# Executed in 0.23 second(s).
