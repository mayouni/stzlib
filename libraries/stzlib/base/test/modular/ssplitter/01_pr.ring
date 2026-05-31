# Narrative
# --------
# pr()
#
# Extracted from stzSsplittertest.ring, block #1.

load "../../../stzBase.ring"


? Q(1:5).IsEqualTo(5:1)
#--> TRUE

? Q(1:5).IsIdenticalTo(5:1)
#--> FALSE

? Q("A":"E").IsSortedInAscending()
#--> TRUE

? Q("E":"A").IsSortedInDescending()
#--> TRUE

? Q("A":"E").IsContiguous()
#--> TRUE

? Q("E":"A").IsCOntiguous()
#--> TRUE

pf()
# Executed in 0.11 second(s) in Ring 1.22
# Executed in 0.24 second(s) in Ring 1.19
