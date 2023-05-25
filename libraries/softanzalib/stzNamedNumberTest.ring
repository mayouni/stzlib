load "stzlib.ring"


new stzNamedNumber(:o1 = "12.453")
? @[:o1].Content()
#--> "12.453"

? @[:o1].StzType()
#--> stznumber

new stzNamedNumber(:o2 = -120.234)
? @[:o2].Content()
#--> "-120.23"
# NOTE that the number has been rounded to the default round in ring (2).
# If you want to preserve the round you want, like in the "12.453" above,
# then provide the number in a string.

new stzNamedNumber(:o1 = 10)
? @[:o1].Content()
#--> Error message:
# The name you provided (:o1) is already used by an other object!

