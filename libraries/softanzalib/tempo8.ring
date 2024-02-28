

/*
changeRingKeyword load ＃
＃ "stzlib.ring"

? SoftanzaLogo() + NL

# Unicode codepoint of the char ＃
? "＃ ~> " + Unicode("＃")
#--> ＃ ~> 65283

? QQ("＃").Name()
#--> FULLWIDTH NUMBER SIGN






//load "stzlib.ring"

/*----

pron()

? 3 : 5
#--> [ 3, 5 ]

? "3" : "5"
#--> [ "3", "4", "5" ]

? 10 : 12
#--> [ 10, 11, 12 ]

? "10" : "12"
#--> "10"

? L(' "10":"12" ')
#--> #--> [ "10", "11", "12" ]

proff()

/*----

? @@( Intersection([ "1":"3", "2":"7", L(' "10":"12" ') ]) )

proff()

/*====

pron()

? Q(1:7) - These(3:5) # Or AllThese() or EachIn()
#--> [ 1, 2, 6, 7 ]

? Q(1:7) - These(3:5)
proff()

/*---

pron()

? Intersection([
	[ "A", "A", "X", "B", "C" ],
	[ "B", "A", "C", "B", "A", "X" ],
	[ "C", "X", "Z", "A" ]
])
#--> [ "A", "X", "C" ]

proff()
# Executed in 0.04 second(s)

/*----

pron()

	a1 = [ "A", "A", "B", "C" ]
	a2 = [ "B", "A", "C", "B", "A", "X" ]

	o1 = new stzListOfLists([ a1, a2 ])
	? @@( o1.IndexBy(:Position) )

proff()
