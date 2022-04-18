load "stzlib.ring"

o1 = new stzPair([ "Me", "You" ])
? o1.Content() #--> [ "Me", "You" ]

o1.Swap()
? o1.Content() #--> [ "You", "Me" ]
