# Narrative
# --------

#
# Extracted from stzlisttest.ring, block #527.

load "../../stzBase.ring"

pr()

# You can replace the nth item of a list
# by a given value by writing:

o1 = new stzList([ "A", "b", "C" ])
o1.ReplaceAt(2, "B")
? o1.Content()
#--> [ "A", "B", "C" ]

# Or you can be a bit more expressive by using :With

o1 = new stzList([ "A", "b", "C" ])
o1.ReplaceAt(2, :With = "B")
? o1.Content()
#--> [ "A", "B", "C" ]

pf()
# Executed in almost 0 second(s).
