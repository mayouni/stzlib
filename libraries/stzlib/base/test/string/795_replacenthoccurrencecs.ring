# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #795.

load "../../stzBase.ring"

pr()

o1 = new stzString("This text is my text not your text, right?!")

? o1.ReplaceNthOccurrenceCSQ(2, "TEXT", :With = "narration", :Casesensitive = FALSE).Content()
#--> This text is my narration not your text, right?!

o1 = new stzString("هذا نصّ لا يشبه أيّ نصّ ويا له من نصّ يا صديقي")
? o1.FindAll("نصّ")
#--> [5, 21, 35]

? o1.FindFirst("نصّ")
#--> 5
? o1.FindLast("نصّ")
#--> 35

pf()
# Executed in 0.01 second(s).
