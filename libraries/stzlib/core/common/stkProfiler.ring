

$nTime0 = 0

func pr()
	$nTime0 = clock()

func pf()

	cElapsed = "" + (clock() - $nTime0) / clockspersecond()
	if 0+ cElapsed = 0 
		cElapsed = "almost 0"
	ok

	? NL + "Executed in " + cElapsed + " second(s) in Ring " + ring_version()
	$nTime0 = 0
	STOP()

func STOP()
	raise( NL + 
	    "----------------" + NL +
	    "    STOPPED!    " + NL +
	    "----------------"
	)
