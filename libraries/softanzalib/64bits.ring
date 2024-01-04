load "stzlib.ring"

pron()

StzListOfListsQ([ 1 : 5_000_000, 5_000_001 : 10_000_000 ]).Merged()
# Executed in 15.69 second(s)

Merge([ 1 : 5_000_000, 5_000_001 : 10_000_000 ])
# Executed in 5.87 second(s)

proff()

/*--------

pron()

o1 = new stzString("12345678")

? o1.Section(3, 5)
#--> 345

? o1.Section(5, 3)
#--> 345

proff()
# Executed in 0.04 second(s)

/*--------

pron()

o1 = new stzList(1:8)

? o1.Section(3, 5)
#--> [ 3, 4, 5 ]

? o1.Section(5, 3)
#--> [ 3, 4, 5 ]

proff()
# Executed in 0.04 second(s)

/*--------

pron()

o1 = new stzList([ 120, "abc", 1:3 ])
? o1.QStringified()
#--> 	pobject: [This Attribute Contains A List]
#	pobject: [This Attribute Contains A List]
#	pobject: [This Attribute Contains A List]

proff()
