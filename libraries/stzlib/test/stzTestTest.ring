load "../stzlib.ring"

/*--------------

pron()

StzTestQ() {

	@Description = "Test 1"
	@Code = '
		? Q("niamey").Uppercased()
	'
	@MustReturn = "NIAMEY"

	CheckXT()

	#--

	@Description = "Test 2"
	@Code = '
		? Q("niamey").SpacifyQ().Uppercased()
	'

	@MustReturn = "N I A M E Y"
	CheckXT()
}

proff()
#--> Executed in 0.20 second(s)

/*--------------
*/

pron()

StzTestQ() {

	@Description = 'Test 1'
	@Code = '
		? Q("niamey").SpacifiedQ().AndThenQ().Uppercased()
	'

	@MustReturn = "N I A M E Y"

	CheckXT()

}

#--> test1 : 
# ~> Succeeded!
# ~~~~~~~~~~~~~
# Correctly returned: "N I A M E Y"

proff()
# Executed in 0.14 second(s)

/*------------ TODO: Retest after managing SubStringsBetween() and cie

StartProfiler()

StzTestQ() {

	@Code = '
		o1 = new stzCCode("{ This[ @i - 3 ] = This[ @i + 3 ] and @i = 10 }")
		? o1.ExecutableSection()
	'
	
	@Result = [ 4, -3 ]

	CheckXT()
	# Correcly returned: [ 4, -3 ]
}

StopProfiler()
# Executed in 0.14 second(s)

/*-----------
