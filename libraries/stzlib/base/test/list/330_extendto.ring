# Narrative
# --------
# ExtendTo(n) and ExtendToXT(n, :With = v): grow a list to a target length.
#
# ExtendTo pads up to position n with a TYPE-AWARE default: 0 for an
# all-number list, "" for anything else. When you want a specific filler,
# ExtendToXT takes :With = value. All three forms mutate in place and only
# grow (never truncate).
#
# Extracted from stzlisttest.ring, block #330.

load "../../stzBase.ring"

pr()

# Extending a list of numbers to a given position

o1 = new stzList([ 1, 2, 3 ])
o1.ExtendTo(5)
? @@( o1.Content() )
#--> [ 1, 2, 3, 0, 0 ]

# Extending a list of strings to a given position

o1 = new stzList([ "A", "B", "C" ])
o1.ExtendTo(5)
? @@( o1.Content() )
#--> [ "A", "B", "C", "", "" ]

# Extending a list by a given item

o1 = new stzList([ "A", "B", "C" ])
o1.ExtendToXT(5, :With = "♥")
? @@( o1.Content() )
#--> [ "A", "B", "C", "♥", "♥" ]

pf()
# Executed in almost 0 second(s)
