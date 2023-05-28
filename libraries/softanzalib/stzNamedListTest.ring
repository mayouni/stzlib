load "stzlib.ring"


new stzNamedList(:o1 = ["A", "B", "C"])
? @[:o1].Content()
#--> 

? @[:o1].StzType()
#--> :stzList

new stzNamedList(:o1 = 10)
? @[:o1].Content()
#--> Error message:
# The name you provided (:o1) is already used by an other object!

