# Narrative
# --------
# TRUTH IN SOFTANZA
#
# Extracted from stzObjectTest.ring, block #4.

load "../../stzBase.ring"


pr()

# By default Sotanza IsTrue/IsFalse functions keep the
# same standard behavior of Ring

? IsTrue("") #--> FALSE

? IsTrue([]) #--> FALSE

? IsTrue(["Hello"]) #--> TRUE

# Softanza alos offer a configurable eXTended forms
# which depend on the settings made at global level
? ""

? IsTrueXT([]) #--> FALSE

# Returned FALSE because we have:
? EmptyListIsConsideredFalse() #--> TRUE

# Change the confi and try again:
SetEmptyListIsConsideredFalse(:No)
? IsTrueXT([]) #--> False

# An other advance feature is to define substrings that
# can automatically "falsilfy" their container string
? ""

# To do so, let's check their list in this gloabal variable:

? @@( SubStringsMakingAStringFalse() )
#--> []

# Let set some of them:

SetSubStringsMakingAStringFalse([ "false", "wrong", "dangerours" ])

? IsTrueXT("this is dangerous and should be false")
#--> FALSE

# while of course in normal Ring-like logic it's TRUE
? IsTrue("this is dangerous and should be false")
#--> TRUE

# Same think is configurable for lists, both for items and inneritems
? ""
SetItemsMakingAListFalse = [ "false", "wrong", "dangerous" ]
? IsTrueXT([ "hello", "this", "is", "wrong" ])
#--> FALSE

? IsTrue([ "hello", "this", "is", "wrong" ])
#--> TRUE

SetInnerItemsMakingAListFalse([ "X" ])
? @@( InnerItemsMakingAListFalse() )
#--> [ "X" ]

? IsTrueXT([ 1, 2, [ 3, "X", 4 ], 5 ])
#--> TRUE

# becuase in fact
? DeepContains([ 1, 2, [ 3, "X", 4 ], 5 ], "X")

pf()
# Executed in 0.01 second(s) in Ring 1.24
