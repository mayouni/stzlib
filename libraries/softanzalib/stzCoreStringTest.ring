load "stzCoreString.ring"
load "stzProfSys.ring"

/*---

pron()

o1 = new stzCoreString("Hello in ")

o1.Append("Softanza ")
? o1.Content()
#--> Hello in Softanza 

o1 + "Core!"
? o1.Content()
#--> Hello in Softanza Core!

proff()

/*---

pron()

o1 = new stzCoreString("مرحبا بكم في رينغ")

? o1.Size()
#--> 17

? o1.At(1) + NL
#o--> م

#---

str = ""
for i = 14 to 17
	str += o1.At(i)
next
? str + NL
#o--> رينغ

proff()
# Executed in almost 0 second(s).

/*===
*/
pron()

o1 = new stzCoreString("one and one makes two ones")
? o1.Find("one")
#--> [ 1, 9, 23 ]

? o1.FindFirst("one")
#--> 1

? o1.FindLast("one")
#--> 23

proff()
# Executed in almost 0 second(s).

/*--

pron()

o1 = new stzCoreString("one and ONE makes two Ones")
? o1.Find("one")
#--> [ 1 ]

? o1.FindCS("one", FALSE)
#--> [ 1, 9, 23 ]

proff()
# Executed in almost 0 second(s).

/*---

pron()

o1 = new stzCoreString("Ring language")
o1.InsertAt(6, "programming ")
? o1.Content()
#--> Ring programming language

proff()
# Executed in almost 0 second(s).

/*---

pron()

o1 = new stzCoreString("بسم الله الرّحمان الرّحيم")

? o1.IsRightToLeft()
#--> TRUE

? o1.StartsWith("بسم")
#--> TRUE

? o1.EndsWith("الرّحيم") + NL
#--> TRUE

#--

o1 = new stzCoreString("mMm...MMm")
? o1.StartsWithCS("mmm", false)
#--> TRUE

? o1.EndsWithCS("mmm", false)
#--> TRUE

proff()
# Executed in almost 0 second(s).

/*---

pron()

o1 = new stzCoreString("one      two three   four  five")
o1.Simplify()
? o1.Content()
#--> one two three four five

proff()

/*---

pron()

o1 = new stzCoreString("one and one make two ones")
? o1.FindNth(2, "one")
#--> 9

o1.Replace("one", "three")
? o1.Content()
#--> three and three make two threes

proff()
# Executed in almost 0 second(s).

/*--

pron()

o1 = new stzCoreString("one and ONE makes two Ones")
o1.ReplaceCS("one", "three", FALSE)
? o1.Content()
#--> three and three makes two threes

proff()
# Executed in almost 0 second(s).

/*===

pron()

o1 = new stzCoreString("ring/ruby/php/python")
? o1.split("/")
#--> [ "ring", "ruby", "php", "python" ]

proff()
# Executed in almost 0 second(s).

/*===

pron()

o1 = new stzCoreString("ringMMMrubyMmmphpMmMpython")
? o1.SplitCS("mmm", false)
#--> [ "ring", "ruby", "php", "python" ]

proff()
# Executed in almost 0 second(s).

/*----
*/
pron()

o1 = new stzCoreString("<<<Ring>>>")
? o1.Qt().left(3)
#--> "<<<"

? o1.Qt().right(3)
#--> ">>>"

? o1.Section(4, 7)
#--> "Ring"

? o1.Contains("Ring")
#--> TRUE

? o1.ContainsCS("RING", false)
#--> TRUE

proff()
