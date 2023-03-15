load "stzlib.ring"

/*--------------

pron()

Q("♥♥♥ Ring programing language ♥♥♥") {

	ReplaceXT( :Each = "♥", [], :With = "*")
	? Content()
	#--> *** Ring programing language ***

	ReplaceXT("*", :With = "♥", [])
	? Content()
	#--> ♥♥♥ Ring programing language ♥♥♥
}

proff()
# Executed in 0.05 second(s)

/*--------------

pron()

o1 = new stzString("_/♥\__/♥\__/♥♥__/♥\_")
o1.ReplaceXT(:Nth = 4, "♥", :With = "\")
? o1.Content()
#--> _/♥\__/♥\__/♥\__/♥\_

proff()
#--> Executed in 0.03 second(s)

/*--------------

pron()

o1 = new stzString("_♥♥\__/♥\__/♥\_")
o1.ReplaceXT(:First, "♥", :With = "/")
? o1.Content()
#--> _/♥\__/♥\__/♥\__/♥\_

proff()
#--> Executed in 0.03 second(s)

/*--------------

pron()

o1 = new stzString("_/♥\__/♥\__/♥♥_")
o1.ReplaceXT(:Last, "♥", :With = "\")
? o1.Content()
#--> _/♥\__/♥\__/♥\__/♥\_

proff()
#--> Executed in 0.03 second(s)

/*--------------

pron()

o1 = new stzString("~♥/♥\~~")
o1.ReplaceXT("♥", :At = 2, :With = "~") # Or :AtPosition
? o1.Content()
#--> ~~/♥\~~

proff()
#-- Executed in 0.04 second(s)

/*--------------

pron()

o1 = new stzString("~♥/♥\~♥")
o1.ReplaceXT("♥", :AtPositions = [2, 7], :With = "~") # Or :AtPositions
? o1.Content()
#--> ~~/♥\~~

proff()
#-- Executed in 0.06 second(s)

/*----------------

pron()

o1 = new stzString("bla bla <<♥♥♥>> and bla!")
o1.ReplaceXT( [], :Between = ["<<",">>"], :With = "bla" )
#--> bla bla <<♥♥♥>> and bla!

? o1.Content()

proff()
#--> Executed in 0.07 second(s)

/*----------------
*/
pron()

o1 = new stzString("bla bla /***/ and bla!")
? o1.FindAnyBetween("/", "/")

o1.ReplaceAnyBetween("/", "/", "bla")

/*----------------
*/
pron()

o1 = new stzString("bla bla /***/ and bla!")
//o1.ReplaceXT( [], :BoundedBy = '/', :With = "bla" )
#--> 

? o1.Content()

proff()
#--> Executed in 0.07 second(s)

/*============

# Suppose you have this string:
o1 = new stzString("*** Ring programin* language ***")

# As you see, the substring "programmin*" contains a
# misspelled char at the end (the "*").

# Let's try to fix it.

# You make think that replacing the "*" by "g" solves it:
o1.Replace("*", :With = "g")
? o1.Content()
#--> ggg Ring programing language ggg

# but it doesn't! All the other "*"s are also replaced!

# To this particular situation, Softanza has an anwser:
# the ReplaceIn() function:

o1 = new stzString("*** Ring programin* language ***")

? o1.ReplaceXT("*", :In = "programmin*", :With = "g")
? o1.Content()
