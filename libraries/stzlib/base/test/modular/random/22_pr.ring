# Narrative
# --------
# pr()
#
# Extracted from stzrandomtest.ring, block #22.

load "../../../stzBase.ring"


MyExamNotes = [ 12, 17, 18, 16, 19 ]
Them = MyExamNotes # An alternative name for semantic convenience
Average = 10

? AllOfQQ(MyExamNotes).ArePositive()
#--> TRUE


? AllOfQQ(Them).AreGreaterThen(Average)
#--> TRUE

pf()
# Executed in 0.01 second(s) in Ring 1.23
# Executed in 0.02 second(s) in Ring 1.22
