# Narrative
# --------
# StartProfiler()
#
# Extracted from stzObjectTest.ring, block #14.
#ERR panic: integer does not fit in destination type

load "../../stzBase.ring"

pr()

? Q(-5).ToNumberW('{ @number = Q(@number).Abs() }')
#--> 5

? Q(5).ToNumberW('{ @number = @number + 5 }')
#--> 10

? QRT([ -1, 2, -3, -4, 5 ], :stzListOfNumbers).ToNumberW('{ @number = This.Sum() }')
#--> -1

StopProfiler()
#--> Executed in 0.12 seconds seconds.

pf()
