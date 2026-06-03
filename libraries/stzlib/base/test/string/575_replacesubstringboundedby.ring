# Narrative
# --------
# ReplaceSubStringBoundedBy
#
# Extracted from stzStringTest.ring, block #575.

load "../../stzBase.ring"


pr()

o1 = new stzString("bla bla --word-- bla bla --nword- bla --word--")

o1.ReplaceSubStringBoundedBy("word", "--", :With = "WORD")
? o1.Content() + NL
#--> bla bla --WORD-- bla bla --nword- bla --WORD--

# or, more naturally, you can say:

o1 = new stzString("bla bla --word-- bla bla --nword- bla --word--")
o1.ReplaceXT("word", :BoundedBy = "--", :With = "word")
? o1.Content()
#--> bla bla --WORD-- bla bla --nword- bla --WORD--

pf()
# Executed in 0.07 second(s) in Ring 1.20
# Executed in 0.15 second(s) in Ring 1.19
