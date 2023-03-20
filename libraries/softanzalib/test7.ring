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

pron()

o1 = new stzString("bla bla /.../ and bla!")
o1.ReplaceAnyBetween("/", "/", "bla")

? o1.Content()

proff()

/*================ Find and AntiFind

pron()

o1 = new stzString("ring...")
? @@S( o1.FindAsSection("ring") )
#--> [1, 4]

? @@S( o1.AntiFindAsSection("ring") )
#--> [5, 7]

proff()
#--> Executed in 0.07 second(s)

/*----------------

pron()
#                   1  4  78
o1 = new stzString("...ring...")

? o1.FindFirst("ring")
#--> 4

? @@S( o1.FindAsSection("ring") )
#--> [ 4, 7 ]

? @@S( o1.AntiFind("ring") )
#--> [1, 8]

? @@S( o1.AntiFindAsSections("ring") )
#--> [ [ 1, 3 ], [ 8, 10 ] ]

proff()
# Executed in 0.12 second(s)

/*----------------

pron()

o1 = new stzString("...456...012...")

? o1.Sections([ [4, 6], [10, 12] ])
#--> [ "456", "012" ]

? o1.AntiSections([ [4, 6], [10, 12] ])
#--> [ "...", "...", "..." ]

? @@S( o1.FindAsSections([ "456", "012" ]) )
#--> [ [ 4, 6 ], [ 10, 12 ] ]

? @@S( o1.AntiFindAsSections([ "456", "012" ]) )
#--> [ [ 1, 3 ], [ 7, 9 ], [ 13, 15 ] ]

proff()

/*----------------
*/

pron()
#                   ...4...8...2...6...2...   
o1 = new stzString("...&^^^&...&vvv&...&...")

? o1.BoundedBy("&")
#--> [ "^^^", "vvv" ]

//? o1.BoundedByD("&", :Going = :Backward)
#--> [ "...", "..." ]

? o1.BoundedByIB("&")
#--> [ "&^^^&", "&vvv&" ]

proff()

/*----------------
*/
pron()

o1 = new stzString('this code : txt1 = "<    leave spaces    >" and this code: txt2 = "< leave spaces >"')

? @@S( o1.SubStringsBetween('"', '"') )

? @@S( o1.AntiFindAsSections([ '"<    leave spaces    >"', '"< leave spaces >"' ]) )
#--> [ [ 1, 19 ], [ 44, 66 ] ]

proff()

/*----------------

*/
pron()
#      1...*....0....*....2....*....3....*....4....*....5....*....6....*....7....*....8....
? @@S('this code : txt1 = "<    leave spaces    >" and this code: txt2 = "< leave spaces >"')


proff()

/*----------------

*/
pron()

o1 = new stzString("bla bla /.../ and bla!")
o1.ReplaceAnyBetweenXT("/", "/", "bla")

? o1.Content()

proff()

/*----------------

pron()

o1 = new stzString("bla bla /.../ and bla!")
o1.ReplaceXT( [], :BoundedBy = '/', :With = "bla" )
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
