load "stzlib.ring"


o1 = new stzCounter([
	:StartAt = 1,
	:AfterYouSkip = 9,	# or :WhenYouReach = 10
	:RestartAt = 0,
	:Step = 1
])

? @@S( o1.Counting( :To = 13 ) ) + NL
#--> [ 1, 2, 3, 4, 5, 6, 7, 8, 9, 0, 1, 2, 3 ]

? o1.CountingXT( :To = 13, :AndReturning = :Last)
#--> 3

? o1.CountXT( :To = 13, :AndReturnNth = 12)
#--> 2
