# Narrative
# --------
# IsNeither(a, :Nor = b): TRUE when the value equals NEITHER argument.
#
# A readable two-way "not equal to either" guard, with the :Nor named
# param spelling the second alternative so the call reads like English.
# It is a Softanza "same semantics across types" method: it works the
# same way on a list (Q(1:3)), a string (Q("Ring")) and a number (Q(5)),
# comparing by content. The last two lines probe Softanza type tokens
# (:ANumber, :List, :Object) rather than concrete values.
#
# Extracted from stzlisttest.ring, block #62.

load "../../stzBase.ring"

pr()

? Q(1:3).IsNeither(5:8, :Nor = 10:12)
#--> TRUE

? Q(1:3).IsNeither(2:4, :Nor = 1:3)
#--> FALSE

#--

? Q("Ring").IsNeither("Python", :Nor = "Ruby")
#--> TRUE

? Q("Ring").IsNeither("Python", :Nor = "Ring")
#--> FALSE

#--

? Q(5).IsNeither( 5 + 2, :Nor = 5 - 2 )
#--> TRUE

? Q(5).IsNeither( 5, :Nor = 15 )
#--> FALSE

#--

? Q("str").IsNeither( :ANumber, :Nor = :List )
#--> TRUE

? Q(12).IsNeither( :List, :Nor = :Object )
#--> FALSE

pf()
# Executed in 0.12 second(s)
