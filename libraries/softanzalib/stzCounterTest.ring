load "stzlib.ring"

/*--------------------------
*/
o1 = new stzCounter([
	:StartAt = 1,
	:AfterYouSkip = 9,
	:RestartAt = 0,
	:Step = 1
])

? o1.CountingTo(13)

/*--------------------------
*/
? StzCounterQ([ :Startat = 1, :AfterYouSkip = 10, :RestartAt = 1, :Step = 1 ]).CountingTo(16)
