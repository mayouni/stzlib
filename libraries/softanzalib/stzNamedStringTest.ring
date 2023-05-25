load "stzlib.ring"


new stzNamedString(:o1 = "Ring")
? @[:o1].Content()
#--> "Ring"

? @[:o1].StzType()
#--> :stzString

new stzNamedString(:o2 = "Softanza")
? @[:o2].Content()
#--> "Softanza"

new stzNamedString(:o1 = "Zai")
? @[:o1].Content()
#--> Error message:
# The name you provided (:o1) is already used by an other object!


