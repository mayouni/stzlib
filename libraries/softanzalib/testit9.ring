load "stzlib.ring"

# Extending a list of numbers to a given position

o1 = new stzList([ 1, 2, 3 ])
o1.ExtendTo(5)
? @@( o1.Content() )
#--> [ 1, 2, 3, 0, 0 ]

# Extending a list of strings to a given position

o1 = new stzList([ "A", "B", "C" ])
o1.ExtendTo(5)
? @@( o1.Content() )
#--> [ "A", "B", "C", "", "" ]


# Extending a list by a given item

o1 = new stzList([ "A", "B", "C" ])
o1.ExtendToXT(5, :With = "♥")
? @@( o1.Content() )
#--> [ "A", "B", "C", "♥", "♥" ]

# Extending a list by its own items

o1 = new stzList([ "A", "B", "C" ])
o1.ExtendToXT(5, :With@ = "@items" )
? @@( o1.Content() )
#--> [ "A", "B", "C", "A", "B" ]

# Extending a list by the items of an other list
o1 = new stzList([ "A", "B", "C" ])
o1.ExtendToXT(8, :With@ = [1, 2, 3] )
? @@( o1.Content() )
#--> [ "A", "B", "C", 1, 2, 3, 0, 0 ]
