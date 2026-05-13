
#----------------------------#
#  LOADING THE CORE LIBRARY  #
#----------------------------#

# You either load the hole SoftanzaCore library (all classes)

	load "../stklib.ring" # or /SoftanzaCoreLib.ring to be expressive

# Or just the files you actually need

/*
	load "lightguiLib.ring"

	load "../object/stkobject.ring"
	load "../string/stkchar.ring"

	load "../error/stkerror.ring"
	load "../common/stkprofiler.ring"
	load "../common/stkringfuncs.ring"
*/

#----------------#
#  TEST SAMPLES  #
#----------------#

decimals(3)
t0 = clock()

/*-----

pr()

o1 = new stzCoreString("Hello in ") # stkString() with <<k>> meaning Kore ;)

o1.Append("Softanza ")
? o1.Content()
#--> Hello in Softanza 

o1 + "Core!"
? o1.Content()
#--> Hello in Softanza Core!

pf()
# Executed in 0.001 second(s) in Ring 1.22

/*---

pr()

o1 = new stkString("مرحبا بكم في رينغ")

? o1.Size()
#--> 17

? o1.At(1) + NL
#o--> م

str = ""
for i = 14 to 17
	str += o1.At(i)
next
? str + NL
#o--> رينغ

pf()
# Executed in 0.001 second(s) in Ring 1.22

/*===

pr()

cStr = " line1 line1 line1 
line2 line2 line2
line3 line3 line3"

? stksplit(cStr, NL)
#--> [
#	" line1 line1 line1",
#	"line2 line2 line2",
#	"line3 line3 line3"
# ]

pf()
# Executed in 0.001 second(s) in Ring 1.22

/*===

pr()

o1 = new stkString("one and one makes two ones")

? o1.Find("one")
#--> [ 1, 9, 23 ]

? o1.FindFirst("one")
#--> 1

? o1.FindLast("one")
#--> 23

pf()
# Executed in 0.001 second(s) in Ring 1.22

/*--

pr()

o1 = new stkString("one and ONE makes two Ones")

? o1.Find("one")
#--> [ 1 ]

? o1.FindCS("one", FALSE)
#--> [ 1, 9, 23 ]

pf()
# Executed in 0.001 second(s) in Ring 1.22

/*---

pr()

o1 = new stkString("Ring language")

o1.InsertAt(6, "programming ")
? o1.Content()
#--> Ring programming language

pf()
# Executed in 0.001 second(s) in Ring 1.22

/*---

pr()

o1 = new stkString("بسم الله الرّحمان الرّحيم")

? o1.StartsWith("بسم")
#--> TRUE

? o1.EndsWith("الرّحيم") + NL
#--> TRUE

#--

o1 = new stkString("mMm...MMm")

? o1.StartsWithCS("mmm", FALSE)
#--> TRUE

? o1.EndsWithCS("mmm", FALSE)
#--> TRUE

pf()
# Executed in 0.001 second(s) in Ring 1.22

/*---

pr()

o1 = new stkString("one      two three   four  five")

o1.Simplify()
? o1.Content()
#--> one two three four five

pf()
# Executed in almost 0 second(s) in Ring 1.22

/*---

pr()

o1 = new stkString("one and one make two ones")

? o1.FindNth(2, "one")
#--> 9

o1.Replace("one", "three")
? o1.Content()
#--> three and three make two threes

pf()
# Executed in 0.001 second(s) in Ring 1.22

/*--

pr()

o1 = new stkString("one and ONE makes two Ones")

o1.ReplaceCS("one", "three", FALSE)
? o1.Content()
#--> three and three makes two threes

pf()
# Executed in 0.001 second(s) in Ring 1.22

/*---

pr()

o1 = new stkString("oneany anytwo three")
o1.Remove("any")
? o1.Content()
# one two three

pf()
# Executed in 0.001 second(s) in Ring 1.22

/*---

pr()

o1 = new stkString("one any two ANY any three")
o1 {
	removeCS("any", FALSE)
	Simplify()
	? o1.Content()
}
#--> one two three

pf()
# Executed in 0.001 second(s) in Ring 1.22

/*===

pr()

o1 = new stkString("AB345C")

? o1.Section(3, 5)
#--> 345

o1.RemoveSection(3, 5)
? o1.Content()
#--> ABC

pf()
# Executed in 0.001 second(s) in Ring 1.22

/*----

pr()

o1 = new stkString("AB345F")
o1.ReplaceSection(3, 5, "CDE")
? o1.Content()
#--> ABCDEF

pf()
# Executed in 0.001 second(s) in Ring 1.22


pf()

/*===

pr()

o1 = new stkString("ring/ruby/php/python")

? o1.split("/")
#--> [ "ring", "ruby", "php", "python" ]

pf()
# Executed in 0.001 second(s) in Ring 1.22

/*---

pr()

o1 = new stkString("ringMMMrubyMmmphpMmMpython")

? o1.SplitCS("mmm", FALSE)
#--> [ "ring", "ruby", "php", "python" ]

pf()
# Executed in 0.001 second(s) in Ring 1.22

/*===

pf()

o1 = new stkString("<<<Ring>>>")

? o1.Section(4, 7)
#--> "Ring"

? o1.Contains("Ring")
#--> TRUE

? o1.ContainsCS("RING", FALSE)
#--> TRUE

pf()
# Executed in 0.001 second(s)

/*---

pr()

# Some basic functions are not part of RingQt QString class,
# but stzCoreString offers them, like:

o1 = new stkString("ring")

? o1.Chars()
#--> [ "r", "i", "n", "g" ]

pf()
# Executed in 0.001 second(s) in Ring 1.22

/*---

pr()

# The Engine provides direct unicode access without Qt:

o1 = new stkString("R")
? o1.Unicode()
#--> 82

o1 = new stkString("Ring")
? o1.Unicodes()
#--> [ 82, 105, 110, 103 ]

pf()
# Executed in 0.001 second(s) in Ring 1.22

/*===
*/
pr()

# stzCoreString bridges naturally to stzCoreChar via the Engine:

o1 = new stzCoreString("輪")
? o1.Unicode()
#--> 36650

o2 = new stkChar( o1.Content() )
? o2.Content()
#--> 輪

? o2.Unicode()
#--> 36650

pf()
# Executed in 0.001 second(s)
