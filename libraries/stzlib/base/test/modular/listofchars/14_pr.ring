# Narrative
# --------
# pr()
#
# Extracted from stzlistofcharstest.ring, block #14.

load "../../../stzBase.ring"


? Q("[1, 2, 3 ]").ToList() # Or L("[1, 2, 3 ]")
#--> [ 1, 2, 3 ]

? Q("1:3").ToList() # Or ? L("1:3")
#--> [ 1, 2, 3 ]

? Q('"A":"C"').ToList() # Or L('"A":"C"')
#--> [ "A", "B", "C"]

? Q(" 'A' : 'C' ").ToList() # Or ? L(" 'A' : 'C' ")

? Q("#1 : #3").ToList() # Or L("#1 : #3")
#--> [ "#1", "#2", "#3" ]

? Q("#21 : #23").ToList() # Or L("#21 : #23")
#--> [ #21, #22, #23 ]

? Q("day1 : day3").ToList() # Or L("day1 : day3")
#--> [ "day1", "day2", "day3" ]

? @@( Q('softanza').ToList() ) # Or @@( L('softanza') )
#--> [ "softanza" ]

pf()
# Executed in 0.22 second(s).
