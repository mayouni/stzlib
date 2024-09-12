
#----------------------------#
#  LOADING THE CORE LIBRARY  #
#----------------------------#

# You either load the hole SoftanzaCore library (all classes)

//	load "../stklib.ring" # or /SoftanzaCoreLib.ring to be expressive

# Or just the files you actually need

	load "../object/stkObject.ring"
	load "../string/stkString.ring"
	load "../error/stkError.ring"

#----------------#
#  TEST SAMPLES  #
#----------------#

/*---
*/

o1 = new stzCoreString("Hello in ") # stkString() with <<k>> meaning Kore ;)

o1.Append("Softanza ")
? o1.Content()
#--> Hello in Softanza 

o1 + "Core!"
? o1.Content()
#--> Hello in Softanza Core!

/*---

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

/*===

o1 = new stkString("one and one makes two ones")

? o1.Find("one")
#--> [ 1, 9, 23 ]

? o1.FindFirst("one")
#--> 1

? o1.FindLast("one")
#--> 23

/*--

o1 = new stkString("one and ONE makes two Ones")

? o1.Find("one")
#--> [ 1 ]

? o1.FindCS("one", FALSE)
#--> [ 1, 9, 23 ]

/*---

o1 = new stkString("Ring language")

o1.InsertAt(6, "programming ")
? o1.Content()
#--> Ring programming language

/*---

o1 = new stkString("بسم الله الرّحمان الرّحيم")

? o1.IsRightToLeft()
#--> TRUE

? o1.StartsWith("بسم")
#--> TRUE

? o1.EndsWith("الرّحيم") + NL
#--> TRUE

#--

o1 = new stkString("mMm...MMm")

? o1.StartsWithCS("mmm", false)
#--> TRUE

? o1.EndsWithCS("mmm", false)
#--> TRUE

/*---

o1 = new stkString("one      two three   four  five")

o1.Simplify()
? o1.Content()
#--> one two three four five

/*---

o1 = new stkString("one and one make two ones")

? o1.FindNth(2, "one")
#--> 9

o1.Replace("one", "three")
? o1.Content()
#--> three and three make two threes

/*--

o1 = new stkString("one and ONE makes two Ones")

o1.ReplaceCS("one", "three", FALSE)
? o1.Content()
#--> three and three makes two threes

/*---

o1 = new stkString("oneany anytwo three")
o1.Remove("any")
? o1.Content()
# one two three

/*---

o1 = new stkString("one any two ANY any three")
o1 {
	removeCS("any", false)
	Simplify()
	? o1.Content()
}
#--> one two three

/*===

o1 = new stkString("AB345C")

? o1.Section(3, 5)
#--> 345

o1.RemoveSection(3, 5)
? o1.Content()
#--> ABC

/*----

o1 = new stkString("AB345F")
o1.ReplaceSection(3, 5, "CDE")
? o1.Content()
#--> ABCDEF

/*===

o1 = new stkString("ring/ruby/php/python")

? o1.split("/")
#--> [ "ring", "ruby", "php", "python" ]

/*---

o1 = new stkString("ringMMMrubyMmmphpMmMpython")

? o1.SplitCS("mmm", false)
#--> [ "ring", "ruby", "php", "python" ]

/*===

o1 = new stkString("<<<Ring>>>")

# All what ringQt provides is accessible in stzCoreString using
# the small Qt() small function

? o1.Qt().left(3)
#--> "<<<"

? o1.Qt().right(3)
#--> ">>>"

# In these two cases above (left() and right() functions), there is
# no need to wrapp them in stzCoreString because they natively
# offer the same semantics and east of use of Softanza.
# ~> Minimalism design principle of SoftanzaCore.

# In the contrary, getting a section is tedious in Qt:

? o1.Qt().mid(3, 4)
#--> ring

# It also obeys to a 0-based indexing and a totally different
# design of the params (3 is the start position, which is actually 2,
# and 4 are the range of chars to take).

# That's why in this case, stzStringCore provides:

? o1.Section(4, 7)
#--> "Ring"

# Same for Contains(), which makes not difference in Qt between
# case-sensitive and non case-sensitive variants, like it is the
# case in Softanza with the CS() prefix:

? o1.Contains("Ring")
#--> TRUE

? o1.ContainsCS("RING", false)
#--> TRUE

/*---

# Some basic functions are not part of RingQt QString class,
# but stzCoreString offers them, like:

o1 = new stkString("ring")

? o1.Chars()
#--> [ "r", "i", "n", "g" ]

/*---

# Some Qt QString constructs go against the programming experience
# we want to offer in Sofantza.

# For example, if you want to get the unicode of the char "R",
# using QString, you must write:

o1 = new stkString("R")
? o1.Qt().unicode().unicode()
#--> 82

# That's why we offer a more natural option in stzCoreString:

? o1.Unicode() + NL
#--> 82

# SoftanzaCore will also help you getting the unicodes of all
# the chars of a string:

o1 = new stkString("Ring")
? o1.Unicodes()
#--> [ 82, 105, 110, 103 ]

# which is, of course, unailable in Qt String.

/*===

# stzCoreString has a useful bridge to stzCoreChar, so you can
# start from a string (based on Qt QString class), then continue
# your exploration with a stzCoreChar (based on Qt QChar class):


o1 = new stzCoreString("輪")
? o1.Unicode()
#--> 36650

? classname( o1.ToQChar(1) )
#--> qchar

# If you must how Qt QChar works, then you can directly use it.
# Otherwise, if you prefer a Softanza experience, use the
# stzCoreChar class, like this:

load "../string/stkChar.ring" # Load it only when you need it!

o2 = new stkChar( o1.Content() )
? o2.Content()
#--> 輪

# Discover other features of stzCoreChar in "../core/test/stkChar.ring"
