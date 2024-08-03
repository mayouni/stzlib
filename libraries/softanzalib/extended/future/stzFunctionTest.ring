load "stzlib.ring"


f = new stzFunction {
	cName	= "Saluate"
	aParam	= [:pcToSomeone]
	cBody	= tab + '? "Hello " + pcToSomeone'
	
	Startup()
	ApplyFor([ "Haneen" ]) + NL
	ApplyForMany([ "Haneen" , "Teeba", "Cherihen", "Mansour" ])

	//AddParameter( pParam )

	// CheckParamValidityFrom( pTemplate )		
}

