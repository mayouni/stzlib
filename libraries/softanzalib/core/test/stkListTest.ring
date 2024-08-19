#----------------------------#
#  LOADING THE CORE LIBRARY  #
#----------------------------#

# You either load the hole SoftanzaCore library (all classes)

//	load "../stklib.ring" # or /SoftanzaCoreLib.ring to be expressive

# Or just the files you actually need

	load "../common/stkWrapRingFuncs.ring"	# Wrappers of Ring functions for scope protection

	load "../object/stkObject.ring"
	load "../list/stkList.ring"
	load "../error/stkError.ring"

#----------------#
#  TEST SAMPLES  #
#----------------#

/*--- Error (minimal) management in SoftanzaCore

# Errors are kept minimal, as anything else in SoftanzaCore library.
# Here a short code is returned telling you an error of type 1 is raised:

/o1 = new stkList("salu")
#--> ERR-1

# Innternally, things are even more elementary!

# if you look inside its code (/../core/list/stklist.ring), in
# the top of of init() method, you see that stzCoreList class
# uses the StkError() function like this:

? StkError(:IncorrectParamType)
#--> 1

# which returns the number 1.

# Information about all codes can be found in /../core/error/stkError.ring file.

/*---

o1 = new stkList(1:3)
? o1.Content()
#--> [ 1, 2, 3 ]

? o1.Size()
#--> 3

/*---

o1 = new stkList(1:3)
o1 + 4
? o1.Content()
#--> [ 1, 2, 3, 4 ]

o1.Append(5)
? o1.Content()
#--> [ 1, 2, 3, 4, 5 ]

/*---

o1 = new stkList("A":"E")

? o1.Size()
#--> 5

? o1.At(1) # Or ItemAt()
#--> A

? o1[3]
#--> C

/*===

o1 = new stkList([ "one", "and", "one", "makes", "two", "ones" ])

? o1.Find("one")
#--> 1

? o1.FindFirst("one")
#--> 1

? o1.FindLast("one")
#--> 3

/*---

o1 = new stkList([ "Ring", "language" ])

o1.InsertAt(2, "programming ")
? o1.Content()
#--> [ "Ring", "programming", "language" ]

/*---

o1 = new stkList([ "بسم", "الله", "الرّحمان", "الرّحيم" ])

? o1.StartsWith("بسم")
#--> TRUE

? o1.EndsWith("الرّحيم") + NL
#--> TRUE

/*---

o1 = new stkList([ "one", "and", "one", "make", "two", "one", "s" ])

? o1.FindNth(2, "one") + NL
#--> 3

o1.Replace("one", "three")
? o1.Content()
#--> [ "three", "and", "three", "make", "two", "three", "s" ]

/*----

o1 = new stkList([ "one", "any", "any", "two", "any", "three", "more" ])
o1.Remove("any")
? o1.content()
#--> [ "one", "two", "three", "more" ]

o1.RemoveAt( o1.Size() )
? o1.Content()
#--> #--> [ "one", "two", "three", "more" ]

/*===

o1 = new stkList([ "A", "B", "3", "4", "5", "C" ])

? o1.Section(3, 5)
#--> [ "3", "4", "5" ]

o1.RemoveSection(3, 5)
? o1.Content()
#--> [ "A", "B", "C" ]

/*----
*/

o1 = new stkList([ "A", "B", "3", "4", "5", "F" ])
o1.ReplaceSection(3, 5, "*")
? o1.Content()
#--> [ "A", "B", "*", "*", "*", "F" ]
