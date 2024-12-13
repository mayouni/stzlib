load "../max/stzmax.ring"

profon()

o1 = new stzPair([ "Me", "You" ])
? o1.Content() #--> [ "Me", "You" ]

o1.Swap()
? o1.Content() #--> [ "You", "Me" ]

proff()
# Executed in 0.01 second(s) in Ring 1.21
