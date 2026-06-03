# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #62.

load "../../stzBase.ring"


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

pf()
# Executed in 0.12 second(s)
