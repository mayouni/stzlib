load "stzlib.ring"

StartProfiler()

StzTestQ() {

	@Code = "{
		o1 = new stzCCode('{ This[ @i - 3 ] = This[ @i + 3 ] and @i = 10 }')
		? o1.ExecutableSection()
	}"
	
	@Result = [ 4, -3 ]

	CheckXT()
	# Correcly returned: [ 4, -3 ]
}

StopProfiler()
# Executed in 0.14 second(s)
