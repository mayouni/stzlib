# Narrative
# --------
# #narration NAMED OBJECTS EQuALiTY
#
# Extracted from stzlisttest.ring, block #605.

load "../../../stzBase.ring"


# Softanza can check objects equality only if objects are
# created as named objects (a special form of a Softanza
# object that you cread along with its name)

pr()

obj1 = new stzString(:first  = "Ring")
obj2 = new stzString(:second = "Python")
obj3 = new stzString(:first  = "basic")

? AreNamedObjects([ obj1, obj2, obj3 ])
#--> TRUE

? ObjectsNames([ obj1, obj2, obj3 ])
#--> [ :first, :second, :first ]

? AreEqual([ obj1, obj2 ]) # Or AreEqualObjects()
#--> FALSE

? AreEqual([ obj1, obj3 ])
#--> TRUE

pf()
# Executed in 0.08 second(s) in Ring 1.22
