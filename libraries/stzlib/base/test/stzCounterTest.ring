load "../stzbase.ring"

/*----

pr()

o1 = new stzCounter([
	:StartAt = 1,
	:AfterYouSkip = 9,	# or :WhenYouReach = 10
	:RestartAt = 0,
	:Step = 1
])

? @@( o1.Counting( :To = 13 ) ) + NL
#--> [ 1, 2, 3, 4, 5, 6, 7, 8, 9, 0, 1, 2, 3 ]

? o1.CountingXT( :To = 13, :AndReturning = :Last)
#--> 3

? o1.CountXT( :To = 13, :AndReturnNth = 12)
#--> 2

pf()
# Executed in 0.01 second(s) in Ring 1.23
# Executed in 0.03 second(s) in Ring 1.21

/*-----

pr()

o1 = new stzCounter([
	:StartAt = 1,
	:WhenYouReach = 5,
	:RestartAt = 1
])

? @@( o1.CountTo(9) )
#--> [ 1, 2, 3, 4, 1, 2, 3, 4, 1 ]

? o1.CountToXT(9, :ReturnNth = 7)
#--> 3

pf()
# Executed in 0.01 second(s) in Ring 1.23
# Executed in 0.05 second(s) in Ring 1.21

/*-----
*/
pr()

o1 = new stzCounter([
	:StartAt = 1,
	:WhenYouReach = 5,
	:RestartAt = 2
])

? @@( o1.CountTo(9) )
#--> [ 1, 2, 3, 4, 2, 3, 4, 2, 3 ]

? o1.CountToXT(9, :ReturnNth = 7)
#--> 4

pf()
# Executed in 0.01 second(s) in Rinhg 1.23
# Executed in 0.04 second(s) in Rinhg 1.21
